library ZombieAi requires ZombieStatsResearch, ZombieBuild, ZombieAttack, ZombieCreate, ZombieIncomeStrategy, Logging

globals
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
    local boolean asddas = false

    call ExecuteStep_EconomyStrategy(p)
    call ExecuteStep_ZombieBuildLogic(p)
    call ExecuteStep_ZombieResearchStats(p)
    
    set p = null
endfunction
function ZombieAi_ExecuteStep takes nothing returns nothing
    call ExecuteStep_CreateNewZombz()
    //call ExecuteStep_ZombieAttack()
    call IteratePlayers(function ZombieAiEnabledFilter, function ZombieAi_ExecuteStepPerPlayer)
endfunction

function ZombieAiInitializeModules takes nothing returns nothing
    call Init_CreateZombiesLogic()
    call Init_ZombieBuildLogic()
    call Init_ResearchStatsLogic()
    call Init_EconomyStrategy()
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
    call ZombieAiInitializeModules()
    call ZombieAiRegisterTrigger()
    
    //Logging
    call EnableLog(Player(10), Log_BalanceEcoStrat)
    call EnableLog(Player(10), Log_Stats)
endfunction

endlibrary