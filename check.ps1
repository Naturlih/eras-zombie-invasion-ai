Get-Content .\*.j | Add-Content -Encoding ascii -force .\bundle.j
Invoke-Expression ('JassHelper\jasshelper.exe --scriptonly JassHelper\common.j JassHelper\Blizzard.j bundle.j result.j')
Start-Sleep 3
Remove-Item 'bundle.j'
Remove-Item 'result.j'