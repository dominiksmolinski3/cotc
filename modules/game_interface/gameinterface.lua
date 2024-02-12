WALK_STEPS_RETRY = 10

gameRootPanel = nil
gameMapPanel = nil
gameRightPanel = nil
gameRightExtraPanel = nil
gameLeftPanel = nil
gameSelectedPanel = nil
panelsList = {}
panelsRadioGroup = nil
gameBottomPanel = nil
showTopMenuButton = nil
logoutButton = nil
mouseGrabberWidget = nil
countWindow = nil
logoutWindow = nil
exitWindow = nil
bottomSplitter = nil
limitedZoom = false
currentViewMode = 0
smartWalkDirs = {}
smartWalkDir = nil
firstStep = false
hookedMenuOptions = {}
lastDirTime = g_clock.millis()
lastManualWalk = 0
quickLootHotkey = "SHIFT+Right"

function init()
    g_ui.importStyle('styles/countwindow')

    connect(g_game, {
        onGameStart = onGameStart,
        onGameEnd = onGameEnd,
        onLoginAdvice = onLoginAdvice
    }, true)

    -- Call load AFTER game window has been created and
    -- resized to a stable state, otherwise the saved
    -- settings can get overridden by false onGeometryChange
    -- events
    if g_app.hasUpdater() then
        connect(g_app, {
            onUpdateFinished = load,
        })
    else
        connect(g_app, {
            onRun = load,
        })
    end

    connect(g_app, {
        onExit = save
    })

    gameRootPanel = g_ui.displayUI('gameinterface')
    gameRootPanel:hide()
    gameRootPanel:lower()
    gameRootPanel.onGeometryChange = updateStretchShrink
    gameRootPanel.onFocusChange = stopSmartWalk

    mouseGrabberWidget = gameRootPanel:getChildById('mouseGrabber')
    mouseGrabberWidget.onMouseRelease = onMouseGrabberRelease

    bottomSplitter = gameRootPanel:getChildById('bottomSplitter')
    gameMapPanel = gameRootPanel:getChildById('gameMapPanel')
    gameRightPanel = gameRootPanel:getChildById('gameRightPanel')
    gameRightExtraPanel = gameRootPanel:getChildById('gameRightExtraPanel')
    gameLeftPanel = gameRootPanel:getChildById('gameLeftPanel')
    gameBottomPanel = gameRootPanel:getChildById('gameBottomPanel')

    panelsList = { {
        panel = gameRightPanel,
        checkbox = gameRootPanel:getChildById('gameSelectRightColumn')
    }, {
        panel = gameRightExtraPanel,
        checkbox = gameRootPanel:getChildById('gameSelectRightExtraColumn')
    }, {
        panel = gameLeftPanel,
        checkbox = gameRootPanel:getChildById('gameSelectLeftColumn')
    } }

    panelsRadioGroup = UIRadioGroup.create()
    for k, v in pairs(panelsList) do
        panelsRadioGroup:addWidget(v.checkbox)
        connect(v.checkbox, {
            onCheckChange = onSelectPanel
        })
    end
    panelsRadioGroup:selectWidget(panelsList[1].checkbox)

    connect(gameLeftPanel, {
        onVisibilityChange = onExtraPanelVisibilityChange
    })
    connect(gameRightExtraPanel, {
        onVisibilityChange = onExtraPanelVisibilityChange
    })

    logoutButton = modules.client_topmenu.addLeftButton('logoutButton', tr('Exit'), '/images/topbuttons/logout',
        tryLogout, true)

    showTopMenuButton = gameMapPanel:getChildById('showTopMenuButton')
    showTopMenuButton.onClick = function()
        modules.client_topmenu.toggle()
    end

    bindKeys()

    if g_game.isOnline() then
        show()
    end
end

function onSelectPanel(self, checked)
    if checked then
        for k, v in pairs(panelsList) do
            if v.checkbox == self then
                gameSelectedPanel = v.panel
                break
            end
        end
    end
end


local function isCorpseOnTile(pos)
  local tile = g_map.getTile(pos)
  local items = tile:getItems()

  if not items or #items == 0 then
    return false
  end

   for v, corpse in pairs(getQuickLootCorpses()) do
     for _, item in pairs(items) do
       if item:getId() == corpse then
         return true
       end
     end
   end

  return false
end


function canQuickLoot(pos1, pos2)
  if pos1.z ~= pos2.z or math.abs(pos1.x - pos2.x) > 1 or math.abs(pos1.y - pos2.y) > 1 then
    return false
  end

  return true
end

function bindKeys()
    gameRootPanel:setAutoRepeatDelay(175)

    bindWalkKey('Up', North)
    bindWalkKey('Right', East)
    bindWalkKey('Down', South)
    bindWalkKey('Left', West)
    bindWalkKey('Numpad8', North)
    bindWalkKey('Numpad9', NorthEast)
    bindWalkKey('Numpad6', East)
    bindWalkKey('Numpad3', SouthEast)
    bindWalkKey('Numpad2', South)
    bindWalkKey('Numpad1', SouthWest)
    bindWalkKey('Numpad4', West)
    bindWalkKey('Numpad7', NorthWest)

    bindTurnKey('Ctrl+Up', North)
    bindTurnKey('Ctrl+Right', East)
    bindTurnKey('Ctrl+Down', South)
    bindTurnKey('Ctrl+Left', West)
    bindTurnKey('Ctrl+Numpad8', North)
    bindTurnKey('Ctrl+Numpad6', East)
    bindTurnKey('Ctrl+Numpad2', South)
    bindTurnKey('Ctrl+Numpad4', West)

    g_keyboard.bindKeyPress('Escape', function()
        g_game.cancelAttackAndFollow()
    end, gameRootPanel)
    g_keyboard.bindKeyPress('Ctrl+=', function()
        gameMapPanel:zoomIn()
    end, gameRootPanel)
    g_keyboard.bindKeyPress('Ctrl+-', function()
        gameMapPanel:zoomOut()
    end, gameRootPanel)
    g_keyboard.bindKeyDown('Ctrl+Q', function()
        tryLogout(false)
    end, gameRootPanel)
    g_keyboard.bindKeyDown('Ctrl+L', function()
        tryLogout(false)
    end, gameRootPanel)
    g_keyboard.bindKeyDown('Alt+W', function()
        g_map.cleanTexts()
        modules.game_textmessage.clearMessages()
    end, gameRootPanel)

    if not g_app.isScaled() then
        g_keyboard.bindKeyDown('Ctrl+.', nextViewMode, gameRootPanel)
    end
