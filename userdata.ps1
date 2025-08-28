# PowerShell script for automatic software installation
<powershell>
# Log all operations
Start-Transcript -Path "C:\terraform-setup.log"

Write-Host "Starting Windows instance configuration for OBS and GPU..." -ForegroundColor Green

# Update Windows
Write-Host "Installing Windows Updates..." -ForegroundColor Yellow
Install-WindowsUpdate -AcceptAll -AutoReboot

# Download and install NVIDIA drivers
Write-Host "Downloading and installing NVIDIA drivers..." -ForegroundColor Yellow
$nvDriverUrl = "https://international.download.nvidia.com/tesla/528.89/528.89-tesla-desktop-winserver-2019-2022-dch-international.exe"
$nvDriverPath = "C:\temp\nvidia-driver.exe"

# Create temp directory
New-Item -ItemType Directory -Path "C:\temp" -Force

# Download NVIDIA driver
Invoke-WebRequest -Uri $nvDriverUrl -OutFile $nvDriverPath
Start-Process -FilePath $nvDriverPath -ArgumentList "/s" -Wait

# Install Chocolatey
Write-Host "Installing Chocolatey package manager..." -ForegroundColor Yellow
Set-ExecutionPolicy Bypass -Scope Process -Force
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Refresh environment for Chocolatey
$env:ChocolateyInstall = Convert-Path "$((Get-Command choco).Path)\..\.."
Import-Module "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
refreshenv

# Install required software via Chocolatey
Write-Host "Installing software packages..." -ForegroundColor Yellow

# OBS Studio
choco install obs-studio -y

# Other useful streaming software
choco install vlc -y
choco install 7zip -y
choco install notepadplusplus -y
choco install googlechrome -y

# Visual Studio Redistributables
choco install vcredist140 -y
choco install vcredist2019 -y

# DirectX
choco install directx -y

# Configure Windows for optimal performance
Write-Host "Configuring Windows for performance..." -ForegroundColor Yellow

# Temporarily disable Windows Defender Real-time Protection
Set-MpPreference -DisableRealtimeMonitoring $true

# Set High Performance Power Plan
powercfg /setactive 8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c

# Disable automatic Windows Updates during sessions
New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force
Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Value 1

# Configure DCV instead of Remote Desktop
Write-Host "Installing and configuring Amazon DCV..." -ForegroundColor Yellow

# Set Administrator password for DCV access
$adminPassword = "WyObs2025!" # Consider using a more secure method in production
net user Administrator $adminPassword

# Download and install DCV Server
$dcvUrl = "https://d1uj6qtbmh3dt5.cloudfront.net/2023.1/Servers/nice-dcv-server-x64-Release-2023.1-15487.msi"
$dcvPath = "C:\temp\dcv-server.msi"

# Download DCV
Invoke-WebRequest -Uri $dcvUrl -OutFile $dcvPath
Start-Process -FilePath "msiexec.exe" -ArgumentList "/i", $dcvPath, "/quiet", "/norestart" -Wait

# Configure DCV
New-Item -Path "C:\Program Files\NICE\DCV\Server\conf" -ItemType Directory -Force
$dcvConfig = @"
[session-management]
create-session = true

[session-management/defaults]
permissions-file = "%ProgramData%\NICE\dcv\default.perm"

[session-management/automatic-console-session]
owner = "Administrator"
storage-root = "%home%"

[connectivity]
web-url-path = "/dcv"
web-port = 8443

[security]
authentication = "system"

[display]
target-fps = 30
"@

Set-Content -Path "C:\Program Files\NICE\DCV\Server\conf\dcv.conf" -Value $dcvConfig

# Configure DCV permissions
$dcvPerms = @"
[permissions]
%any% allow builtin
"@
New-Item -Path "C:\ProgramData\NICE\dcv" -ItemType Directory -Force
Set-Content -Path "C:\ProgramData\NICE\dcv\default.perm" -Value $dcvPerms

# Configure Windows Firewall for DCV
New-NetFirewallRule -DisplayName "DCV Server TCP" -Direction Inbound -Protocol TCP -LocalPort 8443 -Action Allow
New-NetFirewallRule -DisplayName "DCV Server UDP" -Direction Inbound -Protocol UDP -LocalPort 8443 -Action Allow

# Start DCV Server service
Set-Service -Name "DCV Server" -StartupType Automatic
Start-Service -Name "DCV Server"

# Log the access information
Write-Host "DCV Configuration completed!" -ForegroundColor Green
Write-Host "Access URL will be: https://[PUBLIC_IP]:8443" -ForegroundColor Yellow
Write-Host "Username: Administrator" -ForegroundColor Yellow
Write-Host "Password: $adminPassword" -ForegroundColor Yellow

# Install Windows Media Feature Pack (for codecs)
Write-Host "Installing Windows Media Feature Pack..." -ForegroundColor Yellow
Enable-WindowsOptionalFeature -Online -FeatureName "WindowsMediaPlayer" -All

# Create desktop shortcuts
Write-Host "Creating desktop shortcuts..." -ForegroundColor Yellow
$DesktopPath = [Environment]::GetFolderPath("Desktop")

# OBS Studio shortcut
$ObsPath = "${env:ProgramFiles}\obs-studio\bin\64bit\obs64.exe"
if (Test-Path $ObsPath) {
    $WshShell = New-Object -comObject WScript.Shell
    $Shortcut = $WshShell.CreateShortcut("$DesktopPath\OBS Studio.lnk")
    $Shortcut.TargetPath = $ObsPath
    $Shortcut.Save()
}

# Schedule task to verify driver installation
Write-Host "Scheduling post-reboot verification task..." -ForegroundColor Yellow
$TaskAction = New-ScheduledTaskAction -Execute "PowerShell.exe" -Argument "-Command `"nvidia-smi > C:\nvidia-check.txt`""
$TaskTrigger = New-ScheduledTaskTrigger -AtStartup
$TaskPrincipal = New-ScheduledTaskPrincipal -UserId "SYSTEM" -LogonType ServiceAccount -RunLevel Highest
Register-ScheduledTask -Action $TaskAction -Trigger $TaskTrigger -Principal $TaskPrincipal -TaskName "NvidiaCheck" -Description "Verify NVIDIA driver installation"

Write-Host "Configuration completed! Instance will reboot to complete driver installation." -ForegroundColor Green

# Clean up temporary files
Remove-Item -Path "C:\temp" -Recurse -Force -ErrorAction SilentlyContinue

Stop-Transcript

# Reboot to complete driver installation
shutdown /r /t 60 /c "Rebooting to complete NVIDIA driver installation"
</powershell>
