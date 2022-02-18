try{

function Create-NewLocalAdmin {
    [CmdletBinding()]
    param (
        [string] $NewLocalAdmin,
        [securestring] $Password
    )    
    begin {
    }    
    process {
        New-LocalUser "$NewLocalAdmin" -Password $Password -FullName "$NewLocalAdmin" -Description "Temporary local admin"
        Add-LocalGroupMember -Group "Administrators" -Member "$NewLocalAdmin"
        
    }    
    end {
    }
}
$NewLocalAdmin = "sysop"
$Password = ConvertTo-SecureString -String "1ntun3@dm1n" -AsPlainText -Force
Create-NewLocalAdmin -NewLocalAdmin $NewLocalAdmin -Password $Password

exit 0

}

catch{
    $errmsg = $_.Exception.Message
    Write-Host $errmsg
    exit 1
    }