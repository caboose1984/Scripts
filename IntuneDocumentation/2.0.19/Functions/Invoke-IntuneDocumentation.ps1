Function Invoke-IntuneDocumentation(){
    <#
    .DESCRIPTION
    This Script documents an Intune Tenant with almost all settings, which are available over the Graph API.
    NOTE: This no longer does Conditional Access
    The Script is using the PSWord and Microsoft.Graph.Intune Module. Therefore you have to install them first.



    .PARAMETER FullDocumentationPath
        Path including filename where the documentation should be created. The filename has to end with .docx.
        Note:
        If there is already a file present, the documentation will be added at the end of the existing document.

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
    

    .EXAMPLE Interactive
    Invoke-IntuneDocumentation -FullDocumentationPath c:\temp\IntuneDoc.docx

    .EXAMPLE Non interactive
    Invoke-IntuneDocumentation -FullDocumentationPath c:\temp\IntuneDoc.docx  -ClientId d5cf6364-82f7-4024-9ac1-73a9fd2a6ec3 -ClientSecret S03AESdMlhLQIPYYw/cYtLkGkQS0H49jXh02AS6Ek0U= -Tenant d873f16a-73a2-4ccf-9d36-67b8243ab99a

    .NOTES
    Author: Thomas Kurth/baseVISION
    Co-Author: jflieben
    Co-Author: Robin Dadswell
    Date:   26.7.2020

    History
        See Release Notes in Github.

    #>
    [CmdletBinding()]
    Param(
        [ValidateScript({
            if($_ -notmatch "(\.docx)"){
                throw "The file specified in the path argument must be of type docx"
            }
            return $true 
        })]
        [Parameter(ParameterSetName = "NonInteractive")]
        [Parameter(ParameterSetName = "Default")]
        [System.IO.FileInfo]$FullDocumentationPath = ".\IntuneDocumentation.docx",

        [Parameter(ParameterSetName = "Default")]
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
    $ScriptName = "DocumentIntune"
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
    if($PsCmdlet.ParameterSetName -eq "NonInteractive"){
        $authority = "https://login.windows.net/$Tenant"
        Update-MSGraphEnvironment -AppId $ClientId -Quiet
        Update-MSGraphEnvironment -AuthUrl $authority -Quiet
        Connect-MSGraph -ClientSecret $ClientSecret -Quiet
    } else { 
        Connect-MSGraph
    }
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
        Update-WordText -FilePath $FullDocumentationPath -ReplacingText "SYSTEM" -NewText "Intune"
        try{
            $org = Invoke-MSGraphRequest -Url /organization
            Update-WordText -FilePath $FullDocumentationPath -ReplacingText "TENANT" -NewText $org.value.displayName
        } catch{
            Update-WordText -FilePath $FullDocumentationPath -ReplacingText "TENANT" -NewText ""
        }
        
    }
    #endregion
    #region Document Apps
    $Intune_Apps = @()
    $AppGroups = @()
    Get-MobileAppsBeta | ForEach-Object  {
        $App_Assignment = Get-IntuneMobileAppAssignment -mobileAppId $_.id
        if($App_Assignment){
            $Intune_App = New-Object -Type PSObject
            $Intune_App | Add-Member Noteproperty "Publisher" $_.publisher
            $Intune_App | Add-Member Noteproperty "DisplayName" $_.displayName
            $Intune_App | Add-Member Noteproperty "Type" (Format-MsGraphData $_.'@odata.type')
            $Assignments = @()
            foreach($Assignment in $App_Assignment) {
                if($null -ne $Assignment.target.groupId){
                    $AppGroups += $Assignment.target.groupId
                    $Assignments += "$((Get-AADGroup -groupid $Assignment.target.groupId).displayName)`n - Intent:$($Assignment.intent)"
                } else {
                    $Assignments += "$(($Assignment.target.'@odata.type' -replace "#microsoft.graph.",''))`n - Intent:$($Assignment.intent)"
                }
            }
            $Intune_App | Add-Member Noteproperty "Assignments" ($Assignments -join "`n")
            $Intune_Apps += $Intune_App
        }
    } 
    if($null -ne $Intune_Apps){
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "Applications"
        $Intune_Apps | Sort-Object Publisher,DisplayName | Add-WordTable -FilePath $FullDocumentationPath -AutoFitStyle Contents -Design LightListAccent2
        if($null -ne $AppGroups){
            Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "Groups used to assign apps"
            Invoke-PrintGroup -GroupIds $AppGroups
        }
    }
    #endregion
    #region Document App protection policies
    $MAMs = Get-IntuneAppProtectionPolicy | Where-Object { $_.'@odata.type' -notlike "*AppConfiguration" }

    if($null -ne $MAMs){
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "App Protection Policies"
        foreach($MAM in $MAMs){
            write-Log "App Protection Policy: $($MAM.displayName)"
            Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text $MAM.displayName
            if($MAM.'@odata.type' -eq "#microsoft.graph.mdmWindowsInformationProtectionPolicy"){
                $MAM.protectedApps = $MAM.protectedApps.displayName -join ", "
            }
            Invoke-PrintTable -Properties $MAM.psobject.properties -TypeName $MAM.'@odata.type'
            if($MAM.'@odata.type' -eq "#microsoft.graph.iosManagedAppProtection"){
                $MAMA = Get-MAM_iOS_Assignment -policyId $MAM.id
            }
            if($MAM.'@odata.type' -eq "#microsoft.graph.androidManagedAppProtection"){
                $MAMA = Get-MAM_Android_Assignment -policyId $MAM.id
            }
            if($MAM.'@odata.type' -eq "#microsoft.graph.mdmWindowsInformationProtectionPolicy"){
                $MAMA = Get-MAM_Windows_Assignment -policyId $MAM.id
            }
            Invoke-PrintAssignmentDetail -Assignments $MAMA
        }
    }
    #endregion
    #region Document App configuration policies
    $MACs = Get-IntuneAppProtectionPolicy | Where-Object { $_.'@odata.type' -like "*AppConfiguration" }
    if($null -ne $MACs){
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "App Configuration Policies"
        foreach($MAC in $MACs){
            write-Log "App Configuration Policy: $($MAC.displayName)"
            Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text $MAC.displayName
            Invoke-PrintTable -Properties $MAC.psobject.properties -TypeName $MAC.'@odata.type'
            $MACA = Get-ManagedAppConfig_Assignment -policyId $MAC.id
            Invoke-PrintAssignmentDetail -Assignments $MACA
        }
    }
    #endregion
    #region Document Compliance Policies
    $DCPs = Get-IntuneDeviceCompliancePolicy
    if($null -ne $DCPs){
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "Compliance Policies"
        foreach($DCP in $DCPs){
            write-Log "Device Compliance Policy: $($DCP.displayName)"
            Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text $DCP.displayName
            if([String]::IsNullOrWhiteSpace($DCP.'@odata.type') -eq $false){
                Invoke-PrintTable -Properties $DCP.psobject.properties -TypeName $DCP.'@odata.type'
                $id = $DCP.id
                $DCPA = Get-IntuneDeviceCompliancePolicyAssignment -deviceCompliancePolicyId $id
                Invoke-PrintAssignmentDetail -Assignments $DCPA
            }
            
        }
    }
    #endregion
    #region Security Baselines
    $SBs = Get-SecBaselinesBeta
    if($null -ne $SBs){
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "Security Baselines"
        foreach($SB in $SBs){
            write-Log "Security Baselines Policy: $($SB.displayName)"
            Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text $SB.Name
            # $SB.Settings | Add-WordTable -FilePath $FullDocumentationPath -AutoFitStyle Window -Design LightListAccent2 
            Invoke-PrintTable -Properties $SB.Settings -TypeName $SB.'@odata.type'
            Invoke-PrintAssignmentDetail -Assignments $SB.Assignments
        }
    }
    #endregion
    #region Document T&C
    write-Log "Terms and Conditions"
    $GAndTs = Get-IntuneTermsAndConditions
    if($null -ne $GAndTs){
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "Terms and Conditions"
        foreach($GAndT in $GAndTs){
            Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text $GAndT.displayName
            $GAndT | Select-Object -Property id,@{Name="Created at";Expression={$_.createdDateTime}},@{Name="Modified at";Expression={$_.lastModifiedDateTime}},@{Name="Displayname";Expression={$_.displayName}},@{Name="Title";Expression={$_.title}},@{Name="Version";Expression={$_.version}}  | Add-WordTable -FilePath $FullDocumentationPath -AutoFitStyle Contents -Design LightListAccent2
            $DCPA = Get-DeviceManagement_TermsAndConditions_Assignments -termsAndConditionId $GAndT.id
            Invoke-PrintAssignmentDetail -Assignments $DCPA
        }
    }
    #endregion
    
    #region Document Device Configurations
    Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "Device Configuration"
    $DCPs = Get-ConfigurationProfileBeta
    foreach($DCP in $DCPs){
        write-Log "Device Compliance Policy: $($DCP.displayName)"
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text $DCP.displayName
        Invoke-PrintTable -Properties $DCP.psobject.properties -TypeName $DCP.'@odata.type'
        $id = $DCP.id
        $DCPA = Get-IntuneDeviceConfigurationPolicyAssignment -deviceConfigurationId $id
        Invoke-PrintAssignmentDetail -Assignments $DCPA
    }
    $ADMXPolicies = Get-ADMXBasedConfigurationProfile
    foreach($ADMXPolicy in $ADMXPolicies){
        write-Log "Device Configuration (ADMX): $($ADMXPolicy.DisplayName)"
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text $ADMXPolicy.DisplayName
        $ADMXPolicy.Settings | Add-WordTable -FilePath $FullDocumentationPath -AutoFitStyle Window -Design LightListAccent2

        $DCPA = Get-ADMXBasedConfigurationProfile_Assignment -ADMXBasedConfigurationProfileId $ADMXPolicy.Id
        Invoke-PrintAssignmentDetail -Assignments $DCPA
    }
    #endregion
    #region Device Management Scripts (PowerShell)
    Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "Device Management Scripts"
    $PSScripts = Get-DeviceManagementScript
    foreach($PSScript in $PSScripts){
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text $PSScript.displayName
        $ht2 = @{}
        $PSScript.psobject.properties | ForEach-Object { 
            if($_.Name -ne "scriptContent"){
                $ht2[(Format-MsGraphData $($_.Name))] = "$($_.Value)"
            }
        }
        ($ht2.GetEnumerator() | Sort-Object -Property Name | Select-Object Name,Value) | Add-WordTable -FilePath $FullDocumentationPath -AutoFitStyle Window -Design LightListAccent2
        $DCPA = Get-DeviceManagementScript_Assignment -DeviceManagementScriptId $ht2.id
        Invoke-PrintAssignmentDetail -Assignments $DCPA
        
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading3 -Text "Script"
        $PSScript.scriptContent -replace "`0", "" | Add-WordText -FilePath $FullDocumentationPath -Size 10 -Italic -FontFamily "Courier New"
    }
    #endregion
    #region AutoPilot Configuration
    $AutoPilotConfigs = Get-WindowsAutopilotConfig
    if($null -ne $AutoPilotConfigs){
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "AutoPilot Configuration"
        
        foreach($APC in $AutoPilotConfigs){
            write-Log "AutoPilot Config: $($APC.displayName)"
            Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text $APC.displayName
            Invoke-PrintTable -Properties $APC.psobject.properties  -TypeName $APC.'@odata.type'
        }
    }
    #endregion

    #region Enrollment Configuration
    $EnrollmentStatusPage = Get-EnrollmentStatusPage
    if($null -ne $EnrollmentStatusPage){
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "Enrollment Configuration"
        foreach($ESP in $EnrollmentStatusPage){
            write-Log "Enrollment Status Page Config: $($ESP.displayName)"
            $ESPtype = $ESP.'@odata.type'
            switch($ESPtype){
                "#microsoft.graph.windows10EnrollmentCompletionPageConfiguration" { $ESPtype = "ESP" }
                "#microsoft.graph.deviceEnrollmentLimitConfiguration" { $ESPtype = "Enrollment Limit" }
                "#microsoft.graph.deviceEnrollmentPlatformRestrictionsConfiguration" { $ESPtype = "Platform Restrictions" }
                "#microsoft.graph.deviceEnrollmentWindowsHelloForBusinessConfiguration" { $ESPtype = "Windows Hello for Business" }
            }
            Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text "$($ESPtype) - $($ESP.displayName)"
            
            Invoke-PrintTable -Properties $ESP.psobject.properties -TypeName $ESP.'@odata.type'
            $DCPA = Get-DeviceManagement_DeviceEnrollmentConfigurations_Assignments -deviceEnrollmentConfigurationId $ESP.id
            Invoke-PrintAssignmentDetail -Assignments $DCPA
        }
    }
    #endregion

    #region Custom Roles
    $CustomRoles = Get-DeviceManagement_RoleDefinitions | Where-Object { $_.isBuiltin -eq $false }
    if($null -ne $CustomRoles){
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "Custom Roles"
        foreach($CustomRole in $CustomRoles){
            write-Log "Custom role: $($CustomRole.displayName)"
            Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text $CustomRole.displayName
            $CustomRole.rolePermissions.resourceActions.allowedResourceActions | Add-WordText -FilePath $FullDocumentationPath -Size 11
        }
    }
    #endregion

    #region Apple Push Certificate
    try{ 
        $VPPs = Get-IntuneVppToken -ErrorAction SilentlyContinue
        $APNs = Get-IntuneApplePushNotificationCertificate -ErrorAction SilentlyContinue
    } catch {
        Write-Log "Failed to load AppleAPN or VPP information"
    }
    Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "Apple Configurations"
    Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text "Apple Push Certificate"
    foreach($APN in $APNs){
        write-Log "APN Config: $($APN.appleIdentifier)"
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading3 -Text $APN.appleIdentifier
        Invoke-PrintTable -Properties $APN.psobject.properties -TypeName "applePushNotificationCertificate"
    }
    Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text "Apple VPP Tokens"
    foreach($VPP in $VPPs){
        write-Log "VPP Config: $($VPP.appleId)"
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading3 -Text $VPP.appleId
        Invoke-PrintTable -Properties $VPP.psobject.properties -TypeName "appleVPPCertificate"
    }
    #endregion

    #region Device Categories
    $Cats = Get-IntuneDeviceCategory
    if($null -ne $Cats){
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "Device Categories"
        write-Log "Device Categories: $($Cats.count)"
        foreach($Cat in $Cats){
            Add-WordText -FilePath $FullDocumentationPath -Text (" - " + $Cat.displayName) -Size 10
        }
    }
    #endregion

    #region Exchange Connection
    $exch = Get-IntuneExchangeConnector
    if($null -ne $exch){
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "Exchange Connector"
        write-Log "Exchange Connector: $($exch.serverName)"
        Invoke-PrintTable -Properties $exch.psobject.properties -TypeName "ExchangeConnector"
    }
    #endregion

    #region Partner Configuration
    $partnerConfigs = Get-IntuneDeviceManagementPartner
    if($null -ne $partnerConfigs){
        Add-WordText -FilePath $FullDocumentationPath -Heading Heading1 -Text "Partner Connections"
        
        foreach($partnerConfig in $partnerConfigs){
            write-Log "Partner Config: $($partnerConfig.displayName)"
            Add-WordText -FilePath $FullDocumentationPath -Heading Heading2 -Text $partnerConfig.displayName
            Invoke-PrintTable -Properties $partnerConfig.psobject.properties -TypeName "PartnerConfiguration"
        }
    }
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
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQU3jqKQPzpA5nuRvo7ZcVDEhTu
# 03GgggxqMIIFrTCCBJWgAwIBAgIQBD9LZ/ZeEn/YHaINoG/0ljANBgkqhkiG9w0B
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
# AYI3AgEVMCMGCSqGSIb3DQEJBDEWBBR9Z+H0gwh1JsMWAFa/fOe5nIEUoTANBgkq
# hkiG9w0BAQEFAASCAQCbn7hBRGe7Z0PUWeXJHye1oCrr5YVh3Xgy4dh4iYPMTH7J
# LxXr+C/dv6PcDrbgPVrnVnQvKy4jy9wVzqvNeIPYgnGp16+XKaqe/z61dOi3Udb4
# y1Fpkn7VqyuhcUWONjiaCBKkyMFOlKuPbkEnLQkjq7B3+8Z6SfPHzFRreuxJ2gcH
# cyodPx/H6ihjFJV9O80oAV0pDFW86p1lmxRUzPLifVl/gd17kVd9BafuHEx5CFJ3
# vlnj76W2R0GL4T1/EA7OTXQvJvPziM1TPVal8l2I4zWlK+XRAkB6ZB7PGAiGrN8t
# 2vo5Njx5qBCmypZqoibUKCMsvfuarrSjA8V/naNp
# SIG # End signature block
