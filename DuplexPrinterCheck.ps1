$csvpath = "C:\users\w0294101\Desktop\print.csv"

Function Get-DuplexPrintConfig {
    $PrintServer = "servername"
    $printers = get-printer -ComputerName $PrintServer
    

    Foreach ($printer in $printers) {
        get-printconfiguration -printername ($Printer).name -ComputerName $PrintServer -ErrorAction SilentlyContinue
        Set-PrintConfiguration -PrinterName ($Printer).name -ComputerName $PrintServer -ErrorAction SilentlyContinue -DuplexingMode TwoSidedLongEdge
    }
}


Get-DuplexPrintConfig | Select-Object PrinterName, DuplexingMode | Export-Csv $csvpath -NoTypeInformation