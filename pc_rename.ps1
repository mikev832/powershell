# Get current computer name
$currentName = $env:COMPUTERNAME

# Get serial number using CIM
$serial = (Get-CimInstance -ClassName Win32_BIOS).SerialNumber

# Clean serial (remove spaces just in case)
$serial = $serial -replace '\s',''

# Max NetBIOS length = 15
$maxSerialLength = 11
$shortSerial = $serial.Substring(0, [Math]::Min($serial.Length, $maxSerialLength))

# Build new name
$newName = "AKO-$shortSerial"

# Rename only if needed
if ($currentName -ne $newName) {
    Write-Output "Renaming computer from $currentName to $newName"
    Rename-Computer -NewName $newName -Force
}
else {
    Write-Output "Computer name already correct: $currentName"
}
