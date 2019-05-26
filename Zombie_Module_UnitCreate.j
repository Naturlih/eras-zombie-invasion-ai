library ZombieCreate requires Common, Logging, ModuleUnitsObserver

globals
    hashtable zombieAiCreateZombH
    
    // used to understand which group add new unit to
    // maps flesh pile to group
    hashtable pileToGroup
    integer pileToGroup_GroupId = 0
    integer pileToGroup_IsActiveId = 1
    // this shows how many zombies by type are requested for builder module to maintain
    hashtable groupAndTypeToRequestedAmount
    // this shows how many zombies by type are expected to be built
    // we can have queued zombies in piles, they are not counted yet but we don't want to build them again
    hashtable groupAndTypeToInTrainingAmount
    
    integer array zombieTypeIds
    integer zombieTypeAmount = 0
    
    integer tmp_unitTypeToTrain
    group tmp_unitGroupToTrainTo
    integer tmp_unitAmountToTrain
endglobals

function SubmitCreateZombieTaskForIdlePile takes nothing returns nothing
    local unit pile = GetEnumUnit()
    if tmp_unitAmountToTrain > 0 and GetUnitCurrentOrder(pile) == String2OrderIdBJ("none") and LoadBoolean(pileToGroup, GetHandleId(pile), pileToGroup_IsActiveId) == false then
        if IssueImmediateOrderById(pile, tmp_unitTypeToTrain) then
            set tmp_unitAmountToTrain = tmp_unitAmountToTrain - 1
            call IncrementInHashtable(groupAndTypeToInTrainingAmount, GetHandleId(tmp_unitGroupToTrainTo), tmp_unitTypeToTrain)
            call SaveGroupHandle(pileToGroup, GetHandleId(pile), pileToGroup_GroupId, tmp_unitGroupToTrainTo)
            call SaveBoolean(pileToGroup, GetHandleId(pile), pileToGroup_IsActiveId, true)
        endif
    endif    
    set pile = null
endfunction
function RequestUnitsInPiles takes player p, group g, integer unitTypeId, integer amount returns nothing
    set tmp_unitGroupToTrainTo = g
    set tmp_unitAmountToTrain = amount
    set tmp_unitTypeToTrain = unitTypeId
    call ForGroup(pilesByPlayer[PIdx(p)], function SubmitCreateZombieTaskForIdlePile)
endfunction

function CreateNewZombiesByRequests takes player p, group g returns nothing
    local integer amountToMaintain = 0
    local integer currentAmount = 0
    local integer trainingAmount = 0
    local integer zombieTypeId = 0
    local integer expectedAmount = 0
    local integer i = 0
    
    call CleanDeadUnitsFromGroup(g)
    loop
        exitwhen i >= zombieTypeAmount
        
        set zombieTypeId = zombieTypeIds[i]
        set amountToMaintain = LoadInteger(groupAndTypeToRequestedAmount, GetHandleId(g), zombieTypeId)
        if amountToMaintain > 0 then
            set currentAmount = CountUnitsInGroupByTypeId(g, zombieTypeId)
            set trainingAmount = LoadInteger(groupAndTypeToInTrainingAmount, GetHandleId(g), zombieTypeId)
            set expectedAmount = currentAmount + trainingAmount
            call Log(p, Log_UnitCreate, "need to maintain " + I2S(amountToMaintain) + " units of type " + GetObjectName(zombieTypeId) + ", currently has " + I2S(currentAmount) + " in group and training " + I2S(trainingAmount))
            if expectedAmount < amountToMaintain then
                call Log(p, Log_UnitCreate, "training " + I2S(amountToMaintain - expectedAmount) + " units of type " + GetObjectName(zombieTypeId))
                call RequestUnitsInPiles(p, g, zombieTypeId, amountToMaintain - expectedAmount)
            endif
        endif
        
        set i = i + 1
    endloop
endfunction

function AddZombieType takes integer typeId returns nothing
    set zombieTypeIds[zombieTypeAmount] = typeId
    set zombieTypeAmount = zombieTypeAmount + 1
