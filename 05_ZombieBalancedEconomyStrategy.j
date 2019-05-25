library ZombieIncomeStrategy requires Common, ZombieStatsResearch, ZombieBuild, Logging

globals
    player tmp_ecostrategyPlayer
endglobals


function GetIncomeForPlayer takes player p returns integer
    return udg_PlayerGoldIncome[PIdx(p)]
endfunction


function T1BrainExtractorFilter takes nothing returns boolean
    return UF_UnitType(zombieAiBrainExtractorT1) and UF_PlayerOwner(tmp_ecostrategyPlayer)
endfunction
function GetT1BrainExtractor takes player p returns unit
    set tmp_ecostrategyPlayer = p
    return GetRandomUnitOfGroup(function T1BrainExtractorFilter)
endfunction

function T2BrainExtractorFilter takes nothing returns boolean
    return UF_UnitType(zombieAiBrainExtractorT2) and UF_PlayerOwner(tmp_ecostrategyPlayer)
endfunction
function GetT2BrainExtractor takes player p returns unit
    set tmp_ecostrategyPlayer = p
    return GetRandomUnitOfGroup(function T2BrainExtractorFilter)
endfunction

function BuildMoreIncome takes player p returns nothing
    local unit brainExtractor = null
    if GetSecondsSinceStart() < 0 then // TODO
        call Log(p, Log_BalanceEcoStrat, "building pile")
        call Command_RequestBuilding(p, zombieAiFleshPile)
    else
        set brainExtractor = GetT1BrainExtractor(p)
        if brainExtractor != null then
            call Log(p, Log_BalanceEcoStrat, "upgrading T2")
            call IssueImmediateOrderById(brainExtractor, zombieAiBrainExtractorT2)
        else
            set brainExtractor = GetT2BrainExtractor(p)
            if brainExtractor != null then
                call Log(p, Log_BalanceEcoStrat, "upgrading T3")
                call IssueImmediateOrderById(brainExtractor, zombieAiBrainExtractorT3)
            else
                call Log(p, Log_BalanceEcoStrat, "building t1")
                call Command_RequestBuilding(p, zombieAiBrainExtractorT1)
            endif
        endif
    endif
    call Log(p, Log_BalanceEcoStrat, "block stats research")
    call BlockResearch(p)
endfunction

function ContinueStatsResearch takes player p returns nothing
    call Log(p, Log_BalanceEcoStrat, "unblock stats research")
    call UnblockResearch(p)
endfunction

function Init_EconomyStrategy takes nothing returns nothing
    // do nothing
endfunction

function ExecuteStep_EconomyStrategy takes player p returns nothing
    local integer income = GetIncomeForPlayer(p)
    local integer nextStatsPrice = GetNextResearchPrice(p)
    if income >= nextStatsPrice then
        call ContinueStatsResearch(p)
    else
        call BuildMoreIncome(p)
    endif
endfunction

endlibrary