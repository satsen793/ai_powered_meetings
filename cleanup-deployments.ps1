# GitHub Deployment Cleanup Script
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

# Get all deployments
Write-Host "Fetching deployments..." -ForegroundColor Yellow
try {
    $deploymentsJson = gh api "repos/$Owner/$Repo/deployments" --paginate 2>$null
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Failed to fetch deployments. Check repository access permissions."
        exit 1
    }
    
    $deployments = $deploymentsJson | ConvertFrom-Json
    
    if (-not $deployments -or $deployments.Count -eq 0) {
        Write-Host "No deployments found in this repository." -ForegroundColor Green
        exit 0
    }
    
    Write-Host "Found $($deployments.Count) deployments" -ForegroundColor Green
} catch {
    Write-Error "Error fetching deployments: $($_.Exception.Message)"
    exit 1
}

# Confirm deletion (unless dry run)
if (-not $DryRun) {
    Write-Host ""
    Write-Warning "This will permanently delete ALL $($deployments.Count) deployments from $Owner/$Repo"
    $confirm = Read-Host "Are you sure you want to continue? (y/N)"
    if ($confirm -ne "y" -and $confirm -ne "Y") {
        Write-Host "Operation cancelled." -ForegroundColor Yellow
        exit 0
    }
}

# Process each deployment
$successCount = 0
$errorCount = 0

Write-Host ""
Write-Host "Processing deployments..." -ForegroundColor Yellow

foreach ($deployment in $deployments) {
    $deploymentId = $deployment.id
    $env = $deployment.environment
    $ref = $deployment.ref
    
    try {
        if ($DryRun) {
            Write-Host "[DRY RUN] Would delete deployment $deploymentId ($env - $ref)" -ForegroundColor Cyan
            $successCount++
        } else {
            Write-Host "Processing deployment $deploymentId ($env - $ref)..." -NoNewline
            
            # First, set deployment status to inactive
            $null = gh api "repos/$Owner/$Repo/deployments/$deploymentId/statuses" -f state=inactive -f description="Cleanup script" 2>$null
            
            # Then delete the deployment
            $null = gh api -X DELETE "repos/$Owner/$Repo/deployments/$deploymentId" 2>$null
            
            if ($LASTEXITCODE -eq 0) {
                Write-Host " Done" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host " Failed" -ForegroundColor Red
                $errorCount++
            }
        }
    } catch {
        Write-Host " Error: $($_.Exception.Message)" -ForegroundColor Red
        $errorCount++
    }
    
    # Small delay to avoid rate limiting
    Start-Sleep -Milliseconds 100
}

# Summary
Write-Host ""
Write-Host "=== SUMMARY ===" -ForegroundColor Cyan
Write-Host "Successfully processed: $successCount" -ForegroundColor Green
if ($errorCount -gt 0) {
    Write-Host "Errors: $errorCount" -ForegroundColor Red
}

if ($DryRun) {
    Write-Host ""
    Write-Host "This was a dry run. To actually delete deployments, run:" -ForegroundColor Yellow
    Write-Host "PowerShell -ExecutionPolicy Bypass -File .\cleanup-deployments.ps1 -Owner $Owner -Repo $Repo" -ForegroundColor White
} else {
    Write-Host ""
    Write-Host "Deployment cleanup completed!" -ForegroundColor Green
}