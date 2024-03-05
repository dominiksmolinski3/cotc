skillsWindow = nil
skillsButton = nil
skillsSettings = nil
g_bonusSkill = {0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}

function init()
    connect(LocalPlayer, {
        onExperienceChange = onExperienceChange,
        onLevelChange = onLevelChange,
        onHealthChange = onHealthChange,
        onManaChange = onManaChange,
        onSoulChange = onSoulChange,
        onLearningPointsChange = onLearningPointsChange,
        onMagCircleChange = onMagCircleChange,
        onKarmaChange = onKarmaChange,
        onSneakChange = onSneakChange,
        onPickLocksChange = onPickLocksChange,
        onPickpocketChange = onPickpocketChange,
        onCreateRunesChange = onCreateRunesChange,
        onAlchemyChange = onAlchemyChange,
        onForgeWeaponsChange = onForgeWeaponsChange,
        onTakeTrophiesChange = onTakeTrophiesChange,
        onFireDamageReductionChange = onFireDamageReductionChange,
        onMagicDamageReductionChange = onMagicDamageReductionChange,
        onPhysicalDamageReductionChange = onPhysicalDamageReductionChange,

        onCriticalAttackHitChange = onCriticalAttackHitChange,
        onCriticalAttackDamageChange = onCriticalAttackDamageChange,

        onCriticalMagicHitChange = onCriticalMagicHitChange,
        onCriticalMagicDamageChange = onCriticalMagicDamageChange,

        onFreeCapacityChange = onFreeCapacityChange,
        onTotalCapacityChange = onTotalCapacityChange,
        onStaminaChange = onStaminaChange,
        onGreenStaminaChange = onGreenStaminaChange,
        onIsGreenStaminaActiveChange = onIsGreenStaminaActiveChange,
        onXpBoostChange = onXpBoostChange,
        onOfflineTrainingChange = onOfflineTrainingChange,
        -- onRegenerationChange = onRegenerationChange,
        onSpeedChange = onSpeedChange,
        onBaseSpeedChange = onBaseSpeedChange,
        onMagicLevelChange = onMagicLevelChange,
        onBaseMagicLevelChange = onBaseMagicLevelChange,
        onBonusMagicLevelChange = onBonusMagicLevelChange,
        onSkillChange = onSkillChange,
        onBonusSkillChange = onBonusSkillChange,
        onNpcSkillChange = onNpcSkillChange,
        onBaseSkillChange = onBaseSkillChange,
        onBonusManaChange = onBonusManaChange,
        onBaseMaxManaChange = onBaseMaxManaChange,

        onBonusHealthChange = onBonusHealthChange,
        onHealthFromEquipmentChange = onHealthFromEquipmentChange,
        onFoodRegenChange = onFoodRegenChange,

    })
    connect(g_game, {
        onGameStart = online,
        onGameEnd = offline
    })

    skillsButton = modules.client_topmenu.addRightGameToggleButton('skillsButton', tr('Skills') .. ' (Alt+S)',
                                                                   '/images/topbuttons/skills', toggle)
    skillsButton:setOn(true)
    skillsWindow = g_ui.loadUI('skills')

    g_keyboard.bindKeyDown('Alt+S', toggle)

    skillSettings = g_settings.getNode('skills-hide')
    if not skillSettings then
        skillSettings = {}
    end



    refresh() 

    skillsWindow:setup()
    if g_game.isOnline() then
        skillsWindow:setupOnStart()
    end

end

function terminate()
    disconnect(LocalPlayer, {
        onExperienceChange = onExperienceChange,
        onLevelChange = onLevelChange,
        onHealthChange = onHealthChange,
        onManaChange = onManaChange,
        onSoulChange = onSoulChange,
        onLearningPointsChange = onLearningPointsChange,
        onMagCircleChange = onMagCircleChange,
        onKarmaChange = onKarmaChange,
        onSneakChange = onSneakChange,
        onPickLocksChange = onPickLocksChange,
        onPickpocketChange = onPickpocketChange,
        onCreateRunesChange = onCreateRunesChange,
        onAlchemyChange = onAlchemyChange,
        onForgeWeaponsChange = onForgeWeaponsChange,
        onTakeTrophiesChange = onTakeTrophiesChange,
        onFireDamageReductionChange = onFireDamageReductionChange,
        onMagicDamageReductionChange = onMagicDamageReductionChange,
        onPhysicalDamageReductionChange = onPhysicalDamageReductionChange,

        onCriticalAttackHitChange = onCriticalAttackHitChange,
        onCriticalAttackDamageChange = onCriticalAttackDamageChange,

        onCriticalMagicHitChange = onCriticalMagicHitChange,
        onCriticalMagicDamageChange = onCriticalMagicDamageChange,

        onFreeCapacityChange = onFreeCapacityChange,
        onTotalCapacityChange = onTotalCapacityChange,
        onStaminaChange = onStaminaChange,
        onGreenStaminaChange = onGreenStaminaChange,
        -- onIsGreenStaminaActiveChange = onIsGreenStaminaActiveChange,
        onXpBoostChange = onXpBoostChange,
        onOfflineTrainingChange = onOfflineTrainingChange,
        -- onRegenerationChange = onRegenerationChange,
        onSpeedChange = onSpeedChange,
        onBaseSpeedChange = onBaseSpeedChange,
        onMagicLevelChange = onMagicLevelChange,
        onBaseMagicLevelChange = onBaseMagicLevelChange,
        onBonusMagicLevelChange = onBonusMagicLevelChange,
        onSkillChange = onSkillChange,
        onBonusSkillChange = onBonusSkillChange,
        onNpcSkillChange = onNpcSkillChange,
        onBaseSkillChange = onBaseSkillChange,
        onBonusManaChange = onBonusManaChange,
        onBaseMaxManaChange = onBaseMaxManaChange,

        onBonusHealthChange = onBonusHealthChange,
        onHealthFromEquipmentChange = onHealthFromEquipmentChange,
        onFoodRegenChange = onFoodRegenChange,

    })
    disconnect(g_game, {
        onGameStart = online,
        onGameEnd = offline
    })

    g_keyboard.unbindKeyDown('Alt+S')
    skillsWindow:destroy()
    skillsButton:destroy()

    skillsWindow = nil
    skillsButton = nil
