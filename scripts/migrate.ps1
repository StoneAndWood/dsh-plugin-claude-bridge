# One-time migration script: copy Claude Code config into dsh locations.
# This is an ALTERNATIVE to the plugin approach — use one or the other.
#
# Usage:
#   .\scripts\migrate.ps1                          # current project
#   .\scripts\migrate.ps1 -ProjectPath "C:\myproj" # specific project

param(
    [string]$ProjectPath = (Get-Location).Path,
    [string]$ClaudeHome = "$env:USERPROFILE\.claude",
    [string]$DshHome = "$env:USERPROFILE\.dsh"
)

Write-Host "=== Claude Code → DeepSeek Harness Migration ===" -ForegroundColor Cyan
Write-Host ""

# 1. Global CLAUDE.md → ~/.dsh/AGENTS.md
$globalClaude = Join-Path $ClaudeHome "CLAUDE.md"
$dshAgents = Join-Path $DshHome "AGENTS.md"
if (Test-Path $globalClaude) {
    if (-not (Test-Path $dshAgents)) {
        Copy-Item $globalClaude $dshAgents
        Write-Host "[OK] Global CLAUDE.md -> $dshAgents" -ForegroundColor Green
    } else {
        Write-Host "[SKIP] $dshAgents already exists" -ForegroundColor Yellow
    }
} else {
    Write-Host "[SKIP] No global CLAUDE.md found" -ForegroundColor Yellow
}

# 2. Skills → ~/.agents/skills-claude/
$claudeSkills = Join-Path $ClaudeHome "skills"
$agentsSkills = Join-Path "$env:USERPROFILE\.agents" "skills-claude"
if (Test-Path $claudeSkills) {
    if (-not (Test-Path $agentsSkills)) {
        try {
            New-Item -ItemType Junction -Path $agentsSkills -Target $claudeSkills -ErrorAction Stop | Out-Null
            Write-Host "[OK] Linked skills -> $agentsSkills" -ForegroundColor Green
        } catch {
            Write-Host "[WARN] Cannot create junction (need Admin?). Falling back to copy." -ForegroundColor Yellow
            Copy-Item -Recurse $claudeSkills $agentsSkills
            Write-Host "[OK] Copied skills -> $agentsSkills" -ForegroundColor Green
        }
    } else {
        Write-Host "[SKIP] $agentsSkills already exists" -ForegroundColor Yellow
    }
} else {
    Write-Host "[SKIP] No Claude Code skills found" -ForegroundColor Yellow
}

# 3. Memory → MEMORY.md at project root
$encodedPath = $ProjectPath -replace ':', '' -replace '\\', '-' -replace '/', '-'
$memoryDir = Join-Path $ClaudeHome "projects\$encodedPath\memory"
$memoryFiles = @()
if (Test-Path $memoryDir) {
    $memoryFiles = Get-ChildItem -Path $memoryDir -Filter "*.md" -File |
        Where-Object { $_.Name -ne "MEMORY.md" }
}

if ($memoryFiles.Count -gt 0) {
    $output = @()
    $output += "# Agent Memory"
    $output += ""
    $output += "Imported from Claude Code memory on $(Get-Date -Format 'yyyy-MM-dd')."
    $output += ""

    foreach ($file in $memoryFiles) {
        $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
        $name = $file.BaseName
        $description = ""
        if ($content -match '(?s)^---\s*\n(.*?)\n---') {
            $frontmatter = $matches[1]
            if ($frontmatter -match 'name:\s*(.+)') { $name = $matches[1].Trim() }
            if ($frontmatter -match 'description:\s*(.+)') { $description = $matches[1].Trim() }
        }
        $body = $content -replace '(?s)^---\s*\n.*?\n---\s*\n?', ''

        $output += "---"
        $output += ""
        $output += "### $name"
        if ($description) { $output += "*$description*" }
        $output += ""
        $output += $body.Trim()
        $output += ""
    }

    $outputPath = Join-Path $ProjectPath "MEMORY.md"
    $output -join "`n" | Set-Content -Path $outputPath -Encoding UTF8 -NoNewline
    Write-Host "[OK] Written MEMORY.md ($($memoryFiles.Count) memories)" -ForegroundColor Green
} else {
    Write-Host "[SKIP] No memory files found" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "Migration complete!" -ForegroundColor Cyan
Write-Host "Alternatively, install dsh-plugin-claude-bridge for live sync (no migration needed)." -ForegroundColor Gray
