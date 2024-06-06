# Define printer name and printer path
$printerName = "Printername"
$printerPath = "ipp://ipaddress"

# Check if the printer exists
$printer = Get-Printer -Name $printerName -ErrorAction SilentlyContinue

# If the printer exists, remove it
if ($printer) {
    Remove-Printer -Name $printerName
}

# Small delay to ensure the removal completes
Start-Sleep -Seconds 2

# Add the printer
Add-Printer -Name $printerName -DriverName "Microsoft IPP Class Driver" -PortName $printerPath
Set-Printer -Name $printerName -Comment "HR_Printer_Privileged" -Shared $true -Published $true