end

function expForLevel(level)
    return math.floor((50 * level * level * level) / 3 - 100 * level * level + (850 * level) / 3 - 200)
end

function expToAdvance(currentLevel, currentExp)
    return expForLevel(currentLevel + 1) - currentExp
end

function resetSkillColor(id)
    local skill = skillsWindow:recursiveGetChildById(id)
    local widget = skill:getChildById('value')
    widget:setColor('#bbbbbb')
end

function toggleSkill(id, state)
    local skill = skillsWindow:recursiveGetChildById(id)
    skill:setVisible(state)
end

function setSkillBase(id, value, baseValue, bonusValue, loyalityBonus, npcValue)
  if id == nil then
    return
  end

  if ignoredSkill(id) == false then
    if (baseValue <= 0 and loyalityBonus == 0) or (value < 0 and bonusValue == 0 and loyalityBonus == 0) then
      return
    end

    if not bonusValue then
      bonusValue = 0
    end

    if not baseValue then
      baseValue = 0
    end

    if not loyalityBonus then
      loyalityBonus = 0
    end

    if not npcValue then
      npcValue = 0
    end

    local skill = skillsWindow:recursiveGetChildById(id)
    local widget = skill:getChildById('value')

    local num = tonumber(string.match(id, "%d+"))

    if id == 'magiclevel' then
      bonusValue = 0

      if npcValue >= 10 then
        npcValue = npcValue - 10
      end
    end

    if num ~= nil then
      local newValue = value

      if npcValue > 0 then
        newValue = value - 10
      end

      if isCombatSkill(id) then
        newValue = newValue + bonusValue
      end

      setSkillValue(id, getSkillRank(num, newValue))
    else
      setSkillValue(id, value)
    end

    if ((value - loyalityBonus) == baseValue) and bonusValue == 0 and loyalityBonus == 0 then
      skill:removeTooltip()
      widget:setColor('#bbbbbb') -- default
    else
      value = value - npcValue
      local equipmentBonus = value - baseValue - loyalityBonus
      local basicSkill = baseValue

      if not isCombatSkill(id) then
        basicSkill = basicSkill - bonusValue
      else
        -- print("basicSkill: " .. basicSkill)
      end

      local hasAnyBonus = false
      local basicSkillText = ""
      local permamentBonusesText = ""
      local equipmentBonusText = ""
      local loyalityBonusText = ""
      local npcValueText = ""
      local fixedValue = value

      if npcValue > 0 and id ~= 'magiclevel' then
        fixedValue = fixedValue + npcValue - 10
        basicSkill = basicSkill - 10
      end

      if isCombatSkill(id) then
        fixedValue = fixedValue + bonusValue
      end

      if id == 'magiclevel' then
        fixedValue = value + npcValue
      end

      local tooltip = fixedValue .. " ="

      if baseValue > loyalityBonus then
        baseValue = baseValue - loyalityBonus
      end



      basicSkillText = " " .. basicSkill .. " (" .. tr("basic") .. ")"

      if bonusValue > 0 then
        permamentBonusesText = " + " .. (bonusValue ) .. " (" .. tr("bonuses") .. ")"
        hasAnyBonus = true
      end

      if equipmentBonus > 0 then
        equipmentBonusText = " + " .. equipmentBonus .. " (" .. tr("equipment") .. ")"
        hasAnyBonus = true
      end

      if loyalityBonus > 0 then
        loyalityBonusText = " + " .. loyalityBonus .. " (" .. tr("loyalty") .. ")"
        hasAnyBonus = true
      end

      if npcValue > 0 then
        npcValueText = " + " .. npcValue .. " (" .. tr("learnt") .. ")"
        hasAnyBonus = true
      end

      if hasAnyBonus then
        tooltip = tooltip .. basicSkillText
      end

      tooltip = tooltip .. npcValueText
      tooltip = tooltip .. permamentBonusesText
      tooltip = tooltip .. equipmentBonusText
      tooltip = tooltip .. loyalityBonusText


      if value > baseValue then
        widget:setColor('#008b00') -- green
      elseif value < baseValue then
        widget:setColor('#b22222') -- red
      else
        widget:setColor('#bbbbbb') -- default
      end

      if equipmentBonus == 0 then
        widget:setColor('#bbbbbb') -- default
      end

      skill:setTooltip(tooltip)
    end

  end
end

function setSkillValue(id, value)
  if ignoredSkill(id) == false then

    local skill = skillsWindow:recursiveGetChildById(id)
    if skill then
        local widget = skill:getChildById('value')
        widget:setText(value)
    end
  end
