﻿$ErrorActionPreference = 'Stop'
import-module au

$release = 'http://personal.avira-update.com/package/webloader/win32/pecl/avira_free_antivirus.exe'

function global:au_SearchReplace {
	@{
		'tools/chocolateyInstall.ps1' = @{
			"(^[$]url\s*=\s*)('.*')"      		= "`$1'$($Latest.URL32)'"
			"(^[$]checksum\s*=\s*)('.*')" 		= "`$1'$($Latest.Checksum32)'"
			"(^[$]checksumtype\s*=\s*)('.*')" 	= "`$1'$($Latest.ChecksumType32)'"
		}
	}
}

function Get-Version($name) {
	$version_file=$(../../tools/Get-InstalledApps.ps1 -ComputerName $env:COMPUTERNAME -NameRegex $name).DisplayVersion | select-object -first 1
	while($version_file.count -eq 0)
	{
		$version_file=$(../../tools/Get-InstalledApps.ps1 -ComputerName $env:COMPUTERNAME -NameRegex $name).DisplayVersion | select-object -first 1
		Start-Sleep -Seconds 1
	}
	return $version_file
}

function global:au_GetLatest {
	$File = Join-Path($(Split-Path $script:MyInvocation.MyCommand.Path)) "avira.exe"
	Invoke-WebRequest -Uri $release -OutFile $File
	Start-Process $File -ArgumentList '/s' -Wait

	$version = Get-Version("Avira")
	$Latest = @{ URL32 = $release; Version = $version }
	return $Latest
}

update -ChecksumFor 32