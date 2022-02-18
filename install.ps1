#install flukeview and copy ocx

Start-Process msiexec.exe -Wait -ArgumentList "/I flukeview3.20.msi /qn"

Copy-Item ".\comctl32.ocx" -Destination "C:\Windows\System32"
Copy-Item ".\comctl32.ocx" -Destination "C:\Windows\Syswow64"
Copy-Item ".\comdlg32.ocx" -Destination "C:\Windows\System32"
Copy-Item ".\comdlg32.ocx" -Destination "C:\Windows\Syswow64"

Start-Process regsvr32.exe -ArgumentList "/s C:\windows\System32\comctl32.ocx"
Start-Process regsvr32.exe -ArgumentList "/s C:\windows\System32\comdlg32.ocx"
