# TO DO
# 1) Fix so that the script actually creates a hard drive
# 2) confirm that the size menu works.  ie: if i pick 100gb, i should see a 100gb disk
# 3) once 1 & 2 are done, test across all ISOS on the menu
#


# Function to display menu and get user choice
function Show-SizeMenu {
    Clear-Host
    Write-Host "Choose the size of the virtual hard disk:"
    Write-Host "1) 50GB"
    Write-Host "2) 100GB"
    Write-Host "3) 150GB"
    Write-Host "4) 200GB"
    Write-Host "5) 250GB"
    Write-Host "6) 300GB"
    Write-Host "7) 350GB"
    Write-Host "8) 400GB"
    Write-Host "9) 450GB"
    Write-Host "10) 500GB"
    Write-Host "11) 550GB"
    Write-Host "12) 600GB"
    $choice = Read-Host "Enter your choice"
    switch ($choice) {
        "1" { return 50GB }
        "2" { return 100GB }
        "3" { return 150GB }
        "4" { return 200GB }
        "5" { return 250GB }
        "6" { return 300GB }
        "7" { return 350GB }
        "8" { return 400GB }
        "9" { return 450GB }
        "10" { return 500GB }
        "11" { return 550GB }
        "12" { return 600GB }
        default { Write-Host "Invalid choice. Defaulting to 50GB."; return 50GB }
    }
}



# Function to display menu and get user choice
function Show-Menu {
    Clear-Host
    Write-Host "Choose a Linux ISO to download:"
    Write-Host "1) Ubuntu 22.04.4 Server"
    Write-Host "2) Debian 12.5"
    Write-Host "3) Fedora Server 39"
    Write-Host "4) Kali Linux 2024.1"
    Write-Host "Q) Quit"
    Write-Host ""
    $choice = Read-Host "Enter your choice"
    return $choice
}

# Function to download the selected Linux ISO if not already downloaded
function Download-ISO {
    param (
        [string]$url,
        [string]$outputPath
    )
    if (-not (Test-Path $outputPath)) {
        try {
            $webClient = New-Object System.Net.WebClient
            $webClient.DownloadFile($url, $outputPath)
            Write-Host "Downloading $($outputPath.Split('\')[-1])..."
        }
        catch {
            Write-Host "Error downloading the ISO: $_"
        }
    }
    else {
        Write-Host "ISO already exists at $outputPath"
    }
}

# Function to create a Hyper-V VM from the downloaded ISO
function Create-HyperVVM {
    param (
        [string]$isoPath
    )
    $global:vmName = Read-Host "Enter the name for the Hyper-V virtual machine"

    $ramChoice = Read-Host "Enter the amount of RAM for the VM (1GB, 2GB, or 4GB)"
    $ram = switch ($ramChoice) {
        "1GB" {1GB}
        "2GB" {2GB}
        "4GB" {4GB}
        default {Write-Host "Invalid RAM choice. Setting to 1GB."; 1GB}
    }
    $cpuCores = 2
    $secureBoot = "Off"

    # Get the list of available Hyper-V switches
    $switches = Get-VMSwitch | Select-Object -ExpandProperty Name
    $switchMenu = @{}
    for ($i = 0; $i -lt $switches.Count; $i++) {
        $switchMenu.Add(($i + 1).ToString(), $switches[$i])
        Write-Host "$($i + 1): $($switches[$i])"
    }
    $switchChoice = Read-Host "Enter the number of the Hyper-V switch you want to use (or press Enter for default switch)"
    if ($switchChoice -and $switchMenu.ContainsKey($switchChoice)) {
        $switch = $switchMenu[$switchChoice]
    } else {
        $switch = "Default Switch"
    }

    $diskSizeChoice = Show-SizeMenu

    try {
        New-VM -Name $vmName -MemoryStartupBytes $ram -BootDevice CD -Path $env:USERPROFILE\Documents\Hyper-V\VirtualMachines -Generation 2 -SwitchName $switch -Verbose
        Set-VMFirmware -VMName $vmName -EnableSecureBoot $secureBoot
        Set-VMProcessor -VMName $vmName -Count $cpuCores
        Set-VMDvdDrive -VMName $vmName -Path $isoPath
        # Enable all integration services
        Enable-VMIntegrationService -VMName $vmName -Name "*"
        # Add a new virtual hard disk to the VM
        New-VHD -Path "$env:USERPROFILE\Documents\Hyper-V\VirtualHardDisks\$vmName.vhdx" -Size $diskSizeChoice -Dynamic
        Add-VMHardDiskDrive -VMName $vmName -Path "$env:USERPROFILE\Documents\Hyper-V\VirtualHardDisks\$vmName.vhdx"
        Start-VM -Name $vmName
    }
    catch {
        Write-Host "Error creating Hyper-V VM: $_"
    }
}

# Main script
$choice = Show-Menu

switch ($choice) {
    "1" {
        Download-ISO -url "https://releases.ubuntu.com/22.04.4/ubuntu-22.04.4-live-server-amd64.iso" -outputPath "$env:USERPROFILE\Downloads\ubuntu-22.04.4.iso"
        $createVM = Read-Host "Do you want to create a Hyper-V VM with this ISO? (Y/N)"
        if ($createVM -eq "Y") {
            Create-HyperVVM -isoPath "$env:USERPROFILE\Downloads\ubuntu-22.04.4.iso"
        }
    }
    "2" {
        Download-ISO -url "https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-12.5.0-amd64-DVD-1.iso" -outputPath "$env:USERPROFILE\Downloads\debian-12.5.iso"
        $createVM = Read-Host "Do you want to create a Hyper-V VM with this ISO? (Y/N)"
        if ($createVM -eq "Y") {
            Create-HyperVVM -isoPath "$env:USERPROFILE\Downloads\debian-12.5.iso"
        }
    }
    "3" {
        Download-ISO -url "https://download.fedoraproject.org/pub/fedora/linux/releases/39/Server/x86_64/iso/Fedora-Server-dvd-x86_64-39-1.5.iso" -outputPath "$env:USERPROFILE\Downloads\fedora-server-39.iso"
        $createVM = Read-Host "Do you want to create a Hyper-V VM with this ISO? (Y/N)"
        if ($createVM -eq "Y") {
            Create-HyperVVM -isoPath "$env:USERPROFILE\Downloads\fedora-server-39.iso"
        }
    }
    "4" {
        Download-ISO -url "https://cdimage.kali.org/kali-2024.1/kali-linux-2024.1-installer-netinst-amd64.iso" -outputPath "$env:USERPROFILE\Downloads\kali-linux-2024.1-installer-netinst-amd64.iso"
        $createVM = Read-Host "Do you want to create a Hyper-V VM with this ISO? (Y/N)"
        if ($createVM -eq "Y") {
            Create-HyperVVM -isoPath "$env:USERPROFILE\Downloads\kali-linux-2024.1-installer-netinst-amd64.iso"
        }
    }
    "Q" {
        Write-Host "Exiting..."
    }
    default {
        Write-Host "Invalid choice. Please select a valid option."
    }
}

$vmState = Get-VM -Name $vmName | Select-Object -ExpandProperty State
if ($vmState -ne "Running") {
    Start-VM -Name $vmName
}

Write-Host "================================================"
Write-Host "-----> Warning: Secure Boot is disabled. <------"
Write-Host "================================================"
