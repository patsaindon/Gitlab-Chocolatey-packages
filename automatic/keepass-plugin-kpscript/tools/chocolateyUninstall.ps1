# powershell v2 compatibility
$psVer = $PSVersionTable.PSVersion.Major
if ($psver -ge 3) {
  function Get-ChildItemDir {Get-ChildItem -Directory $args}
} else {
  function Get-ChildItemDir {Get-ChildItem $args}
}
$packageName = 'keepass-plugin-kpscript'
$typName = 'KPScript.exe'
$packageSearch = 'KeePass Password Safe'
try {
# search registry for installed KeePass
$regPath = Get-ItemProperty -Path @('HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*',
                                    'HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*',
                                    'HKCU:\Software\Microsoft\Windows\CurrentVersion\Uninstall\*') `
                            -ErrorAction:SilentlyContinue `
           | Where-Object {$_.DisplayName -like "$packageSearch*"} `
           | ForEach-Object {$_.InstallLocation}
$installPath = $regPath
# search Get-ToolsLocation for portable install
if (! $installPath) {
  Write-Verbose "$($packageSearch) not found in registry."
  $binRoot = Get-ToolsLocation
  $portPath = Join-Path $binRoot "keepass"
  $installPath = Get-ChildItemDir $portPath* -ErrorAction SilentlyContinue
}
if (! $installPath) {
  Write-Verbose "$($packageSearch) not found in $(Get-ToolsLocation)"
  throw "$($packageSearch) install location could not be found."
}
$pluginPath = $installPath
$installFile = Join-Path $pluginPath $typName
Remove-Item -Path $installFile `
            -Force `
            -ErrorAction Continue
if ( Get-Process -Name "KeePass" `
                 -ErrorAction SilentlyContinue ) {
  Write-Warning "$($packageSearch) is running. $($packageName) will be removed at next restart of $($packageSearch)."
}
} catch {
  throw $_.Exception
}
