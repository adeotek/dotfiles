#requires -Version 7.0

<#
.SYNOPSIS
    Extracts GitHub organization repository and team information.

.DESCRIPTION
    This script checks for GitHub CLI availability, installs it if needed using winget,
    and then extracts repository and team information from a specified GitHub organization.

.PARAMETER Organization
    The GitHub organization name to query.

.PARAMETER OutputPath
    The output directory for CSV files. Defaults to the current directory.

.EXAMPLE
    .\GetGitHubStats.ps1 -Organization "myorg"

.EXAMPLE
    .\GetGitHubStats.ps1 -Organization "myorg" -OutputPath "C:\Reports"
#>

[CmdletBinding()]
param(
    [Alias('h')]
    [switch]$Help,

    [Parameter(Mandatory = $true, HelpMessage = "GitHub organization name")]
    [string]$Organization,

    [Parameter(Mandatory = $false, HelpMessage = "Output directory for CSV files")]
    [string]$OutputPath = $PWD.Path
)

# Set strict mode and error action preference
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

if ($Help) {
    Get-Help $PSCommandPath -Detailed
    exit 0
}

# Function to check if a command exists
function Test-CommandExists {
    param([string]$Command)

    $null = Get-Command $Command -ErrorAction SilentlyContinue
    return $?
}

