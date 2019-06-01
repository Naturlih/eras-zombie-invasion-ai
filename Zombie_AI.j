library ZombieAi requires ZombieStrategyPicker, ZombieStatsResearch, ZombieBuild, ZombieAttack, ZombieCreate, ZombieBalancedEconomyStrategy, ZombieTierUpgradesEconomyStrategy, ModuleUnitsObserver, Logging

globals
    // for new strategies to work ZombieStrategyPicker needs to be updated
    integer array economyStrategies
    integer array combatStrategies

    boolean array aiEnabledForPlayer
    real zombieAiDecisionInterval = 2
    
    integer currentStep = 0
endglobals

function ZombieAiEnabledFilter takes nothing returns boolean
    return aiEnabledForPlayer[PIdx(GetFilterPlayer())]
endfunction

function setDisabledAi takes nothing returns nothing
    set aiEnabledForPlayer[PIdx(GetEnumPlayer())] = false
endfunction
function setEnabledAi takes nothing returns nothing
    set aiEnabledForPlayer[PIdx(GetEnumPlayer())] = true
endfunction
function ZombieAiInitialize takes nothing returns nothing
    call IteratePlayers(function PF_PlayerIsUndead, function setDisabledAi)
    call IteratePlayers(function PF_PlayerIsUndeadComputer, function setEnabledAi)
endfunction

function ZombieAi_ExecuteStepPerPlayer takes nothing returns nothing
    local player p = GetEnumPlayer()
    
    //must be before attack
    //otherwise at start zombuilders wont be created
    call ExecuteStep_ZombieBuildLogic(p)
    call ExecuteStep_EconomyStrategy(p, economyStrategies[PIdx(p)])
    call ExecuteStep_AttackStrategy(p, combatStrategies[PIdx(p)])
    call ExecuteStep_ZombieResearchStats(p)

    set p = null
endfunction
function ZombieAi_ExecuteStep takes nothing returns nothing
    call IteratePlayers(function ZombieAiEnabledFilter, function ZombieAi_ExecuteStepPerPlayer)
endfunction

function ZombieAiInitializeModules takes nothing returns nothing
    call Init_Module_UnitsObserver()
    call Init_Module_UnitCreate()
    call Init_Module_Build()
    call Init_ResearchStatsLogic()
    call Init_EconomyStrategy_Balanced()
    call Init_EconomyStrategy_TierUpgrades()
    call Init_AttackStrategy_Dumb()
endfunction

function ZombieAiInitializeStrategies takes nothing returns nothing
    set economyStrategies[PIdx(Zombie1Player)] = BalancedEconomyStrategyId
    set combatStrategies[PIdx(Zombie1Player)] = DumbAttackStrategyId
    
    set economyStrategies[PIdx(Zombie2Player)] = TierUpgradeEconomyStrategyId
    set combatStrategies[PIdx(Zombie2Player)] = DumbAttackStrategyId
    
    set economyStrategies[PIdx(Zombie3Player)] = BalancedEconomyStrategyId
    set combatStrategies[PIdx(Zombie3Player)] = DumbAttackStrategyId
    
    set economyStrategies[PIdx(Zombie4Player)] = BalancedEconomyStrategyId
    set combatStrategies[PIdx(Zombie4Player)] = DumbAttackStrategyId
    
    set economyStrategies[PIdx(Zombie5Player)] = BalancedEconomyStrategyId
    set combatStrategies[PIdx(Zombie5Player)] = DumbAttackStrategyId
endfunction

//======================================================================
function ZombieAiRegisterTrigger takes nothing returns nothing
    local trigger trg = CreateTrigger()
    
    call TriggerRegisterTimerEventPeriodic( trg, zombieAiDecisionInterval )
    call TriggerAddAction( trg, function ZombieAi_ExecuteStep )
    
    set trg = null
endfunction

function StartZombieAi takes nothing returns nothing
    call Init_TimeCounter()
    call ZombieAiInitialize()
    call ZombieAiInitializeStrategies()
    call ZombieAiInitializeModules()
    call ZombieAiRegisterTrigger()
    
    //Logging
    //call EnableLog(Zombie2Player, Log_BalanceEcoStrat)
    //call EnableLog(Player(10), Log_Stats)
    //call EnableLog(Player(10), Log_StrategyPicker)
    //call EnableLog(Player(10), Log_TierEcoStrat)
    //call EnableLog(Player(10), Log_UnitCreate)
    //call EnableLog(Player(10), Log_AttackDumb)
endfunction

endlibrary