end

function bindWalkKey(key, dir)
    g_keyboard.bindKeyDown(key, function()
        onWalkKeyDown(dir)
    end, gameRootPanel, true)
    g_keyboard.bindKeyUp(key, function()
        changeWalkDir(dir, true)
    end, gameRootPanel, true)
    g_keyboard.bindKeyPress(key, function()
        smartWalk(dir)
    end, gameRootPanel)
end

function unbindWalkKey(key)
    g_keyboard.unbindKeyDown(key, gameRootPanel)
    g_keyboard.unbindKeyUp(key, gameRootPanel)
    g_keyboard.unbindKeyPress(key, gameRootPanel)
end

function bindTurnKey(key, dir)
    local function callback(widget, code, repeatTicks)
        if g_clock.millis() - lastDirTime >= modules.client_options.getOption('turnDelay') then
            g_game.turn(dir)
            changeWalkDir(dir)

            lastDirTime = g_clock.millis()
        end
    end

    g_keyboard.bindKeyPress(key, callback, gameRootPanel)
end

function unbindTurnKey(key)
    g_keyboard.unbindKeyPress(key, gameRootPanel)
end

function terminate()
    hide()
    if g_app.hasUpdater() then
        disconnect(g_app, {
            onUpdateFinished = load,
        })
    else
        disconnect(g_app, {
            onRun = load,
        })
    end
    disconnect(g_app, {
        onExit = save,
    })

    hookedMenuOptions = {}

    stopSmartWalk()

    disconnect(g_game, {
        onGameStart = onGameStart,
        onGameEnd = onGameEnd,
        onLoginAdvice = onLoginAdvice
    })

    disconnect(gameLeftPanel, {
        onVisibilityChange = onExtraPanelVisibilityChange
    })
    disconnect(gameRightExtraPanel, {
        onVisibilityChange = onExtraPanelVisibilityChange
    })

    for k, v in pairs(panelsList) do
        disconnect(v.checkbox, {
            onCheckChange = onSelectPanel
        })
    end

    logoutButton:destroy()
    gameRootPanel:destroy()
end

function onGameStart()
    show()

    -- open tibia has delay in auto walking
    if not g_game.isOfficialTibia() then
        g_game.enableFeature(GameForceFirstAutoWalkStep)
    else
        g_game.disableFeature(GameForceFirstAutoWalkStep)
    end
end

function onGameEnd()
    hide()
end

function show()
    connect(g_app, {
        onClose = tryExit
    })
    modules.client_background.hide()
    gameRootPanel:show()
    gameRootPanel:focus()
    gameMapPanel:followCreature(g_game.getLocalPlayer())

    updateStretchShrink()
    logoutButton:setTooltip(tr('Logout'))

    setupViewMode(0)
    if g_app.isScaled() then
        setupViewMode(1)
        setupViewMode(2)
    end

    gameMapPanel:clearTiles();

    addEvent(function()
        if not limitedZoom or g_game.isGM() then
            gameMapPanel:setMaxZoomOut(513)
            gameMapPanel:setLimitVisibleRange(false)
        else
            gameMapPanel:setMaxZoomOut(11)
            gameMapPanel:setLimitVisibleRange(true)
        end
    end)
end

function hide()
    setupViewMode(0)

    disconnect(g_app, {
        onClose = tryExit
    })
    logoutButton:setTooltip(tr('Exit'))

    if logoutWindow then
        logoutWindow:destroy()
        logoutWindow = nil
    end
    if exitWindow then
        exitWindow:destroy()
        exitWindow = nil
    end
    if countWindow then
        countWindow:destroy()
        countWindow = nil
    end
    gameRootPanel:hide()
    modules.client_background.show()
end

function save()
    local settings = {}
    settings.splitterMarginBottom = bottomSplitter:getMarginBottom()
    g_settings.setNode('game_interface', settings)
end

function load()
    local settings = g_settings.getNode('game_interface')
    if settings then
        if settings.splitterMarginBottom then
            bottomSplitter:setMarginBottom(settings.splitterMarginBottom)
        end
    end
end

function onLoginAdvice(message)
    displayInfoBox(tr('For Your Information'), message)
end

function forceExit()
    g_game.cancelLogin()
    scheduleEvent(exit, 10)
    return true
end

function tryExit()
    if exitWindow then
        return true
    end

    local exitFunc = function()
        g_game.safeLogout()
        forceExit()
    end
    local logoutFunc = function()
        g_game.safeLogout()
        exitWindow:destroy()
        exitWindow = nil
    end
    local cancelFunc = function()
        exitWindow:destroy()
        exitWindow = nil
    end

    exitWindow = displayGeneralBox(tr('Exit'), tr(
            'If you shut down the program, your character might stay in the game.\nClick on \'Logout\' to ensure that you character leaves the game properly.\nClick on \'Exit\' if you want to exit the program without logging out your character.'),
        {
            {
                text = tr('Force Exit'),
                callback = exitFunc
            },
            {
                text = tr('Logout'),
                callback = logoutFunc
            },
            {
                text = tr('Cancel'),
                callback = cancelFunc
            },
            anchor = AnchorHorizontalCenter
        }, logoutFunc, cancelFunc)

    return true
