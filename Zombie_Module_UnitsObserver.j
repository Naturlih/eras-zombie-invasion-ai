library ModuleUnitsObserver requires Common, Logging

globals
    group array pilesByPlayer
    integer tmp_unitCountByFilter
    integer tmp_unitTypeForFilter
endglobals

function ForGroupCountUnitsInGroupByTypeId takes nothing returns nothing
    if GetUnitTypeId(GetEnumUnit()) == tmp_unitTypeForFilter then
        set tmp_unitCountByFilter = tmp_unitCountByFilter + 1
    endif
endfunction

function PileFilter takes nothing returns boolean
    return GetUnitTypeId(GetTriggerUnit()) == zombieAiFleshPile
endfunction
function AddPileOnCreationByTrigger takes nothing returns nothing
    call GroupAddUnit(pilesByPlayer[PIdx(GetOwningPlayer(GetConstructingStructure()))], GetConstructingStructure())
endfunction
function RemovePileOnDeath takes nothing returns nothing
    call GroupRemoveUnit(pilesByPlayer[PIdx(GetOwningPlayer(GetTriggerUnit()))], GetTriggerUnit())
endfunction
function InitPileCountingTriggers takes nothing returns nothing
    local trigger AddPileOnCreationTrg = CreateTrigger()
    local trigger removePileOnDeathTrg = CreateTrigger()
    
    call TriggerRegisterAnyUnitEventBJ(AddPileOnCreationTrg, EVENT_PLAYER_UNIT_CONSTRUCT_START)
    call TriggerAddCondition(AddPileOnCreationTrg, Condition(function PileFilter))
    call TriggerAddAction(AddPileOnCreationTrg, function AddPileOnCreationByTrigger)
    
    call TriggerRegisterAnyUnitEventBJ(removePileOnDeathTrg, EVENT_PLAYER_UNIT_DEATH )
    call TriggerAddCondition(removePileOnDeathTrg, Condition(function PileFilter))
    call TriggerAddAction(removePileOnDeathTrg, function RemovePileOnDeath)
    
    set AddPileOnCreationTrg = null
    set removePileOnDeathTrg = null
endfunction

function Module_UnitsObserver_InitPerPlayer takes nothing returns nothing
    local player p = GetEnumPlayer()

    set pilesByPlayer[PIdx(p)] = CreateGroup()
    
    set p = null
endfunction

//==============================================
function CountUnitsInGroupByTypeId takes group g, integer typeId returns integer
    set tmp_unitCountByFilter = 0
    set tmp_unitTypeForFilter = typeId
    call ForGroup(g, function ForGroupCountUnitsInGroupByTypeId)

    return tmp_unitCountByFilter
endfunction
function GetPilesCount takes player p returns integer
    return CountUnitsInGroupByTypeId(pilesByPlayer[PIdx(p)], zombieAiFleshPile)
endfunction

function Init_Module_UnitsObserver takes nothing returns nothing
    call IteratePlayers(function PF_PlayerIsUndead, function Module_UnitsObserver_InitPerPlayer)
    call InitPileCountingTriggers()
endfunction

endlibrary