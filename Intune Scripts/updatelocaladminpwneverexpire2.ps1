try{
    Set-LocalUser -name "sysop" -PasswordNeverExpires:$true -ErrorAction Stop
    $Date = Get-Date
    Write-Host "The password expiry was removed on $date"
    exit 0
}
catch{
    $errMsg = $_.Exception.Message
    Write-host $errMsg
    exit 1
}