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
; Get the Day we want to reprocess
; Files will be found in the "ConfigSavePath/YYYY-MM-DD" folder
; ------------------------------------------------
CanContinue := False
FolderName := ""
While (!CanContinue) {
    InputBox, ProcessDate, "Enter Date", "Enter the date to reprocess in YYYY-MM-DD format.", , , , , , , , 2022-05-19
    if ErrorLevel
        ExitApp

    FoundPos := RegExMatch(ProcessDate, "^\d\d\d\d-\d\d-\d\d$")
    if (FoundPos) {
        FolderName := A_ScriptDir . "\" . ConfigSavePath . "\Screenshots-" . ProcessDate 
        if (FileExist(FolderName)) {
            CanContinue := True
        } else {
            MsgBox Folder not found: %FolderName%
        }
    } else {
        MsgBox Please enter a date in YYYY-MM-DD format.
    }
}

; ------------------------------------------------
; Prepare the place to save our results
; ------------------------------------------------
FormatTime, CurrentDateTime,, yyyy-MM-dd 
OutputFile := CreateOutputFile(ConfigSavePath, False, ProcessDate)
GovernorIDs := []


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
Log("Re-Processing Started")
GovCount := "1"

; Get a list of files in our folder
FileGlob = %FolderName%\*--1.png
Loop, Files, %FileGlob% 
{
    ; Parse the filename to get the governor name
    FoundPos := RegExMatch(A_LoopFileName, "(.+)\-\-1\.png", GovName)
    if (FoundPos) {
        Log("Processing Governor " . GovName1) ; Yes, "GovName1". RTFM.
        tooltip %CancelMsg% // Capturing Governor %GovCount% -- %GovName1%, 0, -12
        ;MsgBox Processing Governor %GovName1% in %A_LoopFileName% 
        ReOCR(GovName1, FolderName, ProcessDate, OutputFile)
    }
    GovCount := GovCount + 1
}

MsgBox End of loop
ExitApp




Log("Re-Processing Finished")

; Hotkey to kill the script early
^!x::ExitApp  ; Quit script with Ctrl+Alt+X

tooltip