Function Invoke-PrintAssignmentDetail_Assignment(){
    <#
    .SYNOPSIS
    This function is used to collect information about assignment and the group.
    .DESCRIPTION
    This function is used to collect information about assignment and the group.
    .EXAMPLE
    Invoke-PrintAssignmentDetail_Assignment -Assignment $assignment
    Returns the information from the Assignent

    .OUTPUTS
    Outputs a custom object with the following structure:
    - Name
    - MemberCount
    - Type
    - DynamicRule

    .NOTES
    NAME: Invoke-PrintAssignmentDetail_Assignment 
    #>
    param(
        $Assignment
    )
    if($null -ne $Assignment.target.groupId){
        $GroupObj = Get-Groups -groupid $Assignment.target.groupId 
        $Name = $GroupObj.displayName
        if($GroupObj.groupTypes -contains "DynamicMembership"){
            if($GroupObj.membershipRule -like "*user.*"){
                $GType = "DynamicUser"
            } else {
                $GType = "DynamicDevice"
            }
        } else {
            $GType = "Static"
        }
        $Members = Get-Groups_Members -groupId $Assignment.target.groupId
        if($null -eq $Members.count){
            if($null -eq $Members){
                $MemberCount = 1
            } else {
                $MemberCount = 0
            }
        } else {
            $MemberCount = $Members.count
        }
        $DynamicRule = $GroupObj.membershipRule
        if($null -eq $DynamicRule){
            $DynamicRule = "-"
        }
        $returnObj =[PSCustomObject]@{
            Name = $Name
            MemberCount = $MemberCount
            GroupType = $GType
            DynamicRule = $DynamicRule
        }
    } else {

        $Name = "$(($Assignment.target.'@odata.type' -replace "#microsoft.graph.",''))"
        switch ( $Name )
        {
            "allDevicesAssignmentTarget" { $Name = "All Devices" }
            "allLicensedUsersAssignmentTarget" { $Name = "All Users"  }
        }
        
        $returnObj =[PSCustomObject]@{
            Name = $Name
            MemberCount = "-"
            GroupType = "BuilIn"
            DynamicRule = "-"
        }
    } 

    #Intent if Available
    if($null -ne $Assignment.intent){
        $returnObj | Add-Member -MemberType NoteProperty -Name "Intent" -Value $Assignment.intent
    } else {
        $returnObj | Add-Member -MemberType NoteProperty -Name "Intent" -Value "-"
    }
    # Source
    if($null -ne $Assignment.source){
        $returnObj | Add-Member -MemberType NoteProperty -Name "Source" -Value $Assignment.source
    } else {
        $returnObj | Add-Member -MemberType NoteProperty -Name "Source" -Value "-"
    }
    # Include or Exclude
    if($Assignment.'@odata.type' -imatch 'exclusion'){
        $returnObj | Add-Member -MemberType NoteProperty -Name "Type" -Value "Exclude"
    } else {
        $returnObj | Add-Member -MemberType NoteProperty -Name "Type" -Value "Include"
    }

    $returnObj
}
# SIG # Begin signature block
# MIIPGgYJKoZIhvcNAQcCoIIPCzCCDwcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUUeBgYb6heoOoBm4VKt2yX8kl
# nWygggxqMIIFrTCCBJWgAwIBAgIQBD9LZ/ZeEn/YHaINoG/0ljANBgkqhkiG9w0B
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
# AYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRrv5RVOPdNyF4GAiQV7vlwYW6+zzANBgkq
# hkiG9w0BAQEFAASCAQAnRCKmtYrMquND6bBD4Mj0yH4o+9ELWq/x98TjhTq8MpFx
# 2k2JXSf9DBf1BgohpAwf9hQbKvKALlmdPsGLw/GMEnVkdHuWZXA9w8nGWaihT6WI
# u+VJ3RPge8NIW2fL3KtGyw410AtSzTX7NHS19FtcwPkp82EgcLh8BsnAdAdXEpKS
# Xic4zvU4kdhb0M3M4Ft1jrnnyzGaQKH55zD0RoSL05CYanD529i2JT2ivVFyUe7J
# 6z5PzCgX0QOD1NkQpKej51l7g4H0DZCYrLBlMQFIL3IfA9MEXBjP6YTii+Jpzogp
# MWkZeOJvINxd1buochL6kUpwLXL38qqigUYj0EYZ
# SIG # End signature block