end

function setSkillColor(id, value)
    local skill = skillsWindow:recursiveGetChildById(id)
    if skill then
        local widget = skill:getChildById('value')
        widget:setColor(value)
    end
end

function setSkillTooltip(id, value)
    local skill = skillsWindow:recursiveGetChildById(id)
    if skill then
        local widget = skill:getChildById('value')
        widget:setTooltip(value)
    end
end

function setSkillPercent(id, percent, tooltip, color)
  if ignoredSkill(id) == false then
    local skill = skillsWindow:recursiveGetChildById(id)
    if skill then
        local widget = skill:getChildById('percent')
        if widget then
            widget:setPercent(math.floor(percent))

            if tooltip then
                widget:setTooltip(tooltip)
            end

            if color then
                widget:setBackgroundColor(color)
            end
        end
    end
  end
end

function checkAlert(id, value, maxValue, threshold, greaterThan)
    if greaterThan == nil then
        greaterThan = false
    end
    local alert = false

    -- maxValue can be set to false to check value and threshold
    -- used for regeneration checking
    if type(maxValue) == 'boolean' then
        if maxValue then
            return
        end

        if greaterThan then
            if value > threshold then
                alert = true
            end
        else
            if value < threshold then
                alert = true
            end
        end
    elseif type(maxValue) == 'number' then
        if maxValue < 0 then
            return
        end

        local percent = math.floor((value / maxValue) * 100)
        if greaterThan then
            if percent > threshold then
                alert = true
            end
        else
            if percent < threshold then
                alert = true
            end
        end
    end

    if alert then
        setSkillColor(id, '#b22222') -- red
    else
        resetSkillColor(id)
    end
end

function update()
    -- local offlineTraining =
    --     skillsWindow:recursiveGetChildById('offlineTraining')
    -- if not g_game.getFeature(GameOfflineTrainingTime) then
    --     offlineTraining:hide()
    -- else
    --     offlineTraining:show()
    -- end

    -- local regenerationTime = skillsWindow:recursiveGetChildById(
    --                              'regenerationTime')
    -- if not g_game.getFeature(GamePlayerRegenerationTime) then
    --     regenerationTime:hide()
    -- else
    --     regenerationTime:show()
    -- end
end

function online()
    skillsWindow:setupOnStart() -- load character window configuration
    refresh()
end

function refresh()
    local player = g_game.getLocalPlayer()
    if not player then
        return
    end

    if expSpeedEvent then
        expSpeedEvent:cancel()
    end
    expSpeedEvent = cycleEvent(checkExpSpeed, 30 * 1000)
    addEvent(updateRates, 1000)

    onExperienceChange(player, player:getExperience())
    onLevelChange(player, player:getLevel(), player:getLevelPercent())
    onHealthChange(player, player:getHealth(), player:getMaxHealth())
    onManaChange(player, player:getMana(), player:getMaxMana())
    onSoulChange(player, player:getSoul())
    onLearningPointsChange(player, player:getLearningPoints())
    onMagCircleChange(player, player:getMagCircle())
    onKarmaChange(player, player:getKarma())
    onSneakChange(player, player:getSneak())
    onPickLocksChange(player, player:getPickLocks())
    onPickpocketChange(player, player:getPickpocket())
    onCreateRunesChange(player, player:getCreateRunes())
    onAlchemyChange(player, player:getAlchemy())
    onForgeWeaponsChange(player, player:getForgeWeapons())
    onTakeTrophiesChange(player, player:getTakeTrophies())
    onFireDamageReductionChange(player, player:getFireDamageReduction())
    onMagicDamageReductionChange(player, player:getMagicDamageReduction())
    onPhysicalDamageReductionChange(player, player:getPhysicalDamageReduction())

    onCriticalAttackHitChange(player, player:getCriticalAttackHit())
    onCriticalAttackDamageChange(player, player:getCriticalAttackDamage())
    onCriticalMagicHitChange(player, player:getCriticalMagicHit())
    onCriticalMagicDamageChange(player, player:getCriticalMagicDamage())

    onFreeCapacityChange(player, player:getFreeCapacity())
    onStaminaChange(player, player:getStamina())
    onGreenStaminaChange(player, player:getGreenStamina(), player:isGreenStaminaActive())
    -- onIsGreenStaminaActiveChange(player, player:isGreenStaminaActive())
    onMagicLevelChange(player, player:getMagicLevel(), player:getMagicLevelPercent())
    onOfflineTrainingChange(player, player:getOfflineTrainingTime())
    onXpBoostChange(player, player:getXpBoost(), player:getBaseXpGainRate(), player:getXpBoostInMinutes(), player:getPreyBoostInMinutes())
    -- onRegenerationChange(player, player:getRegenerationTime())
    onSpeedChange(player, player:getSpeed())
    onBonusManaChange(player, player:getBonusMana(), player:getNpcMana())
    onBaseMaxManaChange(player, player:getBaseMaxMana())

    onBonusHealthChange(player, player:getBonusHealth())
    onHealthFromEquipmentChange(player, player:getHealthFromEquipment())
    onFoodRegenChange(player, player:getFoodTicks(), player:getHpTicks(), player:getMpTicks())

    local hasAdditionalSkills = g_game.getFeature(GameAdditionalSkills)
    for i = Skill.Fist, Skill.Mining do
      if i ~= Skill.Shielding then
        onBonusSkillChange(player, i, player:getSkillBonusLevel(i))
        onBaseSkillChange(player, i, player:getSkillBaseLevel(i))
        onNpcSkillChange(player, i, player:getSkillNpcLevel(i))
        onSkillChange(player, i, player:getSkillLevel(i), player:getSkillLevelPercent(i))


        -- if i > Skill.Fishing and i ~=  then
        --     toggleSkill('skillId' .. i, hasAdditionalSkills)
        -- end
      end
    end

    update()
    updateHeight()

