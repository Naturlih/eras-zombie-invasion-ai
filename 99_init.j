// DO NOT COPY
globals
    trigger gg_trg_Init
endglobals

// DO NOT COPY


library Init requires ZombieResearch 

function Trig_Init_Actions takes nothing returns nothing
    call InitTrig_CreateNewZombz()
    call InitTrig_AttackLogic()
    call InitTrig_ResearchLogic()
endfunction

//===========================================================================
function InitTrig_Init takes nothing returns nothing
    set gg_trg_Init = CreateTrigger()
    call TriggerAddAction( gg_trg_Init, function Trig_Init_Actions )
endfunction

endlibrary