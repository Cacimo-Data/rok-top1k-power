; ==================================================
; RISE OF KINDOMS SCREENSHOT CAPTURE TOOL 
; Using AutoHotKey and ROK For PC
;
; Created by: Đumoƞt KD2338
;
; CHANGE HISTORY
;    19 May 2022 - First Working Version
; ==================================================


#Include %A_ScriptDir%\Libraries\General.ahk
#Include %A_ScriptDir%\Libraries\CaptureScreen.ahk
#Include %A_ScriptDir%\Libraries\ROK.ahk
#Include %A_ScriptDir%\Config.ahk

; ------------------------------------------------
; Ensure we are running with admin privileges
; and there is only one copy of this macro running
; ------------------------------------------------
#SingleInstance Force
if not A_IsAdmin
  Run *RunAs "%A_ScriptFullPath%"


; This is ridiculous, but let's do it anyway.
FileEncoding, UTF-8

; ------------------------------------------------
; Activate and show the main ROK window
; ------------------------------------------------
if WinExist("Rise of Kingdoms") {
    WinActivate ;
    Sleep, Delay
    CenterWindow("ahk_exe MASS.exe")
    Sleep, Delay
} else {
    MsgBox Rise of Kingdoms is not running!
}

; ------------------------------------------------
; Prepare the place to save our results
; ------------------------------------------------
FormatTime, CurrentDateTime,, yyyy-MM-dd 
SaveFolder := CreateSaveFolder(ConfigSavePath)
OutputFile := CreateOutputFile(ConfigSavePath, True)
GovernorIDs := []

; ------------------------------------------------
; Verify we are at the current user's City View
; ------------------------------------------------
if (!CheckCityView()) {
    Log("User is not at the City View screen. Quitting.")
    MsgBox Please close the screen and go to the City View.
    Exit
}

; ------------------------------------------------
; Set up the tooltip 
; ------------------------------------------------
tooltip WATCH THIS SPACE FOR INFO, 0, -20

CancelMsg = 
(
Use CTRL-ALT-X to cancel the ROK Statistics macro
)
tooltip %CancelMsg% // Starting up..., 0, -12

; Keep track of where we think we are in the list of governors
; This prevents infinite loops.
Log("Processing Started")

GovCount := 1

if (FileExist(ExtraGovernorsFile)) {
    Log("Capturing Extra Governors")

    TotalGovernors := CountFileLines(ExtraGovernorsFile)
    ClickSleep(50, 65, Delay) ; Click Governor Icon for the current user
    ClickSleep(984, 561, Delay) ; Click Settings Icon
    ClickSleep(925, 225, Delay) ; Click Search Governor

    ClickSleep(325, 145, Delay) ; Place the Cursor in the Search Box

    Loop, Read, %ExtraGovernorsFile%
    { 
        Clipboard = %A_LoopReadLine%
        ; Paste the name
        tooltip %CancelMsg% // Capturing Governor %A_LoopReadLine% -- #%GovCount% of %TotalGovernors% , 0, -12
        Send ^v 
        Sleep 100
        ClickSleep(1073, 145, Delay) ; Click the Search Button
        Ret := CaptureGovernor(230, 255) ; Capture the Governor Info
        if (!Ret) {
            Data = %GovernorName%,NOT FOUND`n
            Log(GovernorName . " could not be loaded")
            FileAppend, %Data%, %OutputFile%
        }
        ClickSleep(65, 345, 350) ; Close the Covernor Window

        ClickSleep(325, 145, Delay) ; Place the Cursor in the Search Box
        Send ^a
        Send {Backspace}
        GovCount := GovCount + 1
    }
    ClickSleep(1147,73,Delay) ; CLose the Search Window
    ClickSleep(1147,73,Delay) ; CLose the Settings
    ClickSleep(65, 345, 350) ; Close the Current User governor Window
} else {
    MsgBox File Not Found: %ExtraGovernorsFile%
    Log("Processing Finished")
}

Log("Processing Finished")

; Hotkey to kill the script early
^!x::ExitApp  ; Quit script with Ctrl+Alt+X

tooltip