end

function tryLogout(prompt)
    if type(prompt) ~= 'boolean' then
        prompt = true
    end
    if not g_game.isOnline() then
        exit()
        return
    end

    if logoutWindow then
        return
    end

    local msg, yesCallback
    if not g_game.isConnectionOk() then
        msg =
        'Your connection is failing, if you logout now your character will be still online, do you want to force logout?'

        yesCallback = function()
            g_game.forceLogout()
            if logoutWindow then
                logoutWindow:destroy()
                logoutWindow = nil
            end
        end
    else
        msg = 'Are you sure you want to logout?'

        yesCallback = function()
            g_game.safeLogout()
            if logoutWindow then
                logoutWindow:destroy()
                logoutWindow = nil
            end
        end
    end

    local noCallback = function()
        logoutWindow:destroy()
        logoutWindow = nil
    end

    if prompt then
        logoutWindow = displayGeneralBox(tr('Logout'), tr(msg), {
            {
                text = tr('Yes'),
                callback = yesCallback
            },
            {
                text = tr('No'),
                callback = noCallback
            },
            anchor = AnchorHorizontalCenter
        }, yesCallback, noCallback)
    else
        yesCallback()
    end
end

function stopSmartWalk()
    smartWalkDirs = {}
    smartWalkDir = nil
end

function onWalkKeyDown(dir)
    if modules.client_options.getOption('autoChaseOverride') then
        if g_game.isAttacking() and g_game.getChaseMode() == ChaseOpponent then
            g_game.setChaseMode(DontChase)
        end
    end
    firstStep = true
    changeWalkDir(dir)
end

function changeWalkDir(dir, pop)
    while table.removevalue(smartWalkDirs, dir) do
    end
    if pop then
        if #smartWalkDirs == 0 then
            stopSmartWalk()
            return
        end
    else
        table.insert(smartWalkDirs, 1, dir)
    end

    smartWalkDir = smartWalkDirs[1]
    if modules.client_options.getOption('smartWalk') and #smartWalkDirs > 1 then
        for _, d in pairs(smartWalkDirs) do
            if (smartWalkDir == North and d == West) or (smartWalkDir == West and d == North) then
                smartWalkDir = NorthWest
                break
            elseif (smartWalkDir == North and d == East) or (smartWalkDir == East and d == North) then
                smartWalkDir = NorthEast
                break
            elseif (smartWalkDir == South and d == West) or (smartWalkDir == West and d == South) then
                smartWalkDir = SouthWest
                break
            elseif (smartWalkDir == South and d == East) or (smartWalkDir == East and d == South) then
                smartWalkDir = SouthEast
                break
            end
        end
    end
end

function smartWalk(dir)
    if g_keyboard.getModifiers() ~= KeyboardNoModifier then
        return false
    end

    local dire = smartWalkDir or dir
    g_game.walk(dire, firstStep)
    firstStep = false

    lastManualWalk = g_clock.millis()
    return true
end

function updateStretchShrink()
    if modules.client_options.getOption('dontStretchShrink') and not alternativeView then
        gameMapPanel:setVisibleDimension({
            width = 15,
            height = 11
        })

        -- Set gameMapPanel size to height = 11 * 32 + 2
        bottomSplitter:setMarginBottom(bottomSplitter:getMarginBottom() + (gameMapPanel:getHeight() - 32 * 11) - 10)
    end
end

function onMouseGrabberRelease(self, mousePosition, mouseButton)
    if selectedThing == nil then
        return false
    end
    if mouseButton == MouseLeftButton then
        local clickedWidget = gameRootPanel:recursiveGetChildByPos(mousePosition, false)
        if clickedWidget then
            if selectedType == 'use' then
                onUseWith(clickedWidget, mousePosition)
            elseif selectedType == 'trade' then
                onTradeWith(clickedWidget, mousePosition)
            end
        end
    end

    selectedThing = nil
    g_mouse.popCursor('target')
    self:ungrabMouse()
    return true
end

function onUseWith(clickedWidget, mousePosition)
    if clickedWidget:getClassName() == 'UIGameMap' then
        local tile = clickedWidget:getTile(mousePosition)
        if tile then
            if selectedThing:isFluidContainer() or selectedThing:isMultiUse() then
                g_game.useWith(selectedThing, tile:getTopMultiUseThing())
            else
                g_game.useWith(selectedThing, tile:getTopUseThing())
            end
        end
    elseif clickedWidget:getClassName() == 'UIItem' and not clickedWidget:isVirtual() then
        g_game.useWith(selectedThing, clickedWidget:getItem())
    elseif clickedWidget:getClassName() == 'UICreatureButton' then
        local creature = clickedWidget:getCreature()
        if creature then
            g_game.useWith(selectedThing, creature)
        end
    end
end

function onTradeWith(clickedWidget, mousePosition)
    if clickedWidget:getClassName() == 'UIGameMap' then
        local tile = clickedWidget:getTile(mousePosition)
        if tile then
            g_game.requestTrade(selectedThing, tile:getTopCreature())
        end
    elseif clickedWidget:getClassName() == 'UICreatureButton' then
        local creature = clickedWidget:getCreature()
        if creature then
            g_game.requestTrade(selectedThing, creature)
        end
    end
end

