# Function to display menu and get user choice
function Show-Menu {
    Clear-Host
    Write-Host "Choose a Linux ISO to download:"
    Write-Host "1) Ubuntu 22.04.4 Server"
    Write-Host "2) Debian 12.5"
    Write-Host "3) Fedora Server 39"
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
            Write-Host "ISO downloaded successfully to $outputPath"
        }
        catch {
            Write-Host "Error downloading the ISO: $_.Exception.Message"
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
    $vmName = Read-Host "Enter the name for the Hyper-V virtual machine"
    $ramChoice = Read-Host "Enter the amount of RAM for the VM (1GB, 2GB, or 4GB)"
    $ram = switch ($ramChoice) {
        "1GB" {1GB}
        "2GB" {2GB}
        "4GB" {4GB}
        default {Write-Host "Invalid RAM choice. Setting to 1GB."; 1GB}
    }
    $cpuCores = 2
    $secureBoot = "Off"
    
    try {
        New-VM -Name $vmName -MemoryStartupBytes $ram -BootDevice CD -Path $env:USERPROFILE\Documents\Hyper-V\VirtualMachines -Generation 2 -Verbose
        Set-VMFirmware -VMName $vmName -EnableSecureBoot $secureBoot
        Set-VMProcessor -VMName $vmName -Count $cpuCores
        Set-VMDvdDrive -VMName $vmName -Path $isoPath
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
    "Q" {
        Write-Host "Exiting..."
    }
    default {
        Write-Host "Invalid choice. Please select a valid option."
    }
}
