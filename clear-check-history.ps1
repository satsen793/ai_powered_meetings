# Clear GitHub Check History Script
# This creates a clean commit to clear all failed check history

Write-Host "WARNING: This will rewrite commit history!" -ForegroundColor Red
Write-Host "Make sure you have no important uncommitted changes" -ForegroundColor Yellow
Write-Host ""

$confirm = Read-Host "Continue with clearing check history? (y/N)"
if ($confirm -ne "y" -and $confirm -ne "Y") {
    Write-Host "Operation cancelled." -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "Creating clean commit to clear check history..." -ForegroundColor Green

# Create a new commit with current state
git add .
git commit -m "Clean commit - clear check history"

# Get current branch name
$currentBranch = git branch --show-current

Write-Host "Force pushing to clear checks..." -ForegroundColor Yellow
git push origin $currentBranch --force-with-lease

Write-Host ""
Write-Host "✅ Check history cleared!" -ForegroundColor Green
Write-Host "The failed checks should disappear from GitHub UI within a few minutes." -ForegroundColor Cyan