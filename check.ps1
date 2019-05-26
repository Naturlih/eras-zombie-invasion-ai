Remove-Item .\bundle.txt -ErrorAction Ignore
Get-ChildItem . | Where-Object {$_.Name -like '*.j'} | Where-Object {$_.Name -ne 'init.j'} | Get-Content | Add-Content -Encoding ascii -force .\bundle.txt
Get-Content .\*.j | Add-Content -Encoding ascii -force .\bundle_test.j
Invoke-Expression ('JassHelper\jasshelper.exe --scriptonly JassHelper\common.j JassHelper\Blizzard.j bundle_test.j result.j')
Start-Sleep 3
Remove-Item 'bundle_test.j'
Remove-Item 'result.j'