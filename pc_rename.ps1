# Get current computer name
$currentName = $env:COMPUTERNAME

# Get BIOS serial
$serial = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber
$serial = $serial -replace '\s',''

# Known bad / placeholder serial values
$invalidSerials = @(
    "",
    "To Be Filled By O.E.M.",
    "Default string",
    "None",
    "System Serial Number"
)

# If serial is invalid, fall back to UUID
if ($invalidSerials -contains $serial -or $serial.Length -lt 5) {
    $uuid = (Get-CimInstance -ClassName Win32_ComputerSystemProduct).UUID
    $uuid = $uuid -replace '[^A-Za-z0-9]', ''
    $serial = $uuid
}

# Enforce 15-char NetBIOS limit
$shortSerial = $serial.Substring(0, [Math]::Min(11, $serial.Length))

$newName = "AKO-$shortSerial"

if ($currentName -ne $newName) {
    Write-Output "Renaming computer from $currentName to $newName"
    Rename-Computer -NewName $newName -Force
    Write-Output "Rename complete. Reboot required to apply."
}
else {
    Write-Output "Computer name already correct."
}
