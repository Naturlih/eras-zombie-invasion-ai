library AttackStrategyByPathes requires Common, Logging, ZombieCreate
globals
    AttackPath northPath
endglobals

struct AttackPath
    location array points[10]
    integer size
endstruct

function RectCenter takes rect r returns location
    return Location(GetRectCenterX(r), GetRectCenterY(r))
endfunction

function AddPointToPath takes AttackPath path, location l returns nothing
    if path.size < 10 then
        set path.points[path.size] = l
        set path.size = path.size + 1
    else
        call LogModule(Log_AttackStrategyByPathes, "Path cannot have more than 10 points, ignoring")
    endif
endfunction

//===========================================================================

function Init_AttackStrategy_ByPathes takes nothing returns nothing
    call AddPointToPath(northPath, RectCenter(gg_rct_PlateauRally))
    call AddPointToPath(northPath, RectCenter(gg_rct_Zombie11Attack2))
    call AddPointToPath(northPath, RectCenter(gg_rct_Zombie11Attack3))
    call AddPointToPath(northPath, RectCenter(gg_rct_SwedenWall1))
    call AddPointToPath(northPath, RectCenter(gg_rct_NorwayFound))
    call AddPointToPath(northPath, RectCenter(gg_rct_BritainFound))
    call AddPointToPath(northPath, RectCenter(gg_rct_IrelandFound))
    
    call AddPointToPath(northPath, RectCenter(gg_rct_PlateauRally))
endfunction

function ExecuteStep_AttackStrategy_ByPathes takes player p returns nothing
    //call AttackOrderForGroup(p)
endfunction

endlibrary
