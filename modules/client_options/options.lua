local defaultOptions = {
    vsync = true,
    showFps = true,
    showPing = true,
    fullscreen = false,
    classicControl = true,
    smartWalk = false,
    preciseControl = false,
    autoChaseOverride = true,
    moveStack = false,
    showStatusMessagesInConsole = true,
    showEventMessagesInConsole = true,
    showInfoMessagesInConsole = true,
    showTimestampsInConsole = true,
    showLevelsInConsole = true,
    showPrivateMessagesInConsole = true,
    showPrivateMessagesOnScreen = true,
    showLeftPanel = true,
    showRightExtraPanel = false,
    openMaximized = false,
    backgroundFrameRate = 201,
    enableAudio = true,
    enableMusicSound = true,
    musicSoundVolume = 75,
    enableLights = true,
    limitVisibleDimension = false,
    floatingEffect = false,
    ambientLight = 50,
    displayNames = true,
    displayHealth = true,
    displayMana = true,
    displayText = true,
    dontStretchShrink = false,
    turnDelay = 50,
    hotkeyDelay = 70,
    crosshair = 'default',
    quickLootHotkey = 'SHIFT+Right',
    dynamicFloorViewModeHotkey = 'Ctrl+F',
    enableHighlightMouseTarget = true,
    antialiasingMode = 1,
    shadowFloorIntensity = 30,
    optimizeFps = true,
    forceEffectOptimization = false,
    drawEffectOnTop = false,
    floorViewMode = 1,
    floorFading = 500,
    asyncTxtLoading = false,
    creatureInformationScale = 0,
    staticTextScale = 0,
    animatedTextScale = 0,
    setEffectAlphaScroll = 100,
    setMissileAlphaScroll = 100,
    colorHighlights = {
        { color = "#979797", F = 0, T = 399 },
        { color = "#00D01C", F = 400, T = 999 },
        { color = "#1f9ffe", F = 1000, T = 2499 },
        { color = "#B400D0", F = 2500, T = 4999 },
        { color = "#C9D000", F = 5000, T = 5000000 },
    },
}

local previousMode = nil
local optionsWindow
local optionsButton
local optionsTabBar
local options = {}
local generalPanel
local controlPanel
local consolePanel
local graphicsPanel
local soundPanel
local audioButton
local lootPanel

local crosshairCombobox
local quickLootHotkeyCombobox
local dynamicFloorViewModeHotkeyCombobox
local antialiasingModeCombobox
local floorViewModeCombobox

function loadHighlightingSettings()
    colorHighlights = deserializeColorHighlights(g_settings.get('colorHighlights', colorHighlights))
end

function saveHighlightingSettings()
    colorHighlights = serializeColorHighlights(colorHighlights)
    g_settings.set('colorHighlights', colorHighlights)
end

function clearHighlights()
    colorHighlights = {}
    setupHighlightList()
end

function setupHighlightList()
    local lootHighlightList = lootPanel:recursiveGetChildById('lootHighlightList')

    -- Clear the current list to avoid duplicating entries
    lootHighlightList:destroyChildren()
    -- Iterate over the colorHighlights table and add each highlight to the list
    for _, highlight in ipairs(colorHighlights) do
        local text = string.format("Color: %s, From: %d, To: %d", highlight.color, highlight.F, highlight.T)

        -- Create a new label widget for each highlight option and add it to the lootHighlightList
        local highlightLabel = g_ui.createWidget('lootLabel')
        highlightLabel:setText(text)
        highlightLabel:setMarginLeft(5)
        lootHighlightList:addChild(highlightLabel)
    end
    saveHighlightingSettings()
    loadHighlightingSettings()
end

function defaultHighlights()
    colorHighlights = {
        { color = "#979797", F = 0, T = 399 },
        { color = "#00D01C", F = 400, T = 999 },
        { color = "#1f9ffe", F = 1000, T = 2499 },
        { color = "#B400D0", F = 2500, T = 4999 },
        { color = "#C9D000", F = 5000, T = 5000000 },
    }
    setupHighlightList()
end

function removeHighlightButton()
    local selected = lootPanel:recursiveGetChildById('lootHighlightList'):getFocusedChild()
    if selected then
        local index = selected:getChildIndex()
        table.remove(colorHighlights, index)
        setupHighlightList()
    else
        modules.game_textmessage.displayInfoBox(tr(''), tr('Please select an highlight to remove.'))
    end
