@echo off
setlocal enabledelayedexpansion

set InstallPath=C:\Utilities\PingTest
set LogPath=%InstallPath%\BadPingLogs
set formatteddate=%date:~10,4%%date:~7,2%%date:~4,2%
set LogFile=%LogPath%\!formatteddate!.txt
set ConfigPath=%InstallPath%\Config.txt
set CurrentTask=:eof
set NextTask=:eof
set IPArray=Blank

for /f "tokens=*" %%a in (%ConfigPath%) do (
	set CurrentLine=%%a
	set CurrentTask=!NextTask!
	if "!CurrentLine!" EQU "[IP Addresses]" (set NextTask=:addIP)
	call !CurrentTask! !CurrentLine!
)

:pingtest
for %%a in (%IPArray%) do (
	set formatteddate=%date:~10,4%%date:~7,2%%date:~4,2%
	ping %%a -n 1
	if errorlevel 1 (
		echo At %time% %date%, this PC could not reach %%a >> %LogFile%
	)
	set counter=0
	set NSResult=Null
	for /F "tokens=2" %%a in ('"nslookup www.google.com" ^') do (
		if "!counter!" EQU "0" set NSResult=%%a
		set counter=counter+1
	)
	if "!NSResult!" EQU "UnKnown" (
		echo At %time% %date%, this PC could not resolve %%a. Please verify DNS server. >> %LogFile%
	)
)
timeout 1
goto :pingtest

goto :eof
:echoinput
echo %*

:addIP
if !IPArray! EQU Blank (
	set IPArray=%*
	goto :eof
)
set IPArray=%IPArray%;%*

:eof