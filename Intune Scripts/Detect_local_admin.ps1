try{
    if (Get-localuser -Name "sysop" -PasswordNeverExpires $True -ErrorAction Stop)
    {
        write-host "Success"
    	exit 0  
    }
  
}
catch{
    $errMsg = $_.Exception.Message
    write-host $errMsg
    exit 1
}