function startUseWith(thing)
    if not thing then
        return
    end
    if g_ui.isMouseGrabbed() then
        if selectedThing then
            selectedThing = thing
            selectedType = 'use'
        end
        return
    end
    selectedType = 'use'
    selectedThing = thing
    mouseGrabberWidget:grabMouse()
    g_mouse.pushCursor('target')
end

function startTradeWith(thing)
    if not thing then
        return
    end
    if g_ui.isMouseGrabbed() then
        if selectedThing then
            selectedThing = thing
            selectedType = 'trade'
        end
        return
    end
    selectedType = 'trade'
    selectedThing = thing
    mouseGrabberWidget:grabMouse()
    g_mouse.pushCursor('target')
end

function isMenuHookCategoryEmpty(category)
    if category then
        for _, opt in pairs(category) do
            if opt then
                return false
            end
        end
    end
    return true
end

function addMenuHook(category, name, callback, condition, shortcut)
    if not hookedMenuOptions[category] then
        hookedMenuOptions[category] = {}
    end
    hookedMenuOptions[category][name] = {
        callback = callback,
        condition = condition,
        shortcut = shortcut
    }
end

function removeMenuHook(category, name)
    if not name then
        hookedMenuOptions[category] = {}
    else
        hookedMenuOptions[category][name] = nil
    end
end

local function getItemDetailsByClientId(id)
  for _, item in pairs(getQuickLootItems()) do
    if item.clientId == id then
      return item
    end
  end

  return false
end

local function getItemDetailsByServerId(id)
  for _, item in pairs(getQuickLootItems()) do
    if item.serverId == id then
      return item
    end
  end

  return false
end

local function getLootList()
  local char = g_game.getCharacterName()
  if not char or #char == 0 then return {} end
  local lootList = {}

  local skippedItems = g_settings.getNode('SkippedItems')
  if not skippedItems then return {} end
  if not skippedItems[char] then return {} end

  for key, value in pairs(skippedItems[char]) do
    local itemDetails = getItemDetailsByServerId(value)

    if itemDetails then
      table.insert(lootList, itemDetails)
    end
  end

  return lootList
end

local function isItemInList(item, list)
  if not item then return false end
  if table.empty(list) then return false end

  for _, element in pairs(list) do
    if element.clientId == item.clientId then
      return true
    end
  end

  return false
end

local function getQuickLootBackpacks()
    local char = g_game.getCharacterName()
    if not char or #char == 0 then return {} end
    local data = {}

    local backpacks = g_settings.getNode('QuickLootBackpacks')
    if not backpacks then return {} end
    if not backpacks[char] then return {} end

    for key, value in pairs(backpacks[char]) do
      table.insert(data, { key = value})
    end

    return data
end

local function loadQuickLootConvertGold()
  local char = g_game.getCharacterName()
  if not char or #char == 0 then return false end

  local convertGoldData = g_settings.getNode('QuickLootConvertGold')
  if not convertGoldData then return false end
  if not convertGoldData[char] then return false end

  return convertGoldData[char] or false
end

local function saveQuickLootingSettings(list)
  local char = g_game.getCharacterName()
  if not char or #char == 0 then return end

  local skippedItems = g_settings.getNode('SkippedItems')
  if not skippedItems then skippedItems = {} end


  skippedItems[char] = {}

  for key, value in pairs(list) do
    skippedItems[char][key] = value.serverId
  end


  g_settings.setNode('SkippedItems', skippedItems)
end

local function sendQuickLootData(skippedList)
  local stringList = ""
  local backpacks = getQuickLootBackpacks()
  local convertGold = loadQuickLootConvertGold()

  for _, item in pairs(skippedList) do
    stringList = stringList .. item.serverId .. ";"
  end

  saveQuickLootingSettings(skippedList)
  g_game.quickLootData(stringList, convertGold, backpacks.lootBackpack or "", backpacks.goldBackpack or "", backpacks.stackBackpack or "")
end

local function isInLootList(id)
  for key, value in pairs(getLootList()) do
    if value.clientId == id then
      return true
    end
  end

  return false
end

local function removeFromLootList(id)
  local skippedList = {}

  for _, item in pairs(getLootList()) do
    if item.clientId ~= id then
      table.insert(skippedList, item)
    end
  end

  sendQuickLootData(skippedList)
end

local function addToLootList(id)
  local skippedList = getLootList()
  local item = getItemDetailsByClientId(id)

  if not item then
    return
  end

  if not isItemInList(item, skippedList) then
    table.insert(skippedList, item)
  end

  sendQuickLootData(skippedList)
end

local function isBackpack(id)
  local backpacks = { 2853, 2854, 2858, 2859, 2862, 2863, 2866, 2867, 2870, 2871, 3253, 5801, 5949, 5950, 8860, 8861 }

  for _, bp in pairs(backpacks) do
    if bp == id then
      return true
    end
  end

  return false
end


