# GitHub Check Runs Cleanup Script
param(
    [Parameter(Mandatory=$false)]
    [string]$Owner,
    
    [Parameter(Mandatory=$false)]
    [string]$Repo,
    
    [Parameter(Mandatory=$false)]
    [switch]$DryRun
)

# Function to get repository info from current directory
function Get-RepoInfo {
    try {
        $remote = git remote get-url origin 2>$null
        if ($remote -match "github\.com[:/]([^/]+)/([^/.]+)") {
            return @{
                Owner = $matches[1]
                Repo = $matches[2]
            }
        }
    } catch {
        Write-Warning "Could not determine repository info from git remote"
    }
    return $null
}

# Get repository info
if (-not $Owner -or -not $Repo) {
    Write-Host "Attempting to detect repository info..." -ForegroundColor Yellow
    $repoInfo = Get-RepoInfo
    
    if ($repoInfo) {
        if (-not $Owner) { $Owner = $repoInfo.Owner }
        if (-not $Repo) { $Repo = $repoInfo.Repo }
        Write-Host "Detected repository: $Owner/$Repo" -ForegroundColor Green
    } else {
        if (-not $Owner) { $Owner = Read-Host "Enter GitHub username/organization" }
        if (-not $Repo) { $Repo = Read-Host "Enter repository name" }
    }
}

# Verify GitHub CLI authentication
try {
    $null = gh auth status 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "GitHub CLI is not authenticated. Run 'gh auth login' first."
        exit 1
    }
} catch {
    Write-Error "GitHub CLI is not installed. Install it with: winget install GitHub.cli"
    exit 1
}

Write-Host "Repository: $Owner/$Repo" -ForegroundColor Cyan
Write-Host "Dry Run Mode: $DryRun" -ForegroundColor Cyan
Write-Host ""

# Get recent commits to check for check runs
Write-Host "Fetching recent commits..." -ForegroundColor Yellow
try {
    $commitsJson = gh api "repos/$Owner/$Repo/commits" --limit 10 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to fetch commits. Check repository access permissions."
        exit 1
    }
    
    $commits = $commitsJson | ConvertFrom-Json
    Write-Host "Found $($commits.Count) recent commits to check" -ForegroundColor Green
} catch {
    Write-Error "Error fetching commits: $($_.Exception.Message)"
    exit 1
}

$totalCheckRuns = 0
$deletedCount = 0

foreach ($commit in $commits) {
    $sha = $commit.sha
    Write-Host "Checking commit $($sha.Substring(0,8))..." -ForegroundColor Yellow
    
    try {
        # Get check runs for this commit
        $checkRunsJson = gh api "repos/$Owner/$Repo/commits/$sha/check-runs" 2>$null
        if ($LASTEXITCODE -eq 0) {
            $checkRuns = ($checkRunsJson | ConvertFrom-Json).check_runs
            
            if ($checkRuns -and $checkRuns.Count -gt 0) {
                $totalCheckRuns += $checkRuns.Count
                Write-Host "  Found $($checkRuns.Count) check runs" -ForegroundColor Cyan
                
                foreach ($checkRun in $checkRuns) {
                    if ($checkRun.status -eq "completed" -and $checkRun.conclusion -eq "failure") {
                        if ($DryRun) {
                            Write-Host "  [DRY RUN] Would delete failed check: $($checkRun.name) (ID: $($checkRun.id))" -ForegroundColor Yellow
                            $deletedCount++
                        } else {
                            Write-Host "  Deleting failed check: $($checkRun.name)..." -NoNewline
                            # Note: GitHub doesn't allow deleting check runs via API
                            # This is just to show what would be deleted
                            Write-Host " (Cannot delete - GitHub limitation)" -ForegroundColor Red
                        }
                    }
                }
            }
        }
    } catch {
        Write-Host "  Error checking commit: $($_.Exception.Message)" -ForegroundColor Red
    }
}

# Summary
Write-Host ""
Write-Host "=== CHECK RUNS SUMMARY ===" -ForegroundColor Cyan
Write-Host "Total check runs found: $totalCheckRuns" -ForegroundColor Green
Write-Host "Failed checks that would be deleted: $deletedCount" -ForegroundColor Yellow

Write-Host ""
Write-Host "NOTE: GitHub API doesn't allow deleting check runs directly." -ForegroundColor Yellow
Write-Host "Failed checks usually disappear when you:" -ForegroundColor Yellow
Write-Host "1. Push new commits that pass" -ForegroundColor White
Write-Host "2. Delete the branch (if it's a feature branch)" -ForegroundColor White
Write-Host "3. Disable the failing check/app in repository settings" -ForegroundColor White