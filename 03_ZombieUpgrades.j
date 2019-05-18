library ZombieResearch requires Common

//if GetConvertedPlayerId(p) == 10 then
//    call DisplayTextToForce( GetPlayersAll(), "research started " + B2S(ResearchStarted) + " research id " + I2S(nextResearchKey) )
//endif

globals
    hashtable upgradeLevels
    integer ResearchLevelKey_Attack = 'R001'
    integer ResearchLevelKey_AttackSpeed = 'R00S'
    integer ResearchLevelKey_Health = 'R000'
    integer ResearchLevelKey_HealthRegen = 'R00Q'
    integer ResearchLevelKey_Speed = 'R00R'
    
    // we keep active research building here, so if it got destroyed we can rollback number
    unit array BuildingWithActiveResearch
    
    // another strategy decides if player should spend money on research or on economy
    boolean array ResearchBlockedForEconomy
    
    integer AlreadyHasMaxResearch = 25
    integer DoNotResearchLevel = -1
    
    player currentPlayerToFilter
    unit tmp_researchCenter
endglobals


///////////////////////////////////////////
//////////////// UTIL /////////////////////
///////////////////////////////////////////

function DoForEveryComputerZombie takes code callback returns nothing
    local force zombiePlayers = CreateForce()
    local boolexpr filter = Condition(function PF_PlayerIsUndeadComputer)
    
    call ForceEnumPlayers(zombiePlayers, filter)
    call DestroyBoolExpr(filter)
    call ForForce(zombiePlayers, callback)
    
    call DestroyForce(zombiePlayers)
    set zombiePlayers = null
    set filter = null
endfunction

///////////////////////////////////////////////////////////
//////////////// DECIDE NEXT RESEARCH /////////////////////
///////////////////////////////////////////////////////////

function LoadResearchLevel takes player p, integer key returns integer
    return LoadInteger(upgradeLevels, GetConvertedPlayerId(p), key)
endfunction

function GetNextResearchKey takes player p returns integer
    local integer result = 0
    local integer attackLvl = LoadResearchLevel(p, ResearchLevelKey_Attack)
    local integer attackSpeedLvl = LoadResearchLevel(p, ResearchLevelKey_AttackSpeed)
    local integer healthLvl = LoadResearchLevel(p, ResearchLevelKey_Health)
    local integer healthRegenLvl = LoadResearchLevel(p, ResearchLevelKey_HealthRegen)
    local integer speedLvl = LoadResearchLevel(p, ResearchLevelKey_Speed)
    local boolean allSameLevel = attackLvl == attackSpeedLvl and attackLvl == healthLvl and attackLvl == healthRegenLvl and attackLvl == speedLvl
    
    if allSameLevel then
        if attackLvl == AlreadyHasMaxResearch then
            return DoNotResearchLevel
        else
            return ResearchLevelKey_Attack
        endif
    else
        set result = ResearchLevelKey_Attack
        if LoadResearchLevel(p, result) > LoadResearchLevel(p, ResearchLevelKey_AttackSpeed) then
            set result = ResearchLevelKey_AttackSpeed
        endif
        if LoadResearchLevel(p, result) > LoadResearchLevel(p, ResearchLevelKey_Health) then
            set result = ResearchLevelKey_Health
        endif
        if LoadResearchLevel(p, result) > LoadResearchLevel(p, ResearchLevelKey_HealthRegen) then
            set result = ResearchLevelKey_HealthRegen
        endif
        if LoadResearchLevel(p, result) > LoadResearchLevel(p, ResearchLevelKey_Speed) then
            set result = ResearchLevelKey_Speed
        endif
        return result
    endif
endfunction

function FilterPlayerOwnedResearchCenter takes nothing returns boolean    
    return GetOwningPlayer(GetFilterUnit()) == currentPlayerToFilter and GetUnitTypeId(GetFilterUnit()) == zombieAiNecrocrypt
endfunction

function PickLastNecrovolverFromGroup takes nothing returns nothing
    set tmp_researchCenter = GetEnumUnit()
endfunction

function GetStatsResearchCenter takes player p returns nothing
    local group necrocryptsGroup = CreateGroup()
    local boolexpr filter = Condition(function FilterPlayerOwnedResearchCenter)
    set currentPlayerToFilter = p
    call GroupEnumUnitsInRect(necrocryptsGroup, GetPlayableMapRect(), filter)
    call DestroyBoolExpr(filter)
    set tmp_researchCenter = null
    call ForGroup(necrocryptsGroup, function PickLastNecrovolverFromGroup)
    
    call DestroyGroup(necrocryptsGroup)
    set necrocryptsGroup = null
    set filter = null
endfunction

