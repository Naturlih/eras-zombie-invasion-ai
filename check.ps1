
$AllItems = ""
Get-ChildItem ".\" -Filter *.j | 
Foreach-Object {
    (gc $_.FullName) -replace '(library Init requires ZombieAttack, ZombieCreate, ZombieUpgrades)|(library Common)|(library ZombieAttack requires Common)|(library ZombieCreate requires Common)|(library ZombieUpgrades requires Common)|(endlibrary)', '' |
    Out-File -Encoding ascii ($_.FullName + '_cleaned')
    $AllItems = $AllItems + " " + $_.Name + '_cleaned'
}

Invoke-Expression ('jc113\pjass.exe jc113\common.j jc113\Blizzard.j ' + $AllItems)

Get-ChildItem ".\" -Filter *.j_cleaned | 
Foreach-Object {
    Remove-Item -path $_.FullName
}