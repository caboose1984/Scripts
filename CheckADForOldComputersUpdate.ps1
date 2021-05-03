Get-WmiObject win32_bios
$wNumber = get-content Env:USERNAME
#Change this *Note the $campus variable has to match EXACTLY what your OU says in AD
$campus = Read-Host "Please enter your campus name as it shows in AD:"

$date = Get-Date
$CurrentDate = $Date.ToString('MM-dd-yyyy_hhmm')
$olderthen = $date.AddDays(-30)
Get-ADComputer -searchbase "ou=$campus,ou=internal computers,DC=" -filter {LastLogonDate -lt $olderthen} -Properties LastLogondate | Select-Object Name, LastLogondate | Export-CSV -path "C:\Users\$wNumber\Desktop\oldcomputers_$CurrentDate.csv" -NoTypeInformation