function QueueResearchForPlayerIfNeeded takes nothing returns nothing
    local player p = GetEnumPlayer()
    local boolean updateNotBlocked = not ResearchBlockedForEconomy[GetConvertedPlayerId(p)]
    local unit possibleActiveNecrocrypt = BuildingWithActiveResearch[GetConvertedPlayerId(p)]
    local boolean noActiveResearch = possibleActiveNecrocrypt == null
    local boolean ResearchStarted = false
    local integer nextResearchKey = GetNextResearchKey(p)
    
    if updateNotBlocked and noActiveResearch and nextResearchKey != AlreadyHasMaxResearch then
        call GetStatsResearchCenter(p)
        set possibleActiveNecrocrypt = tmp_researchCenter
        if possibleActiveNecrocrypt != null then
            set ResearchStarted = IssueImmediateOrderById(possibleActiveNecrocrypt, nextResearchKey)
            if ResearchStarted then
                call DisplayTextToForce( GetPlayersAll(), "Issued research for player " + GetPlayerName(p) + " research id " + GetObjectName(nextResearchKey) + " necro owner " + GetPlayerName(GetOwningPlayer(possibleActiveNecrocrypt)) )
                set BuildingWithActiveResearch[GetConvertedPlayerId(p)] = possibleActiveNecrocrypt
                call IncrementInHashtable(upgradeLevels, GetConvertedPlayerId(p), nextResearchKey)
            endif
        endif
    endif
    
    set p = null
    set possibleActiveNecrocrypt = null
endfunction

////////////////////////////////////////////
//////////////// INIT //////////////////////
////////////////////////////////////////////

function InitVarsForForce takes nothing returns nothing
    local player p = GetEnumPlayer()
    call InitHashtableBJ()
    set upgradeLevels = GetLastCreatedHashtableBJ()
    
    call SaveInteger(upgradeLevels, GetConvertedPlayerId(p), ResearchLevelKey_Attack, 0)
    call SaveInteger(upgradeLevels, GetConvertedPlayerId(p), ResearchLevelKey_AttackSpeed, 0)
    call SaveInteger(upgradeLevels, GetConvertedPlayerId(p), ResearchLevelKey_Health, 0)
    call SaveInteger(upgradeLevels, GetConvertedPlayerId(p), ResearchLevelKey_HealthRegen, 0)
    call SaveInteger(upgradeLevels, GetConvertedPlayerId(p), ResearchLevelKey_Speed, 0)
    set BuildingWithActiveResearch[GetConvertedPlayerId(p)] = null
    set ResearchBlockedForEconomy[GetConvertedPlayerId(p)] = false

    set p = null
endfunction

function InitZombieResearch takes nothing returns nothing
    local force zombiePlayers = CreateForce()
    local boolexpr filter = Condition(function PF_PlayerIsUndeadComputer)
    
    call ForceEnumPlayers(zombiePlayers, filter)
    call DestroyBoolExpr(filter)
    call ForForce(zombiePlayers, function InitVarsForForce)
    
    call DestroyForce(zombiePlayers)
    set zombiePlayers = null
    set filter = null
endfunction

////////////////////////////////////////////////////////
//////////////// SCHEDULE RESEARCH /////////////////////
////////////////////////////////////////////////////////
function QueueResearchIfNeeded takes nothing returns nothing
    call DoForEveryComputerZombie(function QueueResearchForPlayerIfNeeded)
endfunction

function RegisterResearchActionTrigger takes nothing returns nothing
    local trigger trg = CreateTrigger()
    
    call TriggerRegisterTimerEventPeriodic( trg, zombieAiDecisionInterval )
    call TriggerAddAction( trg, function QueueResearchIfNeeded )
    
    set trg = null
endfunction


////////////////////////////////////////////////////////
//////////////// CLEAN ACTIVE NECROVOLVER //////////////
////////////////////////////////////////////////////////

function CleanActiveResearchUnit takes nothing returns nothing
    local player p = GetOwningPlayer(GetTriggerUnit())

    set BuildingWithActiveResearch[GetConvertedPlayerId(p)] = null

    set p = null
endfunction

function ResearchCentersOfComputerZombie takes nothing returns boolean
    local boolean ownerIsComputer = GetPlayerController(GetOwningPlayer(GetTriggerUnit())) == MAP_CONTROL_COMPUTER
    local boolean ownerIsZombie = GetPlayerRace(GetOwningPlayer(GetTriggerUnit())) == RACE_UNDEAD
    local boolean researchCenter = GetUnitTypeId(GetTriggerUnit()) == zombieAiNecrocrypt or GetUnitTypeId(GetTriggerUnit()) == zombieAiNecrovolver
   
    return ownerIsComputer and ownerIsZombie and researchCenter
endfunction

function RegisterResearchFinishedTrigger takes nothing returns nothing
    local trigger trg = CreateTrigger()
    
    call TriggerRegisterAnyUnitEventBJ( trg, EVENT_PLAYER_UNIT_RESEARCH_CANCEL )
    call TriggerRegisterAnyUnitEventBJ( trg, EVENT_PLAYER_UNIT_RESEARCH_FINISH )
    call TriggerAddCondition( trg, Condition( function ResearchCentersOfComputerZombie ) )
    call TriggerAddAction( trg, function CleanActiveResearchUnit )
    
    set trg = null
endfunction


//===========================================================================
function InitTrig_ResearchLogic takes nothing returns nothing
    call InitZombieResearch()
    call RegisterResearchActionTrigger()
    call RegisterResearchFinishedTrigger()
endfunction

endlibrary