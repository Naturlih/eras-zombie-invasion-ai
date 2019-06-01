library ZombieAttack requires Common, Logging, ZombieCreate
globals
    location array mainTargetByPlayer //TODO
    group array groupByPlayer // TODO
    integer array lastZombieTier
    player tmp_player_DumbAttack
endglobals

function IssueAttackOrderForUnit takes nothing returns nothing
    local unit u = GetEnumUnit()

    if GetUnitCurrentOrder(u) == String2OrderIdBJ("none") then
        call IssuePointOrderLoc(u, "attack", mainTargetByPlayer[PIdx(tmp_player_DumbAttack)])
    endif
    
    set u = null
endfunction

function AttackOrderForGroup takes player p returns nothing
    if CurrentZombieTier() != lastZombieTier[PIdx(p)] then
        call Log(p, Log_AttackDumb, "Updated tier to " + I2S(CurrentZombieTier()))
        set lastZombieTier[PIdx(p)] = CurrentZombieTier
        call ClearGroupZombieRequirement(groupByPlayer[PIdx(p)])
    endif
    call Log(p, Log_AttackDumb, "setting requirement to 50 of " + GetObjectName(GetZombieUnitTypeByTier(lastZombieTier[PIdx(p)])))
    call SetGroupZombieRequirement(groupByPlayer[PIdx(p)], GetZombieUnitTypeByTier(lastZombieTier[PIdx(p)]), 14)
    call ModuleStep_CreateNewZombz(p, groupByPlayer[PIdx(p)])
    call Log(p, Log_AttackDumb, "setting attack order")
    set tmp_player_DumbAttack = p
    call ForGroup(groupByPlayer[PIdx(p)], function IssueAttackOrderForUnit)
endfunction

function Module_AttackStrategy_DumbInitPerPlayer takes nothing returns nothing
    local player p = GetEnumPlayer()
    
    call Log(p, Log_AttackDumb, "init dumb")
    set groupByPlayer[PIdx(p)] = CreateGroup()
    set lastZombieTier[PIdx(p)] = 1
    
    set p = null
endfunction

function Lvl1ZombieFilter takes nothing returns boolean
    return UF_UnitType(zombieAiZombieLvl1)
endfunction
function AddZombieToPlayerGroup takes nothing returns nothing
    local unit u = GetEnumUnit()
    local player p = GetOwningPlayer(u)
    
    call GroupAddUnit(groupByPlayer[PIdx(p)], u)
    
    set u = null
    set p = null
endfunction
function Module_AttackStrategy_AddStartingZombies takes nothing returns nothing
    call IterateUnits(function Lvl1ZombieFilter, function AddZombieToPlayerGroup)
endfunction

//===========================================================================

function Init_AttackStrategy_Dumb takes nothing returns nothing
    set mainTargetByPlayer[PIdx(Zombie1Player)] = Location(8800, -240) //hardcode to Romania
    set mainTargetByPlayer[PIdx(Zombie2Player)] = GetStartLocationLoc(GetPlayerStartLocation(Player(3 - 1))) //hardcode to Russia
    set mainTargetByPlayer[PIdx(Zombie3Player)] = Location(15000, -5800) //hardcode to Turkey
    set mainTargetByPlayer[PIdx(Zombie4Player)] = GetStartLocationLoc(GetPlayerStartLocation(Player(7 - 1))) //hardcode to Turkey
    set mainTargetByPlayer[PIdx(Zombie5Player)] = GetStartLocationLoc(GetPlayerStartLocation(Player(19 - 1))) //hardcode to Egypt
    
    call IteratePlayers(function PF_PlayerIsUndead, function Module_AttackStrategy_DumbInitPerPlayer)
    call Module_AttackStrategy_AddStartingZombies()
endfunction

function ExecuteStep_DumbZombieAttack takes player p returns nothing
    call AttackOrderForGroup(p)
endfunction

endlibrary
