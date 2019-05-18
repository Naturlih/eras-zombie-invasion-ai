function Trig_Leak_test_Actions takes nothing returns nothing
    local location L = Location(0,0)
    call DisplayTextToForce( GetPlayersAll(), I2S(GetHandleId(L)-0x100000) )
    call RemoveLocation(L)
    set L = null
endfunction

//===========================================================================
function InitTrig_Leak_test takes nothing returns nothing
    set gg_trg_Leak_test = CreateTrigger(  )
    call TriggerRegisterTimerEventPeriodic( gg_trg_Leak_test, 2.00 )
    call TriggerAddAction( gg_trg_Leak_test, function Trig_Leak_test_Actions )
endfunction

