#variables
$csvpath = "C:\users\w0294101\Desktop\print2.csv"
$printserver = "servername"

#function
function get-printerinfo {
    param ( $ComputerName )
    $printers = Get-WmiObject -Query "Select Name,DriverName,Location,PortName from Win32_Printer" -ComputerName $ComputerName -Credential $cred
    $printerCfgs = Get-WmiObject -Query "select Name,Duplex from Win32_PrinterConfiguration" -ComputerName $ComputerName -Credential $cred
    foreach ( $printer in $printers ) {
        $printerCfg = $printerCfgs | Where-Object { $_.Name -eq $printer.Name }
        $printerInfo = New-Object PSObject -Property @{
            ComputerName = $ComputerName
            Name         = $printer.Name
            DriverName   = $printer.DriverName
            Location     = $printer.Location
            PortName     = $printer.PortName
            Duplex       = $printerCfg.Duplex

        }
        $printerInfo | Select-Object ComputerName, Name, DriverName, Location, PortName, Duplex
    }
}

get-printerinfo $printserver | Export-Csv -path $csvpath -NoTypeInformation