end

function convertColorLabelToHex(color)
    if color == '' then
        return nil
    elseif color == "Green" then
        return "#00FF00"
    elseif color == "Red" then
        return "#FF0000"
    elseif color == "Gray" then
        return "#808080"
    elseif color == "Blue" then
        return "#0000FF"
    elseif color == "Black" then
        return "#000000"
    elseif color == "White" then
        return "#FFFFFF"
    elseif color == "Yellow" then
        return "#FFFF00"
    elseif color == "Orange" then
        return "#FFA500"
    elseif color == "Brown" then
        return "#964B00"
    end
end

function addHighlightButton()
    local popupWindow = g_ui.displayUI('popupwindow')

    local fTextEdit = popupWindow:getChildById('fTextEdit')
    local tTextEdit = popupWindow:getChildById('tTextEdit')
    local colorHexTextEdit = popupWindow:getChildById('colorHexTextEdit')
    local colorLabelComboBox = popupWindow:getChildById('colorLabelComboBox')
    colorLabelComboBox:addOption(tr(''), '')
    colorLabelComboBox:addOption(tr('Red'), '#FF0000')
    colorLabelComboBox:addOption(tr('Gray'), '#808080')
    colorLabelComboBox:addOption(tr('Green'), '#00FF00')
    colorLabelComboBox:addOption(tr('Blue'), '#0000FF')
    colorLabelComboBox:addOption(tr('Black'), '#000000')
    colorLabelComboBox:addOption(tr('White'), '#FFFFFF')
    colorLabelComboBox:addOption(tr('Yellow'), '#FFFF00')
    colorLabelComboBox:addOption(tr('Orange'), '#FFA500')
    colorLabelComboBox:addOption(tr('Brown'), '#964B00')

    local addButton = popupWindow:getChildById('addButton')
    addButton.onClick = function()
        local F = tonumber(fTextEdit:getText())
        local T = tonumber(tTextEdit:getText())
        local colorHex = colorHexTextEdit:getText()
        local colorComboBox = colorLabelComboBox:getCurrentOption().text


        if not F or not T or F >= T then
            modules.game_textmessage.displayInfoBox(tr(''), tr('Invalid From and To values or From is not less than To.'))
            return
        end

        -- Check if F and T are within any existing range
        for _, highlight in ipairs(colorHighlights) do
            if not (T < highlight.F or F > highlight.T) then
                modules.game_textmessage.displayInfoBox(tr(''), tr('F and T range overlaps with an existing highlight.'))
                return
            end
        end

        local color = nil

        if (colorHex == "" and colorComboBox == "") or (colorHex ~= "" and colorComboBox ~= "") then
            modules.game_textmessage.displayInfoBox(tr(''), tr('Specify either a Color Hex or select a Color Label, not both or neither.'))
            return
        elseif colorHex ~= "" then
            if not colorHex:match("^#%x%x%x%x%x%x$") then
                modules.game_textmessage.displayInfoBox(tr(''), tr('Invalid hex color.'))
                return
            end
            color = colorHex
        else
            color = convertColorLabelToHex(colorComboBox)
        end

        table.insert(colorHighlights, {color = color, F = F, T = T})

        setupHighlightList()
        popupWindow:destroy()
    end

    local closeButton = popupWindow:getChildById('closeButton')
    closeButton.onClick = function()
        popupWindow:destroy()
    end


end


function toggleFloorViewMode()
    local currentMode = getOption('floorViewMode')
    if currentMode == 2 then
        if previousMode ~= nil then
            setOption('floorViewMode', previousMode)
            previousFloorViewMode = nil -- Reset the previous mode
        end
    else
        previousMode = currentMode
        setOption('floorViewMode', 2)
    end
end

