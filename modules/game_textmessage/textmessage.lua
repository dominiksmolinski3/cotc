MessageSettings = {
    none = {},
    consoleRed = {
        color = TextColors.red,
        consoleTab = 'Default'
    },
    consoleOrange = {
        color = TextColors.orange,
        consoleTab = 'Default'
    },
    consoleBlue = {
        color = TextColors.blue,
        consoleTab = 'Default'
    },
    centerRed = {
        color = TextColors.red,
        consoleTab = 'Server Log',
        screenTarget = 'lowCenterLabel'
    },

    centerGreen = {
        color = TextColors.green,
        consoleTab = 'Server Log',
        screenTarget = 'highCenterLabel',
        consoleOption = 'showInfoMessagesInConsole'
    },

    centerLoot = {
      color = TextColors.white,
      consoleTab = 'Server Log',
      screenTarget = 'highCenterLabel',
      consoleOption = 'showInfoMessagesInConsole',
      highLightItems = true,
    },

    centerWhite = {
        color = TextColors.white,
        consoleTab = 'Server Log',
        screenTarget = 'middleCenterLabel',
        consoleOption = 'showEventMessagesInConsole'
    },
    bottomWhite = {
        color = TextColors.white,
        consoleTab = 'Server Log',
        screenTarget = 'statusLabel',
        consoleOption = 'showEventMessagesInConsole'
    },
    status = {
        color = TextColors.white,
        consoleTab = 'Server Log',
        screenTarget = 'statusLabel',
        consoleOption = 'showStatusMessagesInConsole'
    },
    statusSmall = {
        color = TextColors.white,
        screenTarget = 'statusLabel'
    },
    private = {
        color = TextColors.lightblue,
        screenTarget = 'privateLabel'
    }
}

MessageTypes = {
    [MessageModes.MonsterSay] = MessageSettings.consoleOrange,
    [MessageModes.MonsterYell] = MessageSettings.consoleOrange,
    [MessageModes.BarkLow] = MessageSettings.consoleOrange,
    [MessageModes.BarkLoud] = MessageSettings.consoleOrange,
    [MessageModes.Failure] = MessageSettings.statusSmall,
    [MessageModes.Login] = MessageSettings.bottomWhite,
    [MessageModes.Game] = MessageSettings.centerWhite,
    [MessageModes.Status] = MessageSettings.status,
    [MessageModes.Warning] = MessageSettings.centerRed,
    [MessageModes.Look] = MessageSettings.centerGreen,
    [MessageModes.Loot] = MessageSettings.centerLoot,
    [MessageModes.Red] = MessageSettings.consoleRed,
    [MessageModes.Blue] = MessageSettings.consoleBlue,
    [MessageModes.PrivateFrom] = MessageSettings.consoleBlue,

    [MessageModes.GamemasterBroadcast] = MessageSettings.consoleRed,

    [MessageModes.DamageDealed] = MessageSettings.status,
    [MessageModes.DamageReceived] = MessageSettings.status,
    [MessageModes.Heal] = MessageSettings.status,
    [MessageModes.Exp] = MessageSettings.status,

    [MessageModes.DamageOthers] = MessageSettings.none,
    [MessageModes.HealOthers] = MessageSettings.none,
    [MessageModes.ExpOthers] = MessageSettings.none,

    [MessageModes.TradeNpc] = MessageSettings.centerWhite,
    [MessageModes.Guild] = MessageSettings.centerWhite,
    [MessageModes.Party] = MessageSettings.centerGreen,
    [MessageModes.PartyManagement] = MessageSettings.centerWhite,
    [MessageModes.TutorialHint] = MessageSettings.centerWhite,
    [MessageModes.BeyondLast] = MessageSettings.centerWhite,
    [MessageModes.Report] = MessageSettings.consoleRed,
    [MessageModes.GameHighlight] = MessageSettings.centerRed,
    [MessageModes.HotkeyUse] = MessageSettings.centerGreen,
    [MessageModes.Attention] = MessageSettings.bottomWhite,
    [MessageModes.BoostedCreature] = MessageSettings.centerWhite,
    [MessageModes.OfflineTrainning] = MessageSettings.centerWhite,
    [MessageModes.Transaction] = MessageSettings.centerWhite,
    [MessageModes.Potion] = MessageSettings.none,

    [254] = MessageSettings.private
}