function createThingMenu(menuPosition, lookThing, useThing, creatureThing)
    if not g_game.isOnline() then
        return
    end

    local menu = g_ui.createWidget('PopupMenu')
    menu:setGameMenu(true)

    local classic = modules.client_options.getOption('classicControl')
    local shortcut = nil

    if not classic then
        shortcut = '(Shift)'
    else
        shortcut = nil
    end
    if lookThing then
        menu:addOption(tr('Look'), function()
            g_game.look(lookThing)
        end, shortcut)
    end

    if not classic then
        shortcut = '(Ctrl)'
    else
        shortcut = nil
    end
    if useThing then
        if useThing:isContainer() then
            if useThing:getParentContainer() then
                menu:addOption(tr('Open'), function()
                    g_game.open(useThing, useThing:getParentContainer())
                end, shortcut)
                menu:addOption(tr('Open in new window'), function()
                    g_game.open(useThing)
                end)
            else
                menu:addOption(tr('Open'), function()
                    g_game.open(useThing)
                end, shortcut)
            end
        else
            if useThing:isMultiUse() then
                menu:addOption(tr('Use with ...'), function()
                    startUseWith(useThing)
                end, shortcut)
            else
                menu:addOption(tr('Use'), function()
                    g_game.use(useThing)
                end, shortcut)
            end
        end

        if useThing:isRotateable() then
            menu:addOption(tr('Rotate'), function()
                g_game.rotate(useThing)
            end)
        end

        local onWrapItem = function()
            g_game.wrap(useThing)
        end
        if useThing:isWrapable() then
            menu:addOption(tr('Wrap'), onWrapItem)
        end
        if useThing:isUnwrapable() then
            menu:addOption(tr('Unwrap'), onWrapItem)
        end

        if g_game.getFeature(GameBrowseField) and useThing:getPosition().x ~= 0xffff then
            menu:addOption(tr('Browse Field'), function()
                g_game.browseField(useThing:getPosition())
            end)
        end

        local localPlayer = g_game.getLocalPlayer()
        if canQuickLoot(localPlayer:getPosition(), useThing:getPosition()) and isCorpseOnTile(useThing:getPosition()) then
          menu:addOption(tr('Quick Loot'), function()
            g_game.quickLoot(useThing:getPosition())
          end)
        end

    end

    if lookThing and not lookThing:isCreature() and not lookThing:isNotMoveable() and lookThing:isPickupable() then
        menu:addSeparator()
        menu:addOption(tr('Trade with ...'), function()
            startTradeWith(lookThing)
        end)
    end

    if lookThing then
        local parentContainer = lookThing:getParentContainer()
        if parentContainer and parentContainer:hasParent() then
            menu:addOption(tr('Move up'), function()
                g_game.moveToParentContainer(lookThing, lookThing:getCount())
            end)
        end
    end

    if useThing and not useThing:isCreature() and useThing:isPickupable() then
      menu:addSeparator()

      if isBackpack(useThing:getId()) and useThing:getPosition().x == 0xffff then
        menu:addOption(tr('Manage Loot Containers'), function()
           modules.game_lootcontainer.toggle()
         end)
      end


      if isInLootList(lookThing:getId()) then
        menu:addOption(tr('Remove from Loot List'), function()
           removeFromLootList(lookThing:getId())
         end)
      else
        menu:addOption(tr('Add to Loot List'), function()
           addToLootList(lookThing:getId())
         end)
      end
    end

    if creatureThing then
        local localPlayer = g_game.getLocalPlayer()
        menu:addSeparator()

        if creatureThing:isLocalPlayer() then
            menu:addOption(tr('Set Outfit'), function()
                g_game.requestOutfit()
            end)

            if g_game.getFeature(GamePrey) then
                menu:addOption(tr('Prey Dialog'), function()
                    modules.game_prey.show()
                end)
            end

            if creatureThing:isPartyMember() then
                if creatureThing:isPartyLeader() then
                    if creatureThing:isPartySharedExperienceActive() then
                        menu:addOption(tr('Disable Shared Experience'), function()
                            g_game.partyShareExperience(false)
                        end)
                    else
                        menu:addOption(tr('Enable Shared Experience'), function()
                            g_game.partyShareExperience(true)
                        end)
                    end
                end
                menu:addOption(tr('Leave Party'), function()
                    g_game.partyLeave()
                end)
            end
        else
            local localPosition = localPlayer:getPosition()
            if not classic then
                shortcut = '(Alt)'
            else
                shortcut = nil
            end
            if creatureThing:getPosition().z == localPosition.z then
              if creatureThing:isNpc() then
                menu:addOption(tr('Talk'), function() g_game.talkNpc(creatureThing) end, shortcut)
              else
                if g_game.getAttackingCreature() ~= creatureThing then
                    menu:addOption(tr('Attack'), function()
                        g_game.attack(creatureThing)
                    end, shortcut)
                else
                    menu:addOption(tr('Stop Attack'), function()
                        g_game.cancelAttack()
                    end, shortcut)
                end

                if g_game.getFollowingCreature() ~= creatureThing then
                    menu:addOption(tr('Follow'), function()
                        g_game.follow(creatureThing)
                    end)
                else
                    menu:addOption(tr('Stop Follow'), function()
                        g_game.cancelFollow()
                    end)
                end
              end
            end

            if creatureThing:isPlayer() then
                menu:addSeparator()
                local creatureName = creatureThing:getName()
                menu:addOption(tr('Message to %s', creatureName), function()
                    g_game.openPrivateChannel(creatureName)
                end)
                if modules.game_console.getOwnPrivateTab() then
                    menu:addOption(tr('Invite to private chat'), function()
                        g_game.inviteToOwnChannel(creatureName)
                    end)
                    menu:addOption(tr('Exclude from private chat'), function()
                        g_game.excludeFromOwnChannel(creatureName)
                    end) -- [TODO] must be removed after message's popup labels been implemented
                end
                if not localPlayer:hasVip(creatureName) then
                    menu:addOption(tr('Add to VIP list'), function()
                        g_game.addVip(creatureName)
                    end)
                end

                if modules.game_console.isIgnored(creatureName) then
                    menu:addOption(tr('Unignore') .. ' ' .. creatureName, function()
                        modules.game_console.removeIgnoredPlayer(creatureName)
                    end)
                else
                    menu:addOption(tr('Ignore') .. ' ' .. creatureName, function()
                        modules.game_console.addIgnoredPlayer(creatureName)
                    end)
                end

                local localPlayerShield = localPlayer:getShield()
                local creatureShield = creatureThing:getShield()

                if localPlayerShield == ShieldNone or localPlayerShield == ShieldWhiteBlue then
                    if creatureShield == ShieldWhiteYellow then
                        menu:addOption(tr('Join %s\'s Party', creatureThing:getName()), function()
                            g_game.partyJoin(creatureThing:getId())
                        end)
                    else
                        menu:addOption(tr('Invite to Party'), function()
                            g_game.partyInvite(creatureThing:getId())
                        end)
                    end
                elseif localPlayerShield == ShieldWhiteYellow then
                    if creatureShield == ShieldWhiteBlue then
                        menu:addOption(tr('Revoke %s\'s Invitation', creatureThing:getName()), function()
                            g_game.partyRevokeInvitation(creatureThing:getId())
                        end)
                    end
                elseif localPlayerShield == ShieldYellow or localPlayerShield == ShieldYellowSharedExp or
                    localPlayerShield == ShieldYellowNoSharedExpBlink or localPlayerShield == ShieldYellowNoSharedExp then
                    if creatureShield == ShieldWhiteBlue then
                        menu:addOption(tr('Revoke %s\'s Invitation', creatureThing:getName()), function()
                            g_game.partyRevokeInvitation(creatureThing:getId())
                        end)
                    elseif creatureShield == ShieldBlue or creatureShield == ShieldBlueSharedExp or creatureShield ==
                        ShieldBlueNoSharedExpBlink or creatureShield == ShieldBlueNoSharedExp then
                        menu:addOption(tr('Pass Leadership to %s', creatureThing:getName()), function()
                            g_game.partyPassLeadership(creatureThing:getId())
                        end)
                    else
                        menu:addOption(tr('Invite to Party'), function()
                            g_game.partyInvite(creatureThing:getId())
                        end)
                    end
                end
            end
        end

        if modules.game_ruleviolation.hasWindowAccess() and creatureThing:isPlayer() then
            menu:addSeparator()
            menu:addOption(tr('Rule Violation'), function()
                modules.game_ruleviolation.show(creatureThing:getName())
            end)
        end

        menu:addSeparator()
        menu:addOption(tr('Copy Name'), function()
            g_window.setClipboardText(creatureThing:getName())
        end)
    end

    -- hooked menu options
    for _, category in pairs(hookedMenuOptions) do
        if not isMenuHookCategoryEmpty(category) then
            menu:addSeparator()
            for name, opt in pairs(category) do
                if opt and opt.condition(menuPosition, lookThing, useThing, creatureThing) then
                    menu:addOption(name, function()
                        opt.callback(menuPosition, lookThing, useThing, creatureThing)
                    end, opt.shortcut)
                end
            end
        end
    end

    if not g_game.isEnabledBotProtection() and useThing and useThing:isItem() then
           menu:addSeparator()
           local useThingId = useThing:getId()
           if useThing:getSubType() > 1 then
               menu:addOption("ID: " .. useThingId .. " SubType: " .. g_window.getClipboardText(), function() end)
           else
               menu:addOption("ID: " .. useThingId, function() g_window.setClipboardText(useThingId) end)
           end
       end

    menu:display(menuPosition)
