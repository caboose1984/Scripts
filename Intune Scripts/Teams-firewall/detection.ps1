# used for testing
# Clear-Variable FWRules

# find currently logged in user
$proc = Get-CimInstance Win32_Process -Filter "name = 'explorer.exe'"
$username = (Invoke-CimMethod -InputObject $proc[0] -MethodName GetOwner).user


Try
{
    $FWRules = Get-NetFirewallRule -displayName "Teams.exe for user $username" -ErrorAction Stop

}

# we do nothing in the catch because returning nothing equals to false in the MEMCM application detection
Catch
{
    
}


# if the $FWRules variable returns $null output nothing
# otherwise return "rule exists" which will trigger a true on the MEMCM application detection
switch ($FWRules)
{
    $null {}
    default {write-host "rule exists"}

}