messagesPanel = nil

function init()
    for messageMode, _ in pairs(MessageTypes) do registerMessageMode(messageMode, displayMessage) end

    connect(g_game, 'onGameEnd', clearMessages)
    messagesPanel = g_ui.loadUI('textmessage', modules.game_interface.getRootPanel())
end

function terminate()
    for messageMode, _ in pairs(MessageTypes) do unregisterMessageMode(messageMode, displayMessage) end

    disconnect(g_game, 'onGameEnd', clearMessages)
    clearMessages()
    messagesPanel:destroy()
    messagesPanel = nil
end

function calculateVisibleTime(text) return math.max(#text * 100, 4000) end

local function getItemColor(name)
  local search = string.match(name, "%D+")

  if search then
    search = search:gsub("%+", ""):trim()
  end
  print("text search: " .. search)

  local found = getHighLightItems()[search]

  return determineColor(found)
end

local function getColoredLoot(inputString, delimiter)
    local result = {}
    local loot = nil
    local beginPosition = inputString:find(": ")
    local lastPosition = inputString:find("%(") or nil

    table.insert(result, { text = inputString:sub(0, beginPosition + 1), color = "white"})

    if lastPosition then
      loot = inputString:sub(beginPosition + 1, lastPosition)
    else
      loot = inputString:sub(beginPosition + 1)
    end

    local pattern = string.format("([^%s]+)", delimiter)

    for match in loot:gmatch(pattern) do
      local itemName = match:trim()

      table.insert(result, { text = itemName, color = getItemColor(itemName)})
    end

    return result
end

function displayMessage(mode, text)
    if not g_game.isOnline() then return end

    local msgtype = MessageTypes[mode]
    if not msgtype then return end

    if msgtype == MessageSettings.none then return end

    if msgtype.consoleTab ~= nil and
        (msgtype.consoleOption == nil or modules.client_options.getOption(msgtype.consoleOption)) then
        modules.game_console.addText(text, msgtype, tr(msgtype.consoleTab))
    end

    if msgtype.highLightItems then
      local label = messagesPanel:recursiveGetChildById(msgtype.screenTarget)
      local coloredText = ""
      local coloredParts = getColoredLoot(text, ",")

      for i, item in pairs(coloredParts) do
        coloredText = coloredText .. "{" .. item.text .. "," .. item.color .."}"

        if i < #coloredParts and i > 1 then
          coloredText = coloredText .. "{, ,white}"
        end
      end

       label:setColoredText(coloredText)

      label:setVisible(true)
      removeEvent(label.hideEvent)
      label.hideEvent = scheduleEvent(function() label:setVisible(false) end, calculateVisibleTime(text))
    end

    if not msgtype.highLightItems and msgtype.screenTarget then
        local label = messagesPanel:recursiveGetChildById(msgtype.screenTarget)
        label:setText(text)
        label:setColor(msgtype.color)
        label:setVisible(true)
        removeEvent(label.hideEvent)
        label.hideEvent = scheduleEvent(function() label:setVisible(false) end, calculateVisibleTime(text))
    end
end

function displayPrivateMessage(text) displayMessage(254, text) end

function displayStatusMessage(text) displayMessage(MessageModes.Status, text) end

function displayFailureMessage(text) displayMessage(MessageModes.Failure, text) end

function displayGameMessage(text) displayMessage(MessageModes.Game, text) end

function displayBroadcastMessage(text) displayMessage(MessageModes.Warning, text) end

function clearMessages()
    for _i, child in pairs(messagesPanel:recursiveGetChildren()) do
        if child:getId():match('Label') then
            child:hide()
            removeEvent(child.hideEvent)
        end
    end
end

function LocalPlayer:onAutoWalkFail(player) modules.game_textmessage.displayFailureMessage(tr('There is no way.')) end
