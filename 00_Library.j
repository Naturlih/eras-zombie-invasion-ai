library Common

// call DisplayTextToForce( GetPlayersAll(), "Hello world!" )

globals
    integer zombieAiZombieLvl1 = 'h006'
    integer zombieAiZombieLvl2 = 'h02I'
    integer zombieAiZombieLvl3 = 'h02P'
    integer zombieAiZombieLvl4 = 'h03L'
    integer zombieAiZombieLvl5 = 'h03W'
    integer zombieAiZombuilder = 'h008'
    
    integer zombieAiFleshPile = 'u006'
    // stats upgrade building
    integer zombieAiNecrocrypt = 'u000'
    // zombie type upgrade building
    integer zombieAiNecrovolver = 'u005'
    
    real zombieAiDecisionInterval = 2
endglobals

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
// Simple filters


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
endlibrary