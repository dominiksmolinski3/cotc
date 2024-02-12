function init()
    connect(g_game, {
        onGameStart = online,
        onGameEnd = offline
    })
end

function terminate()
    disconnect(g_game, {
        onGameStart = online,
        onGameEnd = offline
    })

end

function toggleMount()
    local player = g_game.getLocalPlayer()
    if player then player:toggleMount() end
end

function mount()
    local player = g_game.getLocalPlayer()
    if player then player:mount() end
end

function dismount()
    local player = g_game.getLocalPlayer()
    if player then player:dismount() end
end
