$SharedServerPath = "\\servername\Techs\Documents\NSCC_Staff_Backups\$env:COMPUTERNAME"
$EmployeeID = Read-Host -Prompt 'Enter W#: '
$FirefoxPath = "C:\Users\w$EmployeeID\AppData\Roaming\Mozilla\Firefox"
mkdir \\servername\Techs\Documents\NSCC_Staff_Backups\$env:COMPUTERNAME -ErrorAction SilentlyContinue
$source="c:\"
$destination="\\servername\techs\Documents\NSCC_Staff_Backups\$env:COMPUTERNAME"
$files=@("*.pst","*.one")
$files2=@("*.doc","*.docx", "*.pdf", "*.xls", "*.xlsx", "*.ppt", "*.pptx", "*.accda", "*.mdb", "*.accdr", "*.adp")

$Exclude2 = Get-ChildItem -recurse ($source) -include ($files) -File -ErrorAction SilentlyContinue | Where-Object {$_.PSParentPath -notmatch "OneDrive - Nova Scotia Community College"} -ErrorAction SilentlyContinue
$Exclude3 = Get-ChildItem -recurse ($source) -include ($files2) -File -ErrorAction SilentlyContinue | Where-Object {$_.PSParentPath -notmatch "OneDrive - Nova Scotia Community College"} -ErrorAction SilentlyContinue


$Exclude2 | Copy-Item -Destination ($destination) -ErrorAction SilentlyContinue
$Exclude3 | Copy-Item -Destination ($destination) -ErrorAction SilentlyContinue



Copy-Item "C:\Users\w$EmployeeID\AppData\Local\Google\Chrome\User Data\Default\Bookmarks*" "\\servername\Techs\Documents\NSCC_Staff_Backups\$env:COMPUTERNAME" -Force
Copy-Item "C:\Users\w$EmployeeID\Favorites" -Recurse "\\servername\Techs\Documents\NSCC_Staff_Backups\$env:COMPUTERNAME" -Force
Copy-Item "C:\Users\w$EmployeeID\AppData\Local\Packages\Microsoft.MicrosoftEdge_8wekyb3d8bbwe\AC\MicrosoftEdge\User\Default" -Recurse "\\servername\Techs\Documents\NSCC_Staff_Backups\$env:COMPUTERNAME" -Force
#cp "C:\Users\w$EmployeeID\AppData\Roaming\Mozilla\Firefox\Profiles" -Recurse "\\servername\Techs\Documents\NSCC_Staff_Backups\$env:COMPUTERNAME" -Force


    if(Test-Path $FirefoxPath){
        Write-Output "Firefox is installed for this user"
        $ProfileSettings = Get-Content "$FirefoxPath\profiles.ini"
        $DefaultProfile = (($ProfileSettings | Select-String -Pattern 'Default=1' -Context 1).Context.PreContext)
        $ProfileName = $DefaultProfile.split("/")[1]
        $FileToCopy = Get-ChildItem -Path "$FirefoxPath\Profiles\$ProfileName" -recurse | Where-Object{$_.Name -like "places.sqlite"}
        try{
            Copy-Item -Path $FileToCopy -Destination $SharedServerPath
        }
        catch{
            Write-Warning "Error copying!"
            throw
        }
    }