end

function updateHeight()
    local maximumHeight = 8 -- margin top and bottom

    if g_game.isOnline() then
        local char = g_game.getCharacterName()

        if not skillSettings[char] then
            skillSettings[char] = {}
        end

        local skillsButtons = skillsWindow:recursiveGetChildById('experience'):getParent():getChildren()

        for _, skillButton in pairs(skillsButtons) do
            local percentBar = skillButton:getChildById('percent')

            if skillButton:isVisible() then
                if percentBar then
                    showPercentBar(skillButton, skillSettings[char][skillButton:getId()] ~= 1)
                end
                maximumHeight = maximumHeight + skillButton:getHeight() + skillButton:getMarginBottom()
            end
        end
    else
        maximumHeight = 390
    end

    maximumHeight = maximumHeight + 25

    local contentsPanel = skillsWindow:getChildById('contentsPanel')
    skillsWindow:setContentMinimumHeight(44)
    skillsWindow:setContentMaximumHeight(maximumHeight)
end

function offline()
    skillsWindow:setParent(nil, true)
    if expSpeedEvent then
        expSpeedEvent:cancel()
        expSpeedEvent = nil
    end
    g_settings.setNode('skills-hide', skillSettings)
end

function toggle()
    if skillsButton:isOn() then
        skillsWindow:close()
        skillsButton:setOn(false)
    else
        skillsWindow:open()
        skillsButton:setOn(true)
        updateHeight()
    end
end

function updateRates()
  local player = g_game.getLocalPlayer()

  if player then
    onXpBoostChange(player, player:getXpBoost(), player:getBaseXpGainRate(), player:getXpBoostInMinutes(), player:getPreyBoostInMinutes())
    onStaminaChange(player, player:getStamina())
    onGreenStaminaChange(player, player:getGreenStamina(), player:isGreenStaminaActive())
  end

end

function checkExpSpeed()
    local player = g_game.getLocalPlayer()
    if not player then
        return
    end

    local currentExp = player:getExperience()
    local currentTime = g_clock.seconds()
    if player.lastExps ~= nil then
        player.expSpeed = (currentExp - player.lastExps[1][1]) / (currentTime - player.lastExps[1][2])
        onLevelChange(player, player:getLevel(), player:getLevelPercent())
    else
        player.lastExps = {}
    end
    table.insert(player.lastExps, {currentExp, currentTime})
    if #player.lastExps > 30 then
        table.remove(player.lastExps, 1)
    end
end

function onMiniWindowOpen()
    skillsButton:setOn(true)
end

function onMiniWindowClose()
    skillsButton:setOn(false)
end

function onSkillButtonClick(button)
    local percentBar = button:getChildById('percent')
    if percentBar then
        showPercentBar(button, not percentBar:isVisible())

        local char = g_game.getCharacterName()
        if percentBar:isVisible() then
            skillsWindow:modifyMaximumHeight(6)
            skillSettings[char][button:getId()] = 0
        else
            skillsWindow:modifyMaximumHeight(-6)
            skillSettings[char][button:getId()] = 1
        end
    end
end

function showPercentBar(button, show)
    local percentBar = button:getChildById('percent')
    if percentBar then
        percentBar:setVisible(show)
        if show then
            button:setHeight(21)
        else
            button:setHeight(21 - 6)
        end
    end
end

function onExperienceChange(localPlayer, value)
    setSkillValue('experience', comma_value(value))
end

function onLevelChange(localPlayer, value, percent)
    setSkillValue('level', comma_value(value))
    local text = tr('You have %s percent to go', 100 - percent) .. '\n' ..
                     tr('%s of experience left', expToAdvance(localPlayer:getLevel(), localPlayer:getExperience()))

    if localPlayer.expSpeed ~= nil then
        local expPerHour = math.floor(localPlayer.expSpeed * 3600)
        if expPerHour > 0 then
            local nextLevelExp = expForLevel(localPlayer:getLevel() + 1)
            local hoursLeft = (nextLevelExp - localPlayer:getExperience()) / expPerHour
            local minutesLeft = math.floor((hoursLeft - math.floor(hoursLeft)) * 60)
            hoursLeft = math.floor(hoursLeft)
            text = text .. '\n' .. tr('%s of experience per hour', comma_value(expPerHour))
            text = text .. '\n' .. tr('Next level in %d hours and %d minutes', hoursLeft, minutesLeft)
        end
    end

    setSkillPercent('level', percent, text)
end

function onHealthChange(localPlayer, health, maxHealth)
    --setSkillValue('health', comma_value(health))
    onBonusHealthChange(localPlayer, localPlayer:getBonusHealth())
    onHealthFromEquipmentChange(localPlayer, localPlayer:getHealthFromEquipment())
    --checkAlert('health', health, maxHealth, 30)
end

function onManaChange(localPlayer, mana, maxMana)
  onBaseMaxManaChange(localPlayer, localPlayer:getBaseMaxMana())
  onBonusManaChange(localPlayer, localPlayer:getBonusMana(), localPlayer:getNpcMana())
    --setSkillValue('mana', comma_value(mana))
    --checkAlert('mana', mana, maxMana, 30)
