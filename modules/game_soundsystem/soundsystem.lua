local musicFilename = '/sounds/startup'
local musicChannel = nil
if g_sounds then
    musicChannel = g_sounds.getChannel(SoundChannels.Music)
end

function setMusic(musicfilename, channelid)
    musicfilename = filename
    channelid = Ambient
    if g_sounds then
        if channelid == Ambient then
            ambientChannel = g_sounds.getChannel(SoundChannels.Ambient)
        elseif channelid == Effects then
            effectsChannel = g_sounds.getChannel(SoundChannels.Effects)
        elseif channelid == Music then
            musicChannel = g_sounds.getChannel(SoundChannels.Music)
        end
    end

    if not g_game.isOnline() then
        musicChannel:stop()
        musicChannel:enqueue(musicFilename, 3)
    end
end

modules.client_options.getOption('musicSoundVolume')

if modules.client_options.getOption('enableMusicSound')

enableAudio
g_sounds.stopAll()