# Function to check and install GitHub CLI
function Install-GitHubCLI {
    Write-Host "Checking for GitHub CLI (gh)..." -ForegroundColor Cyan

    if (Test-CommandExists "gh") {
        $ghVersion = gh --version | Select-Object -First 1
        Write-Host "✓ GitHub CLI is already installed: $ghVersion" -ForegroundColor Green
        return $true
    }

    Write-Host "GitHub CLI not found. Checking for winget..." -ForegroundColor Yellow

    if (-not (Test-CommandExists "winget")) {
        Write-Host "✗ winget is not available. Please install App Installer from Microsoft Store." -ForegroundColor Red
        return $false
    }

    Write-Host "Installing GitHub CLI using winget..." -ForegroundColor Cyan

    try {
        winget install --id GitHub.cli --source winget --silent --accept-package-agreements --accept-source-agreements

        # Refresh environment variables
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")

        # Verify installation
        Start-Sleep -Seconds 2
        if (Test-CommandExists "gh") {
            $ghVersion = gh --version | Select-Object -First 1
            Write-Host "✓ GitHub CLI installed successfully: $ghVersion" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "✗ GitHub CLI installation completed but command not found. Try restarting your terminal." -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Failed to install GitHub CLI: $_" -ForegroundColor Red
        return $false
    }
}

# Function to check GitHub CLI authentication
function Test-GitHubAuth {
    Write-Host "Checking GitHub CLI authentication..." -ForegroundColor Cyan

    try {
        $null = gh auth status 2>&1
        if ($LASTEXITCODE -eq 0) {
            Write-Host "✓ GitHub CLI is authenticated" -ForegroundColor Green
            return $true
        }
        else {
            Write-Host "✗ GitHub CLI is not authenticated. Please run: gh auth login" -ForegroundColor Red
            return $false
        }
    }
    catch {
        Write-Host "✗ Failed to check authentication status: $_" -ForegroundColor Red
        return $false
    }
}

# Function to get repository members
function Get-RepositoryMembers {
    param([string]$OrgName)

    Write-Host "`nFetching repositories for organization '$OrgName'..." -ForegroundColor Cyan

    try {
        # Get all repositories
        $repos = gh repo list $OrgName --limit 1000 --json name | ConvertFrom-Json
        Write-Host "Found $($repos.Count) repositories" -ForegroundColor Green

        $results = @()
        $counter = 0

        foreach ($repo in $repos) {
            $counter++
            Write-Progress -Activity "Processing Repositories" -Status "Repository $counter of $($repos.Count): $($repo.name)" -PercentComplete (($counter / $repos.Count) * 100)

            # Get direct collaborators (users) - only those directly assigned, not through team membership
            try {
                $collaborators = gh api "repos/$OrgName/$($repo.name)/collaborators?affiliation=direct" --paginate | ConvertFrom-Json
                foreach ($collab in $collaborators) {
                    $results += [PSCustomObject]@{
                        Repository = $repo.name
                        Member     = $collab.login
                        Type       = "User"
                        Role       = $collab.permissions.admin ? "admin" : ($collab.permissions.maintain ? "maintain" : ($collab.permissions.push ? "write" : ($collab.permissions.triage ? "triage" : "read")))
                    }
                }
            }
            catch {
                Write-Warning "Failed to get collaborators for $($repo.name): $_"
            }

            # Get team access
            try {
                $teams = gh api "repos/$OrgName/$($repo.name)/teams" --paginate | ConvertFrom-Json
                foreach ($team in $teams) {
                    # Normalize team permission to match user role values
                    $normalizedRole = switch ($team.permission) {
                        "pull" { "read" }
                        "push" { "write" }
                        "admin" { "admin" }
                        "maintain" { "maintain" }
                        default { $team.permission }
                    }

                    $results += [PSCustomObject]@{
                        Repository = $repo.name
                        Member     = $team.name
                        Type       = "Team"
                        Role       = $normalizedRole
                    }
                }
            }
            catch {
                Write-Warning "Failed to get teams for $($repo.name): $_"
            }
        }

        Write-Progress -Activity "Processing Repositories" -Completed
        Write-Host "✓ Collected $($results.Count) repository member entries" -ForegroundColor Green

        return $results
    }
    catch {
        Write-Host "✗ Failed to fetch repository information: $_" -ForegroundColor Red
        throw
    }
}

# Function to get team members
function Get-TeamMembers {
    param([string]$OrgName)

    Write-Host "`nFetching teams for organization '$OrgName'..." -ForegroundColor Cyan

    try {
        # Get all teams
        $teams = gh api "orgs/$OrgName/teams" --paginate | ConvertFrom-Json
        Write-Host "Found $($teams.Count) teams" -ForegroundColor Green

        $results = @()
        $counter = 0

        foreach ($team in $teams) {
            $counter++
            Write-Progress -Activity "Processing Teams" -Status "Team $counter of $($teams.Count): $($team.name)" -PercentComplete (($counter / $teams.Count) * 100)

            # Get team members
            try {
                $members = gh api "orgs/$OrgName/teams/$($team.slug)/members" --paginate | ConvertFrom-Json

                foreach ($member in $members) {
                    # Get member details (name and email)
                    $memberName = $member.login
                    $email = "N/A"

                    try {
                        $userDetails = gh api "users/$($member.login)" | ConvertFrom-Json

                        # Use actual name if available, otherwise fall back to login
                        if (-not [string]::IsNullOrEmpty($userDetails.name)) {
                            $memberName = $userDetails.name
                        }

                        # Try to get email from user profile
                        if (-not [string]::IsNullOrEmpty($userDetails.email)) {
                            $email = $userDetails.email
                        }
                        else {
                            # Try to get email from organization membership
                            try {
                                $orgMembership = gh api "orgs/$OrgName/members/$($member.login)" | ConvertFrom-Json
                                if (-not [string]::IsNullOrEmpty($orgMembership.email)) {
                                    $email = $orgMembership.email
                                }
                            }
                            catch {
                                # Email not available
                            }
                        }
                    }
                    catch {
                        # Use defaults if API call fails
                    }

                    $results += [PSCustomObject]@{
                        Team        = $team.name
                        Member      = $memberName
                        MemberEmail = $email
                    }
                }
            }
            catch {
                Write-Warning "Failed to get members for team $($team.name): $_"
            }
        }

        Write-Progress -Activity "Processing Teams" -Completed
        Write-Host "✓ Collected $($results.Count) team member entries" -ForegroundColor Green

        return $results
    }
    catch {
        Write-Host "✗ Failed to fetch team information: $_" -ForegroundColor Red
        throw
    }
}

# Main script execution
try {
    Write-Host "`n=== GitHub Organization Stats Extractor ===" -ForegroundColor Cyan
    Write-Host "Organization: $Organization" -ForegroundColor White
    Write-Host "Output Path: $OutputPath`n" -ForegroundColor White

    # Ensure output directory exists
    if (-not (Test-Path $OutputPath)) {
        New-Item -ItemType Directory -Path $OutputPath -Force | Out-Null
        Write-Host "Created output directory: $OutputPath" -ForegroundColor Green
    }

    # Check and install GitHub CLI if needed
    if (-not (Install-GitHubCLI)) {
        throw "GitHub CLI is required but could not be installed."
    }

    # Check authentication
    if (-not (Test-GitHubAuth)) {
        throw "GitHub CLI authentication is required. Please run: gh auth login"
    }

    # Generate output file paths
    $repositoriesFile = Join-Path $OutputPath "$Organization-repositories.csv"
    $teamsFile = Join-Path $OutputPath "$Organization-teams.csv"

    # Extract repository members
    $repoMembers = Get-RepositoryMembers -OrgName $Organization
    if ($repoMembers.Count -gt 0) {
        $repoMembers | Export-Csv -Path $repositoriesFile -NoTypeInformation -Encoding UTF8
        Write-Host "`n✓ Repository data saved to: $repositoriesFile" -ForegroundColor Green
    }
    else {
        Write-Host "`n⚠ No repository member data found" -ForegroundColor Yellow
    }

    # Extract team members
    $teamMembers = Get-TeamMembers -OrgName $Organization
    if ($teamMembers.Count -gt 0) {
        $teamMembers | Export-Csv -Path $teamsFile -NoTypeInformation -Encoding UTF8
        Write-Host "✓ Team data saved to: $teamsFile" -ForegroundColor Green
    }
    else {
        Write-Host "⚠ No team member data found" -ForegroundColor Yellow
    }

    Write-Host "`n=== Extraction Complete ===" -ForegroundColor Cyan
    Write-Host "Repositories: $($repoMembers.Count) entries" -ForegroundColor White
    Write-Host "Teams: $($teamMembers.Count) entries`n" -ForegroundColor White
}
catch {
    Write-Host "`n✗ Script failed: $_" -ForegroundColor Red
    exit 1
}