function init()
    for k, v in pairs(defaultOptions) do
        g_settings.setDefault(k, v)
        options[k] = v
    end

    optionsWindow = g_ui.displayUI('options')
    optionsWindow:hide()

    optionsTabBar = optionsWindow:getChildById('optionsTabBar')
    optionsTabBar:setContentWidget(optionsWindow:getChildById('optionsTabContent'))

    g_keyboard.bindKeyDown('Ctrl+Shift+F', function()
        toggleOption('fullscreen')
    end)
    g_keyboard.bindKeyDown('Ctrl+N', toggleDisplays)

    generalPanel = g_ui.loadUI('general')
    optionsTabBar:addTab(tr('General'), generalPanel, '/images/optionstab/game')

    controlPanel = g_ui.loadUI('control')
    optionsTabBar:addTab(tr('Control'), controlPanel, '/images/optionstab/controls')

    consolePanel = g_ui.loadUI('console')
    optionsTabBar:addTab(tr('Console'), consolePanel, '/images/optionstab/console')

    graphicsPanel = g_ui.loadUI('graphics')
    optionsTabBar:addTab(tr('Graphics'), graphicsPanel, '/images/optionstab/graphics')

    soundPanel = g_ui.loadUI('audio')
    optionsTabBar:addTab(tr('Audio'), soundPanel, '/images/optionstab/audio')

    optionsButton = modules.client_topmenu.addLeftButton('optionsButton', tr('Options'), '/images/topbuttons/options',
                                                         toggle)
    audioButton = modules.client_topmenu.addLeftButton('audioButton', tr('Audio'), '/images/topbuttons/audio',
                                                       function()
        toggleOption('enableAudio')
    end)

    -- custom loot
    lootPanel = g_ui.loadUI('loot')
    optionsTabBar:addTab(tr('Loot'), lootPanel, '/images/optionstab/loot')

    addEvent(function()
        setup()
    end)
end

function terminate()
    g_keyboard.unbindKeyDown('Ctrl+N')
    optionsWindow:destroy()
    optionsButton:destroy()
    audioButton:destroy()
    saveHighlightingSettings()
end

function setupComboBox()


    crosshairCombobox = generalPanel:recursiveGetChildById('crosshair')

    crosshairCombobox:addOption(tr('Disabled'), 'disabled')
    crosshairCombobox:addOption(tr('Default'), 'default')
    crosshairCombobox:addOption(tr('Full'), 'full')

    crosshairCombobox.onOptionChange = function(comboBox, option)
        setOption('crosshair', comboBox:getCurrentOption().data)
    end

    quickLootHotkeyCombobox = controlPanel:recursiveGetChildById('quickLootHotkey')

    quickLootHotkeyCombobox:addOption('SHIFT + Right mouse click', 'SHIFT+Right')
    quickLootHotkeyCombobox:addOption('Right mouse click', 'Right')
    quickLootHotkeyCombobox:addOption('Left mouse click', 'Left')

    quickLootHotkeyCombobox.onOptionChange = function(comboBox, option)
        setOption('quickLootHotkey', comboBox:getCurrentOption().data)
    end


    dynamicFloorViewModeHotkeyCombobox = controlPanel:recursiveGetChildById('dynamicFloorViewModeHotkey')

    dynamicFloorViewModeHotkeyCombobox:addOption('CONTROL + F', 'Ctrl+F')
    dynamicFloorViewModeHotkeyCombobox:addOption('CONTROL + Y', 'Ctrl+Y')
    dynamicFloorViewModeHotkeyCombobox:addOption('CONTROL + U', 'Ctrl+U')

    dynamicFloorViewModeHotkeyCombobox.onOptionChange = function(comboBox, option)
        setOption('dynamicFloorViewModeHotkey', comboBox:getCurrentOption().data)
    end


    antialiasingModeCombobox = graphicsPanel:recursiveGetChildById('antialiasingMode')

    antialiasingModeCombobox:addOption('None', 0)
    antialiasingModeCombobox:addOption('Antialiasing', 1)
    antialiasingModeCombobox:addOption('Smooth Retro', 2)

    antialiasingModeCombobox.onOptionChange = function(comboBox, option)
        setOption('antialiasingMode', comboBox:getCurrentOption().data)
    end

    floorViewModeCombobox = graphicsPanel:recursiveGetChildById('floorViewMode')

    floorViewModeCombobox:addOption('Normal', 0)
    floorViewModeCombobox:addOption('Fade', 1)
    floorViewModeCombobox:addOption('Locked', 2)
    floorViewModeCombobox:addOption('Always', 3)
    floorViewModeCombobox:addOption('Always with transparency', 4)

    floorViewModeCombobox.onOptionChange = function(comboBox, option)
        setOption('floorViewMode', comboBox:getCurrentOption().data)
    end
end

