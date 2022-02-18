Function Invoke-ConditionalAccessDocumentation(){
    <#
    .DESCRIPTION
    This Script documents an Conditional Access with almost all settings, which are available over the Graph API.
    
    The Script is using the PSWord and Microsoft.Graph.Intune Module. Therefore you have to install them first.

    .PARAMETER FullDocumentationPath
        Path including filename where the documentation should be created. The filename has to end with .docx.
        Note:
        If there is already a file present, the documentation witt be added at the end of the existing document.

    .PARAMETER UseTranslationBeta
        When using this parameter the API names will be translated to the labels used in the Intune Portal. 
        Note:
        These Translations need to be created manually, only a few are translated yet. If you are willing 
        to support this project. You can do this by translating the json files which are mentioned to you when 
        you generate the documentation in your tenant. 

    .PARAMETER ClientSecret
        If the client secret is set, app-only authentication will be performed using the client ID specified by 
        the AppId environment parameter.

    .PARAMETER ClientId
        The client id of the application registration with the required permissions.

    .PARAMETER Tenant
        Name of your tenant in form of "kurcontoso.onmicrosoft.com" or the TenantId

    .EXAMPLE Non interactive
    Invoke-ConditionalAccessDocumentation -FullDocumentationPath c:\temp\IntuneDoc.docx  -ClientId d5cf6364-82f7-4024-9ac1-73a9fd2a6ec3 -ClientSecret S03AESdMlhLQIPYYw/cYtLkGkQS0H49jXh02AS6Ek0U= -Tenant d873f16a-73a2-4ccf-9d36-67b8243ab99a

    .NOTES
    Author: Thomas Kurth/baseVISION
    Date:   26.7.2020

    History
        See Release Notes in Github.

    #>
    [alias("Invoke-CADocumentation")]
    [CmdletBinding()]
    Param(
        [ValidateScript({
            if($_ -notmatch "(\.docx)"){
                throw "The file specified in the path argument must be of type docx"
            }
            return $true 
        })]
        [Parameter(ParameterSetName = "NonInteractive")]
        [System.IO.FileInfo]$FullDocumentationPath = ".\IntuneDocumentation.docx",

        [Parameter(ParameterSetName = "NonInteractive")]
        [switch]$UseTranslationBeta,

        [Parameter(Mandatory = $true, ParameterSetName = "NonInteractive")]
        [String]$ClientId,

        [Parameter(Mandatory = $true, ParameterSetName = "NonInteractive")]
        [String]$ClientSecret,

        [Parameter(Mandatory = $true, ParameterSetName = "NonInteractive")]
        [String]$Tenant

    )
    ## Manual Variable Definition
    ########################################################
    #$DebugPreference = "Continue"
    $ScriptName = "DocumentCA"
    $Script:NewTranslationFiles = @()
    if($UseTranslationBeta){
        $Script:UseTranslation = $true
    } else {
        $Script:UseTranslation = $false
    }

    #region Initialization
    ########################################################
    Write-Log "Start Script $Scriptname"
    #region Authentication
    
    $authority = "https://login.windows.net/$Tenant"
    Update-MSGraphEnvironment -AppId $ClientId -Quiet
    Update-MSGraphEnvironment -AuthUrl $authority -Quiet
    Connect-MSGraph -ClientSecret $ClientSecret -Quiet
    
    #endregion
    #region Main Script
    ########################################################
    #region Save Path

    #endregion
    #region CopyTemplate
    if((Test-Path -Path $FullDocumentationPath)){
        Write-Log "File already exists, does not use built-in template." -Type Warn
    } else {
        Copy-Item "$PSScriptRoot\..\Data\Template.docx" -Destination $FullDocumentationPath
        Update-WordText -FilePath $FullDocumentationPath -ReplacingText "DATE" -NewText (Get-Date -Format "HH:mm dd.MM.yyyy")
        Update-WordText -FilePath $FullDocumentationPath -ReplacingText "SYSTEM" -NewText "Conditional Access"
        try{
            $org = Invoke-MSGraphRequest -Url /organization
            Update-WordText -FilePath $FullDocumentationPath -ReplacingText "TENANT" -NewText $org.value.displayName
        } catch{
            Update-WordText -FilePath $FullDocumentationPath -ReplacingText "TENANT" -NewText ""
        }
    }
    #endregion
    #region Document Conditional Access
    $ResultCAPolicies = @()
    $CAPolicies = Get-ConditionalAccess
    foreach($CAPolicy in $CAPolicies){
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text $CAPolicy.displayName
        $ResultCAPolicy = New-Object -Type PSObject
        $ResultCAPolicy | Add-Member Noteproperty "M_Id" $CAPolicy.id
        $ResultCAPolicy | Add-Member Noteproperty "M_DisplayName" $CAPolicy.displayName
        $ResultCAPolicy | Add-Member Noteproperty "M_Created" $CAPolicy.createdDateTime
        $ResultCAPolicy | Add-Member Noteproperty "M_Modified" $CAPolicy.modifiedDateTime
        $ResultCAPolicy | Add-Member Noteproperty "M_State" $CAPolicy.state
        $ResultCAPolicy | Add-Member Noteproperty "C_SignInRiskLevel" ($CAPolicy.conditions.signInRiskLevels -join ",")
        $ResultCAPolicy | Add-Member Noteproperty "C_ClientAppTypes" ($CAPolicy.conditions.clientAppTypes -join ",")
        $ResultCAPolicy | Add-Member Noteproperty "C_PlatformsInclude" ($CAPolicy.conditions.platforms.includePlatforms -join ",")
        $ResultCAPolicy | Add-Member Noteproperty "C_PlatformsExclude" ($CAPolicy.conditions.platforms.excludePlatforms -join ",")
        $ResultCAPolicy | Add-Member Noteproperty "C_LocationsInclude" ($CAPolicy.conditions.locations.includeLocations -join ",")
        $ResultCAPolicy | Add-Member Noteproperty "C_LocationsExclude" ($CAPolicy.conditions.locations.excludeLocations -join ",")
        $ResultCAPolicy | Add-Member Noteproperty "C_DeviceStates" ($CAPolicy.conditions.deviceStates -join ",")
        $ResultCAPolicy | Add-Member Noteproperty "C_Devices" ($CAPolicy.conditions.devices -join ",")
        
        # Application Condition
        $IncludeApps = @()
        foreach($app in $CAPolicy.conditions.applications.includeApplications){
            $IncludeApps += Get-AzureADApplicationName -AppId $app
        }
        $ResultCAPolicy | Add-Member Noteproperty "C_ApplicationsInclude" ($IncludeApps -join [System.Environment]::NewLine)

        $ExcludeApps = @()
        foreach($app in $CAPolicy.conditions.applications.excludeApplications){
            $ExcludeApps += Get-AzureADApplicationName -AppId $app
        }
        $ResultCAPolicy | Add-Member Noteproperty "C_ApplicationsExclude" ($ExcludeApps -join [System.Environment]::NewLine)

        $ResultCAPolicy | Add-Member Noteproperty "C_ApplicationsIncludeUserActions" ($CAPolicy.conditions.applications.includeUserActions -join ",")

        #User Conditions
        $IncludeUsers = @()
        foreach($user in $CAPolicy.conditions.users.includeUsers){
            $IncludeUsers += Get-AzureADUser -UserId $user
        }
        $ResultCAPolicy | Add-Member Noteproperty "C_UsersInclude" ($IncludeUsers -join [System.Environment]::NewLine)

        $ExcludeUsers = @()
        foreach($user in $CAPolicy.conditions.users.excludeUsers){
            $ExcludeUsers += Get-AzureADUser -UserId $user
        }
        $ResultCAPolicy | Add-Member Noteproperty "C_UsersExclude" ($ExcludeUsers -join [System.Environment]::NewLine)

        # Group Conditions
        $IncludeGroups = @()
        foreach($group in $CAPolicy.conditions.users.includeGroups){
            $IncludeGroups += (Get-AADGroup -groupid $group).displayName
        }
        $ResultCAPolicy | Add-Member Noteproperty "C_UsersIncludeGroups" ($IncludeGroups -join [System.Environment]::NewLine)

        $ExcludeApps = @()
        foreach($group in $CAPolicy.conditions.users.excludeGroups){
            $ExcludeGroups += (Get-AADGroup -groupid $group).displayName
        }
        $ResultCAPolicy | Add-Member Noteproperty "C_UsersExcludeGroups" ($ExcludeGroups -join [System.Environment]::NewLine)

        # Role Conditions
        $IncludeRoles = @()
        foreach($role in $CAPolicy.conditions.users.includeRoles){
            $IncludeRoles += Get-AzureADRole -RoleId $role
        }
        $ResultCAPolicy | Add-Member Noteproperty "C_UsersIncludeRoles" ($IncludeRoles -join [System.Environment]::NewLine)

        $ExcludeApps = @()
        foreach($role in $CAPolicy.conditions.users.excludeRoles){
            $ExcludeRoles += Get-AzureADRole -RoleId $role
        }
        $ResultCAPolicy | Add-Member Noteproperty "C_UsersExcludeRoles" ($ExcludeRoles -join [System.Environment]::NewLine)

        $ResultCAPolicy | Add-Member Noteproperty "G_Operator" $CAPolicy.grantControls.operator
        $ResultCAPolicy | Add-Member Noteproperty "G_BuiltInControls" ($CAPolicy.grantControls.builtInControls -join ",")
        $ResultCAPolicy | Add-Member Noteproperty "G_CustomControls" ($CAPolicy.grantControls.customAuthenticationFactors -join ",")
        $ResultCAPolicy | Add-Member Noteproperty "G_TermsOfUse" ($CAPolicy.grantControls.termsOfUse -join ",")
        $ResultCAPolicy | Add-Member Noteproperty "S_ApplicationEnforcedRestriction" ($CAPolicy.sessionControls.applicationEnforcedRestrictions.isEnabled)
        $ResultCAPolicy | Add-Member Noteproperty "S_CloudAppSecurity" ($CAPolicy.sessionControls.cloudAppSecurity.isEnabled)
        $ResultCAPolicy | Add-Member Noteproperty "S_CloudAppSecurityType" ($CAPolicy.sessionControls.cloudAppSecurity.cloudAppSecurityTyp)
        $ResultCAPolicy | Add-Member Noteproperty "S_PersistentBrowser" ($CAPolicy.sessionControls.persistentBrowser.isEnabled)
        $ResultCAPolicy | Add-Member Noteproperty "S_PersistentBrowserMode" ($CAPolicy.sessionControls.persistentBrowser.mode)
        $ResultCAPolicy | Add-Member Noteproperty "S_SignInFrequency" ($CAPolicy.sessionControls.signInFrequency.isEnabled)
        $ResultCAPolicy | Add-Member Noteproperty "S_SignInFrequencyTimeframe" ($CAPolicy.sessionControls.signInFrequency.value +" "+ $CAPolicy.sessionControls.signInFrequency.type)
        
        $ResultCAPolicies += $ResultCAPolicy

        Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text Metadata
        $ht2 = @{}
        $ResultCAPolicy.psobject.properties | Where-Object { $_.Name -like "M_*" } | ForEach-Object { $ht2[($_.Name.Replace("M_",""))] = ($(if($null -eq $_.Value){""}else{$_.Value})) }
        ($ht2.GetEnumerator() | Sort-Object -Property Name | Select-Object Name,Value) | Add-WordTable -FilePath $FullDocumentationPath -AutoFitStyle Window -Design LightListAccent2 

        Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text Conditions
        $ht2 = @{}
        $ResultCAPolicy.psobject.properties | Where-Object { $_.Name -like "C_*" } | ForEach-Object { $ht2[($_.Name.Replace("C_",""))] = ($(if($null -eq $_.Value){""}else{$_.Value})) }
        ($ht2.GetEnumerator() | Sort-Object -Property Name | Select-Object Name,Value) | Add-WordTable -FilePath $FullDocumentationPath -AutoFitStyle Window -Design LightListAccent2 
        
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text "Grant Controls"
        $ht2 = @{}
        $ResultCAPolicy.psobject.properties | Where-Object { $_.Name -like "G_*" } | ForEach-Object { $ht2[($_.Name.Replace("G_",""))] = ($(if($null -eq $_.Value){""}else{$_.Value})) }
        ($ht2.GetEnumerator() | Sort-Object -Property Name | Select-Object Name,Value) | Add-WordTable -FilePath $FullDocumentationPath -AutoFitStyle Window -Design LightListAccent2 
        
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text "Session Controls"
        $ht2 = @{}
        $ResultCAPolicy.psobject.properties | Where-Object { $_.Name -like "S_*" } | ForEach-Object { $ht2[($_.Name.Replace("S_",""))] = ($(if($null -eq $_.Value){""}else{$_.Value})) }
        ($ht2.GetEnumerator() | Sort-Object -Property Name | Select-Object Name,Value) | Add-WordTable -FilePath $FullDocumentationPath -AutoFitStyle Window -Design LightListAccent2 
    
    }
    $CsvPath = $FullDocumentationPath -replace "docx","csv"
    $ResultCAPolicies | Invoke-TransposeObject | Export-Csv -Path $CsvPath -Delimiter ";" -NoTypeInformation -Force


    #endregion

    #endregion
    #region Finishing
    ########################################################
    Write-Log "Press Ctrl + A and then F9 to Update the table of contents and other dynamic fields in the Word document."
    if($Script:NewTranslationFiles.Count -gt 0 -and $Script:UseTranslation){
        Write-Log "You used the option to translate API properties. Some of the configurations of your tenant could not be translated because translations are missing." -Type Warn
        foreach($file in ($Script:NewTranslationFiles | Select-Object -Unique)){
            Write-Log " - $($file.Replace('Internal\..\',''))" -Type Warn
        }
        Write-Log "You can support the project by translating and submitting the files as issue on the project page. Then it will be included for the future." -Type Warn
        Write-Log "Follow the guide here https://github.com/ThomasKur/IntuneDocumentation/blob/master/AddTranslation.md" -Type Warn
    }
    
    Write-Log "End Script $Scriptname"
    #endregion
}
# SIG # Begin signature block
# MIIPGgYJKoZIhvcNAQcCoIIPCzCCDwcCAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU/Pi6a0BPFB2VOlu8b7mlgt7i
# ie6gggxqMIIFrTCCBJWgAwIBAgIQBD9LZ/ZeEn/YHaINoG/0ljANBgkqhkiG9w0B
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
# AYI3AgEVMCMGCSqGSIb3DQEJBDEWBBRM4it0EsopiSrqy2q3OPdTTMPDBTANBgkq
# hkiG9w0BAQEFAASCAQATTpTh/+4pK8wmFy+NaOLIgFauL3BP7osVbLwyV/LYfXal
# 28HwRBYK5QOhsXX1U1q7A1Oj0MymfgXv2q8qdLhocPMMy9oNrhpF/8o6ioQ17ecs
# HoRVkTi9XNwAfEb/s389c5iu1g/8a4YlKINZfpZTY8kxhk87nVSSrFo2qRlRTRd2
# J8FiYy5kj9ZpZAzyc18DklWMfM+j7F7wueH35iu2HfFv9S5qDgrE6Qc/Fl5Ih6gw
# hgNyamtFd9mFzBaktsiLi9N0sOdgIqsXHHTUIa+qOx+CvqxcGZ7pFtvtyB1J3tHH
# 4n8Ymp4OGybq0Ef8s8G1sNwNzhAmbtwQzXOp9o7N
# SIG # End signature block