end

function processMouseAction(menuPosition, mouseButton, autoWalkPos, lookThing, useThing, creatureThing, attackCreature)
    local keyboardModifiers = g_keyboard.getModifiers()
    local player = g_game.getLocalPlayer()

    if modules.client_options.getOption('quickLootHotkey') == "SHIFT+Right" then
        if keyboardModifiers == KeyboardShiftModifier and mouseButton == MouseRightButton then
          local pos = useThing:getPosition()
          if canQuickLoot(player:getPosition(), pos) and isCorpseOnTile(pos) then
            g_game.quickLoot(pos)
            return true
          end
        end
    end

    if modules.client_options.getOption('quickLootHotkey') == "Right" then
        if mouseButton == MouseRightButton and keyboardModifiers == KeyboardNoModifier then
          local pos = useThing:getPosition()
            if canQuickLoot(player:getPosition(), pos) and isCorpseOnTile(pos) then
              if not creatureThing and not attackCreature then
                  g_game.quickLoot(pos)
                  return true
                end

                if creatureThing and attackCreature then
                  if (creatureThing:getId() == attackCreature:getId()) and (creatureThing:getId() == player:getId()) then
                      g_game.quickLoot(pos)
                      return true
                  end
                end
            end

        end
    end

    if modules.client_options.getOption('quickLootHotkey') == "Left" then
        if mouseButton == MouseLeftButton and keyboardModifiers == KeyboardNoModifier then
          if not ((g_mouse.isPressed(MouseLeftButton) and mouseButton == MouseRightButton) or
              (g_mouse.isPressed(MouseRightButton) and mouseButton == MouseLeftButton)) then
              local pos = autoWalkPos
              if canQuickLoot(player:getPosition(), pos) and isCorpseOnTile(pos) then
                g_game.quickLoot(pos, modules.client_options.getOption('lootBackpack'))
              return true
            end
          end
        end
    end


    if not modules.client_options.getOption('classicControl') then
        if keyboardModifiers == KeyboardNoModifier and mouseButton == MouseRightButton then
            createThingMenu(menuPosition, lookThing, useThing, creatureThing)
            return true
        elseif lookThing and keyboardModifiers == KeyboardShiftModifier and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            g_game.look(lookThing)
            return true
        elseif useThing and keyboardModifiers == KeyboardCtrlModifier and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            if useThing:isContainer() then
                if useThing:getParentContainer() then
                    g_game.open(useThing, useThing:getParentContainer())
                else
                    g_game.open(useThing)
                end
                return true
            elseif useThing:isMultiUse() then
                startUseWith(useThing)
                return true
            else
                g_game.use(useThing)
                return true
            end
            return true
        elseif useThing and useThing:isContainer() and keyboardModifiers == KeyboardCtrlShiftModifier and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            g_game.open(useThing)
            return true
        elseif attackCreature and g_keyboard.isAltPressed() and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            g_game.attack(attackCreature)
            return true
        elseif creatureThing and creatureThing:getPosition().z == autoWalkPos.z and g_keyboard.isAltPressed() and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then

              if attackCreature:isNpc() then
                  g_game.talkNpc(attackCreature)
              else
                g_game.attack(attackCreature)
              end

            return true
        end

        -- classic control
    else
        if useThing and keyboardModifiers == KeyboardNoModifier and mouseButton == MouseRightButton and
            not g_mouse.isPressed(MouseLeftButton) then
            local player = g_game.getLocalPlayer()
            if attackCreature and attackCreature ~= player then

              if attackCreature:isNpc() then
                  g_game.talkNpc(attackCreature)
              else
                  g_game.attack(attackCreature)
              end

                return true
            elseif creatureThing and creatureThing ~= player and creatureThing:getPosition().z == autoWalkPos.z then
                g_game.attack(creatureThing)
                return true
            elseif useThing:isContainer() then
                if useThing:getParentContainer() then
                    g_game.open(useThing, useThing:getParentContainer())
                    return true
                else
                    g_game.open(useThing)
                    return true
                end
            elseif useThing:isMultiUse() then
                startUseWith(useThing)
                return true
            else
                g_game.use(useThing)
                return true
            end
            return true
        elseif useThing and useThing:isContainer() and keyboardModifiers == KeyboardCtrlShiftModifier and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            g_game.open(useThing)
            return true
        elseif lookThing and keyboardModifiers == KeyboardShiftModifier and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            g_game.look(lookThing)
            return true
        elseif lookThing and ((g_mouse.isPressed(MouseLeftButton) and mouseButton == MouseRightButton) or
                (g_mouse.isPressed(MouseRightButton) and mouseButton == MouseLeftButton)) then
            g_game.look(lookThing)
            return true
        elseif useThing and keyboardModifiers == KeyboardCtrlModifier and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            createThingMenu(menuPosition, lookThing, useThing, creatureThing)
            return true
        elseif attackCreature and g_keyboard.isAltPressed() and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then
            g_game.attack(attackCreature)
            return true
        elseif creatureThing and creatureThing:getPosition().z == autoWalkPos.z and g_keyboard.isAltPressed() and
            (mouseButton == MouseLeftButton or mouseButton == MouseRightButton) then

              if attackCreature:isNpc() then
                g_game.talkNpc(attackCreature)
              else
                g_game.attack(attackCreature)
              end

            return true
        end
    end

    local player = g_game.getLocalPlayer()
    player:stopAutoWalk()

    if autoWalkPos and keyboardModifiers == KeyboardNoModifier and mouseButton == MouseLeftButton then
        player:autoWalk(autoWalkPos)
        return true
    end

    return false
