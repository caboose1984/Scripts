$files=@("*.pst","*.one")
$files2=@("*.doc","*.docx", "*.pdf", "*.xls", "*.xlsx", "*.ppt", "*.pptx", "*.accda", "*.mdb", "*.accdr", "*.adp")

$EmployeeID = Read-Host -Prompt 'Enter W#: '
$FirefoxPath = "C:\Users\w$EmployeeID\AppData\Roaming\Mozilla\Firefox"
$OldPC = Read-Host -Prompt 'Enter Previous PC'
$SharedServerPath = "\\servername\Techs\Documents\NSCC_Staff_Backups\$OldPC"



Copy-Item \\servername\Techs\Documents\NSCC_Staff_Backups\$OldPC\Bookmarks* -Recurse "C:\Users\w$EmployeeID\AppData\Local\Google\Chrome\User Data\Default\" -Force
Copy-Item \\servername\Techs\Documents\NSCC_Staff_Backups\$OldPC\Favorites -Recurse C:\Users\w$EmployeeID -Force
Copy-Item \\servername\Techs\Documents\NSCC_Staff_Backups\$OldPC\Default -Recurse C:\Users\w$EmployeeID\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\User\ -Force
# Copy-Item \\servername\Techs\Documents\NSCC_Staff_Backups\$OldPC\places.sqlite -Recurse C:\Users\w$EmployeeID\AppData\Roaming\Mozilla\Firefox\ -Force
Copy-Item \\servername\Techs\Documents\NSCC_Staff_Backups\$OldPC\* -Include ($files) C:\Users\w$EmployeeID\Documents -Force
Copy-Item \\servername\Techs\Documents\NSCC_Staff_Backups\$OldPC\* -Include ($files2) C:\Users\w$EmployeeID\Documents -Force


if(Test-Path $FirefoxPath){
    Write-Output "Firefox is installed for this user"
    $ProfileSettings = Get-Content "$FirefoxPath\profiles.ini"
    $DefaultProfile = (($ProfileSettings | Select-String -Pattern 'Default=1' -Context 1).Context.PreContext)
    $ProfileName = $DefaultProfile.split("/")[1]
    $FileToCopy = Get-ChildItem -Path $sharedserverpath -recurse | Where-Object{$_.Name -like "places.sqlite"}
    try{
        Copy-Item -Path $FileToCopy -Destination "$FirefoxPath\Profiles\$ProfileName"
    }
    catch{
        Write-Warning "Error copying!"
        throw
    }
}