function setup()
    setupComboBox()
    loadHighlightingSettings()
    setupHighlightList()
    -- load options
    for k, v in pairs(defaultOptions) do
        if type(v) == 'boolean' then
            setOption(k, g_settings.getBoolean(k), true)
        elseif type(v) == 'number' then
            setOption(k, g_settings.getNumber(k), true)
        elseif type(v) == 'string' then
            setOption(k, g_settings.getString(k), true)
        end
    end
end

function toggle()
    if optionsWindow:isVisible() then
        hide()
    else
        show()
    end
end

function show()
    optionsWindow:show()
    optionsWindow:raise()
    optionsWindow:focus()
end

function hide()
    optionsWindow:hide()
end

function toggleDisplays()
    if options['displayNames'] and options['displayHealth'] and options['displayMana'] then
        setOption('displayNames', false)
    elseif options['displayHealth'] then
        setOption('displayHealth', false)
        setOption('displayMana', false)
    else
        if not options['displayNames'] and not options['displayHealth'] then
            setOption('displayNames', true)
        else
            setOption('displayHealth', true)
            setOption('displayMana', true)
        end
    end
end

function toggleOption(key)
    setOption(key, not getOption(key))
end

function setOption(key, value, force)
    if not force and options[key] == value then
        return
    end

    local gameMapPanel = modules.game_interface.getMapPanel()

    if key == 'vsync' then
        g_window.setVerticalSync(value)
    elseif key == 'showFps' then
        modules.client_topmenu.setFpsVisible(value)
    elseif key == 'optimizeFps' then
        g_app.optimize(value)
    elseif key == 'forceEffectOptimization' then
        g_app.forceEffectOptimization(value)
    elseif key == 'drawEffectOnTop' then
        g_app.setDrawEffectOnTop(value)
    elseif key == 'asyncTxtLoading' then
        if g_game.isUsingProtobuf() then
            value = true
        elseif g_app.isEncrypted() then
            local asyncWidget = graphicsPanel:getChildById('asyncTxtLoading')
            asyncWidget:setEnabled(false)
            asyncWidget:setChecked(false)
            return
        end

        g_app.setLoadingAsyncTexture(value)
    elseif key == 'showPing' then
        modules.client_topmenu.setPingVisible(value)
    elseif key == 'fullscreen' then
        g_window.setFullscreen(value)
    elseif key == 'enableAudio' then
        if g_sounds then
            g_sounds.setAudioEnabled(value)
        end
        if value then
            audioButton:setIcon('/images/topbuttons/audio')
        else
            audioButton:setIcon('/images/topbuttons/audio_mute')
        end
    elseif key == 'enableMusicSound' then
        if g_sounds then
            g_sounds.getChannel(SoundChannels.Music):setEnabled(value)
        end
    elseif key == 'musicSoundVolume' then
        if g_sounds then
            g_sounds.getChannel(SoundChannels.Music):setGain(value / 100)
        end
        soundPanel:getChildById('musicSoundVolumeLabel'):setText(tr('Music volume: %d', value))
    elseif key == 'showLeftPanel' then
        modules.game_interface.getLeftPanel():setOn(value)
    elseif key == 'showRightExtraPanel' then
        modules.game_interface.getRightExtraPanel():setOn(value)
    elseif key == 'backgroundFrameRate' then
        local text, v = value, value
        if value <= 0 or value >= 201 then
            text = 'max'
            v = 201
        end
        graphicsPanel:getChildById('backgroundFrameRateLabel'):setText(tr('Game framerate limit: %s', text))
        g_app.setMaxFps(v)
    elseif key == 'enableLights' then
        gameMapPanel:setDrawLights(value and options['ambientLight'] < 100)
        graphicsPanel:getChildById('ambientLight'):setEnabled(value)
        graphicsPanel:getChildById('ambientLightLabel'):setEnabled(value)
    elseif key == 'ambientLight' then
        graphicsPanel:getChildById('ambientLightLabel'):setText(tr('Ambient light: %s%%', value))
        gameMapPanel:setMinimumAmbientLight(value / 200)
        gameMapPanel:setDrawLights(options['enableLights'])
    elseif key == 'shadowFloorIntensity' then
        graphicsPanel:getChildById('shadowFloorIntensityLevel'):setText(tr('Shadow floor Intensity: %s%%', value))

        local shadowFloorIntensity = (value / 2) + 50

        gameMapPanel:setShadowFloorIntensity(1 - (shadowFloorIntensity  / 100))
    elseif key == 'floorFading' then
        graphicsPanel:getChildById('floorFadingLabel'):setText(tr('Floor Fading: %s ms', value))
        gameMapPanel:setFloorFading(tonumber(value))
    elseif key == 'limitVisibleDimension' then
        gameMapPanel:setLimitVisibleDimension(value)
    elseif key == 'floatingEffect' then
        g_map.setFloatingEffect(value)
    elseif key == 'displayNames' then
        gameMapPanel:setDrawNames(value)
    elseif key == 'displayHealth' then
        gameMapPanel:setDrawHealthBars(value)
    elseif key == 'displayMana' then
        gameMapPanel:setDrawManaBar(value)
    elseif key == 'displayText' then
        g_app.setDrawTexts(value)
    elseif key == 'dontStretchShrink' then
        addEvent(function()
            modules.game_interface.updateStretchShrink()
        end)
    elseif key == 'preciseControl' then
        g_game.setScheduleLastWalk(not value)
    elseif key == 'turnDelay' then
        controlPanel:getChildById('turnDelayLabel'):setText(tr('Turn delay: %sms', value))
    elseif key == 'hotkeyDelay' then
        controlPanel:getChildById('hotkeyDelayLabel'):setText(tr('Hotkey delay: %sms', value))
    elseif key == 'crosshair' then
        local crossPath = '/images/game/crosshair/'
        local newValue = value
        if newValue == 'disabled' then
            newValue = nil
        end
        gameMapPanel:setCrosshairTexture(newValue and crossPath .. newValue or nil)
        crosshairCombobox:setCurrentOptionByData(newValue, true)
    elseif key == 'quickLootHotkey' then
        quickLootHotkeyCombobox:setCurrentOptionByData(value, true)
    elseif key == 'enableHighlightMouseTarget' then
        gameMapPanel:setDrawHighlightTarget(value)
    elseif key == 'floorShadowing' then
        gameMapPanel:setFloorShadowingFlag(value)
        floorShadowingComboBox:setCurrentOptionByData(value, true)
    elseif key == 'antialiasingMode' then
        gameMapPanel:setAntiAliasingMode(value)
        antialiasingModeCombobox:setCurrentOptionByData(value, true)
    elseif key == 'floorViewMode' then
        gameMapPanel:setFloorViewMode(value)
        floorViewModeCombobox:setCurrentOptionByData(value, true)

        local fadeMode = value == 1
        graphicsPanel:getChildById('floorFading'):setEnabled(fadeMode)
        graphicsPanel:getChildById('floorFadingLabel'):setEnabled(fadeMode)
    elseif key == 'setEffectAlphaScroll' then
      g_client.setEffectAlpha(value/100)
      generalPanel:getChildById('setEffectAlphaLabel'):setText(tr('Opacity Effect: %s%%', value))
    elseif key == 'setMissileAlphaScroll' then

      g_client.setMissileAlpha(value/100)
      generalPanel:getChildById('setMissileAlphaLabel'):setText(tr('Opacity Missile: %s%%', value))
    elseif key == 'testserver' then
        modules.client_options.setOption('testServer', value)
    elseif key == 'dynamicFloorViewModeHotkey' then
        dynamicFloorViewModeHotkeyCombobox:setCurrentOptionByData(value, true)
        if dynamicFloorViewModeHotkey then
            g_keyboard.unbindKeyPress(dynamicFloorViewModeHotkey, gameRootPanel)
        end

        g_keyboard.bindKeyPress(value, function()
            toggleFloorViewMode()
        end, gameRootPanel)

        dynamicFloorViewModeHotkey = value
    end


    -- change value for keybind updates
    for _, panel in pairs(optionsTabBar:getTabsPanel()) do
        local widget = panel:recursiveGetChildById(key)
        if widget then
            if widget:getStyle().__class == 'UICheckBox' then
                widget:setChecked(value)
            elseif widget:getStyle().__class == 'UIScrollBar' then
                widget:setValue(value)
            end
            break
        end
    end

    g_settings.set(key, value)
    options[key] = value
end

function getOption(key)
    return options[key]
end

function addTab(name, panel, icon)
    optionsTabBar:addTab(name, panel, icon)
end

function removeTab(v)
    if type(v) == 'string' then
        v = optionsTabBar:getTab(v)
    end

    optionsTabBar:removeTab(v)
end

function addButton(name, func, icon)
    optionsTabBar:addButton(name, func, icon)
end
