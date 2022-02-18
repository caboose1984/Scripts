try {
    $fastboot = Get-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Session Manager\Power" -Name HiberbootEnabled -ErrorAction Stop
    if ($fastboot.HiberbootEnabled -eq 0) {
        write-host "Fast Boot is already Disabled"
        exit 0  
    }
    else { 
        Write-Host "Fast boot is enabled, running remediation"
        exit 1 
    }
  
}
catch {
    $errMsg = $_.Exception.Message
    write-host $errMsg
    exit 1
}