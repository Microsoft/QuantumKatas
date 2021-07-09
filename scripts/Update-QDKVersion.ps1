#!/usr/bin/env pwsh

[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)]
    [string] $Version
);

<#
    .SYNOPSIS
        Updates the contents of this repo to use a given version of
        the Quantum Development Kit.
        
    .PARAMETER Version
        The version that this repo should be updated to. This version should be
        a valid NuGet package version as well as a valid tag for the
        mcr.microsoft.com/quantum/iqsharp-base Docker image.
        
    .EXAMPLE
    
        PS> ./Update-QDKVersion.ps1 -Version 0.18.2106148911
#>

$katasRoot = Join-Path $PSScriptRoot "\..\"

# old version regular expression accounts for possible suffixes like "-beta"
$versionRegex = "(?<oldVersion>[0-9|\.|\-|a-z]+)"

$csStringPackage = 'PackageReference Include=\"Microsoft\.Quantum\.[a-zA-Z\.]+\" Version=\"' + $versionRegex + '\"'
$csStringProject = 'Project Sdk=\"Microsoft.Quantum.Sdk/' + $versionRegex + '\"'
$csFiles = (Get-ChildItem -Path $katasRoot -file -Recurse -Include "*.csproj" | ForEach-Object { Select-String -Path $_ -Pattern "Microsoft.Quantum" } | Select-Object -Unique Path)
$csFiles | ForEach-Object {
    (Get-Content -Encoding UTF8 $_.Path) | ForEach-Object {
         $isQuantumPackage = $_ -match $csStringPackage
         $isQuantumProject = $_ -match $csStringProject
         if ($isQuantumPackage -or $isQuantumProject) {
             $_ -replace $Matches.oldVersion, $Version
         } else {
             $_
         }
    } | Set-Content -Encoding UTF8 $_.Path
}

$dockerString = "FROM mcr.microsoft.com/quantum/iqsharp-base:$versionRegex"
$dockerPath = Join-Path $katasRoot "Dockerfile"
(Get-Content -Path $dockerPath) | ForEach-Object {
         $isQuantumPackage = $_ -match $dockerString
         if ($isQuantumPackage) {
             $_ -replace $Matches.oldVersion, $Version
         } else {
             $_
         }
    } | Set-Content -Path $dockerPath


$ps1String = "Microsoft.Quantum.IQSharp --version 0.18.210729073-pull
$ps1Path = Join-Path $katasRoot "scripts\install-iqsharp.ps1"
(Get-Content -Path $ps1Path) | ForEach-Object {
         $isQuantumPackage = $_ -match $ps1String
         if ($isQuantumPackage) {
             $_ -replace $Matches.oldVersion, $Version
         } else {
             $_
         }
    } | Set-Content -Path $ps1Path

$updateps1String = "PS> ./Update-QDKVersion.ps1 -Version $versionRegex"
$updateps1Path = Join-Path $katasRoot "scripts\Update-QDKVersion.ps1"
(Get-Content -Path $updateps1Path) | ForEach-Object {
         $isQuantumPackage = $_ -match $updateps1String
         if ($isQuantumPackage) {
             $_ -replace $Matches.oldVersion, $Version
         } else {
             $_
         }
    } | Set-Content -Path $updateps1Path

$contributingString = "PS> ./scripts/Update-QDKVersion.ps1 $versionRegex"
$contributingPath = Join-Path $katasRoot ".github\CONTRIBUTING.md"
(Get-Content -Path $contributingPath) | ForEach-Object {
         $isQuantumPackage = $_ -match $contributingString
         if ($isQuantumPackage) {
             $_ -replace $Matches.oldVersion, $Version
         } else {
             $_
         }
    } | Set-Content -Path $contributingPath

