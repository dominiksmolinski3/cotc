gothicSkillsWindow = nil
gothiSkillsButton = nil
gothicSkillsSettings = nil
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

    --gothicSkillsButton = modules.client_topmenu.addLeftGameToggleButton('gothicSkillsButton', tr('Gothic Skills') .. ' (Alt+C)',
    --'/images/topbuttons/skills', toggle)

    --gothicSkillsWindow = g_ui.loadUI('gothic', modules.game_interface.getRootPanel())
    g_keyboard.bindKeyDown('Alt+C', toggle)

end

function toggle()
    if gothicSkillsButton:isOn() then
        gothicSkillsWindow:close()       
        gothicSkillsButton:setOn(false)
    else
        gothicSkillsWindow:open()
        gothicSkillsButton:setOn(true)
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
end