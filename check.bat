powershell -Command "(gc Library.j) -replace '(library Init requires ZombieAttack, ZombieCreate, ZombieUpgrades)|(library Common)|(library ZombieAttack requires Common)|(library ZombieCreate requires Common)|(library ZombieUpgrades requires Common)|(endlibrary)', '' | Out-File -Encoding ascii Library_cleaned.j"
powershell -Command "(gc CreateZombz.j) -replace '(library Init requires ZombieAttack, ZombieCreate, ZombieUpgrades)|(library Common)|(library ZombieAttack requires Common)|(library ZombieCreate requires Common)|(library ZombieUpgrades requires Common)|(endlibrary)', '' | Out-File -Encoding ascii CreateZombz_cleaned.j"
powershell -Command "(gc ZombieUpgrades.j) -replace '(library Init requires ZombieAttack, ZombieCreate, ZombieUpgrades)|(library Common)|(library ZombieAttack requires Common)|(library ZombieCreate requires Common)|(library ZombieUpgrades requires Common)|(endlibrary)', '' | Out-File -Encoding ascii ZombieUpgrades_cleaned.j"
powershell -Command "(gc ZombieAttack.j) -replace '(library Init requires ZombieAttack, ZombieCreate, ZombieUpgrades)|(library Common)|(library ZombieAttack requires Common)|(library ZombieCreate requires Common)|(library ZombieUpgrades requires Common)|(endlibrary)', '' | Out-File -Encoding ascii ZombieAttack_cleaned.j"
powershell -Command "(gc init.j) -replace '(library Init requires ZombieAttack, ZombieCreate, ZombieUpgrades)|(library Common)|(library ZombieAttack requires Common)|(library ZombieCreate requires Common)|(library ZombieUpgrades requires Common)|(endlibrary)', '' | Out-File -Encoding ascii init_cleaned.j"
jc113\pjass.exe jc113\common.j jc113\Blizzard.j Library_cleaned.j CreateZombz_cleaned.j ZombieAttack_cleaned.j ZombieUpgrades_cleaned.j init_cleaned.j
del Library_cleaned.j
del CreateZombz_cleaned.j
del ZombieUpgrades_cleaned.j
del ZombieAttack_cleaned.j
del init_cleaned.j
