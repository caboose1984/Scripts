$a =Import-Csv -LiteralPath "c:\temp\test.csv"

Foreach ($name in $a){

    Invoke-Command -ComputerName $name -ScriptBlock { (Get-Item c:\windows\syswow64\ULAgentExe.exe).versioninfo.fileversion } -ErrorAction Continue
}