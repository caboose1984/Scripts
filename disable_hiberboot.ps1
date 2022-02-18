try{
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name HiberbootEnabled -Value 0 -ErrorAction Stop
    exit 0
}
catch{
    $errMsg = $_.Exception.Message
    Write-host $errMsg
    exit 1
}