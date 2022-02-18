Function New-IntuneDocumentationAppRegistration(){
    <#
    .DESCRIPTION
    This script will create an App registration(WPNinjas.eu Automatic Documentation) in Azure AD. Global Admin privileges are required during execution of this function. Afterwards the created clint secret can be used to execute the Intunde Documentation silently. 

    .EXAMPLE
    $p = New-IntuneDocumentationAppRegistration
    $p | fl

    ClientID               : d5cf6364-82f7-4024-9ac1-73a9fd2a6ec3
    ClientSecret           : S03AESdMlhLQIPYYw/cYtLkGkQS0H49jXh02AS6Ek0U=
    ClientSecretExpiration : 21.07.2025 21:39:02
    TenantId               : d873f16a-73a2-4ccf-9d36-67b8243ab99a

    .NOTES
    Author: Thomas Kurth/baseVISION
    Date:   21.7.2020

    History
        See Release Notes in Github.

    #>
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact='Medium')]
    Param(
        [int]
        $TokenLifetimeDays = 365
    )
    ## Manual Variable Definition
    ########################################################
    #$DebugPreference = "Continue"
    $ScriptName = "DocumentIntuneAppRegistration"
    

    #region Initialization
    ########################################################
    Write-Log "Start Script $Scriptname"

    $AzureAD = Get-Module -Name AzureAD
    if($AzureAD){
        Write-Verbose -Message "AzureAD module is loaded."
    } else {
        Write-Warning -Message "AzureAD module is not loaded, please install by 'Install-Module AzureAD'."
    }

    #region Authentication
    Connect-AzureAD | Out-Null
    #endregion
    #region Main Script
    ########################################################
    
    $displayName = "WPNinjas.eu Automatic Documentation"
    $appPermissionsRequired = @('Policy.Read.All',
                                    'Directory.Read.All',
                                    'DeviceManagementServiceConfig.Read.All',
                                    'DeviceManagementRBAC.Read.All',
                                    'DeviceManagementManagedDevices.Read.All',
                                    'DeviceManagementConfiguration.Read.All',
                                    'DeviceManagementApps.Read.All',
                                    'Device.Read.All',
                                    'Agreement.Read.All',
                                    'Application.Read.All')
    $targetServicePrincipalName = 'Microsoft Graph'

    if (!(Get-AzureADApplication -SearchString $displayName)) {
        $app = New-AzureADApplication -DisplayName $displayName `
            -Homepage "https://localhost" `
            -ReplyUrls "urn:ietf:wg:oauth:2.0:oob" `
            -PublicClient $true


        # create SPN for App Registration
        Write-Debug ('Creating SPN for App Registration {0}' -f $displayName)

        # create a password (spn key)
        $startDate = Get-Date
        $endDate = $startDate.AddDays($TokenLifetimeDays)
        $appPwd = New-AzureADApplicationPasswordCredential -ObjectId $app.ObjectId -CustomKeyIdentifier ((New-Guid).Guid.Replace("-","").subString(0, 30)) -StartDate $startDate -EndDate $endDate

        # create a service principal for your application
        # you need this to be able to grant your application the required permission
        $spForApp = New-AzureADServicePrincipal -AppId $app.AppId -PasswordCredentials @($appPwd)
        Set-AzureADAppPermission -targetServicePrincipalName $targetServicePrincipalName -appPermissionsRequired $appPermissionsRequired -childApp $app -spForApp $spForApp
    
    } else {
        Write-Debug ('App Registration {0} already exists' -f $displayName)
        $app = Get-AzureADApplication -SearchString $displayName
        $spForApp = Get-AzureADServicePrincipal -SearchString $app.AppId
        # create a password (spn key)
        $startDate = Get-Date
        $endDate = $startDate.AddDays($TokenLifetimeDays)
        $appPwd = New-AzureADApplicationPasswordCredential -ObjectId $app.ObjectId -CustomKeyIdentifier ((New-Guid).Guid.Replace("-","").subString(0, 30)) -StartDate $startDate -EndDate $endDate
        Set-AzureADAppPermission -targetServicePrincipalName $targetServicePrincipalName -appPermissionsRequired $appPermissionsRequired -childApp $app -spForApp $spForApp -ErrorAction SilentlyContinue
    
    }

    
    

    #endregion
    #region Finishing
    ########################################################
    [PSCustomObject]@{
        ClientID = $app.AppId
        ClientSecret = $appPwd.Value
        ClientSecretExpiration = $appPwd.EndDate
        TenantId = (Get-AzureADCurrentSessionInfo).TenantId
    }

    Write-Log "End Script $Scriptname"
    #endregion
}
# SIG # Begin signature block
# MIIPGgYJKoZIhvcNAQcCoIIPCzCCDwcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUd+c1WFJsOhlXQsgiVdhoqV/5
# ouygggxqMIIFrTCCBJWgAwIBAgIQBD9LZ/ZeEn/YHaINoG/0ljANBgkqhkiG9w0B
# AQUFADBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGlnaUNlcnQgSW5jMRkwFwYD
# VQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtEaWdpQ2VydCBFViBDb2Rl
# IFNpZ25pbmcgQ0EwHhcNMjAwMzA2MDAwMDAwWhcNMjMwMzE1MTIwMDAwWjCBzjET
# MBEGCysGAQQBgjc8AgEDEwJDSDEaMBgGCysGAQQBgjc8AgECEwlTb2xvdGh1cm4x
# HTAbBgNVBA8MFFByaXZhdGUgT3JnYW5pemF0aW9uMRgwFgYDVQQFEw9DSEUtMzE0
# LjYzOS41MjMxCzAJBgNVBAYTAkNIMRIwEAYDVQQIEwlTb2xvdGh1cm4xETAPBgNV
# BAcMCETDpG5pa2VuMRYwFAYDVQQKEw1iYXNlVklTSU9OIEFHMRYwFAYDVQQDEw1i
# YXNlVklTSU9OIEFHMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAp9MW
# Qk/Mk+vNR2VWPILVJVESssMvDX6vLor/4ySVPv03+Bx11ycx6PemRaP1jljA91jF
# kWEZ6Y/eT2W3y2hfpIvz1EUYaff6E/6eTt807+Cap4oOwDniC+XbfVuVIo/awzhG
# YZhaVU9PCgioTDTDLuzIQbPrhwZckO9I+R9iIwY3j7RA2HGpG79UTQyuYVPpNlKi
# mREEmqrdvq4nsMUtkeEVL2SeZ0a2n+KTWKg3Xpth9Lyde8x7BvmQdGBS5Pz94uq+
# LSRAJLGAFJLibBQ7dGM/cTNqphtka+IsOwFE3xORsdDTVg/3zFhT/9rA91ZBwPDM
# /DwKJA3xc9tTqmK1zwIDAQABo4IB7TCCAekwHwYDVR0jBBgwFoAUrWkGcPyAGxaz
# qRiUa5QChl73J4wwHQYDVR0OBBYEFEXZZP9kZKig72bPLKJdFIc5iUwqMDcGA1Ud
# EQQwMC6gLAYIKwYBBQUHCAOgIDAeDBxDSC1TT0xPVEhVUk4tQ0hFLTMxNC42Mzku
# NTIzMA4GA1UdDwEB/wQEAwIHgDATBgNVHSUEDDAKBggrBgEFBQcDAzBzBgNVHR8E
# bDBqMDOgMaAvhi1odHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRVZDb2RlU2lnbmlu
# Zy1nMS5jcmwwM6AxoC+GLWh0dHA6Ly9jcmw0LmRpZ2ljZXJ0LmNvbS9FVkNvZGVT
# aWduaW5nLWcxLmNybDBLBgNVHSAERDBCMDcGCWCGSAGG/WwDAjAqMCgGCCsGAQUF
# BwIBFhxodHRwczovL3d3dy5kaWdpY2VydC5jb20vQ1BTMAcGBWeBDAEDMHkGCCsG
# AQUFBwEBBG0wazAkBggrBgEFBQcwAYYYaHR0cDovL29jc3AuZGlnaWNlcnQuY29t
# MEMGCCsGAQUFBzAChjdodHRwOi8vY2FjZXJ0cy5kaWdpY2VydC5jb20vRGlnaUNl
# cnRFVkNvZGVTaWduaW5nQ0EuY3J0MAwGA1UdEwEB/wQCMAAwDQYJKoZIhvcNAQEF
# BQADggEBABmHqy/WAPIFuHMe51hGgxaTdl52mOPvdDZfIGo+mnkI+pMCH41i1gMw
# cg3VTb8UpK8F3X6N3ZBuQzTSN8D0dkhNosiJgxes1004XHAapMBNcdU2+an4WgOP
# I39fH/CW71YL7W2Vl6YdW/gC8g9vddW9+ELenGJqJYNfb5Jll2VAA0YwNdUt1R4Y
# R+Biynh6BNt40krOvbUDzQtY3Uvkcesjv2GteFKw8DqyaNakp9sU4pX/bO+5ksUS
# QqS/AndT1Bz77oFBRy8PZ6jkADFG+3B3Q1ERLOwa733MqNKkce5cioyDNXdMBrYg
# c/vJECXEgnSvUvBxkg98uEdTfvmPIGEwgga1MIIFnaADAgECAhAN0OM3Sslb2/pr
# Q0sqSOwGMA0GCSqGSIb3DQEBBQUAMGwxCzAJBgNVBAYTAlVTMRUwEwYDVQQKEwxE
# aWdpQ2VydCBJbmMxGTAXBgNVBAsTEHd3dy5kaWdpY2VydC5jb20xKzApBgNVBAMT
# IkRpZ2lDZXJ0IEhpZ2ggQXNzdXJhbmNlIEVWIFJvb3QgQ0EwHhcNMTIwNDE4MTIw
# MDAwWhcNMjcwNDE4MTIwMDAwWjBlMQswCQYDVQQGEwJVUzEVMBMGA1UEChMMRGln
# aUNlcnQgSW5jMRkwFwYDVQQLExB3d3cuZGlnaWNlcnQuY29tMSQwIgYDVQQDExtE
# aWdpQ2VydCBFViBDb2RlIFNpZ25pbmcgQ0EwggEiMA0GCSqGSIb3DQEBAQUAA4IB
# DwAwggEKAoIBAQC5BnQcXbQgqqkhqCpCRqslIBclyyKPkKKgMWuDBXWvsg58Ekl7
# aoZkhA+D3GS5sW4WBT4clbnn54htuGKBkHnU3fXilvnDtYgjV0oaz3Ep6QgAj7WY
# 46cy/awuuPSTU/QKOUORr9Vr6NSfRr2OPavi+SvU6gBAZiS36H+0RHWNeJquMcE3
# z04fW/hFStc/wsmSBmS+3gaKr9DoirHwLIgAbwvchadMywa/1i4qMm4pca+OIvMP
# 0NiYSC2oCMu2iyPCY+C2c+tvfSZPi/c0PTeGDLd4J/TChttDa1r4PT306LBiVsbn
# 7Xih+/16ck8yZcR8w8R3oAQyMu2PP6+G3X7RAgMBAAGjggNYMIIDVDASBgNVHRMB
# Af8ECDAGAQH/AgEAMA4GA1UdDwEB/wQEAwIBhjATBgNVHSUEDDAKBggrBgEFBQcD
# AzB/BggrBgEFBQcBAQRzMHEwJAYIKwYBBQUHMAGGGGh0dHA6Ly9vY3NwLmRpZ2lj
# ZXJ0LmNvbTBJBggrBgEFBQcwAoY9aHR0cDovL2NhY2VydHMuZGlnaWNlcnQuY29t
# L0RpZ2lDZXJ0SGlnaEFzc3VyYW5jZUVWUm9vdENBLmNydDCBjwYDVR0fBIGHMIGE
# MECgPqA8hjpodHRwOi8vY3JsMy5kaWdpY2VydC5jb20vRGlnaUNlcnRIaWdoQXNz
# dXJhbmNlRVZSb290Q0EuY3JsMECgPqA8hjpodHRwOi8vY3JsNC5kaWdpY2VydC5j
# b20vRGlnaUNlcnRIaWdoQXNzdXJhbmNlRVZSb290Q0EuY3JsMIIBxAYDVR0gBIIB
# uzCCAbcwggGzBglghkgBhv1sAwIwggGkMDoGCCsGAQUFBwIBFi5odHRwOi8vd3d3
# LmRpZ2ljZXJ0LmNvbS9zc2wtY3BzLXJlcG9zaXRvcnkuaHRtMIIBZAYIKwYBBQUH
# AgIwggFWHoIBUgBBAG4AeQAgAHUAcwBlACAAbwBmACAAdABoAGkAcwAgAEMAZQBy
# AHQAaQBmAGkAYwBhAHQAZQAgAGMAbwBuAHMAdABpAHQAdQB0AGUAcwAgAGEAYwBj
# AGUAcAB0AGEAbgBjAGUAIABvAGYAIAB0AGgAZQAgAEQAaQBnAGkAQwBlAHIAdAAg
# AEMAUAAvAEMAUABTACAAYQBuAGQAIAB0AGgAZQAgAFIAZQBsAHkAaQBuAGcAIABQ
# AGEAcgB0AHkAIABBAGcAcgBlAGUAbQBlAG4AdAAgAHcAaABpAGMAaAAgAGwAaQBt
# AGkAdAAgAGwAaQBhAGIAaQBsAGkAdAB5ACAAYQBuAGQAIABhAHIAZQAgAGkAbgBj
# AG8AcgBwAG8AcgBhAHQAZQBkACAAaABlAHIAZQBpAG4AIABiAHkAIAByAGUAZgBl
# AHIAZQBuAGMAZQAuMB0GA1UdDgQWBBStaQZw/IAbFrOpGJRrlAKGXvcnjDAfBgNV
# HSMEGDAWgBSxPsNpA/i/RwHUmCYaCALvY2QrwzANBgkqhkiG9w0BAQUFAAOCAQEA
# nluWOi4SiKyrAW2kn3XkAYejpTLXvLqpfqPWFBf3whNrfHOPK2rlDyZZaLCOJZts
# 7/psk5IIwU3PRZ6cRtYedKGbFKP6AS9KsQHhckBIERNouTadkUvXwjkSEMHE3Lti
# FBQqYV1POHxmH8Yb/62+T3+UW3NDAA9Nc7dRzw72d8BbzTSM2WMTqg5hEdbyjif8
# tHu4uREgkYZ46g7UKP8q1SQ46Dey7Ja7n7xKFlDhXr9RfSOgMsfBlJ56ycAmoswl
# h6ASfnSfLY2xyOeEvrnR6d67ak6Ic3HhIjjLJIfpc35Rsv+Y605+L+DKDvqzXtG6
# BUKoSJ+D9j/EyqjfaKBQYTGCAhowggIWAgEBMHkwZTELMAkGA1UEBhMCVVMxFTAT
# BgNVBAoTDERpZ2lDZXJ0IEluYzEZMBcGA1UECxMQd3d3LmRpZ2ljZXJ0LmNvbTEk
# MCIGA1UEAxMbRGlnaUNlcnQgRVYgQ29kZSBTaWduaW5nIENBAhAEP0tn9l4Sf9gd
# og2gb/SWMAkGBSsOAwIaBQCgeDAYBgorBgEEAYI3AgEMMQowCKACgAChAoAAMBkG
# CSqGSIb3DQEJAzEMBgorBgEEAYI3AgEEMBwGCisGAQQBgjcCAQsxDjAMBgorBgEE
# AYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRUAr2BCne9G4WUlPKUysIgtZ6vIjANBgkq
# hkiG9w0BAQEFAASCAQBrNKIP25Z0YFyIPgxs4yhZF05aKvvdSmabh12DNjYlXL87
# Ryb1D/6nwwzMpHjHz3RjrVDTyZxMEwswkl2hUwYnr/3b5gXXnp0DmCFrdAAritrR
# 2RK/CcxHF65xbd2i2VsO3Gk8MNkjQmtES6c37+IXQyG9YT5NsBiwDOpNRBchwUz+
# ThmPxMQzipMiyh2zZGkfcgPOvzrwSZhCQ4Md1UUS+JU0hbIzUpPvOQMSlN7ZBNyb
# So+iOTiTnCnLl1npAku4+IB8RgZxYv3QBqoiioSBeg2EoCOl1eo101LyJ7dyOHnu
# KYcef8mDyKfEx7BEqoLORspDbF9WBKQowpmzYzQH
# SIG # End signature block
