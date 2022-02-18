$compliance = $false


if (Test-Path "C:\Windows\System32\Macromed\Flash") {
    $flashfiles = (Get-ChildItem "C:\Windows\System32\Macromed\Flash" -Filter *.exe -ErrorAction SilentlyContinue).Name
    if ($flashfiles -match "flashutil64") {
    }

    else {
        $compliance = $true
    }

}

else {
    $compliance = $true
}

if ($compliance -eq $true) {
    exit 0
}

else {
    exit 1
}