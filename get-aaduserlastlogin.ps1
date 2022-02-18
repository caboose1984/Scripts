$Cred = Get-Credential
Connect-MsolService -Credential $Cred
Connect-AzureAD -Credential $Cred

$Users = Get-MsolUser -all
$Headers = "DisplayName`tUserPrincipalName`tLicense`tLastLogon" >>C:\list.csv
ForEach ($User in $Users)
    {
    $UPN = $User.UserPrincipalName
    $LoginTime = Get-AzureAdAuditSigninLogs -top 1 -filter "userprincipalname eq '$UPN'" | select CreatedDateTime
    $NewLine = $User.DisplayName + "`t" + $User.UserPrincipalName + "`t" + $User.Licenses.AccountSkuId + "`t" + $LoginTime.CreatedDateTime
    $NewLine >>'G:\list.csv'
    }