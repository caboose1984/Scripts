try{
    $PWexpires = (get-ciminstance -Query "SELECT PasswordExpires FROM Win32_UserAccount WHERE Name = 'sysop'").PasswordExpires
    if ($PWexpires -eq $true)
    {
        write-host "Account is set to expire"
    	exit 1
    }
    else {
        write-host "This account is already set to not expire"
        exit 0
        }
  
}

catch{
    $errMsg = $_.Exception.Message
    write-host $errMsg
    exit 1
}