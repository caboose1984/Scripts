$computers = Get-Content C:\Users\w0294101\Desktop\7010check.txt
$output = Foreach ($C in $computers) {
    Get-WmiObject win32_computersystem -computername $C | Select-Object -Property Name, Model
}

$output | Export-Csv -path C:\Users\w0294101\Desktop\7010results.csv -NoTypeInformation