end

function onSoulChange(localPlayer, soul) setSkillValue('soul', comma_value(soul)) end

function onLearningPointsChange(localPlayer, learningPoints)
  setSkillValue('learningPoints', learningPoints)
end

function onMagCircleChange(localPlayer, magCircle)
  setSkillValue('magCircle',  magCircle)
end

function onKarmaChange(localPlayer, karma)
  setSkillValue('karma',  karma .. "%")
  local karmaWidget = skillsWindow:recursiveGetChildById("karma")

  if karma == 100 then
    setSkillColor('karma', '#008b00')
  else
    setSkillColor('karma', '#bbbbbb')
  end

  if karmaWidget then
    karmaWidget:setTooltip(tr("100%% karma protects you by a special blessing in the event of death caused by another player,\n provided that you are not aggressive towards others."))
  end
end

function onSneakChange(localPlayer, value)
setSkillValue('sneak',  specialSkillValue(value))
end

function onPickLocksChange(localPlayer, value)
  setSkillValue('pickLocks',  specialSkillValue(value))
end

function onPickpocketChange(localPlayer, value)
  setSkillValue('pickpocket',  specialSkillValue(value))
end

function onCreateRunesChange(localPlayer, value)
  setSkillValue('createRunes',  specialSkillValue(value))
end

function onAlchemyChange(localPlayer, value)
  setSkillValue('alchemy',  specialSkillValue(value))
end

function onForgeWeaponsChange(localPlayer, value)
  setSkillValue('forgeWeapons',  specialSkillValue(value))
end

function onTakeTrophiesChange(localPlayer, value)
  setSkillValue('takeTrophies',  specialSkillValue(value))
end

function onFireDamageReductionChange(localPlayer, value)

  if value > 0 then
    value = "+" .. value
    setSkillColor('fireDamageReduction', '#008b00')
  else
    resetSkillColor('fireDamageReduction')
  end

  setSkillValue('fireDamageReduction', value .. "%", "gfdgfd", 'red')
  setSkillTooltip('fireDamageReduction', 'dsfdsfds')

end

function onMagicDamageReductionChange(localPlayer, value)
  if value > 0 then
    value = "+" .. value
    setSkillColor('magicDamageReduction', '#008b00')
  else
    resetSkillColor('magicDamageReduction')
  end

  setSkillValue('magicDamageReduction', value .. "%", "gfdgfd", 'red')
  setSkillTooltip('magicDamageReduction', 'dsfdsfds')
end

function onPhysicalDamageReductionChange(localPlayer, value)
  if value > 0 then
    value = "+" .. value
    setSkillColor('physicalDamageReduction', '#008b00')
  else
    resetSkillColor('physicalDamageReduction')
  end

  setSkillValue('physicalDamageReduction', value .. "%", "gfdgfd", 'red')
  setSkillTooltip('physicalDamageReduction', 'dsfdsfds')
end

function onCriticalAttackHitChange(localPlayer, value)
  if value > 0 then
    value = "+" .. value
    setSkillColor('criticalAttackHit', '#008b00')
  else
    resetSkillColor('criticalAttackHit')
  end

  setSkillValue('criticalAttackHit', value .. "%", "gfdgfd", 'red')
  setSkillTooltip('criticalAttackHit', 'dsfdsfds')
end

function onCriticalAttackDamageChange(localPlayer, value)
  if value > 0 then
    value = "+" .. value
    setSkillColor('criticalAttackDamage', '#008b00')
  else
    resetSkillColor('criticalAttackDamage')
  end

  setSkillValue('criticalAttackDamage', value .. "%", "gfdgfd", 'red')
  setSkillTooltip('criticalAttackDamage', 'dsfdsfds')
end

function onCriticalMagicHitChange(localPlayer, value)
  if value > 0 then
    value = "+" .. value
    setSkillColor('criticalMagicHit', '#008b00')
  else
    resetSkillColor('criticalMagicHit')
  end

  setSkillValue('criticalMagicHit', value .. "%", "gfdgfd", 'red')
  setSkillTooltip('criticalMagicHit', 'dsfdsfds')
end

function onCriticalMagicDamageChange(localPlayer, value)
  if value > 0 then
    value = "+" .. value
    setSkillColor('criticalMagicDamage', '#008b00')
  else
    resetSkillColor('criticalMagicDamage')
  end

  setSkillValue('criticalMagicDamage', value .. "%", "gfdgfd", 'red')
  setSkillTooltip('criticalMagicDamage', 'dsfdsfds')
end

function onFreeCapacityChange(localPlayer, freeCapacity)
    setSkillValue('capacity', comma_value(freeCapacity))
    checkAlert('capacity', freeCapacity, localPlayer:getTotalCapacity(), 20)
end

function onTotalCapacityChange(localPlayer, totalCapacity)
    checkAlert('capacity', localPlayer:getFreeCapacity(), totalCapacity, 20)
end

local function formatMinutesToHours(totalMinutes)
  local hours = math.floor(totalMinutes / 60)
  local minutes = totalMinutes % 60

  return string.format("%02d:%02d h", hours, minutes)
end

