#!/usr/bin/env pwsh
#Requires -Version 7.0
<#
.SYNOPSIS
    Lists files in a specified directory with optional extension filtering.

.DESCRIPTION
    This PowerShell script lists files in a specified directory.
    It can optionally filter by extension and display just filenames without paths.

.PARAMETER Path
    The directory path to list files from.

.PARAMETER Extension
    Optional. Filter files by this extension.

.PARAMETER NamesOnly
    Optional switch. When specified, displays only filenames without paths.

.EXAMPLE
    ./list_files.ps1 C:\Documents
    Lists all files with full paths in C:\Documents

.EXAMPLE
    ./list_files.ps1 C:\Documents -NamesOnly
    Lists all filenames without paths in C:\Documents

.EXAMPLE
    ./list_files.ps1 C:\Documents txt
    Lists all .txt files with full paths in C:\Documents

.EXAMPLE
    ./list_files.ps1 C:\Documents txt -NamesOnly
    Lists all .txt filenames without paths in C:\Documents
#>

param(
    [Parameter(Mandatory = $true, Position = 0)]
    [string]$Path,

    [Parameter(Mandatory = $false, Position = 1)]
    [string]$Extension,

    [Parameter(Mandatory = $false)]
    [switch]$NamesOnly
)

# Check if the directory exists
if (-not (Test-Path -Path $Path -PathType Container)) {
    Write-Error "Error: Directory '$Path' does not exist."
    exit 1
}

# Prepare filter pattern for Get-ChildItem
$filterPattern = "*"
$Extension = $Extension -replace '^\.', ''  # Remove leading dot if present
if ([string]::IsNullOrWhitespace($Extension)) {
    Write-Host "Listing all files in '$Path':"
} else {
    $filterPattern = "*." + $Extension
    Write-Host "Listing '$filterPattern' files in '$Path':"
}

# Get files based on parameters
$files = Get-ChildItem -Path $Path -File -Filter $filterPattern -Recurse:$false

# Display results based on NamesOnly switch
if ($NamesOnly) {
    $files | ForEach-Object { $_.Name } | Sort-Object
} else {
    $files | ForEach-Object { $_.FullName } | Sort-Object
}

exit 0