end

function moveStackableItem(item, toPos)
    if countWindow then
        return
    end
    if g_keyboard.isShiftPressed() then
        g_game.move(item, toPos, 1)
        return
    elseif g_keyboard.isCtrlPressed() ~= modules.client_options.getOption('moveStack') then
        g_game.move(item, toPos, item:getCount())
        return
    end
    local count = item:getCount()

    countWindow = g_ui.createWidget('CountWindow', rootWidget)
    local itembox = countWindow:getChildById('item')
    local scrollbar = countWindow:getChildById('countScrollBar')
    itembox:setItemId(item:getId())
    itembox:setItemCount(count)
    scrollbar:setMaximum(count)
    scrollbar:setMinimum(1)
    scrollbar:setValue(count)

    local spinbox = countWindow:getChildById('spinBox')
    spinbox:setMaximum(count)
    spinbox:setMinimum(0)
    spinbox:setValue(0)
    spinbox:hideButtons()
    spinbox:focus()
    spinbox.firstEdit = true

    local spinBoxValueChange = function(self, value)
        spinbox.firstEdit = false
        scrollbar:setValue(value)
    end
    spinbox.onValueChange = spinBoxValueChange

    local check = function()
        if spinbox.firstEdit then
            spinbox:setValue(spinbox:getMaximum())
            spinbox.firstEdit = false
        end
    end
    g_keyboard.bindKeyPress('Up', function()
        check()
        spinbox:upSpin()
    end, spinbox)
    g_keyboard.bindKeyPress('Down', function()
        check()
        spinbox:downSpin()
    end, spinbox)
    g_keyboard.bindKeyPress('Right', function()
        check()
        spinbox:upSpin()
    end, spinbox)
    g_keyboard.bindKeyPress('Left', function()
        check()
        spinbox:downSpin()
    end, spinbox)
    g_keyboard.bindKeyPress('PageUp', function()
        check()
        spinbox:setValue(spinbox:getValue() + 10)
    end, spinbox)
    g_keyboard.bindKeyPress('PageDown', function()
        check()
        spinbox:setValue(spinbox:getValue() - 10)
    end, spinbox)

    scrollbar.onValueChange = function(self, value)
        itembox:setItemCount(value)
        spinbox.onValueChange = nil
        spinbox:setValue(value)
        spinbox.onValueChange = spinBoxValueChange
    end

    local okButton = countWindow:getChildById('buttonOk')
    local moveFunc = function()
        g_game.move(item, toPos, itembox:getItemCount())
        okButton:getParent():destroy()
        countWindow = nil
        modules.game_hotkeys.enableHotkeys(true)
    end
    local cancelButton = countWindow:getChildById('buttonCancel')
    local cancelFunc = function()
        cancelButton:getParent():destroy()
        countWindow = nil
        modules.game_hotkeys.enableHotkeys(true)
    end

    countWindow.onEnter = moveFunc
    countWindow.onEscape = cancelFunc

    okButton.onClick = moveFunc
    cancelButton.onClick = cancelFunc

    modules.game_hotkeys.enableHotkeys(false)