function onXpBoostChange(localPlayer, xpBoost, baseXpGainRate, xpBoostInMinutes, preyBoostInMinutes)
  local exp = xpBoost
  local staminaMinutes = localPlayer:getStamina()
  local greenStaminaMinutes = localPlayer:getGreenStamina()
  local isGreenStaminaActive = localPlayer:isGreenStaminaActive()
  local xpGainRateElement = skillsWindow:recursiveGetChildById("xpGainRate")

  if staminaMinutes <= 840 then
    exp = exp * 0.5
  end

  if isGreenStaminaActive and greenStaminaMinutes > 0 then
    exp = exp * 1.5
  end

  local tooltip = tr("Your current XP gain rate amounts to ") .. exp .. "%"
  tooltip = tooltip ..  "\n" .. tr("Your XP Gain rate is calculated as follows:")
  tooltip = tooltip ..  "\n" .. tr("Base XP gain rate: 100%%")

  if xpBoostInMinutes and xpBoostInMinutes > 0 then
    tooltip = tooltip ..  "\n" .. tr("XP Boost: +50%% (") .. formatMinutesToHours(xpBoostInMinutes) ..  tr(" remaining)")
  end


  if preyBoostInMinutes and preyBoostInMinutes > 0 then
    tooltip = tooltip ..  "\n" .. tr("Innos Prey XP Boost: +12%% (") .. formatMinutesToHours(preyBoostInMinutes) ..  tr(" remaining)")
  end

  if baseXpGainRate and baseXpGainRate < 100 then -- below 14h
    tooltip = tooltip ..  "\n" .. tr("Stage XP Gain Rate: x0.") .. baseXpGainRate
  end

  if staminaMinutes and staminaMinutes <= 840 then -- below 14h
    tooltip = tooltip ..  "\n" .. tr("Low Stamina penatly: x0.5 (below 14 hours)")
  end

  if greenStaminaMinutes > 0 and isGreenStaminaActive == true then -- below 14h
    tooltip = tooltip ..  "\n" .. tr("Bonus Stamina: x1.5 (") .. formatMinutesToHours(greenStaminaMinutes) ..  tr(" remaining)")
  end


  if exp > 50 then
    setSkillColor('xpGainRate', '#008b00')
  elseif exp < 50 then
    setSkillColor('xpGainRate', '#b22222')
  else
    resetSkillColor('xpGainRate')
  end

  setSkillValue('xpGainRate', exp .. "%", "gfdgfd", 'red')
  if tooltip ~= "" then
    xpGainRateElement:setTooltip(tooltip)
  end

end

function onDamageReductionChange(localPlayer, value)

end

function onStaminaChange(localPlayer, stamina)
    local hours = math.floor(stamina / 60)
    local minutes = stamina % 60
    if minutes < 10 then
        minutes = '0' .. minutes
    end
    local percent = math.floor(100 * stamina / (42 * 60)) -- max is 42 hours --TODO not in all client versions

    setSkillValue('stamina', hours .. ':' .. minutes)

    -- TODO not all client versions have premium time
    if stamina >= 2520 then
        local text = tr('You have %s hours and %s minutes left', hours, minutes)
        setSkillPercent('stamina', percent, text, 'green')
    elseif stamina < 2520 and stamina > 840 then
        setSkillPercent('stamina', percent, tr('You have %s hours and %s minutes left', hours, minutes), 'orange')
    elseif stamina <= 840 and stamina > 0 then
        local text = tr('You have %s hours and %s minutes left', hours, minutes) .. '\n' ..
                         tr('You gain only 50%% experience and you don\'t may gain loot from monsters')
        setSkillPercent('stamina', percent, text, 'red')
    elseif stamina == 0 then
        local text = tr('You have %s hours and %s minutes left', hours, minutes) .. '\n' ..
                         tr('You don\'t may receive experience and loot from monsters')
        setSkillPercent('stamina', percent, text, 'black')
    end
end

function onOfflineTrainingChange(localPlayer, offlineTrainingTime)
    if not g_game.getFeature(GameOfflineTrainingTime) then
        return
    end
    local hours = math.floor(offlineTrainingTime / 60)
    local minutes = offlineTrainingTime % 60
    if minutes < 10 then
        minutes = '0' .. minutes
    end
    local percent = math.floor(100 * offlineTrainingTime / (12 * 60)) -- max is 12 hours
    local color = 'green'

    if offlineTrainingTime < 240 then
      color = 'orange'
    end

    setSkillValue('offlineTraining', hours .. ':' .. minutes)
    setSkillPercent('offlineTraining', percent, tr('You have %s percent', percent), color)
end

function onGreenStaminaChange(localPlayer, greenStamina, isGreenStaminaActive)
    local hours = math.floor(greenStamina / 60)
    local minutes = greenStamina % 60
    if minutes < 10 then
        minutes = '0' .. minutes
    end


    local color = 'green'

    local percent = math.floor(100 * greenStamina / (2 * 60)) -- max is 2 hours

    setSkillValue('greenStamina', hours .. ':' .. minutes)
    local text = tr('You have %s hours and %s minutes left', hours, minutes) .. '\n' ..
                     tr('Now you will gain 50%% more experience')

    if greenStamina == 0 or isGreenStaminaActive == false then
      text = tr('You have %s hours and %s minutes left', hours, minutes)
    end

    if greenStamina == 0 then
      color = 'black'
    end

    if isGreenStaminaActive == false then
      color = 'orange'
    end


    setSkillPercent('greenStamina', percent, text, color)

    onXpBoostChange(localPlayer, localPlayer:getXpBoost(), localPlayer:getBaseXpGainRate(), localPlayer:getXpBoostInMinutes(), localPlayer:getPreyBoostInMinutes())
