library ZombieStatsResearch requires Common, Logging

//if GetConvertedPlayerId(p) == 10 then
//    call DisplayTextToForce( GetPlayersAll(), "research started " + B2S(ResearchStarted) + " research id " + I2S(nextResearchKey) )
//endif

globals
    integer ResearchLevelKey_Attack = 'R001'
    integer ResearchLevelKey_AttackSpeed = 'R00S'
    integer ResearchLevelKey_Health = 'R000'
    integer ResearchLevelKey_HealthRegen = 'R00Q'
    integer ResearchLevelKey_Speed = 'R00R'
    integer ResearchLevelKeyOffset = 'R000'
    
    integer array baseTechPrice
    integer array modTechPrice
    
    // we keep active research building here, so if it got destroyed we can rollback number
    unit array BuildingWithActiveResearch
    
    // another strategy decides if player should spend money on research or on economy
    boolean array StatsResearchBlocked
    
    integer MaxTechLevel = 25
    integer DoNotResearchLevel = -1
    
    player currentPlayerToFilter
endglobals

///////////////////////////////////////////////////////////
//////////////// DECIDE NEXT RESEARCH /////////////////////
///////////////////////////////////////////////////////////

function TechKey takes integer i returns integer
    return i - ResearchLevelKeyOffset
endfunction

function LoadResearchLevel takes player p, integer key returns integer
    return GetPlayerTechCount(p, key, false) // no idea what is the difference for last boolean arg
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
        if attackLvl == MaxTechLevel then
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

function QueueResearchForPlayerIfNeeded takes player p returns nothing
    local boolean updateNotBlocked = not StatsResearchBlocked[PIdx(p)]
    local unit possibleActiveNecrocrypt = BuildingWithActiveResearch[PIdx(p)]
    local boolean noActiveResearch = possibleActiveNecrocrypt == null
    local boolean ResearchStarted = false
    local integer nextResearchKey = GetNextResearchKey(p)
    
    call Log(p, Log_Stats, "research updateNotBlocked " + B2S(updateNotBlocked) + " noActiveResearch " + B2S(noActiveResearch) + " nextResearchKey " + GetObjectName(nextResearchKey))
    if updateNotBlocked and noActiveResearch and nextResearchKey != DoNotResearchLevel then
        set currentPlayerToFilter = p
        set possibleActiveNecrocrypt = GetLastUnitOfGroup(function FilterPlayerOwnedResearchCenter)
        if possibleActiveNecrocrypt != null then
            call Log(p, Log_Stats, "necrocrypt exists")
            set ResearchStarted = IssueImmediateOrderById(possibleActiveNecrocrypt, nextResearchKey)
            if ResearchStarted then
                call Log(p, Log_Stats, "research started")
                set BuildingWithActiveResearch[PIdx(p)] = possibleActiveNecrocrypt
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
    
    set BuildingWithActiveResearch[PIdx(p)] = null
    set StatsResearchBlocked[PIdx(p)] = false

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

function InitTechPrices takes nothing returns nothing
    set baseTechPrice[TechKey(ResearchLevelKey_Attack)] = 250
    set modTechPrice[TechKey(ResearchLevelKey_Attack)] = 350
    
    set baseTechPrice[TechKey(ResearchLevelKey_AttackSpeed)] = 175
    set modTechPrice[TechKey(ResearchLevelKey_AttackSpeed)] = 200
    
    set baseTechPrice[TechKey(ResearchLevelKey_HealthRegen)] = 75
    set modTechPrice[TechKey(ResearchLevelKey_HealthRegen)] = 100
    
    set baseTechPrice[TechKey(ResearchLevelKey_Health)] = 200
    set modTechPrice[TechKey(ResearchLevelKey_Health)] = 200
    
    set baseTechPrice[TechKey(ResearchLevelKey_Speed)] = 125
    set modTechPrice[TechKey(ResearchLevelKey_Speed)] = 150
endfunction

///////////////////////////////////////////////////////
//////////////// CLEAN ACTIVE NECROCRYPT //////////////
///////////////////////////////////////////////////////

function CleanActiveResearchUnit takes nothing returns nothing
    local player p = GetOwningPlayer(GetTriggerUnit())

    set BuildingWithActiveResearch[PIdx(p)] = null

    set p = null
endfunction

function ZombieNecrocryptFilter takes nothing returns boolean
    return GetUnitTypeId(GetTriggerUnit()) == zombieAiNecrocrypt
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

////////////////////////////////////////////////
//////////////// PUBLIC FUNCTIONS //////////////
////////////////////////////////////////////////

function GetNextResearchPrice takes player p returns integer
    local integer nextResearchKey = TechKey(GetNextResearchKey(p))
    return baseTechPrice[nextResearchKey] + modTechPrice[nextResearchKey] * LoadResearchLevel(p, nextResearchKey)
endfunction

function BlockResearch takes player p returns nothing
    set StatsResearchBlocked[PIdx(p)] = true
endfunction

function UnblockResearch takes player p returns nothing
    set StatsResearchBlocked[PIdx(p)] = false
endfunction

//===========================================================================
function Init_ResearchStatsLogic takes nothing returns nothing
    call InitZombieResearch()
    call InitTechPrices()
    call RegisterResearchFinishedTrigger()
endfunction

function ExecuteStep_ZombieResearchStats takes player p returns nothing
    call QueueResearchForPlayerIfNeeded(p)
endfunction

endlibrary