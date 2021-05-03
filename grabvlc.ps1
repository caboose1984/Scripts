# This is a test script to download and install VLC and deploy a shortcut to the desktop

#Check for a temp folder (could also use $env:TEMP, but for the purposes of this we can create a folder)

$doestempexist = Test-Path c:\Temp

#if folder doesnt exist, create it
if (-not $doestempexist)
{
    New-Item -Path c:\Temp -ItemType Directory
}

#download file from web
$fileloc = "https://ftp.osuosl.org/pub/videolan/vlc/3.0.12/win64/vlc-3.0.12-win64.exe"
$destination = "c:\Temp\vlc-3.0.12-win64.exe"
Invoke-WebRequest -Uri $fileloc -OutFile $destination

#silently run the installer
& $destination /L=1033 /S

#create shortcut on the desktop
$shortcutpath = "C:\users\$ENV:USERNAME\Desktop"
$shellcmd = New-Object -ComObject WScript.Shell
$shortcut = $shellcmd.CreateShortcut($shortcutpath)
$shortcut.TargetPath = "C:\Program Files (x86)\VideoLAN\VLC\vlc.exe"
$shortcut.Save()