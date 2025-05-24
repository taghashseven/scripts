# # Check for admin rights
# function Test-IsAdmin {
#     $currentUser = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
#     return $currentUser.IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)
# }

# if (-not (Test-IsAdmin)) {
#     Write-Host "Not running as Administrator. Restarting with elevated privileges..."
#     Start-Process -FilePath "powershell" -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
#     exit
# }

$destDir = "C:\auto"

if (-not (Test-Path $destDir)) {
    New-Item -Path $destDir -ItemType Directory | Out-Null
    Write-Host "Created directory $destDir"
}

$currentDir = Get-Location

# Only files in the current directory, no recursion
Get-ChildItem -Path $currentDir -File | ForEach-Object {
    $sourceFile = $_.FullName
    $destFile = Join-Path $destDir $_.Name

    $copyFile = $true

    if (Test-Path $destFile) {
        $srcHash = Get-FileHash $sourceFile -Algorithm SHA256
        $destHash = Get-FileHash $destFile -Algorithm SHA256
        if ($srcHash.Hash -eq $destHash.Hash) {
            $copyFile = $false
            Write-Host "Skipping unchanged file $($_.Name)"
        }
    }

    if ($copyFile) {
        Copy-Item -Path $sourceFile -Destination $destFile -Force
        Write-Host "Copied/Updated $($_.Name) to $destDir"
    }
}

# Update system PATH if needed
$envName = "Path"
$regPath = "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Environment"
$currentPath = (Get-ItemProperty -Path $regPath -Name $envName).Path

if (-not ($currentPath -split ';' | Where-Object { $_ -ieq $destDir })) {
    $newPath = "$currentPath;$destDir"
    Set-ItemProperty -Path $regPath -Name $envName -Value $newPath

    # Notify system about env variable change
    $signature = @'
    [DllImport("user32.dll", SetLastError = true)]
    public static extern IntPtr SendMessageTimeout(IntPtr hWnd, uint Msg, UIntPtr wParam, string lParam, uint fuFlags, uint uTimeout, out UIntPtr lpdwResult);
'@

    Add-Type -MemberDefinition $signature -Name NativeMethods -Namespace Win32

    $HWND_BROADCAST = [intptr]0xffff
    $WM_SETTINGCHANGE = 0x001A
    $SMTO_ABORTIFHUNG = 0x0002
    $result = [uintptr]::Zero

    [Win32.NativeMethods]::SendMessageTimeout($HWND_BROADCAST, $WM_SETTINGCHANGE, [uintptr]::Zero, "Environment", $SMTO_ABORTIFHUNG, 5000, [ref]$result) | Out-Null

    Write-Host "Added $destDir to system PATH. Restart your terminal for changes to take effect."
} else {
    Write-Host "$destDir is already in the system PATH."
}
