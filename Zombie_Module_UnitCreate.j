library ZombieCreate requires Common, Logging

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
    //TODO
        //call IssueTrainOrderByIdBJ( GetEnumUnit(), zombieAiZombieLvl1 )
        call IssueTrainOrderByIdBJ( GetEnumUnit(), zombieAiZombieLvl2 )
        call IssueTrainOrderByIdBJ( GetEnumUnit(), zombieAiZombieLvl3 )
        call IssueTrainOrderByIdBJ( GetEnumUnit(), zombieAiZombieLvl4 )
        call IssueTrainOrderByIdBJ( GetEnumUnit(), zombieAiZombieLvl5 )
    endif
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


///////////////////////////////////////////////
//////////////// PUBLIC ///////////////////////
///////////////////////////////////////////////

function Init_CreateZombiesLogic takes nothing returns nothing
    local trigger updateZombieCountOnUnitDeath = CreateTrigger()
    
    call ZombieAiNewZombzInitGlobals() // TODO
    call TriggerRegisterAnyUnitEventBJ(updateZombieCountOnUnitDeath, EVENT_PLAYER_UNIT_DEATH )
    call TriggerAddCondition( updateZombieCountOnUnitDeath, Condition(function TriggeringUnitOwnedByComputerUndead))
    call TriggerAddAction( updateZombieCountOnUnitDeath, function DecrementZombieCount )
    
    set updateZombieCountOnUnitDeath = null
endfunction

function ExecuteStep_CreateNewZombz takes nothing returns nothing
    local group piles = CreateGroup()
    
    call GetFleshPilesUnderComputerWithoutOrders(piles)
    call ForGroup(piles, function AddZombieCreationTask)
    
    call DestroyGroup(piles)
    set piles = null
endfunction

endlibrary