// DO NOT COPY
// it's needed for code checker to work
globals
    trigger gg_trg_Init
    integer array udg_PlayerGoldIncome
    integer udg_ZombieLevel
endglobals
function main takes nothing returns nothing
endfunction

// DO NOT COPY


library Init requires ZombieAi 

// When changing balance don't forget to update base and inc prices for zombie tech upgrades in ZombieStatsResearch
// Based on prices AI decides when to boost eco and when to upgrade zombz
function Trig_Init_Actions takes nothing returns nothing
    call StartZombieAi()
endfunction

//===========================================================================
function InitTrig_Init takes nothing returns nothing
    set gg_trg_Init = CreateTrigger()
    call TriggerAddAction( gg_trg_Init, function Trig_Init_Actions )
endfunction

endlibrary