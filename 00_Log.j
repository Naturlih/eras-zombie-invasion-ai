library Logging requires Common

globals
    integer Log_Stats = 0
    integer Log_Build = 1
    integer Log_BalanceEcoStrat = 2
    integer Log_StrategyPicker = 3
    integer Log_TierEcoStrat = 4
    
    boolean array LoggingEnabledModule
    boolean array LoggingEnabledPlayer
endglobals

function ModStr takes integer x, integer d returns string
    local real t = I2R(x) / d
    local integer second = R2I((t - R2I(t)) * d)
    
    if second < 10 then
        return "0" + I2S(second)
    else
        return I2S(second)
    endif
endfunction

function Log takes player p, integer moduleId, string text returns nothing
    if LoggingEnabledModule[moduleId] and LoggingEnabledPlayer[PIdx(p)] then
        call DisplayTextToForce(GetPlayersAll(), I2S(GetMinutesSinceStart()) + ":" + ModStr(GetSecondsSinceStart(), 60) + " " + GetPlayerName(p) + " (" + I2S(moduleId) + "): " + text)
    endif
endfunction

function EnableLog takes player p, integer moduleId returns nothing
    set LoggingEnabledModule[moduleId] = true
    set LoggingEnabledPlayer[PIdx(p)] = true
    call Log(p, moduleId, "Enabled logging")
endfunction

function DisableLog takes player p, integer moduleId returns nothing
    call Log(p, moduleId, "Disabled logging")
    set LoggingEnabledModule[moduleId] = false
    set LoggingEnabledPlayer[PIdx(p)] = false
endfunction

endlibrary