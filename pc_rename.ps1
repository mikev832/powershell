# Get current computer name
$currentName = $env:COMPUTERNAME

# Get serial number using CIM (WMI replacement)
$serial = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber

# Build new name
$newName = "AKO-$serial"

# Check if rename is needed
if ($currentName -ne $newName) {
    Write-Output "Renaming computer from $currentName to $newName"

    Rename-Computer -NewName $newName -Force -Restart
}
else {
    Write-Output "Computer name already correct: $currentName"
}
