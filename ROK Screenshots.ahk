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
OutputFile := CreateOutputFile(ConfigSavePath)
GovernorIDs := []

GovCount := 1
Msg = 
(
Start at which governor? 
Enter a number from
1 to 1000
)
InputBox, GovCount, "Start at", %Msg%, , 200, 160, , , ,10, 1
if ErrorLevel {
    ExitApp
} Else {
    msgbox Ensure Governor No. %GovCount% is showing at the top of the list
}


; ------------------------------------------------
; Verify we are at the current user's City View
; ------------------------------------------------
if (GovCount = 1) {
    if (!CheckCityView()) {
        Log("User is not at the City View screen. Quitting.")
        MsgBox Please close the screen and go to the City View.
        ExitApp
    }
}

; ------------------------------------------------
; Set up the tooltip 
; ------------------------------------------------
tooltip WATCH THIS SPACE FOR INFO, 0, -20

CancelMsg = 
(
Use CTRL-ALT-X to cancel the ROK Statistics macro
)
tooltip %CancelMsg% // Capturing Governor %GovCount%, 0, -12

; Keep track of where we think we are in the list of governors
; This prevents infinite loops.
Log("Processing Started")

if (GovCount <= 1000) {
    ; ------------------------------------------------
    ; Go to the top 1000 power rankings list
    ; ------------------------------------------------
    ClickSleep(50, 65, Delay) ; Governor Icon for the current user
    ClickSleep(444, 560, Delay) ; Rankings Icon
    ClickSleep(330, 430, Delay) ; Individual Power Icon

    ; ------------------------------------------------
    ; Start capturing governor info. The first four are special
    ; ------------------------------------------------
    GovFound := CaptureGovernor(230, 255) ; Governor #1
    GovCount += 1
    tooltip %CancelMsg% // Capturing Governor %GovCount%, 0, -12

    GovFound := CaptureGovernor(230, 335) ; Governor #2
    GovCount += 1
    tooltip %CancelMsg% // Capturing Governor %GovCount%, 0, -12

    GovFound := CaptureGovernor(230, 415) ; Governor #3
    GovCount += 1
    tooltip %CancelMsg% // Capturing Governor %GovCount%, 0, -12

    GovFound := CaptureGovernor(230, 495) ; Governor #4
    GovCount += 1
    tooltip %CancelMsg% // Capturing Governor %GovCount%, 0, -12
    
    ; Capture Governors 5-998
    ; We click the same place on the screen, the list auto-scrolls
    While(GovCount <= 998) {
        GovFound := CaptureGovernor(230, 495) ; Governor #N
        if (GovFound) {
            GovCount += 1
        }
        ; Didn't find a governor. Try again, but prevent infinite loops
        While (!GovFound and GovCount <= 1000) {
            Log("Unable to load Governor # " . GovCount . ". Scrolling down.")
            ; Drag the mouse to move the list and click the next Governor
            MouseClickDrag Left, 230, 575, 230, 495, 25
            GovFound := CaptureGovernor(230, 500) ; Governor #N+1
            GovCount += 1
        }
        tooltip %CancelMsg% // Capturing Governor %GovCount%, 0, -12
    }

    ; Capture Governor 999, also uses special coordinates
    GovFound := CaptureGovernor(230, 600) ; Governor #999
    GovCount += 1
    tooltip %CancelMsg% // Capturing Governor %GovCount%, 0, -12

    ; Capture Governor 1000, also uses special coordinates
    GovFound := CaptureGovernor(230, 680) ; Governor #1000
    GovCount += 1
    tooltip %CancelMsg% // Capturing Governor %GovCount%, 0, -12

    ; ------------------------------------------------
    ; Clean up
    ; ------------------------------------------------

    ClickSleep(1147,73,Delay) ; Close the Individual Power Window
    ClickSleep(1147,73,Delay) ; Close the Rankings Window
    ClickSleep(65, 345, 350) ; Close the Current User governor Window
}

; ------------------------------------------------
; Did we get a list of additional names to search?
; ------------------------------------------------
if (FileExist(ExtraGovernorsFile)) {
    Log("Capturing Extra Governors")

    tooltip %CancelMsg% // Capturing Extra Governors

    ClickSleep(50, 65, Delay) ; Click Governor Icon for the current user
    ClickSleep(984, 561, Delay) ; Click Settings Icon
    ClickSleep(925, 225, Delay) ; Click Search Governor

    ClickSleep(325, 145, Delay) ; Place the Cursor in the Search Box

    Loop, Read, %ExtraGovernorsFile%
    { 
        Clipboard = %A_LoopReadLine%
        ; Paste the name
        Send ^v 
        Sleep 100
        ClickSleep(1073, 145, Delay) ; Click the Search Button
        Ret := CaptureGovernor(230, 255) ; Capture the Governor Info
        if (!Ret) {
            Data = %GovernorName%,NOT FOUND`n
            FileAppend, %Data%, %OutputFile%
        }
        ClickSleep(65, 345, 350) ; Close the Covernor Window

        ClickSleep(325, 145, Delay) ; Place the Cursor in the Search Box
        Send ^a
        Send {Backspace}
    }
    ClickSleep(1147,73,Delay) ; CLose the Search Window
    ClickSleep(1147,73,Delay) ; CLose the Settings
    ClickSleep(65, 345, 350) ; Close the Current User governor Window
}

Log("Processing Finished")

; Hotkey to kill the script early
^!x::ExitApp  ; Quit script with Ctrl+Alt+X

tooltip