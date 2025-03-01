; === CONFIGURATION ===
; Log file path is fixed.
logFilePath := "C:\Games\EverQuest\Logs\eqlog_Toon_server.txt"

; --- Debugging: Check if the file exists ---
if !FileExist(logFilePath)
{
    MsgBox, 16, Error, Log file not found:`n%logFilePath%
    ExitApp
}

; --- Create a GUI Status Window ---
Gui, Add, Text, vStatusText, Script is active and monitoring for buff requests...
Gui, Show, w400 h100, Buff Script Status

; --- Initialize log file reading ---
FileGetSize, lastSize, %logFilePath%
if ErrorLevel
{
    MsgBox, 16, Error, Failed to get size of log file:`n%logFilePath%
    ExitApp
}
ToolTip, Log file loaded successfully.
Sleep, 1500
ToolTip

; --- Set a timer to check the log every 100 milliseconds ---
SetTimer, CheckLog, 100
Return

CheckLog:
    ; Get the current file size.
    FileGetSize, currentSize, %logFilePath%
    if ErrorLevel
    {
        GuiControl,, StatusText, Error: Unable to read log file.
        Return
    }
    
    if (currentSize > lastSize)
    {
        ; Read the entire file and then extract only the new part.
        FileRead, fullContent, %logFilePath%
        if ErrorLevel
        {
            GuiControl,, StatusText, Error: Unable to read contents of log file.
            Return
        }
        
        newContent := SubStr(fullContent, lastSize + 1)
        lastSize := currentSize

        ; Look for a tell that contains 'buff:' using a regex.
        ; Expected format: "SenderName tells you, 'buff: SoW'"
        if (RegExMatch(newContent, "i)(\w+)\s+tells you,\s*'buff:\s*(\S+)'", m))
        {
            sender := m1
            buffRequest := m2
            StringLower, buffRequest, buffRequest

            ; Determine the keystroke based on the buff request.
            castKey := ""
            if (buffRequest = "sow")
                castKey := "6"
            else if (buffRequest = "focus")
                castKey := "5"
	    else if (buffRequest = "regen")
		castKey := "3"
            
            if (castKey != "")
            {
                GuiControl,, StatusText, Received buff request from %sender% for "%buffRequest%" (casting key %castKey%)
                ; First, target the sender.
                SendInput, /target %sender%{Enter}
                Sleep, 3000
                ; Then send the keystroke to cast the buff.
                SendInput, /cast %castKey%{Enter}
                Sleep, 500
                GuiControl,, StatusText, Request processed for %sender%.
            }
            else
            {
                GuiControl,, StatusText, Unknown buff request: "%buffRequest%"
            }
        }
    }
Return

; When the GUI is closed, exit the script.
GuiClose:
    ExitApp
