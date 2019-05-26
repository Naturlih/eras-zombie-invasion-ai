library ZombieTierUpgradesEconomyStrategy requires Common, ZombieStatsResearch, ZombieBuild, Logging

globals
    integer NoTierUpgradeNeeded = -1
    integer BigIncomeSeconds = 900
    
    integer array zombieAiTierUpgrades
    integer zombieAiT2Upgrade = 'R00Z'
    integer zombieAiT3Upgrade = 'R00B'
    integer zombieAiT4Upgrade = 'R00H'
    integer zombieAiT5Upgrade = 'R00V'
endglobals

function GetRequiredTierUpgradeIfAny takes nothing returns integer
    if (CurrentZombieTier() < 2) and (GetSecondsSinceStart() >= BigIncomeSeconds) then
        return 2
    elseif (CurrentZombieTier() < 3) and (GetSecondsSinceStart() >= BigIncomeSeconds * 2) then
        return 3
    elseif (CurrentZombieTier() < 4) and (GetSecondsSinceStart() >= BigIncomeSeconds * 3) then
        return 4
    elseif (CurrentZombieTier() < 5) and (GetSecondsSinceStart() >= BigIncomeSeconds * 4) then
        return 5
    endif
    return NoTierUpgradeNeeded
endfunction
    
function Init_EconomyStrategy_TierUpgrades takes nothing returns nothing
    set zombieAiTierUpgrades[2] = zombieAiT2Upgrade
    set zombieAiTierUpgrades[3] = zombieAiT3Upgrade
    set zombieAiTierUpgrades[4] = zombieAiT4Upgrade
    set zombieAiTierUpgrades[5] = zombieAiT5Upgrade
    // do nothing
endfunction

function ExecuteStep_EconomyStrategy_TierUpgrades takes player p returns nothing
    local unit necrovolver = null
    local integer tierUpgrade = GetRequiredTierUpgradeIfAny()
    local integer tierUpgradeAbilityId = zombieAiTierUpgrades[tierUpgrade]
    
    if tierUpgrade != NoTierUpgradeNeeded then
        call Log(p, Log_TierEcoStrat, "tier " + I2S(tierUpgrade) + " has been requested")
        set necrovolver = GetNecrovolver(p)
        if necrovolver != null then
            call Log(p, Log_TierEcoStrat, "got necrovolver " + GetUnitName(necrovolver) + ", tier to upgrade " + I2S(tierUpgrade) + " " + I2S(tierUpgradeAbilityId) + " " + GetObjectName(tierUpgradeAbilityId))
            if IssueImmediateOrderById(necrovolver, tierUpgradeAbilityId) then
                call Log(p, Log_TierEcoStrat, "submitted " + GetObjectName(tierUpgradeAbilityId))
            endif
        endif
    else
        call Log(p, Log_TierEcoStrat, "going balanced eco")
        call ExecuteStep_EconomyStrategy_Balanced(p)
    endif
    set necrovolver = null
endfunction

endlibrary