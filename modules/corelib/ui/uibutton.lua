-- @docclass
UIButton = extends(UIWidget, 'UIButton')

function UIButton.create()
    local button = UIButton.internalCreate()
    button:setFocusable(false)
    return button
end

function UIButton:onMouseRelease(pos, button)
    local onButtonClickAudio = '/sounds/mouseclick'
    local effectsChannel = nil
    if g_sounds then
        if modules.client_options.getOption('enableSoundEffects') == true then
            effectsChannel = g_sounds.getChannel(SoundChannels.Effect)
            effectsChannel:play(onButtonClickAudio, 1)
        end
    end



    

    return self:isPressed()
end


