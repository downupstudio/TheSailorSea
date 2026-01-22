@echo off
REM SPDX-FileCopyrightText: Copyright (c) 2023 ave9858 <edging.duj6i@simplelogin.com>
REM SPDX-License-Identifier: CC0-1.0
echo Running Microsoft Edge Uninstaller...
echo.
echo WARNING: This will completely remove Microsoft Edge from your system.
echo.
choice /c yn /m "Do you want to continue? (Y/N)"
if errorlevel 2 goto exit
if errorlevel 1 goto run

:run
echo.
echo Please wait while the script runs...
echo.
powershell -ExecutionPolicy Bypass -NoProfile -Command ^
"$ErrorActionPreference = 'Stop'; ^
$regView = [Microsoft.Win32.RegistryView]::Registry32; ^
$microsoft = [Microsoft.Win32.RegistryKey]::OpenBaseKey([Microsoft.Win32.RegistryHive]::LocalMachine, $regView).OpenSubKey('SOFTWARE\Microsoft', $true); ^
$edgeUWP = \"$env:SystemRoot\SystemApps\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\"; ^
$uninstallRegKey = $microsoft.OpenSubKey('Windows\CurrentVersion\Uninstall\Microsoft Edge'); ^
if ($null -eq $uninstallRegKey) { Write-Error 'Edge is not installed!'; } ^
$uninstallString = $uninstallRegKey.GetValue('UninstallString') + ' --force-uninstall'; ^
$tempPath = \"$env:SystemRoot\SystemTemp\"; ^
if (-not (Test-Path -Path $tempPath) ) { $tempPath = New-Item \"$env:SystemRoot\Temp\$([Guid]::NewGuid().Guid)\" -ItemType Directory; } ^
$fakeDllhostPath = \"$tempPath\dllhost.exe\"; ^
$edgeClient = $microsoft.OpenSubKey('EdgeUpdate\ClientState\{56EB18F8-B008-4CBD-B6D2-8C97FE7E9062}', $true); ^
if ($null -ne $edgeClient.GetValue('experiment_control_labels')) { $edgeClient.DeleteValue('experiment_control_labels'); } ^
$microsoft.CreateSubKey('EdgeUpdateDev').SetValue('AllowUninstall', ''); ^
Copy-Item \"$env:SystemRoot\System32\cmd.exe\" -Destination $fakeDllhostPath; ^
[void](New-Item $edgeUWP -ItemType Directory -ErrorVariable fail -ErrorAction SilentlyContinue); ^
[void](New-Item \"$edgeUWP\MicrosoftEdge.exe\" -ErrorAction Continue); ^
Start-Process $fakeDllhostPath \"/c $uninstallString\" -WindowStyle Hidden -Wait; ^
[void](Remove-Item \"$edgeUWP\MicrosoftEdge.exe\" -ErrorAction Continue); ^
[void](Remove-Item $fakeDllhostPath -ErrorAction Continue); ^
if (-not $fail) { [void](Remove-Item \"$edgeUWP\"); } ^
Write-Output 'Microsoft Edge has been uninstalled!'"
echo.
echo Script completed!
pause
goto end

:exit
echo.
echo Operation cancelled.
pause

:end