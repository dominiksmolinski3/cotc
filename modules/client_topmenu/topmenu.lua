-- private variables
local topMenu
local leftButtonsPanel
local rightButtonsPanel
local leftGameButtonsPanel
local rightGameButtonsPanel

local lastSyncValue = -1
local fpsEvent = nil
local fpsMin = -1;
local fpsMax = -1;

-- private functions
local function addButton(id, description, icon, callback, panel, toggle, front)
    local class
    if toggle then
        class = 'TopToggleButton'
    else
        class = 'TopButton'
    end

    local button = panel:getChildById(id)
    if not button then
        button = g_ui.createWidget(class)
        if front then
            panel:insertChild(1, button)
        else
            panel:addChild(button)
        end
    end
    button:setId(id)
    button:setTooltip(description)
    button:setIcon(resolvepath(icon, 3))
    button.onMouseRelease = function(widget, mousePos, mouseButton)
        local onButtonClickAudio = '/sounds/mouseclick'
        local effectsChannel = nil
        if g_sounds then
            if modules.client_options.getOption('enableSoundEffects') == true then
                effectsChannel = g_sounds.getChannel(SoundChannels.Effect)
                effectsChannel:play(onButtonClickAudio, 1)
            end
        end
        if widget:containsPoint(mousePos) and mouseButton ~= MouseMidButton then
            callback()
            return true
        end
    end
    return button
end

-- public functions
function init()
    connect(g_game, {
        onGameStart = online,
        onGameEnd = offline,
        onPingBack = updatePing
    })
    connect(g_app, {
        onFps = updateFps
    })

    topMenu = g_ui.displayUI('topmenu')

    leftButtonsPanel = topMenu:getChildById('leftButtonsPanel')
    rightButtonsPanel = topMenu:getChildById('rightButtonsPanel')
    leftGameButtonsPanel = topMenu:getChildById('leftGameButtonsPanel')
    rightGameButtonsPanel = topMenu:getChildById('rightGameButtonsPanel')
    pingLabel = topMenu:getChildById('pingLabel')
    fpsLabel = topMenu:getChildById('fpsLabel')
    gothaniaLabel = topMenu:getChildById('clickLabel')

    g_keyboard.bindKeyDown('Ctrl+Shift+T', toggle)
    if g_game.isOnline() then
        online()
    end
end

function terminate()
    disconnect(g_game, {
        onGameStart = online,
        onGameEnd = offline,
        onPingBack = updatePing
    })
    disconnect(g_app, {
        onFps = updateFps
    })
    topMenu:destroy()
end

function online()
    showGameButtons()
    if not modules.client_options.getOption('hideGothaniaLabelInGame') then
        gothaniaLabel:show()
    end
    addEvent(function()
        if modules.client_options.getOption('showPing') and
            (g_game.getFeature(GameClientPing) or g_game.getFeature(GameExtendedClientPing)) then
            pingLabel:show()
        else
            pingLabel:hide()
        end
    end)
end

function offline()
    hideGameButtons()
    pingLabel:hide()
    gothaniaLabel:hide()
    fpsMin = -1
end

function updateFps(fps)
    if not fpsLabel:isVisible() then
        return
    end

    text = 'FPS: ' .. fps

    if g_game.isOnline() then
        local vsync = modules.client_options.getOption('vsync')
        if fpsEvent == nil and lastSyncValue ~= vsync then
            fpsEvent = scheduleEvent(function()
                fpsMin = -1
                lastSyncValue = vsync
                fpsEvent = nil
            end, 2000)
        end

        if fpsMin == -1 then
            fpsMin = fps
            fpsMax = fps
        end

        if fps > fpsMax then
            fpsMax = fps
        end

        if fps < fpsMin then
            fpsMin = fps
        end

        local midFps = math.floor((fpsMin + fpsMax) / 2)
        fpsLabel:setTooltip('Min: ' .. fpsMin .. '\nMid: ' .. midFps .. '\nMax: ' .. fpsMax)
    else
        fpsLabel:removeTooltip()
    end

    fpsLabel:setText(text)
end

function updatePing(ping)
    if not pingLabel:isVisible() then
        return
    end

    local text = 'Ping: '
    local color
    if ping < 0 then
        text = text .. '??'
        color = 'yellow'
    else
        text = text .. ping .. ' ms'
        if ping >= 500 then
            color = 'red'
        elseif ping >= 250 then
            color = 'yellow'
        else
            color = 'green'
        end
    end
    pingLabel:setColor(color)
    pingLabel:setText(text)
end

function setPingVisible(enable)
    pingLabel:setVisible(enable)
end

function setFpsVisible(enable)
    fpsLabel:setVisible(enable)
end

function addLeftButton(id, description, icon, callback, front)
    return addButton(id, description, icon, callback, leftButtonsPanel, false, front)
end

function addLeftToggleButton(id, description, icon, callback, front)
    return addButton(id, description, icon, callback, leftButtonsPanel, true, front)
end

function addRightButton(id, description, icon, callback, front)
    return addButton(id, description, icon, callback, rightButtonsPanel, false, front)
end

function addRightToggleButton(id, description, icon, callback, front)
    return addButton(id, description, icon, callback, rightButtonsPanel, true, front)
end

function addLeftGameButton(id, description, icon, callback, front)
    return addButton(id, description, icon, callback, leftGameButtonsPanel, false, front)
end

function addLeftGameToggleButton(id, description, icon, callback, front)
    return addButton(id, description, icon, callback, leftGameButtonsPanel, true, front)
end

function addRightGameButton(id, description, icon, callback, front)
    return addButton(id, description, icon, callback, rightGameButtonsPanel, false, front)
end

function addRightGameToggleButton(id, description, icon, callback, front)
    return addButton(id, description, icon, callback, rightGameButtonsPanel, true, front)
end

function showGameButtons()
    leftGameButtonsPanel:show()
    rightGameButtonsPanel:show()
end

function hideGameButtons()
    leftGameButtonsPanel:hide()
    rightGameButtonsPanel:hide()
end

function hideGothaniaLabel()
    gothaniaLabel:hide()
end

function showGothaniaLabel()
    gothaniaLabel:show()
end

function getButton(id)
    return topMenu:recursiveGetChildById(id)
end

function getTopMenu()
    return topMenu
end

function toggle()
    local menu = getTopMenu()
    if not menu then
        return
    end

    if menu:isVisible() then
        menu:hide()
        modules.client_background.getBackground():addAnchor(AnchorTop, 'parent', AnchorTop)
        modules.game_interface.getRootPanel():addAnchor(AnchorTop, 'parent', AnchorTop)
        modules.game_interface.getShowTopMenuButton():show()
    else
        menu:show()
        modules.client_background.getBackground():addAnchor(AnchorTop, 'topMenu', AnchorBottom)
        modules.game_interface.getRootPanel():addAnchor(AnchorTop, 'topMenu', AnchorBottom)
        modules.game_interface.getShowTopMenuButton():hide()
    end
end
