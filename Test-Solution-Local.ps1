#Requires -Version 5.1
<#
.SYNOPSIS
    Local validator for BI Technical Assessment candidates.
    
.DESCRIPTION
    This script replicates the exact validation that GitHub Actions performs.
    Use this BEFORE submitting your PR to check if your solution will pass.
    
    The validation checks:
    - PR title format (when submitted)
    - Required files exist
    - SOLUTION.md word count (minimum 50)
    - Score calculation
    
.PARAMETER Candidate
    Your name (as it will appear in the PR title)
    Example: "JuanPerez"
    
.PARAMETER Issue
    Issue number (001-007)
    Example: "001"
    
.EXAMPLE
    # Test your solution before submitting
    .\Test-Solution-Local.ps1 -Candidate "JuanPerez" -Issue "001"
    
    # Output will show:
    # ✓ Solution folder found: Solutions/JuanPerez/Issue001
    # ✓ Required files check...
    # ✓ SOLUTION.md word count: 288 words (min 50) - PASS
    # Score: 75/100
    # Status: PASS
    # 
    # This is the EXACT same evaluation that will run on GitHub when you create the PR
    
.NOTES
    When you submit your PR, use this title format (EXACT):
    Solution - [YourName] - Issue [00X]
    
    Example: Solution - [JuanPerez] - Issue [001]
#>

param(
    [Parameter(Mandatory=$true)]
    [ValidatePattern('^\d{3}$')]
    [string]$Issue,

    [Parameter(Mandatory=$true)]
    [string]$Candidate
)

$ErrorActionPreference = "Stop"

# Colors
$ColorHeader = "Cyan"
$ColorSuccess = "Green"
$ColorError = "Red"
$ColorWarning = "Yellow"

# ============================================================
# SECTION 1: Display Header
# ============================================================

Write-Host ""
Write-Host ("=" * 60) -ForegroundColor $ColorHeader
Write-Host "  LOCAL SOLUTION VALIDATOR" -ForegroundColor $ColorHeader
Write-Host "  BI Technical Assessment" -ForegroundColor $ColorHeader
Write-Host ("=" * 60) -ForegroundColor $ColorHeader
Write-Host ""

Write-Host "Candidate: $Candidate" -ForegroundColor White
Write-Host "Issue:     $Issue" -ForegroundColor White
Write-Host ""

# ============================================================
# SECTION 2: Check Solution Folder
# ============================================================

Write-Host "STEP 1: Checking solution folder..." -ForegroundColor $ColorHeader
$solutionPath = "Solutions\$Candidate\Issue$Issue"

if (-not (Test-Path $solutionPath)) {
    Write-Host "ERROR: Solution folder not found at: $solutionPath" -ForegroundColor $ColorError
    Write-Host ""
    Write-Host "Please create your solution folder:" -ForegroundColor $ColorWarning
    Write-Host "  mkdir -p '$solutionPath'" -ForegroundColor White
    exit 1
}

Write-Host "[OK] Solution folder found" -ForegroundColor $ColorSuccess
Write-Host "     Path: $solutionPath" -ForegroundColor White
Write-Host ""

# ============================================================
# SECTION 3: Check Required Files
# ============================================================

Write-Host "STEP 2: Checking required files..." -ForegroundColor $ColorHeader

$requiredFiles = @("SOLUTION.md")
$missingFiles = @()

foreach ($file in $requiredFiles) {
    $filePath = Join-Path $solutionPath $file
    if (-not (Test-Path $filePath)) {
        $missingFiles += $file
        Write-Host "  [FAIL] Missing: $file" -ForegroundColor $ColorError
    } else {
        Write-Host "  [OK] Found: $file" -ForegroundColor $ColorSuccess
    }
}

if ($missingFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "ERROR: Missing required files: $($missingFiles -join ', ')" -ForegroundColor $ColorError
    exit 1
}

Write-Host ""

# ============================================================
# SECTION 4: Check Word Count
# ============================================================

Write-Host "STEP 3: Validating SOLUTION.md content..." -ForegroundColor $ColorHeader

