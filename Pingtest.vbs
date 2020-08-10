REM TODO Add functionality to notice high pings, and a config field to determine what is too high and what is not
REM TODO Add functionality to test connection to primary gateway to verify connection issues between gateway or the rest of the internet
REM TODO Add Unscheduler
REM TODO Set scheduler to use this vbs file
REM TODO Somehow configure this to appear in task manager as something other than "wscript.exe"
REM TODO Add ability to install in other locations
REM TODO Add functionality to recognize situations where DNS does not work, but ping does, instead of double logging when both are failing.
REM TODO Increase logging readability

strInstallPath = "C:\Utilities\PingTest"
strLogPath = strInstallPath + "\BadPingLogs"
strConfigPath = strInstallPath + "\Config.txt"
set logger = new TxtLogger
logger.init(strLogPath)

'reads config file until it gets to the line [IP Addresses]. Every line after that is added to an IP address array
'TODO: Make reading the config file more useful for more variables
strIPArray = Array()
set objFileToRead = CreateObject("Scripting.FileSystemObject").OpenTextFile(strConfigPath, 1)
dim strLine
blnIPFlag=false
do while not objFileToRead.AtEndOfStream
	strLine = objFileToRead.ReadLine()
	if blnIPFlag=true then
		strIPArray = arrayPush(strIPArray, strLine)
	end if
	if strLine = "[IP Addresses]" then
		blnIPFlag=true
	end if

loop

do while true
		for each IP in strIPArray
		strPingCommand = "Ping -n 1 " & IP
		set Shell = CreateObject("WScript.Shell")
		Result = Shell.run(strPingCommand, 1, true)
		if Result <> 1 then
			dateObj = Date
			logger.logData("At " & FormatDateTime(Now, vbLongTime) & " ping Failed for " & IP)
		end if
	next
	WScript.Sleep 1000
loop

'Similar to array.push in other langauges
Function arrayPush(objArray, objPushMe)
	ReDim Preserve objArray(UBound(objArray) + 1)
	objArray(UBound(objArray)) = objPushMe
	arrayPush = objArray	
End Function


Class TxtLogger
	'TxtLogger writes to a dated folder in a path set at initialization. Example: folderpath/20191231.txt
	'It writes one line at a time any time the logData function is called.
	'Will not function until init(path) has been called'
	'TODO: Show up errors with an echo if no path set when logging attempted
	Private strLoggingFolderPath
	Private objFileToWrite
	Private strSavedDate

	Public Sub init(strNewLoggingFolderPath)
		'TODO verify existence of folder in OS
		strLoggingFolderPath = strNewLoggingFolderPath
	End Sub

	Public Sub logData(txtData)
		setLogFileToTodaysDate()
		objFileToWrite.WriteLine(txtData)
	End Sub

	'Checks to see if the logging filename includes todays date or not, fixes it if it is wrong
	Private Sub setLogFileToTodaysDate()
		'TODO FIX: If the file does not already exist, this will not create it.
		strTodaysDate = eightDigitDate()
		if strSavedDate <> strTodaysDate then
			strSavedDate = strTodaysDate
			strLogFile = strLoggingFolderPath + "\" + strTodaysDate + ".txt"
			WScript.Echo("Attempting to open " & strLogFile)
			set objFileToWrite = CreateObject("Scripting.FileSystemObject").OpenTextFile(strLogFile, 2)
		end if
	End Sub

	'returns the date as 8 digits YYYYMMDD
	Private Function eightDigitDate()
		objDate = Date
	    d = Right("00" & Day(objDate), 2)
	    m = Right("00" & Month(objDate), 2)
	    y = Year(objDate)
		strEightDigitDate = y & m & d
	    eightDigitDate = strEightDigitDate
	End Function
End Class