$NewPassword = ""
$OldPassword = ""
$OldPassword2 = ""
$OldPassword3 = ""
$passwords = $OldPassword, $OldPassword2, $OldPassword3
$DetectionRegPath = "HKLM:\SOFTWARE\Intune\DellBIOSProvider"
$DetectionRegName = "PasswordSet"
 
if (-not (Test-Path -Path $DetectionRegPath)) {
    New-Item -Path $DetectionRegPath -Force | Out-Null
}

Install-Module DellBIOSProvider -Force
Import-Module DellBIOSProvider -Force -ErrorAction Stop


$IsAdminPassSet = (Get-Item -Path DellSmbios:\Security\IsAdminPasswordSet).CurrentValue
 
if ($IsAdminPassSet -eq $false) {
    Set-Item -Path DellSmbios:\Security\AdminPassword -value $NewPassword -ErrorAction Stop
    if ( (Get-Item -Path DellSmbios:\Security\IsAdminPasswordSet).CurrentValue -eq $true ) {
        New-ItemProperty -Path $DetectionRegPath -Name $DetectionRegName -Value 1 -Force | Out-Null
        Write-Host "Password successfully set from null"
        exit 0
    }
}

else {
    foreach ($password in $passwords) {  
        try {
            Set-Item -Path DellSmbios:\Security\AdminPassword -value $NewPassword -Password $password -ErrorAction Stop
            New-ItemProperty -Path $DetectionRegPath -Name $DetectionRegName -Value 1 -Force | Out-Null 
            Write-Host "Password successfully changed"
            exit 0
        }
        catch {
            #$errMsg = $_.Exception.Message
            write-host $_.exception
            continue
        }
    }
}
Write-Host "None of the passwords are correct"
exit 1