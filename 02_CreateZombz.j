library ZombieCreate requires Common

globals
    hashtable zombieAiCreateZombH
    integer ExpectedWorkerCountKey = 0
    integer TotalNormalZombiesKey = 1
endglobals

function GetUnitCountForCurrentPlayer takes integer unitKey returns integer
    return LoadInteger(zombieAiCreateZombH, Unit_GetPlayerNumber(), unitKey)
endfunction
function IncrementUnitCountForCurrentPlayer takes integer unitKey returns nothing
    call SaveInteger(zombieAiCreateZombH, Unit_GetPlayerNumber(), unitKey, GetUnitCountForCurrentPlayer(unitKey) + 1)
endfunction

//////////////////////////////////////////////////////
//////////////// CREATING ZOMBIES ////////////////////
//////////////////////////////////////////////////////

function Filter_UnitIsFleshPileOfComputerPlayerWithoutOrders takes nothing returns boolean
    return UF_UnitIsFleshPile() and UF_ComputerIsTheOwner() and UF_NoOrders()
endfunction
function GetFleshPilesUnderComputerWithoutOrders takes group grp returns nothing
    local boolexpr filter = Condition(function Filter_UnitIsFleshPileOfComputerPlayerWithoutOrders)
    
    call GroupEnumUnitsInRect(grp, GetPlayableMapRect(), filter)
    
    call DestroyBoolExpr(filter)
    set filter = null
endfunction

function AddZombieCreationTask takes nothing returns nothing
    if GetUnitCountForCurrentPlayer(zombieAiZombuilder) < 3 then
        call IssueTrainOrderByIdBJ( GetEnumUnit(), zombieAiZombuilder )
        call IncrementUnitCountForCurrentPlayer(zombieAiZombuilder)
    else
        call IssueTrainOrderByIdBJ( GetEnumUnit(), zombieAiZombieLvl1 )
        call IssueTrainOrderByIdBJ( GetEnumUnit(), zombieAiZombieLvl2 )
        call IssueTrainOrderByIdBJ( GetEnumUnit(), zombieAiZombieLvl3 )
        call IssueTrainOrderByIdBJ( GetEnumUnit(), zombieAiZombieLvl4 )
        call IssueTrainOrderByIdBJ( GetEnumUnit(), zombieAiZombieLvl5 )
    endif
endfunction

function CreateNewZombzAction takes nothing returns nothing
    local group piles = CreateGroup()
    
    call GetFleshPilesUnderComputerWithoutOrders(piles)
    call ForGroup(piles, function AddZombieCreationTask)
    
    call DestroyGroup(piles)
    set piles = null
endfunction

function InitTrig_CreateNewZombiesDecision takes nothing returns nothing
    local trigger createNewZombzTrg = CreateTrigger()
    
    call TriggerRegisterTimerEventPeriodic(createNewZombzTrg, zombieAiDecisionInterval)
    call TriggerAddAction(createNewZombzTrg, function CreateNewZombzAction)
    
    set createNewZombzTrg = null
endfunction

//////////////////////////////////////////////////////
//////////////// COUNTING UNITS //////////////////////
//////////////////////////////////////////////////////

function TriggeringUnitOwnedByComputerUndead takes nothing returns boolean
    return (GetPlayerController(GetOwningPlayer(GetTriggerUnit())) == MAP_CONTROL_COMPUTER) and ((GetOwningPlayer(GetTriggerUnit())) == RACE_UNDEAD)
endfunction

function DecrementZombieCount takes nothing returns nothing
    local integer triggerUnitTypeId = GetUnitTypeId(GetTriggerUnit())
    
    call SaveInteger(zombieAiCreateZombH, Unit_GetPlayerNumber(), triggerUnitTypeId, GetUnitCountForCurrentPlayer(triggerUnitTypeId) - 1)
endfunction

function InitTrig_RegisterExpectedZombieCountOnEvent takes nothing returns nothing
    local trigger updateZombieCountOnUnitDeath = CreateTrigger()
    
    call TriggerRegisterAnyUnitEventBJ(updateZombieCountOnUnitDeath, EVENT_PLAYER_UNIT_DEATH )
    call TriggerAddCondition( updateZombieCountOnUnitDeath, Condition(function TriggeringUnitOwnedByComputerUndead))
    call TriggerAddAction( updateZombieCountOnUnitDeath, function DecrementZombieCount )
    
    set updateZombieCountOnUnitDeath = null
endfunction

////////////////////////////////////////////////////
//////////////// GLOBALS INIT //////////////////////
////////////////////////////////////////////////////

function ZombieAiNewZombzInitGlobals takes nothing returns nothing
    local force zombForce = CreateForce()
    
    call InitHashtableBJ()
    set zombieAiCreateZombH = GetLastCreatedHashtableBJ()
    call GetZombieAiPlayers(zombForce)
    
    call DestroyForce(zombForce)
    set zombForce = null
endfunction


//////////////////////////////////////////////////////
//////////////// TRIGGERS INIT ///////////////////////
//////////////////////////////////////////////////////

function InitTrig_CreateNewZombz takes nothing returns nothing
    call ZombieAiNewZombzInitGlobals()
    call InitTrig_CreateNewZombiesDecision()
    call InitTrig_RegisterExpectedZombieCountOnEvent()
endfunction

endlibrary