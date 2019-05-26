library Common

// GetObjectName(int)

globals
    //north
    player Zombie1Player = Player(9)
    player Zombie2Player = Player(10)
    player Zombie3Player = Player(11)
    //south
    player Zombie4Player = Player(22)
    player Zombie5Player = Player(23)
    
    integer zombieAiZombieLvl1 = 'h006'
    integer zombieAiZombieLvl2 = 'h02I'
    integer zombieAiZombieLvl3 = 'h02P'
    integer zombieAiZombieLvl4 = 'h03L'
    integer zombieAiZombieLvl5 = 'h03W'
    integer zombieAiZombuilder = 'h008'
    integer zombieAiGorecrow = 'h04Y'
    integer zombieAiSneezer = 'h022'
    integer zombieAiBloodCultist = 'h015'
    integer zombieAiStalker = 'h00C'
    integer zombieAiMauler = 'h00Z'
    integer zombieAiLumpy = 'h00F'
    integer zombieAiFleshGiant = 'h04G'
    
    integer zombieAiFleshPile = 'u006'
    // stats upgrade building
    integer zombieAiNecrocrypt = 'u000'
    // zombie type upgrade building
    integer zombieAiNecrovolver = 'u005'
    
    integer zombieAiBrainExtractorT1 = 'u001'
    integer zombieAiBrainExtractorT2 = 'u007'
    integer zombieAiBrainExtractorT3 = 'u008'
    
    integer zombieAiReleaseControl = 'A028'
    
    integer tmp_counter
    unit tmp_getUnitResult
    integer tmp_unitIdFilter
    player tmp_playerFilter
    
    integer secondsSinceStart = 0
    
    group tmp_groupOfDeadUnits
    group tmp_groupToRemoveUnitsFrom
endglobals

// string utils
function B2S takes boolean b returns string
    if b then
        return "true"
    else
        return "false"
    endif
endfunction
function H2NullCheckS takes handle h returns string
    if h == null then
        return "null"
    else
        return "not null"
    endif
endfunction
// string utils

// Simple filters
// PF stands for PlayerFilter and works on GetFilterPlayer()
// filter works on GetFilterUnit()
function PF_PlayerIsUndead takes nothing returns boolean
    return ( GetPlayerRace(GetFilterPlayer()) == RACE_UNDEAD )
endfunction
function PF_PlayerIsComputer takes nothing returns boolean
    return ( GetPlayerController(GetFilterPlayer()) == MAP_CONTROL_COMPUTER )
endfunction
function PF_PlayerIsUndeadComputer takes nothing returns boolean
    return PF_PlayerIsUndead() and PF_PlayerIsComputer()
endfunction

// UF stands for UnitFilter and works on GetFilterUnit()
function UF_GenericUnitTypeFilter takes nothing returns boolean
    return GetUnitTypeId(GetFilterUnit()) == tmp_unitIdFilter
endfunction
function UF_UnitIsFleshPile takes nothing returns boolean
    return ( GetUnitTypeId(GetFilterUnit()) == zombieAiFleshPile )
endfunction
function UF_ComputerIsTheOwner takes nothing returns boolean
    return ( GetPlayerController(GetOwningPlayer(GetFilterUnit())) == MAP_CONTROL_COMPUTER )
endfunction
function UF_PlayerIsUndead takes nothing returns boolean
    return ( GetPlayerRace(GetOwningPlayer(GetFilterUnit())) == RACE_UNDEAD )
endfunction
function UF_NoOrders takes nothing returns boolean
    return ( GetUnitCurrentOrder(GetFilterUnit()) == String2OrderIdBJ("none") )
endfunction
function UF_Structure takes nothing returns boolean
    return ( IsUnitType(GetFilterUnit(), UNIT_TYPE_STRUCTURE) == true )
endfunction
function UF_OwnerIsHuman takes nothing returns boolean
    return ( GetUnitRace(GetFilterUnit()) == RACE_HUMAN )
endfunction
function UF_UnitType takes integer typeId returns boolean
    return ( GetUnitTypeId(GetFilterUnit()) == typeId )
endfunction
function UF_PlayerOwner takes player p returns boolean
    return ( GetOwningPlayer(GetFilterUnit()) == p)
endfunction
// Simple filters

// iterators
function IteratePlayers takes code filter, code callback returns nothing
    local force zombiePlayers = CreateForce()
    local boolexpr f = Condition(filter)
    
    call ForceEnumPlayers(zombiePlayers, f)
    call DestroyBoolExpr(f)
    call ForForce(zombiePlayers, callback)
    
    call DestroyForce(zombiePlayers)
    set zombiePlayers = null
    set f = null
endfunction

function IterateUnits takes code filter, code callback returns nothing
    local group grp = CreateGroup()
    local boolexpr f = Condition(filter)
    call GroupEnumUnitsInRect(grp, GetPlayableMapRect(), f)
    call DestroyBoolExpr(f)
    call ForGroup(grp, callback)
    
    call DestroyGroup(grp)
    set grp = null
    set f = null
endfunction
// iterators

// hashtable utils
function IncrementInHashtable takes hashtable h, integer PK, integer SK returns nothing
    local integer currentVal = LoadInteger(h, PK, SK)
    call SaveInteger(h, PK, SK, currentVal + 1)
endfunction
function DecrementInHashtable takes hashtable h, integer PK, integer SK returns nothing
    local integer currentVal = LoadInteger(h, PK, SK)
    call SaveInteger(h, PK, SK, currentVal - 1)
