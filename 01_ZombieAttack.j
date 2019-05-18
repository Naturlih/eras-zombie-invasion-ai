library ZombieAttack requires Common
globals
    location currentTarget
endglobals

function FilterHumanBuilding takes nothing returns boolean
    return UF_Structure() and UF_OwnerIsHuman()
endfunction

function FilterCombatZombiesWithoutOrders takes nothing returns boolean
    return UF_NoOrders() and not UF_Structure() and UF_ComputerIsTheOwner() and UF_PlayerIsUndead() and not UF_UnitType(zombieAiZombuilder)
endfunction

function TriggerAttackAtCurrentPoint takes nothing returns nothing
    call IssuePointOrderLoc( GetEnumUnit(), "attack", currentTarget )
endfunction

function AttackOrderForIdleZombzAction takes nothing returns nothing
    local location targetBuildingToAttack = null
    local boolexpr filter = null
    local group humanBuildings = CreateGroup()
    local group currentAttackGroup = CreateGroup()
    
    set filter = Condition(function FilterHumanBuilding)
    call GroupEnumUnitsInRect(humanBuildings, GetPlayableMapRect(), filter)
    call DestroyBoolExpr(filter)
    call ForGroup(humanBuildings, function GroupPickRandomUnitEnum)
    set currentTarget = GetUnitLoc(bj_groupRandomCurrentPick)
    
    set filter = Condition(function FilterCombatZombiesWithoutOrders)
    call GroupEnumUnitsInRect(currentAttackGroup, GetPlayableMapRect(), filter)
    call DestroyBoolExpr(filter)
    call ForGroup(currentAttackGroup, function TriggerAttackAtCurrentPoint )

    call DestroyGroup(humanBuildings)
    call DestroyGroup(currentAttackGroup)
    call RemoveLocation(currentTarget)
    set targetBuildingToAttack = null
    set filter = null
    set humanBuildings = null
    set currentAttackGroup = null
endfunction

function InitTrig_AttackByIdleUnits takes nothing returns nothing
    local trigger trg = CreateTrigger()
    
    call TriggerRegisterTimerEventPeriodic( trg, zombieAiDecisionInterval )
    call TriggerAddAction( trg, function AttackOrderForIdleZombzAction )
    
    set trg = null
endfunction

//===========================================================================
function InitTrig_AttackLogic takes nothing returns nothing
    call InitTrig_AttackByIdleUnits()
endfunction

endlibrary
