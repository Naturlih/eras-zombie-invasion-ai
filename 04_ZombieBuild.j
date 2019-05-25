library ZombieBuild requires Common, Logging

globals
    location tmp_loc
    real startingLocationDx = 1000
    real startingLocationDy = 1000
    
    private ZombieBuildInfo array buildInfo
    
    integer BuildingIsNotRequested = -1
    
    player tmp_filterPlayer
endglobals

struct ZombieBuildInfo
    player p = null
    integer buildingRequested = BuildingIsNotRequested
    location optionalLocationCenter = null
    // this is needed to detect stuck zombuilders
    // if there are active zombuilder, he has no orders and building was not started, he stuck and he needs to be killed
    unit activeZombuilder = null
endstruct

function ReleaseStuckActiveZombuilder takes ZombieBuildInfo info returns nothing
    local boolean noOrder = false
    local boolean isDead = false

    if info.activeZombuilder != null then
        set noOrder = GetUnitCurrentOrder(info.activeZombuilder) == String2OrderIdBJ("none")
        set isDead = IsUnitDead(info.activeZombuilder)
        if noOrder or isDead then
            call Log(info.p, Log_Build, "releasing builder")
            call IssueReleaseControlCommand(info.activeZombuilder)
            set info.activeZombuilder = null
        endif
    endif
endfunction

function GetRandomPointAroundStartingPoint takes player p returns nothing
    local location s = GetStartLocationLoc(GetPlayerStartLocation(p))
    local rect r = Rect(GetLocationX(s) - startingLocationDx, GetLocationY(s) - startingLocationDy, GetLocationX(s) + startingLocationDx, GetLocationY(s) + startingLocationDy)
    
    set tmp_loc = null
    set tmp_loc = GetRandomLocInRect(r)
    
    call RemoveLocation(s)
    call RemoveRect(r)
    set s = null
    set r = null
endfunction

function IssueBuildAtFreeLocationAround takes location loc, unit builder, integer buildingId returns boolean
    local boolean placedBuildOrder = false
    local real dx = 64 // size of one building square, minimal movable element
    local real dy = 0
    local real x = 0
    local real y = 0
    local real buf = 0
    local integer segmentPassed = 0
    local integer segmentLength = 1
    
    loop
        exitwhen segmentLength > 6 or placedBuildOrder
        set placedBuildOrder = IssueBuildOrderById(builder, buildingId, GetLocationX(loc) + x, GetLocationY(loc) + y)
        set x = x + dx
        set y = y + dy
        set segmentPassed = segmentPassed + 1
        if segmentPassed == segmentLength then
            set segmentPassed = 0
            set buf = dx
            set dx = -dy
            set dy = buf
            if (dy == 0) then
                set segmentLength = segmentLength + 1
            endif
        endif
    endloop
    
    return placedBuildOrder
endfunction

function PlayerOwnedIdleZombuilderFilter takes nothing returns boolean
    return UF_UnitType(zombieAiZombuilder) and UF_PlayerOwner(tmp_filterPlayer) and UF_NoOrders()
endfunction

function FindIdleZombuilder takes player p returns unit
    set tmp_filterPlayer = p
    return GetLastUnitOfGroup(function PlayerOwnedIdleZombuilderFilter)
endfunction

function StartBuildingCreationIfNotAlready takes ZombieBuildInfo info returns nothing
    local unit builder = null
    local boolean requestSucceeded = false
    local location locationToTryBuild = null
    
    call ReleaseStuckActiveZombuilder(info)
    if info.buildingRequested != BuildingIsNotRequested and info.activeZombuilder == null then
        call Log(info.p, Log_Build, "got requested building")
        set builder = FindIdleZombuilder(info.p)
        if builder != null then
            call Log(info.p, Log_Build, "builder exists")
            set locationToTryBuild = info.optionalLocationCenter
            if locationToTryBuild == null then
                call Log(info.p, Log_Build, "location found")
                call GetRandomPointAroundStartingPoint(info.p)
                set locationToTryBuild = tmp_loc
            endif
            set requestSucceeded = IssueBuildAtFreeLocationAround(locationToTryBuild, builder, info.buildingRequested)
            if requestSucceeded then
                call Log(info.p, Log_Build, "request succeeded")
                set info.activeZombuilder = builder
            endif
        endif
    endif
    
    call RemoveLocation(locationToTryBuild)
    set locationToTryBuild = null
    set builder = null
endfunction

function ZombuilderStartedConstruction takes nothing returns nothing
    local player p = GetOwningPlayer(GetTriggerUnit())
    
    local ZombieBuildInfo info = buildInfo[PIdx(p)]
    set info.activeZombuilder = null
    set info.buildingRequested = BuildingIsNotRequested
    
    set p = null
endfunction

function InitIfNeeded_ZombieBuildLogicForPlayer takes player p returns nothing
    local ZombieBuildInfo info
    if buildInfo[PIdx(p)] == null then
        set info = ZombieBuildInfo.create()
        set buildInfo[PIdx(p)] = info
        set info.p = p
    endif
endfunction

////////////////////////////////////////////
//////////////// PUBLIC ////////////////////
////////////////////////////////////////////

function Command_RequestBuilding takes player p, integer buildingId returns boolean
    local ZombieBuildInfo info = buildInfo[PIdx(p)]
    if info.buildingRequested == BuildingIsNotRequested then
        set info.buildingRequested = buildingId
        return true
    else
        return false
    endif
endfunction

function Init_ZombieBuildLogic takes nothing returns nothing
    local trigger constructionStartedTrigger = CreateTrigger()
    
    call TriggerRegisterAnyUnitEventBJ( constructionStartedTrigger, EVENT_PLAYER_UNIT_CONSTRUCT_START )
    call TriggerAddAction( constructionStartedTrigger, function ZombuilderStartedConstruction )
    
    set constructionStartedTrigger = null
endfunction

function ExecuteStep_ZombieBuildLogic takes player p returns nothing
    local boolean requestSucceeded = false

    call InitIfNeeded_ZombieBuildLogicForPlayer(p)
    call StartBuildingCreationIfNotAlready(buildInfo[PIdx(p)])
endfunction

endlibrary
