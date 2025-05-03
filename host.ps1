# Run this script as Administrator

function Add-HostEntry {
    $ip = Read-Host "Enter IP address"
    $hostname = Read-Host "Enter Hostname"
    $username = Read-Host "Enter Username"
    $password = Read-Host "Enter Password"

    $hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"
    $entry = "$ip`t$hostname`t# $username , $password"

    if (Select-String -Path $hostsFile -Pattern "$ip\s+$hostname") {
        Write-Host "`n[!] Entry for $hostname already exists in hosts file." -ForegroundColor Yellow
    } else {
        try {
            Add-Content -Path $hostsFile -Value $entry
            Write-Host "`n[+] Entry added successfully:" -ForegroundColor Green
            Write-Host $entry
        } catch {
            Write-Host "[!] Error: Failed to write to hosts file. Run as Administrator." -ForegroundColor Red
        }
    }
}

function View-Hosts {
    $hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"
    Write-Host "`n===== Hosts File Content =====" -ForegroundColor Cyan
    Get-Content -Path $hostsFile
    Write-Host "==============================" -ForegroundColor Cyan
}

function Edit-With-Notepad {
    $hostsFile = "$env:SystemRoot\System32\drivers\etc\hosts"
    Write-Host "`nOpening hosts file in Notepad..."
    Start-Process notepad.exe $hostsFile
}

# Menu Loop with proper exit
$looping = $true
while ($looping) {
    Write-Host "`n====== Windows Hosts File Manager ======" -ForegroundColor Cyan
    Write-Host "1) Add a host"
    Write-Host "2) View hosts file"
    Write-Host "3) Edit hosts file in Notepad"
    Write-Host "4) Exit"
    $choice = Read-Host "Select an option (1-4)"

    switch ($choice) {
        '1' { Add-HostEntry }
        '2' { View-Hosts }
        '3' { Edit-With-Notepad }
        '4' {
            Write-Host "Exiting..."
            $looping = $false
        }
        default { Write-Host "Invalid option. Please choose 1-4." -ForegroundColor Red }
    }
}
