Connect-MsGraph
#REPLACE YOUR_PR_ID with the unique ID of your PR (Click on script package name in MEM to get ID in URL)
$Url = 'https://graph.microsoft.com/beta/deviceManagement/deviceHealthScripts/bfc70dc6-a6a9-4119-8cf6-c5bf74d475b5/deviceRunStates'
$Invoke = Invoke-MsGraphRequest  -Url $Url -HttpMethod GET
$Array = New-Object System.Collections.ArrayList
$Data = $Invoke.Value
Foreach ($Result in $Data) {
            $TempOutput = New-Object -TypeName PSObject -Property @{
                'preRemediationDetectionScriptOutput' = $Result.preRemediationDetectionScriptOutput
                'detectionState' = $Result.detectionState
                'remediationState' = $Result.remediationState
                'lastStateUpdateDateTime' = $Result.lastStateUpdateDateTime
                'lastSyncDateTime' = $Result.lastSyncDateTime                
            }
        $Array.Add($TempOutput) | out-null
}
$Array | Select-Object preRemediationDetectionScriptOutput,lastSyncDateTime | out-gridview