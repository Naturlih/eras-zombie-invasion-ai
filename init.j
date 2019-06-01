// DO NOT COPY
// it's needed for code checker to work
globals
    trigger gg_trg_Init
    integer array udg_PlayerGoldIncome
    integer udg_ZombieLevel
    rect                    gg_rct_American_Zombies    = null
    rect                    gg_rct_Brit_in_America     = null
    rect                    gg_rct_GreeceFound         = null
    rect                    gg_rct_IrelandFound        = null
    rect                    gg_rct_Zombie10Attack1     = null
    rect                    gg_rct_Spanish_in_America  = null
    rect                    gg_rct_Zombie11Ex1         = null
    rect                    gg_rct_Zombie12Attack1     = null
    rect                    gg_rct_Spanish_Zombies     = null
    rect                    gg_rct_TurkeyNoobProtect   = null
    rect                    gg_rct_SuperFort_Whole     = null
    rect                    gg_rct_Sweden_Ice_Melt     = null
    rect                    gg_rct_Zombies_Canada      = null
    rect                    gg_rct_Zombie10Attack2     = null
    rect                    gg_rct_Zombie10Attack3     = null
    rect                    gg_rct_Zombie11Attack2     = null
    rect                    gg_rct_Zombie11Attack3     = null
    rect                    gg_rct_RussiaWall3         = null
    rect                    gg_rct_FranceWall4         = null
    rect                    gg_rct_FranceWall5         = null
    rect                    gg_rct_PolandWall1         = null
    rect                    gg_rct_PolandWall2         = null
    rect                    gg_rct_PolandWall3         = null
    rect                    gg_rct_NorwayFound         = null
    rect                    gg_rct_BritainTowers3      = null
    rect                    gg_rct_BritainTowers1      = null
    rect                    gg_rct_RussiaFound         = null
    rect                    gg_rct_TurkeyTech          = null
    rect                    gg_rct_GermanyTowers2      = null
    rect                    gg_rct_GermanyTowers3      = null
    rect                    gg_rct_PlateauRally        = null
    rect                    gg_rct_AISideAttack1       = null
    rect                    gg_rct_ItalyStuck1         = null
    rect                    gg_rct_SuperFortSouthWall  = null
    rect                    gg_rct_SuperFortEastWall   = null
    rect                    gg_rct_SuperFortNorthWall  = null
    rect                    gg_rct_SouthEuroStuck2     = null
    rect                    gg_rct_SouthEuroStuck1     = null
    rect                    gg_rct_AmericaWhole        = null
    rect                    gg_rct_SuperFort_Expel     = null
    rect                    gg_rct_SpecialUnitZone     = null
    rect                    gg_rct_Zombies_Florida     = null
    rect                    gg_rct_Zombies_Mexico      = null
    rect                    gg_rct_Balkan_Revolt       = null
    rect                    gg_rct_IcelandFound        = null
    rect                    gg_rct_SwedenWall1         = null
    rect                    gg_rct_RomaniaFound        = null
    rect                    gg_rct_EgyptTowers1        = null
    rect                    gg_rct_MoroccoTech         = null
    rect                    gg_rct_MoroccoTowers2      = null
    rect                    gg_rct_SomaliaW1H1         = null
    rect                    gg_rct_SomaliaW1V1         = null
    rect                    gg_rct_SomaliaW2H1         = null
    rect                    gg_rct_SomaliaW2V1         = null
    rect                    gg_rct_CongoFound          = null
    rect                    gg_rct_CongoTech           = null
    rect                    gg_rct_SomaliaWall1        = null
    rect                    gg_rct_SomaliaFound        = null
    rect                    gg_rct_SomaliaTech         = null
    rect                    gg_rct_BritainFound        = null
    rect                    gg_rct_RomaniaTowers1      = null
    rect                    gg_rct_GreeceSwap          = null
    rect                    gg_rct_IrelandSwap         = null
endglobals
function main takes nothing returns nothing
endfunction

// DO NOT COPY


library Init requires ZombieAi 
// To make this work create trigger with name Init (name is important), add event Map initialization (important), convert to custom text and copy everything below DO NOT COPY comment line

// When changing balance don't forget to update base and inc prices for zombie tech upgrades in ZombieStatsResearch
// Based on prices AI decides when to boost eco and when to upgrade zombz

// Also all zombie unit types should be saved in Zombie_Module_UnitCreate, otherwise builder module will not create them
function Trig_Init_Actions takes nothing returns nothing
    call StartZombieAi()
endfunction

//===========================================================================
function InitTrig_Init takes nothing returns nothing
    set gg_trg_Init = CreateTrigger()
    call TriggerAddAction( gg_trg_Init, function Trig_Init_Actions )
endfunction

endlibrary