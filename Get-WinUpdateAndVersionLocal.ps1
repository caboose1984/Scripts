$date = Get-date
$CurrentDate = $date.ToString('MM-dd-yyyy')
$winver = (Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion" -Name ReleaseId).ReleaseId
$data = (Get-Hotfix -ErrorAction Stop | Select-Object -Property PSComputername, Description, HotFixID, InstalledOn | Sort-Object -Property InstalledOn -Descending)[0..1]
$data | Add-Member -Type noteproperty -name winver -value $winver
$data | Add-Member -Type noteproperty -name Date -value $CurrentDate
$data | Export-Csv -Path "C:\Temp\Updates.csv" -NoTypeInformation -Append