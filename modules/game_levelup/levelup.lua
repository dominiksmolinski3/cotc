cacheLevel = 0
firstLogin = true

function init()
	g_ui.importStyle("levelup.otui")
	levelupWindow = g_ui.createWidget("GameLevelupLegacyWindow", modules.game_interface.getMapPanel())
    connect(g_game, {
        onGameStart = online,
        onGameEnd = offline
    })
end

function online()
    connect(LocalPlayer, {
        onLevelChange = onLevelChange,
    })
end

function offline()
	disconnect(LocalPlayer, {
        onLevelChange = onLevelChange,
    })
    firstLogin = true
    cacheLevel = 0
end

function terminate()
	offline()

	if levelupWindow then
		levelupWindow:destroy()
	end

    disconnect(g_game, {
        onGameStart = online,
        onGameEnd = offline
    })
end

function onLevelChange()
	local player = g_game.getLocalPlayer()
    if not player then
        return
    end
    local value = player:getLevel()
    if value > cacheLevel then
		if not firstLogin then
			levelupNotification(value)
		else
			firstLogin = false
		end
    end
    cacheLevel = value

end

function levelupNotification(level)
	if not levelupWindow then return end

    local player = g_game.getLocalPlayer()
    if not player then
        return
    end

    local levelWidget = levelupWindow:getChildById('level')
    if levelWidget then
        levelWidget:setText("Zdobyles " .. tostring(level) .. " Poziom!")
    end

    levelupWindow:show()
    g_game.getLocalPlayer():attachEffect(g_attachedEffects.getById(10))
    g_effects.fadeIn(levelupWindow, 1000)
    player:setShader('Outfit - Outline')
    scheduleEvent(function()
        if levelupWindow then
            g_effects.fadeOut(levelupWindow, 500)
            g_game.getLocalPlayer():detachEffect(g_attachedEffects.getById(10))
            player:setShader('Default')
        end
    end, 3000)
end
