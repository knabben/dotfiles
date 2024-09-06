$vmName = "sandbox"
$vmDisk = "./flatcar_production_hyperv_vhdx_image.vhdx"

# Resize ROOT node for container usage
Resize-VHD -Path .\flatcar_production_hyperv_vhdx_image.vhdx -sizebytes 100Gb

# Create a new VM using the disk
New-VM -Name $vmName -MemoryStartupBytes 4GB `
    -BootDevice VHD -SwitchName "Default Switch" -VHDPath $vmDisk -Generation 2
Set-VMFirmware -EnableSecureBoot "Off" -VMName $vmName

# Convert ignition with butane
butane.exe ".\ignition.yaml" -o ".\ignition.json"
# Add ignition in the image
kvpctl.exe "$vmName" add-ign ignition.json

# Start the VM
Start-VM -Name $vmName