endfunction

function ZombieAiNewZombzInitGlobals takes nothing returns nothing
    // order here defines priority to create
    // zombuilder should be top one
    call AddZombieType(zombieAiZombuilder)
    call AddZombieType(zombieAiZombieLvl1)
    call AddZombieType(zombieAiZombieLvl2)
    call AddZombieType(zombieAiZombieLvl3)
    call AddZombieType(zombieAiZombieLvl4)
    call AddZombieType(zombieAiZombieLvl5)
    call AddZombieType(zombieAiGorecrow)
    call AddZombieType(zombieAiSneezer)
    call AddZombieType(zombieAiSneezer)
    call AddZombieType(zombieAiStalker)
    call AddZombieType(zombieAiMauler)
    call AddZombieType(zombieAiLumpy)
    call AddZombieType(zombieAiFleshGiant)
    
    set pileToGroup = InitHashtable()
    set groupAndTypeToRequestedAmount = InitHashtable()
    set groupAndTypeToInTrainingAmount = InitHashtable()
endfunction

function HandleTrainedUnit takes nothing returns nothing
    local unit pile = GetTriggerUnit()
    local group g = null
    local unit trainedUnit = GetTrainedUnit()
    local integer unitTypeId = 0
    
    if pile != null then
        set g = LoadGroupHandle(pileToGroup, GetHandleId(pile), 0)
    endif
    
    if g != null and pile != null and trainedUnit != null then
        set unitTypeId = GetUnitTypeId(trainedUnit)
        call DecrementInHashtable(groupAndTypeToInTrainingAmount, GetHandleId(g), unitTypeId)
        call GroupAddUnit(g, trainedUnit)
        call SaveGroupHandle(pileToGroup, GetHandleId(pile), pileToGroup_GroupId, null)
        call SaveBoolean(pileToGroup, GetHandleId(pile), pileToGroup_IsActiveId, false)
    endif
    
    set pile = null
    set g = null
    set trainedUnit = null
endfunction
function TriggerUnitIsPile takes nothing returns boolean
    return GetUnitTypeId(GetTriggerUnit()) == zombieAiFleshPile
endfunction
function InitTrainCompleteTrigger takes nothing returns nothing
    local trigger trainCompleteTrg = CreateTrigger()
        
    call TriggerRegisterAnyUnitEventBJ(trainCompleteTrg, EVENT_PLAYER_UNIT_TRAIN_FINISH)
    call TriggerAddCondition(trainCompleteTrg, Condition(function TriggerUnitIsPile))
    call TriggerAddAction(trainCompleteTrg, function HandleTrainedUnit)
    
    set trainCompleteTrg = null
endfunction

function AddPileByIterate takes nothing returns nothing
    call GroupAddUnit(pilesByPlayer[PIdx(GetOwningPlayer(GetEnumUnit()))], GetEnumUnit())
endfunction
function Init_AddExistingPilesToGroup takes nothing returns nothing
    call IterateUnits(function UF_UnitIsFleshPile, function AddPileByIterate)
endfunction

///////////////////////////////////////////////
//////////////// PUBLIC ///////////////////////
///////////////////////////////////////////////

function Init_Module_UnitCreate takes nothing returns nothing
    call ZombieAiNewZombzInitGlobals()
    call Init_AddExistingPilesToGroup()
    call InitTrainCompleteTrigger()
endfunction

function ClearGroupZombieRequirement takes group g returns nothing
    local integer i = 0
    loop
        exitwhen i >= zombieTypeAmount
        call SaveInteger(groupAndTypeToRequestedAmount, GetHandleId(g), zombieTypeIds[i], 0)
        set i = i + 1
    endloop
endfunction

function SetGroupZombieRequirement takes group g, integer zombieType, integer amount returns nothing
    call SaveInteger(groupAndTypeToRequestedAmount, GetHandleId(g), zombieType, amount)
endfunction

function ModuleStep_CreateNewZombz takes player p, group g returns nothing
    call CreateNewZombiesByRequests(p, g)
endfunction

endlibrary