library ZombieUpgrades requires Common

globals
    hashtable playerVars
    integer UpgradeLevelKey_Attack = 'R001'
    integer UpgradeLevelKey_AttackSpeed = 'R002'
    integer UpgradeLevelKey_Health = 'R000'
    integer UpgradeLevelKey_HealthRegen = 'R00Q'
    integer UpgradeLevelKey_Speed = 'R00R'
    
    // we keep active research building here, so if it got destroyed we can rollback number
    integer BuildingWithActiveUpgrade_Key = 5
    
    // another strategy decides if player should spend money on upgrades or on economy
    integer UpgradeIsBlocked_Key = 6
    
    integer AlreadyHasMaxUpgrades = 25
    integer DoNotUpgradeLevel = -1
    
    player currentPlayerToFilter
endglobals

///////////////////////////////////////////////////////////
//////////////// DECIDE NEXT UPGRADE //////////////////////
///////////////////////////////////////////////////////////

function LoadUpgradeLevel takes player p, integer key returns integer
    return LoadInteger(playerVars, GetConvertedPlayerId(p), key)
endfunction

function GetNextUpgradeKey takes player p returns integer
    local integer result = 0
    local integer attackLvl = LoadUpgradeLevel(p, UpgradeLevelKey_Attack)
    local integer attackSpeedLvl = LoadUpgradeLevel(p, UpgradeLevelKey_AttackSpeed)
    local integer healthLvl = LoadUpgradeLevel(p, UpgradeLevelKey_Health)
    local integer healthRegenLvl = LoadUpgradeLevel(p, UpgradeLevelKey_HealthRegen)
    local integer speedLvl = LoadUpgradeLevel(p, UpgradeLevelKey_Speed)
    local boolean allSameLevel = attackLvl == attackSpeedLvl and attackLvl == healthLvl and attackLvl == healthRegenLvl and attackLvl == speedLvl
    
    if allSameLevel then
        if attackLvl == AlreadyHasMaxUpgrades then
            return DoNotUpgradeLevel
        else
            return attackLvl + 1
        endif
    else
        set result = UpgradeLevelKey_Attack
        if LoadUpgradeLevel(p, result) > LoadUpgradeLevel(p, UpgradeLevelKey_AttackSpeed) then
            set result = UpgradeLevelKey_AttackSpeed
        endif
        if LoadUpgradeLevel(p, result) > LoadUpgradeLevel(p, UpgradeLevelKey_Health) then
            set result = UpgradeLevelKey_Health
        endif
        if LoadUpgradeLevel(p, result) > LoadUpgradeLevel(p, UpgradeLevelKey_HealthRegen) then
            set result = UpgradeLevelKey_HealthRegen
        endif
        if LoadUpgradeLevel(p, result) > LoadUpgradeLevel(p, UpgradeLevelKey_Speed) then
            set result = UpgradeLevelKey_Speed
        endif
        return result
    endif
endfunction

function FilterPlayerOwnedUpgradeCenter takes nothing returns boolean
    return GetOwningPlayer(GetFilterUnit()) == currentPlayerToFilter and GetUnitTypeId(GetFilterUnit()) == zombieAiNecrocrypt
endfunction

function GetStatsUpgradeCenter takes player p, unit necrocrypt returns nothing
    local group necrocryptsGroup
    local boolexpr filter = Condition(function FilterPlayerOwnedUpgradeCenter)
    set currentPlayerToFilter = p
    call GroupEnumUnitsInRect(necrocryptsGroup, GetPlayableMapRect(), filter)
    call DestroyBoolExpr(filter)
    call ForGroup(necrocryptsGroup, function GroupPickRandomUnitEnum)
    set necrocrypt = bj_groupRandomCurrentPick
    call DestroyGroup(necrocryptsGroup)
    
    set necrocryptsGroup = null
    set filter = null
endfunction

function QueueUpgradeForPlayerIfNeeded takes nothing returns nothing
    local player p = GetEnumPlayer()
    local boolean updateNotBlocked = not LoadBoolean(playerVars, GetConvertedPlayerId(p), UpgradeIsBlocked_Key)
    local unit possibleActiveNecrocrypt = LoadUnitHandle(playerVars, GetConvertedPlayerId(p), BuildingWithActiveUpgrade_Key)
    local boolean noActiveUpgrade = possibleActiveNecrocrypt == null
    local boolean upgradeStarted = false
    local integer nextUpgradeKey = GetNextUpgradeKey(p)

    if updateNotBlocked and noActiveUpgrade and nextUpgradeKey != AlreadyHasMaxUpgrades then
        call GetStatsUpgradeCenter(p, possibleActiveNecrocrypt)
        if possibleActiveNecrocrypt != null then
            set upgradeStarted = IssueImmediateOrderById(possibleActiveNecrocrypt, nextUpgradeKey)
            call SaveUnitHandle(playerVars, GetConvertedPlayerId(p), BuildingWithActiveUpgrade_Key, possibleActiveNecrocrypt)
            call IncrementInHashtable(playerVars, GetConvertedPlayerId(p), nextUpgradeKey)
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
    set playerVars = GetLastCreatedHashtableBJ()
    
    call SaveInteger(playerVars, GetConvertedPlayerId(p), UpgradeLevelKey_Attack, 1)
    call SaveInteger(playerVars, GetConvertedPlayerId(p), UpgradeLevelKey_AttackSpeed, 1)
    call SaveInteger(playerVars, GetConvertedPlayerId(p), UpgradeLevelKey_Health, 1)
    call SaveInteger(playerVars, GetConvertedPlayerId(p), UpgradeLevelKey_HealthRegen, 1)
    call SaveInteger(playerVars, GetConvertedPlayerId(p), UpgradeLevelKey_Speed, 1)
    call SaveUnitHandle(playerVars, GetConvertedPlayerId(p), BuildingWithActiveUpgrade_Key, null)
    call SaveBoolean(playerVars, GetConvertedPlayerId(p), UpgradeIsBlocked_Key, false)

    set p = null
endfunction

function InitZombieUpgrades takes nothing returns nothing
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
//////////////// SCHEDULE UPGRADE //////////////////////
////////////////////////////////////////////////////////
function QueueUpgradesIfNeeded takes nothing returns nothing
    local force zombiePlayers = CreateForce()
    local boolexpr filter = Condition(function PF_PlayerIsUndeadComputer)
    call ForceEnumPlayers(zombiePlayers, filter)
    call DestroyBoolExpr(filter)
    call ForForce(zombiePlayers, function QueueUpgradeForPlayerIfNeeded)
    
    call DestroyForce(zombiePlayers)
    set zombiePlayers = null
    set filter = null
endfunction

function RegisterUpgradeActionTrigger takes nothing returns nothing
    local trigger trg = CreateTrigger()
    
    call TriggerRegisterTimerEventPeriodic( trg, zombieAiDecisionInterval )
    call TriggerAddAction( trg, function QueueUpgradesIfNeeded )
    
    set trg = null
endfunction


//===========================================================================
function InitTrig_UpgradesLogic takes nothing returns nothing
    call InitZombieUpgrades()
    call RegisterUpgradeActionTrigger()
endfunction

endlibrary