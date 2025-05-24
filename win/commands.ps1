# LinuxHelpMenu.ps1

$notesDir = Join-Path $PSScriptRoot "notes"

function Show-Menu {
    Clear-Host
    Write-Host "=== Linux Command Topics Menu ===`n" -ForegroundColor Cyan

    $global:topics = Get-ChildItem -Path $notesDir -Filter *.txt | Sort-Object Name
    $i = 1
    foreach ($file in $topics) {
        $topicName = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        Write-Host "$i. " -NoNewline; Write-Host "$topicName" -ForegroundColor Green
        $i++
    }

    Write-Host "$i. Add New Topic" -ForegroundColor Yellow
    Write-Host "$($i + 1). Exit" -ForegroundColor Red
    Write-Host ""
}

function Show-Topic($choice) {
    $numTopics = $topics.Count
    if ($choice -eq $numTopics + 1) {
        Add-NewTopic
        return
    }

    if ($choice -eq $numTopics + 2) {
        Write-Host "`nGoodbye!" -ForegroundColor Red
        exit
    }

    if ($choice -ge 1 -and $choice -le $numTopics) {
        $file = $topics[$choice - 1].FullName
        Write-Host "`n$($topics[$choice - 1].BaseName)`n" -ForegroundColor Cyan
        Get-Content $file | Write-Host -ForegroundColor Gray
    } else {
        Write-Host "Invalid selection. Try again." -ForegroundColor Red
    }

    Pause
}

function Add-NewTopic {
    $newName = Read-Host "Enter new topic name (no spaces, example: DiskUsage)"
    if (-not $newName -or $newName -match '[^\w\-]') {
        Write-Host "Invalid name. Use only letters, numbers, underscores, or dashes." -ForegroundColor Red
        return
    }

    $newFile = Join-Path $notesDir "$newName.txt"
    if (Test-Path $newFile) {
        Write-Host "Topic already exists!" -ForegroundColor Red
        return
    }

    New-Item -ItemType File -Path $newFile -Force | Out-Null

    Write-Host "Opening editor for '$newName'..." -ForegroundColor Yellow
    Start-Process notepad.exe $newFile

    Pause
}

# Ensure notes directory exists
if (-not (Test-Path $notesDir)) {
    New-Item -ItemType Directory -Path $notesDir | Out-Null
}

# Main Loop
do {
    Show-Menu
    $choice = Read-Host "Enter your choice number"
    Show-Topic $choice
} while ($true)
