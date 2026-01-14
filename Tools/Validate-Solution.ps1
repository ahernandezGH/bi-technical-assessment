param(
    [Parameter(Mandatory = $true)]
    [string]$Issue,
    
    [Parameter(Mandatory = $false)]
    [string]$Candidate = "TestCandidate",
    
    [Parameter(Mandatory = $false)]
    [switch]$DryRun
)

Write-Host ""
Write-Host "[UFT ACADEMIC - SOLUTION VALIDATOR]" -ForegroundColor Cyan
Write-Host "Issue: $Issue | Candidate: $Candidate" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

if ($DryRun) {
    Write-Host "`nDRY RUN MODE" -ForegroundColor Yellow
    Write-Host "This would validate:" -ForegroundColor Gray
    $repoRoot = Get-Location
    $solutionDir = [System.IO.Path]::Combine($repoRoot, "Solutions", $Candidate, "Issue$Issue")
    Write-Host "  Solution Dir: $solutionDir" -ForegroundColor Gray
    Write-Host "  Required files depend on issue type" -ForegroundColor Gray
    Write-Host ""
    exit 0
}

$repoRoot = Get-Location
$solutionDir = [System.IO.Path]::Combine($repoRoot, "Solutions", $Candidate, "Issue$Issue")

Write-Host "`n[PHASE 1] FILE VALIDATION" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

$requiredFiles = @("CREATE_table.sql", "SOLUTION.md", "CREATE_dimension.sql", "CREATE_fact.sql")
$filesFound = 0
$filesChecked = 0

foreach ($file in $requiredFiles) {
    $filePath = [System.IO.Path]::Combine($solutionDir, $file)
    if (Test-Path $filePath) {
        Write-Host "[OK] Found: $file" -ForegroundColor Green
        $filesFound++
    } else {
        Write-Host "[SKIP] Not required: $file" -ForegroundColor Gray
    }
    $filesChecked++
}

Write-Host "`n[PHASE 2] DOCUMENTATION CHECK" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

$solutionMd = [System.IO.Path]::Combine($solutionDir, "SOLUTION.md")
if (Test-Path $solutionMd) {
    $content = Get-Content $solutionMd -Raw
    $wordCount = ($content -split '\s+' | Where-Object { $_ }).Count
    $minWords = 50
    
    if ($wordCount -ge $minWords) {
        Write-Host "[OK] SOLUTION.md has $wordCount words (min: $minWords)" -ForegroundColor Green
        $docPass = $true
    } else {
        Write-Host "[FAIL] SOLUTION.md has $wordCount words (min: $minWords)" -ForegroundColor Red
        $docPass = $false
    }
} else {
    Write-Host "[FAIL] SOLUTION.md not found" -ForegroundColor Red
    $docPass = $false
}

Write-Host "`n[PHASE 3] SQL FILES CHECK" -ForegroundColor Cyan
Write-Host ("=" * 70) -ForegroundColor Cyan

$sqlFiles = Get-ChildItem -Path $solutionDir -Filter "CREATE_*.sql" -ErrorAction SilentlyContinue
if ($sqlFiles) {
    Write-Host "[OK] Found $($sqlFiles.Count) SQL file(s)" -ForegroundColor Green
    foreach ($sql in $sqlFiles) {
        Write-Host "     - $($sql.Name)" -ForegroundColor Green
    }
    $sqlPass = $true
} else {
    Write-Host "[FAIL] No SQL files found" -ForegroundColor Red
    $sqlPass = $false
}

Write-Host "`n" -NoNewline
Write-Host ("=" * 70) -ForegroundColor Cyan

$score = 0
if ($docPass) { $score += 25 }
if ($sqlPass) { $score += 25 }
if ($filesFound -gt 0) { $score += 25 }
$score += 25

$status = if ($score -ge 70) { "PASS" } else { "FAIL" }
$color = if ($score -ge 70) { "Green" } else { "Red" }

Write-Host "SCORE: $score/100" -ForegroundColor $color
Write-Host "STATUS: $status" -ForegroundColor $color

if ($status -eq "PASS") {
    Write-Host "[OK] ELIGIBLE FOR PHASE 2" -ForegroundColor Green
} else {
    Write-Host "[FAIL] NEEDS IMPROVEMENT" -ForegroundColor Red
}

Write-Host ("=" * 70) -ForegroundColor Cyan
Write-Host ""

exit 0
