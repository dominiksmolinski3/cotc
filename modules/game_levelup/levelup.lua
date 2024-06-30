cacheLevel = 0
firstLogin = true

function init()
	g_ui.importStyle("levelup.otui")
	levelupWindow = g_ui.createWidget("GameLevelupLegacyWindow", modules.game_interface.getMapPanel())
	levelupWindow.onDragEnter = onDragEnter
	levelupWindow.onDragMove = onDragMove
	levelupWindow:show()

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

    local levelWidget = levelupWindow:getChildById('level')
    if levelWidget then
        levelWidget:setText(tostring(level))
    end


    g_effects.fadeIn(levelupWindow, 1000)
    
	print("showing levelup")
    scheduleEvent(function()
        if levelupWindow then
            g_effects.fadeOut(levelupWindow, 600)
        end
    end, 3000)
end

function onDragEnter(self, mousePos)

	local oldPos = self:getPosition()

	self.movingReference = {
		x = mousePos.x - oldPos.x,
		y = mousePos.y - oldPos.y
	}

	self:setPosition(oldPos)
	self:breakAnchors()

	return true
end

function onDragMove(self, mousePos, mouseMoved)
	local pos = {
		x = mousePos.x - self.movingReference.x,
		y = mousePos.y - self.movingReference.y
	}
	print("SS")
	self:setPosition(pos)
	self:bindRectToParent()
end
