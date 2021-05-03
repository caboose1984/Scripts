$searchbase = "OU="
$computers = Get-ADComputer -filter * -SearchBase $searchbase -properties * | Select-Object -property Name, OperatingSystemVersion 
$date = Get-date
$currentdate = $date.ToString('MM-dd-yyyy_hhmm')
$CSVPath = "C:\Scripts\Updates_$currentdate.csv"
$ErrorActionPreference = "Stop"

$results = @()

$results = foreach ($c in $computers) {

    $obj = @{
        name    = $c.name
        version = $c.OperatingSystemVersion
    }
    
    switch ($obj.version) {
        "10.0 (14393)" { $obj.version = "1607" }
        "10.0 (10586)" { $obj.version = "1511" }
        "10.0 (10240)" { $obj.version = "1507" }
        "10.0 (15063)" { $obj.version = "1703" }
        "10.0 (16299)" { $obj.version = "1709" }
        "10.0 (17133)" { $obj.version = "1803" }
        "10.0 (17134)" { $obj.version = "1803" }
        "10.0 (17763)" { $obj.version = "1809" }
        "10.0 (18362)" { $obj.version = "1903" }
        
    }
    [pscustomobject]$obj
}

$results | Export-Csv -path $CSVPath -NoTypeInformation