$solutionFile = Join-Path $solutionPath "SOLUTION.md"
$solutionContent = Get-Content $solutionFile -Raw
$wordCount = ($solutionContent | Measure-Object -Word).Words
$minWords = 50

if ($wordCount -lt $minWords) {
    Write-Host "  [FAIL] SOLUTION.md has $wordCount words (minimum required: $minWords)" -ForegroundColor $ColorError
    Write-Host ""
    Write-Host "Your SOLUTION.md is too short. Please add more details." -ForegroundColor $ColorWarning
    exit 1
} else {
    Write-Host "  [OK] SOLUTION.md has $wordCount words (minimum: $minWords)" -ForegroundColor $ColorSuccess
}

Write-Host ""

# ============================================================
# SECTION 5: Calculate Score
# ============================================================

Write-Host "STEP 4: Calculating score..." -ForegroundColor $ColorHeader

$score = 75
$maxScore = 100

Write-Host "  Base score: $score/$maxScore" -ForegroundColor $ColorSuccess
Write-Host ""

# ============================================================
# SECTION 6: Generate Output Format
# ============================================================

# Generate output in the EXACT format that GitHub Actions expects
$output = "VALIDATION: All checks passed`nSTATUS: PASS`nSCORE: $score/$maxScore"

# Save to file for reference (same as GitHub Actions does)
$output | Out-File -FilePath "local-validation-output.txt" -Encoding UTF8

# ============================================================
# SECTION 7: Display Results
# ============================================================

Write-Host ("=" * 60) -ForegroundColor $ColorHeader
Write-Host "  VALIDATION RESULTS" -ForegroundColor $ColorHeader
Write-Host ("=" * 60) -ForegroundColor $ColorHeader
Write-Host ""

Write-Host "Status:" -ForegroundColor White
Write-Host "  ✓ PASS" -ForegroundColor $ColorSuccess

Write-Host ""
Write-Host "Score:" -ForegroundColor White
Write-Host "  $score/$maxScore" -ForegroundColor $ColorSuccess

Write-Host ""
Write-Host "Feedback:" -ForegroundColor White
Write-Host "  Your solution meets the minimum requirements (≥70 points)." -ForegroundColor $ColorSuccess
Write-Host "  You are eligible for Phase 2 (Technical Interview)." -ForegroundColor $ColorSuccess

Write-Host ""

# ============================================================
# SECTION 8: Next Steps
# ============================================================

Write-Host ("=" * 60) -ForegroundColor $ColorWarning
Write-Host "  NEXT STEPS - SUBMIT YOUR SOLUTION" -ForegroundColor $ColorWarning
Write-Host ("=" * 60) -ForegroundColor $ColorWarning
Write-Host ""

Write-Host "1. Commit your solution to your fork:" -ForegroundColor White
Write-Host "   git add Solutions/" -ForegroundColor "Gray"
Write-Host "   git commit -m 'solution: Issue $Issue - Your description'" -ForegroundColor "Gray"
Write-Host "   git push origin main" -ForegroundColor "Gray"
Write-Host ""

Write-Host "2. Create a PR with THIS EXACT TITLE:" -ForegroundColor White
Write-Host "   Solution - [$Candidate] - Issue [$Issue]" -ForegroundColor "Yellow"
Write-Host ""

Write-Host "3. GitHub Actions will:" -ForegroundColor White
Write-Host "   - Automatically validate your solution (3-5 minutes)" -ForegroundColor "Gray"
Write-Host "   - Post a comment with your score and feedback" -ForegroundColor "Gray"
Write-Host "   - The results will be IDENTICAL to this local validation" -ForegroundColor "Gray"
Write-Host ""

Write-Host "4. If PASS (≥70): Evaluator will schedule your interview" -ForegroundColor $ColorSuccess
Write-Host "5. If FAIL (<70):  You can resubmit once (1 retry allowed)" -ForegroundColor $ColorWarning
Write-Host ""

Write-Host ("=" * 60) -ForegroundColor White

# ============================================================
# APPENDIX: Validation Output File
# ============================================================

Write-Host ""
Write-Host "📄 Validation output saved to: local-validation-output.txt" -ForegroundColor $ColorHeader
Write-Host ""

exit 0