endfunction
// hashtable utils

// array utils
function PIdx takes player p returns integer
    return GetConvertedPlayerId(p)
endfunction
// array utils

// unit utils
function SaveUnitFromGroup takes nothing returns nothing
    set tmp_getUnitResult = GetEnumUnit()
endfunction
function GetLastUnitOfGroup takes code f returns unit
    set tmp_getUnitResult = null
    call IterateUnits(f, function SaveUnitFromGroup)
    
    return tmp_getUnitResult
endfunction

function SaveRandomUnitFromGroup takes nothing returns nothing
    set tmp_counter = tmp_counter + 1
    if (GetRandomInt(1, tmp_counter) == 1) then
        set tmp_getUnitResult = GetEnumUnit()
    endif
endfunction
function GetRandomUnitOfGroup takes code f returns unit
    set tmp_getUnitResult = null
    set tmp_counter = 0
    call IterateUnits(f, function SaveRandomUnitFromGroup)
    
    return tmp_getUnitResult
endfunction

function IssueReleaseControlCommand takes unit u returns boolean
    // TODO dunno why but this does not work
    //return IssueImmediateOrderById(u, zombieAiReleaseControl)
    call KillUnit(u)
    return true
endfunction

function IsUnitDead takes unit u returns boolean
    return IsUnitType(u, UNIT_TYPE_DEAD) or GetUnitTypeId(u) == 0
endfunction

function SaveDeadUnits takes nothing returns nothing
    local unit u = GetEnumUnit()
    if IsUnitDead(u) then
        call DisplayTextToForce(GetPlayersAll(), "Removing unit " + GetUnitName(u))//TODO
        call GroupAddUnit(tmp_groupOfDeadUnits, u)
    endif
    set u = null
endfunction
function RemoveUnitsFromGroup takes nothing returns nothing
    call GroupRemoveUnit(tmp_groupToRemoveUnitsFrom, GetEnumUnit())
endfunction
function CleanDeadUnitsFromGroup takes group g returns nothing
    set tmp_groupOfDeadUnits = CreateGroup()

    call ForGroup(g, function SaveDeadUnits)
    set tmp_groupToRemoveUnitsFrom = g
    call ForGroup(tmp_groupOfDeadUnits, function RemoveUnitsFromGroup)
    
    call DestroyGroup(tmp_groupOfDeadUnits)
    set tmp_groupOfDeadUnits = null
endfunction
// unit utils

function Unit_GetPlayerNumber takes nothing returns integer
    return GetConvertedPlayerId(GetOwningPlayer(GetEnumUnit()))
endfunction

function Filter_ZombieAiPlayers takes nothing returns boolean
    return PF_PlayerIsUndead() and PF_PlayerIsComputer()
endfunction
function GetZombieAiPlayers takes force f returns nothing
    local boolexpr filter
    
    set filter = Condition(function Filter_ZombieAiPlayers)
    call ForceEnumPlayers(f, filter)
    
    call DestroyBoolExpr(filter)
    set filter = null
endfunction


function CurrentZombieTier takes nothing returns integer
    return udg_ZombieLevel
endfunction

function GetZombieUnitTypeByTier takes integer tier returns integer
    if tier == 1 then
        return zombieAiZombieLvl1
    elseif tier == 2 then
        return zombieAiZombieLvl2
    elseif tier == 3 then
        return zombieAiZombieLvl3
    elseif tier == 4 then
        return zombieAiZombieLvl4
    elseif tier == 5 then
        return zombieAiZombieLvl5
    else
        return -1 // TODO logging?
    endif
endfunction


function GetIncomeForPlayer takes player p returns integer
    return udg_PlayerGoldIncome[PIdx(p)]
endfunction


function T1BrainExtractorFilter takes nothing returns boolean
    return UF_UnitType(zombieAiBrainExtractorT1) and UF_PlayerOwner(tmp_playerFilter)
endfunction
function GetT1BrainExtractor takes player p returns unit
    set tmp_playerFilter = p
    return GetRandomUnitOfGroup(function T1BrainExtractorFilter)
endfunction

function T2BrainExtractorFilter takes nothing returns boolean
    return UF_UnitType(zombieAiBrainExtractorT2) and UF_PlayerOwner(tmp_playerFilter)
endfunction
function GetT2BrainExtractor takes player p returns unit
    set tmp_playerFilter = p
    return GetRandomUnitOfGroup(function T2BrainExtractorFilter)
endfunction

function NecrovolverFilter takes nothing returns boolean
    return UF_UnitType(zombieAiNecrovolver) and UF_PlayerOwner(tmp_playerFilter)
endfunction
function GetNecrovolver takes player p returns unit
    set tmp_playerFilter = p
    return GetRandomUnitOfGroup(function NecrovolverFilter)
endfunction


function Library_IncrementTime takes nothing returns nothing
    set secondsSinceStart = secondsSinceStart + 1
endfunction
function GetSecondsSinceStart takes nothing returns integer
    return secondsSinceStart
endfunction
function GetMinutesSinceStart takes nothing returns integer
    return secondsSinceStart / 60
endfunction

function Init_TimeCounter takes nothing returns nothing
    local trigger trg = CreateTrigger()
    
    call TriggerRegisterTimerEventPeriodic( trg, 1 )
    call TriggerAddAction( trg, function Library_IncrementTime )
    
    set trg = null
endfunction
endlibrary