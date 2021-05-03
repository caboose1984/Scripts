#Import activeDirectory Module
Import-Module activedirectory
#search ad for computer or computers
$Computers = Get-ADComputer -Filter {name -like "stws034*"}
foreach ($pc in $computers.name) {
    #ping computer to see if it is up
    $check = Test-Connection $pc -count 2 -Quiet
    #if computer is up, get username of logged on user
    If ($check -eq "true") {
        $user = get-wmiobject win32_computersystem -ComputerName $pc -ErrorAction SilentlyContinue
        $username = $user.UserName
        #if no one is logged on, end
        if ($username -eq $null) {out-null}
        # if they are logged on take the username from format of campus\w# and change it to just w#
        else {
            $split = $user.username -split '\\'
            #take the w# and search and for the first and last name of the user.
            $find = $split[1]
            $loggedOnuser = get-aduser  $find -ErrorAction SilentlyContinue
            $fName = $loggedOnuser.Givenname
            $sName = $loggedOnuser.surname
            $wNumber = $loggedOnuser.samaccountname
            write-host "$pc $fname $sname $wnumber"
        }
    }
}