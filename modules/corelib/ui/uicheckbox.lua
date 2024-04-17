-- @docclass
UICheckBox = extends(UIWidget, 'UICheckBox')

function UICheckBox.create()
    local checkbox = UICheckBox.internalCreate()
    checkbox:setFocusable(false)
    checkbox:setTextAlign(AlignLeft)
    return checkbox
end

function UICheckBox:onClick()
    self:setChecked(not self:isChecked())
    local onButtonClickAudio = '/sounds/mouseclick'
    local effectsChannel = nil
    if g_sounds then
        if modules.client_options.getOption('enableSoundEffects') == true then
            effectsChannel = g_sounds.getChannel(SoundChannels.Effect)
            effectsChannel:play(onButtonClickAudio, 1)
        end
    end
end
