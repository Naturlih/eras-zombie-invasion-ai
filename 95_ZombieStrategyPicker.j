library ZombieStrategyPicker requires Common, Logging, ZombieBalancedEconomyStrategy, ZombieTierUpgradesEconomyStrategy

globals
    integer BalancedEconomyStrategyId = 0
    integer TierUpgradeEconomyStrategyId = 1
    integer DumbAttackStrategyId = 100
endglobals

function ExecuteStep_EconomyStrategy takes player p, integer id returns nothing
    if id == BalancedEconomyStrategyId then
        call ExecuteStep_EconomyStrategy_Balanced(p)
    elseif id == TierUpgradeEconomyStrategyId then
        call ExecuteStep_EconomyStrategy_TierUpgrades(p)
    else
        call Log(p, Log_StrategyPicker, "Cannot match economy strategy id " + I2S(id) + " for player " + GetPlayerName(p))
    endif
endfunction

function ExecuteStep_AttackStrategy takes player p, integer id returns nothing
    if id == DumbAttackStrategyId then
        call ExecuteStep_DumbZombieAttack(p)
    else
        call Log(p, Log_StrategyPicker, "Cannot match attack strategy id " + I2S(id) + " for player " + GetPlayerName(p))
    endif
endfunction

endlibrary