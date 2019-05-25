library ZombieAi requires ZombieStrategyPicker, ZombieStatsResearch, ZombieBuild, ZombieAttack, ZombieCreate, ZombieBalancedEconomyStrategy, ZombieTierUpgradesEconomyStrategy, Logging

globals
    //north
    player Zombie1Player = Player(9)
    player Zombie2Player = Player(10)
    player Zombie3Player = Player(11)
    //south
    player Zombie4Player = Player(22)
    player Zombie5Player = Player(23)

    // for new strategies to work ZombieStrategyPicker needs to be updated
    integer array economyStrategies
    integer array combatStrategies

    boolean array aiEnabledForPlayer
    real zombieAiDecisionInterval = 2
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
    
    call ExecuteStep_EconomyStrategy(p, economyStrategies[PIdx(p)])
    call ExecuteStep_AttackStrategy(p, combatStrategies[PIdx(p)])
    call ExecuteStep_ZombieBuildLogic(p)
    call ExecuteStep_ZombieResearchStats(p)

    set p = null
endfunction
function ZombieAi_ExecuteStep takes nothing returns nothing
    call ExecuteStep_CreateNewZombz()
    call IteratePlayers(function ZombieAiEnabledFilter, function ZombieAi_ExecuteStepPerPlayer)
endfunction

function ZombieAiInitializeModules takes nothing returns nothing
    call Init_CreateZombiesLogic()
    call Init_ZombieBuildLogic()
    call Init_ResearchStatsLogic()
    call Init_EconomyStrategy_Balanced()
    call Init_EconomyStrategy_TierUpgrades()
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
    call EnableLog(Player(10), Log_BalanceEcoStrat)
    call EnableLog(Player(10), Log_Stats)
    call EnableLog(Player(10), Log_StrategyPicker)
    call EnableLog(Player(10), Log_TierEcoStrat)
endfunction

endlibrary