end

function onRegenerationChange(localPlayer, regenerationTime)
    if not g_game.getFeature(GamePlayerRegenerationTime) or regenerationTime < 0 then
        return
    end
    local minutes = math.floor(regenerationTime / 60)
    local seconds = regenerationTime % 60
    if seconds < 10 then
        seconds = '0' .. seconds
    end

    setSkillValue('regenerationTime', minutes .. ':' .. seconds)
    checkAlert('regenerationTime', regenerationTime, false, 300)
end

function onSpeedChange(localPlayer, speed)
    setSkillValue('speed', comma_value(speed))

    onBaseSpeedChange(localPlayer, localPlayer:getBaseSpeed())
end

function onBaseSpeedChange(localPlayer, baseSpeed)
    setSkillBase('speed', localPlayer:getSpeed(), baseSpeed, 0)
end

function onMagicLevelChange(localPlayer, magiclevel, percent)
    setSkillValue('magiclevel', getMagicLevelRank(magiclevel))
    setSkillPercent('magiclevel', percent, tr('You have %s percent to go', 100 - percent))
    onBaseMagicLevelChange(localPlayer, localPlayer:getBaseMagicLevel())
end

function onBaseMagicLevelChange(localPlayer, baseMagicLevel)
    setSkillBase('magiclevel', localPlayer:getMagicLevel(), baseMagicLevel, 0, localPlayer:getLoyality())
end

function onBonusMagicLevelChange(localPlayer, npcMagicLevel, bonusMagicLevel)
    setSkillBase('magiclevel', localPlayer:getMagicLevel(), localPlayer:getBaseMagicLevel(), bonusMagicLevel, localPlayer:getLoyality(), npcMagicLevel)
end

function onSkillChange(localPlayer, id, level, percent)
    if ignoredSkill(id) == false then

      onBaseSkillChange(localPlayer, id, localPlayer:getSkillBaseLevel(id))
      onBonusSkillChange(localPlayer, id, localPlayer:getSkillBonusLevel(id))
      onNpcSkillChange(localPlayer, id, localPlayer:getSkillNpcLevel(id))

      -- setSkillValue('skillId' .. id, getSkillRank(id,level, localPlayer:getSkillNpcLevel(id)))
      setSkillPercent('skillId' .. id, percent,
                      tr('You have %s percent to go', 100 - percent))

  end
end

function onBaseSkillChange(localPlayer, id, baseLevel, old_skill)
    if ignoredSkill(id) == false then
      setSkillBase('magiclevel', localPlayer:getMagicLevel(), localPlayer:getBaseMagicLevel(), 0, localPlayer:getLoyality())
      onBonusSkillChange(localPlayer, id, localPlayer:getSkillBonusLevel(id))
    end
end
--
function onBonusSkillChange(localPlayer, id, bonusSkill)
  if ignoredSkill(id) == false then
    setSkillBase('skillId' .. id, localPlayer:getSkillLevel(id), localPlayer:getSkillBaseLevel(id), bonusSkill, localPlayer:getLoyality())
    setSkillBase('magiclevel', localPlayer:getMagicLevel(), localPlayer:getBaseMagicLevel(), localPlayer:getBonusMagicLevel(), localPlayer:getLoyality(), localPlayer:getNpcMagicLevel())
  end
end

function onNpcSkillChange(localPlayer, id, bonusSkill)
  if ignoredSkill(id) == false then
    setSkillBase('skillId' .. id, localPlayer:getSkillLevel(id), localPlayer:getSkillBaseLevel(id), localPlayer:getSkillBonusLevel(id), localPlayer:getLoyality(), bonusSkill)
  end
end

function onBonusManaChange(localPlayer, bonusMana, npcMana)
  onBaseMaxManaChange(localPlayer, localPlayer:getBaseMaxMana())
end

function onBonusHealthChange(localPlayer, bonusHealth)
  onHealthFromEquipmentChange(localPlayer, localPlayer:getHealthFromEquipment())
end

function onFoodRegenChange(localPlayer, foodTicks, hpTicks, mpTicks)
    local ticksLimit = 5

    if localPlayer:isPremium() then
      ticksLimit = 8
    end

    skillsWindow:recursiveGetChildById("hpTicks"):getChildById('value'):setText(hpTicks .. " (" .. foodTicks .. "/" .. ticksLimit .. ")")
    skillsWindow:recursiveGetChildById("mpTicks"):getChildById('value'):setText(mpTicks .. " (" .. foodTicks .. "/" .. ticksLimit .. ")")
end

