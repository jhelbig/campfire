#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Thegirltyler-Brand-Camp-Camp-Fire-Stories.ico
#AutoIt3Wrapper_Outfile=campfire.exe
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <Process.au3>
;get the settings from ini file
Global $application, $savefrom, $saveto, $reg
$application = IniRead("campfire.ini", "settings", "application", False)
$savefrom = IniRead("campfire.ini", "settings", "savefrom", "C:\Users\jakec\Documents\My Games")
$saveto = IniRead("campfire.ini", "settings", "saveto", "P:\My Games")
$reg = IniRead("campfire.ini", "settings", "reg", 0)
$fil = IniRead("campfire.ini", "settings", "file", 0)
if($application == False Or $application == "") Then
	MsgBox(0, "Error", "There was an error reading the ini file located in " & @ScriptDir & ".  Please verify it has the proper attributes.")
	Exit
Else
	;restore any files from cloud
	restore()

	;run the application
	_waitRun(Run($application, ""))

	;backup any new changes after 1 seconds and exit
	Sleep(1000)
	backup()

	Exit
EndIf


func backup()
	Sleep(1000)
;~ 	SplashTextOn("Campfire", "Saving game files to the cloud...", 400, 75)
;~ 	Sleep(2500)
	if($reg == 1)Then
		RunWait('reg export "' & $savefrom & '" "' & $saveto & '.reg" /y', "", @SW_HIDE)
	Elseif($fil == 1)Then
;~ 		ConsoleWrite("BACKUP - FILE SETTING" & @CRLF)
;~ 		ConsoleWrite("BACKUP - " & $savefrom & @CRLF)
		if ($savefrom == "files") Then
;~ 			ConsoleWrite("BACKUP - MULTIPLE FILES" & @CRLF)
			$counter = 0
			$source = IniRead("campfire.ini", "files", "source", False)
			while True
				if ($source == False) Then
					ExitLoop
				EndIf
				$file = IniRead("campfire.ini", "files", "f" & $counter, False)
;~ 				ConsoleWrite($source & $file & @CRLF)
				if ($file == False) Then
					ExitLoop
				Else
					$counter = $counter + 1
				EndIf
;~ 				if the current 'file' does not have a "D" in it, the it's most likely a file.
				if(StringInStr(FileGetAttrib($source & $file), "D") == 0)Then
					FileCopy($source & $file, $saveto & $file, 9)
				Else
					DirCopy($source & $file, $saveto & $file, 1)
				EndIf
			WEnd
		Else
			FileCopy($savefrom, $saveto, 9)
		EndIf
	Else
		DirCopy($savefrom, $saveto, 1)
	EndIf
;~ 	$fileDate = FileGetTime($saveto)
;~ 	if($fileDate[0] == @YEAR And $fileDate[1] == @MON And $fileDate[2] == @MDAY And $fileDate[3] == @HOUR And $fileDate[4] == @MIN)Then

;~ 	Else
;~ 		MsgBox(16, "Campfire", "There was an error saving your game data.  Please move it yourself!" & @CRLF & "From: " & $savefrom & @CRLF & "To: " & $saveto)
;~ 	EndIf
EndFunc

func restore()
	if($reg == 1)Then
		RunWait('reg import "' & $saveto & '"', "", @SW_HIDE)
	Elseif($fil == 1)Then
		if ($savefrom == "files") Then
			if(StringInStr(FileGetAttrib($saveto), "D") == 0)Then
				FileCopy($saveto, IniRead("campfire.ini", "files", "source", false), 9)
			Else
				DirCopy($saveto, IniRead("campfire.ini", "files", "source", false), 1)
			EndIf
		Else
			FileCopy($saveto, $savefrom, 9)
		EndIf
	Else
		DirCopy($saveto, $savefrom, 1)
	EndIf
EndFunc


Func _waitRun($pid)
	$debug = false
	if $debug Then
;~ 		ConsoleWrite("STARTING WAITRUN" & @CRLF)
;~ 		ConsoleWrite($pid & @CRLF)
	EndIf
;~ 	check if the process exists at all first
	if(ProcessExists($pid))Then
;~ 		if the pid sent is a number get the process name
;~ 		else set the name and get the process id from the name
		if(IsNumber($pid))Then
;~ 			ConsoleWrite("SETTING WAITRUN NAME" & @CRLF)
			$name = _ProcessGetName($pid)
;~ 			ConsoleWrite($name & @CRLF)
		else
;~ 			ConsoleWrite("SETTING WAITRUN PID AND NAME" & @CRLF)
			$temp = $pid
			$pid = ProcessExists($pid)
			$name = $temp
;~ 			ConsoleWrite($temp & @CRLF)
;~ 			ConsoleWrite($pid & @CRLF)
;~ 			ConsoleWrite($name & @CRLF)
		EndIf
;~ 		if pid is > 0 then continue the while loop
;~ 		else return 0 because the process no longer exists
		if ($pid > 0) Then
			While (ProcessExists($pid))
				Sleep(1000)
;~ 				ConsoleWrite($name & @CRLF)
			WEnd
;~ 			if the process exists through a different pid but the same name, run this loop again
;~ 			else return false cause it no longer exists
			if ProcessExists($name)Then
;~ 				ConsoleWrite("RESTARTING WAITRUN" & @CRLF)
				_waitRun($name)
			Else
;~ 				ConsoleWrite("STOPING WAITRUN" & @CRLF)
				Return false
			EndIf
		Else
;~ 			ConsoleWrite("STOPING WAITRUN" & @CRLF)
			Return false
		EndIf
		Sleep(5000)
	EndIf
EndFunc