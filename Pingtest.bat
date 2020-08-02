@echo off

REM TODO Add functionality to notice high pings, and a config field to determine what is too high and what is not
REM TODO Add functionality to test connection to primary gateway to verify connection issues between gateway or the rest of the internet
REM TODO Set Date to not be global
REM TODO Add Unscheduler
REM TODO Add ability to install in other locations

setlocal enabledelayedexpansion

REM filepaths and filenames
set InstallPath=C:\Utilities\PingTest
set LogPath=%InstallPath%\BadPingLogs
set formatteddate=%date:~10,4%%date:~7,2%%date:~4,2%
set LogFile=%LogPath%\!formatteddate!.txt
set ConfigPath=%InstallPath%\Config.txt

REM reads config file until it gets to the line [IP Addresses]. Every line after that is added to an IP address array
set CurrentTask=:eof
set NextTask=:eof
set IPArray=Blank

for /f "tokens=*" %%a in (%ConfigPath%) do (
	set CurrentLine=%%a
	set CurrentTask=!NextTask!
	if "!CurrentLine!" EQU "[IP Addresses]" (set NextTask=:addIP)
	call !CurrentTask! !CurrentLine!
)

REM Main Loop, runs forever checks DNS and ping timeout for each address
:pingtest
for %%a in (%IPArray%) do (
	REM Pings address, reports if there is a timeout error
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

:addIP
if !IPArray! EQU Blank (
	set IPArray=%*
	goto :eof
)
set IPArray=%IPArray%;%*

:eof