function onHealthFromEquipmentChange(localPlayer, healthFromEquipment)
  local health = localPlayer:getHealth()
  local maxHealth = localPlayer:getMaxHealth()
  local bonusHealth = localPlayer:getBonusHealth()

  setSkillValue('health', comma_value(health))

  if not healthFromEquipment then
    healthFromEquipment = 0
  end

  local skill = skillsWindow:recursiveGetChildById("health")
  local widget = skill:getChildById('value')

  widget:setColor('#bbbbbb') -- default

  if healthFromEquipment > 0 then
    widget:setColor('#008b00') -- green
  end

  if bonusHealth > 0 or healthFromEquipment > 0 then
    local tooltip = maxHealth .. " (" .. tr("total hit points") .. ") ="

    local hasAnyBonus = false
    local permamentBonusesText = ""
    local equipmentBonusesText = ""

    basicHealthText = " " .. (maxHealth - bonusHealth - healthFromEquipment) .. " (" .. tr("basic") .. ")"

    if bonusHealth > 0 then
      permamentBonusesText = " + " .. bonusHealth .. " (" .. tr("bonuses") .. ")"
      hasAnyBonus = true
    end

    if healthFromEquipment > 0 then
      equipmentBonusesText = " +" .. healthFromEquipment .. " (" .. tr("equipment") .. ")"
      hasAnyBonus = true
    end

    if hasAnyBonus then
      tooltip = tooltip .. basicHealthText
    end

    tooltip = tooltip .. permamentBonusesText
    tooltip = tooltip .. equipmentBonusesText

    skill:setTooltip(tooltip)
  else
    skill:removeTooltip()
  end

end

function onBaseMaxManaChange(localPlayer, baseMaxMana)
  local mana = localPlayer:getMana()
  local maxMana = localPlayer:getMaxMana()
  local bonusMana = localPlayer:getBonusMana()
  local npcMana = localPlayer:getNpcMana()

  -- print("mana: " .. mana)
  -- print("maxMana: " .. maxMana)
  -- print("bonusMana: " .. bonusMana)
  -- print("npcMana: " .. npcMana)

  setSkillValue('mana', comma_value(mana))

  if not baseMaxMana then
    baseMaxMana = 0
  end

  local skill = skillsWindow:recursiveGetChildById("mana")
  local widget = skill:getChildById('value')

  widget:setColor('#bbbbbb') -- default

  if maxMana ~= baseMaxMana then
    widget:setColor('#008b00') -- green
  end

  if bonusMana > 0 or maxMana ~= baseMaxMana then
    local tooltip = maxMana .. " (" .. tr("total mana") .. ") ="

    local hasAnyBonus = false
    local permamentBonusesText = ""
    local equipmentBonusesText = ""
    local npcManaBonusesText = ""
    local basicManaText = ""
    local equipmentMana = maxMana - baseMaxMana

    if equipmentMana > 0 then
      widget:setColor('#008b00') -- green
    end

    basicManaText = " " .. (maxMana - bonusMana - equipmentMana - npcMana) .. " (" .. tr("basic") .. ")"
    if bonusMana > 0 then
      permamentBonusesText = " + " .. bonusMana .. " (" .. tr("bonuses") .. ")"
      hasAnyBonus = true
    end

    if equipmentMana > 0 then
      equipmentBonusesText = " +" .. equipmentMana .. " (" .. tr("equipment") .. ")"
      hasAnyBonus = true
    end

    if npcMana > 0 then
      npcManaBonusesText = " +" .. npcMana .. " (" .. tr("learnt") .. ")"
      hasAnyBonus = true
    end

    if hasAnyBonus then
      tooltip = tooltip .. basicManaText
    end

    tooltip = tooltip .. npcManaBonusesText
    tooltip = tooltip .. permamentBonusesText
    tooltip = tooltip .. equipmentBonusesText

    skill:setTooltip(tooltip)
  else
    skill:removeTooltip()
  end


end

function getSkillRank(id, value)
  if specialSkill(id) == true then
    if value and value > 0 then
      return tr('Learned')
    else
      return "-"
    end
  end

  id = tonumber(string.match(id, "%d+"))

  if id > 7 or id < 2 then
    return value
  end

  result = tr('Rookie')
  local space = "%4d"

  if value < 30 then
    if id == 7 then
      result = tr('Beachman')
    else
      result = tr('Rookie')
    end
  elseif value >= 30 and value < 60 then
    if id == 4 or id == 6 then -- bow/crossbow
      result = tr('Marksman')
    elseif id == 7 then
      result = tr('Fisherman')
    else
      result = tr('Fighter')
    end
  elseif value >= 60 and value < 90 and id == 7 then
    result = tr('Pearl Digger')
  elseif value >= 90 and id == 7 then
    result = tr('King of the Sea')
    space = "%3d"
  elseif value >= 60 and value < 160 and id ~= 7 then
    result = tr('Master')
  else
    if id ~= 7 then
    result = tr('Grandmaster')
    space = "%3d"
    end
  end

  return string.format(result .. space, value)
end

function ignoredSkill(id)
  return inArray(id,
    { "skillId5", "skillId12", "skillId13", "skillId14", "skillId15", "skillId16", "skillId17", "regenerationTime" }
  )
end

function inArray(id, elements)
  for i=1, #elements do
    if elements[i] == id then
       return true
     end
  end

  return false
end

function specialSkill(id)
  return inArray(id,
    { "sneak", "pickLocks", "pickpocket", "createRunes", "alchemy", "forgeWeapons", "takeTrophies" }
  )
end

function isCombatSkill(id)
  return inArray(id, { "skillId2", "skillId3", "skillId4", "skillId5", "skillId6" })
end

function specialSkillValue(value)
  if not value then
    print(value .. " is not here, smth is wrong")
  end

  if value and value > 0 then
    return tr("Learned")
  else
    return "-"
  end
end

function getMagicLevelRank(value)
  if not value or value == -1 then
    value = 0
  end

  local result = ""

  if value < 10 then
    result = tr('Adept')
  elseif value >= 30 and value < 60 then
    result = tr('Master')
  else
    result = tr('Priest')
  end

  return string.format(result .. "%3d", value)
end
