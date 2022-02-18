Set-LocalUser -name "sysop" -PasswordNeverExpires:$true
$Date = Get-Date
Write-Host "The password expiry was removed on $date"