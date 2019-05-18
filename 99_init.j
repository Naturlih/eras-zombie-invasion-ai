// DO NOT COPY
globals
    trigger gg_trg_Init
endglobals

// DO NOT COPY


library Init requires ZombieAttack, ZombieCreate, ZombieUpgrades

function Trig_Init_Actions takes nothing returns nothing
    call InitTrig_CreateNewZombz()
    call InitTrig_AttackLogic()
    call InitTrig_UpgradesLogic()
endfunction

//===========================================================================
function InitTrig_Init takes nothing returns nothing
    set gg_trg_Init = CreateTrigger()
    call TriggerAddAction( gg_trg_Init, function Trig_Init_Actions )
endfunction

endlibrary