end

function getRootPanel()
    return gameRootPanel
end

function getMapPanel()
    return gameMapPanel
end

function getRightPanel()
    return gameRightPanel
end

function getLeftPanel()
    return gameLeftPanel
end

function getRightExtraPanel()
    return gameRightExtraPanel
end

function getSelectedPanel()
    return gameSelectedPanel
end

function getBottomPanel()
    return gameBottomPanel
end

function getShowTopMenuButton()
    return showTopMenuButton
end

function findContentPanelAvailable(child, minContentHeight)
    if gameSelectedPanel:isVisible() and gameSelectedPanel:fits(child, minContentHeight, 0) >= 0 then
        return gameSelectedPanel
    end

    for k, v in pairs(panelsList) do
        if v.panel ~= gameSelectedPanel and v.panel:isVisible() and v.panel:fits(child, minContentHeight, 0) >= 0 then
            return v.panel
        end
    end

    return gameSelectedPanel
end

function onExtraPanelVisibilityChange(extraPanel, visible)
    if not visible then
        -- move children to right panel
        if g_game.isOnline() then
            local children = extraPanel:getChildren()
            for i = 1, #children do
                children[i]:setParent(gameRightPanel)
            end
        end

        -- unselect hiding panel
        if extraPanel == getSelectedPanel() then
            panelsRadioGroup:selectWidget(panelsList[1].checkbox)
        end

        -- hide checkbox of hidden panel
        for k, v in pairs(panelsList) do
            if v.panel == extraPanel then
                v.checkbox:setVisible(false)
            end
        end

        -- if there is only the right panel visible, hide its checkbox too
        if not gameRightExtraPanel:isVisible() and not gameLeftPanel:isVisible() then
            panelsList[1].checkbox:setVisible(false)
        end
    else
        -- this means that, besided the right panel, there is another panel visible
        -- so we'll enable the checkboxes from the one at right, and the one being shown
        for k, v in pairs(panelsList) do
            if v.panel == extraPanel then
                v.checkbox:setVisible(true)
            end
        end
        panelsList[1].checkbox:setVisible(true)
    end
end

function nextViewMode()
    setupViewMode((currentViewMode + 1) % 3)
end

function setupViewMode(mode)
    if mode == currentViewMode then
        return
    end

    if currentViewMode == 2 then
        gameMapPanel:addAnchor(AnchorLeft, 'gameLeftPanel', AnchorRight)
        gameMapPanel:addAnchor(AnchorRight, 'gameRightPanel', AnchorLeft)
        gameMapPanel:addAnchor(AnchorRight, 'gameRightExtraPanel', AnchorLeft)
        gameMapPanel:addAnchor(AnchorBottom, 'gameBottomPanel', AnchorTop)
        gameRootPanel:addAnchor(AnchorTop, 'topMenu', AnchorBottom)
        gameLeftPanel:setOn(modules.client_options.getOption('showLeftPanel'))
        gameRightExtraPanel:setOn(modules.client_options.getOption('showRightExtraPanel'))
        gameLeftPanel:setImageColor('white')
        gameRightPanel:setImageColor('white')
        gameRightExtraPanel:setImageColor('white')
        gameLeftPanel:setMarginTop(0)
        gameRightPanel:setMarginTop(0)
        gameRightExtraPanel:setMarginTop(0)
        gameBottomPanel:setImageColor('white')
        modules.client_topmenu.getTopMenu():setImageColor('white')
    end

    if mode == 0 then
        gameMapPanel:setKeepAspectRatio(true)
        gameMapPanel:setLimitVisibleRange(false)
        gameMapPanel:setZoom(11)
        gameMapPanel:setVisibleDimension({
            width = 15,
            height = 11
        })
    elseif mode == 1 then
        gameMapPanel:setKeepAspectRatio(false)
        gameMapPanel:setLimitVisibleRange(true)
        gameMapPanel:setZoom(11)
        gameMapPanel:setVisibleDimension({
            width = 15,
            height = 11
        })
    elseif mode == 2 then
        local limit = limitedZoom and not g_game.isGM()
        gameMapPanel:setLimitVisibleRange(limit)
        gameMapPanel:setZoom(11)
        gameMapPanel:setVisibleDimension({
            width = 15,
            height = 11
        })
        gameMapPanel:fill('parent')
        gameRootPanel:fill('parent')
        gameLeftPanel:setImageColor('alpha')
        gameRightPanel:setImageColor('alpha')
        gameRightExtraPanel:setImageColor('alpha')
        gameLeftPanel:setMarginTop(modules.client_topmenu.getTopMenu():getHeight() - gameLeftPanel:getPaddingTop())
        gameRightPanel:setMarginTop(modules.client_topmenu.getTopMenu():getHeight() - gameRightPanel:getPaddingTop())
        gameRightExtraPanel:setMarginTop(modules.client_topmenu.getTopMenu():getHeight() -
            gameRightExtraPanel:getPaddingTop())
        gameLeftPanel:setOn(true)
        gameLeftPanel:setVisible(true)
        gameRightPanel:setOn(true)
        gameRightExtraPanel:setOn(true)
        gameRightExtraPanel:setVisible(true)
        gameMapPanel:setOn(true)
        gameBottomPanel:setImageColor('#ffffff88')
        modules.client_topmenu.getTopMenu():setImageColor('#ffffff66')
    end

    currentViewMode = mode
end

function limitZoom()
    limitedZoom = true
end
