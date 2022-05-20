; ==================================================
; GENERAL FUNCTIONS NOT RELATED TO RISE OF KINGDOMS
;
; Created by: Đumoƞt KD2338
;
; CHANGE HISTORY
;    19 May 2022 - First Working Version
; ==================================================


; -----------------------------
; Center the active window
; -----------------------------
CenterWindow(WinTitle) {
    WinGetPos,,, Width, Height, %WinTitle%
    WinMove, %WinTitle%,, (A_ScreenWidth/2)-(Width/2), (A_ScreenHeight/2)-(Height/2)
}

; -----------------------------
; Create a folder, return the path
; -----------------------------
CreateSaveFolder() {
    global SavePath
    global CurrentDateTime

    FolderName := "\Screenshots-" . CurrentDateTime
    FolderName := SavePath . "\" . FolderName

    FileCreateDir, %FolderName%
    return %FolderName%
}

; -----------------------------
; Create and initialize the CSV file
; Overwrites an existing file with the same name+
; -----------------------------
CreateOutputFile() {
    global SavePath
    global CurrentDateTime

    OutputFile := SavePath . "\Statistics-" . CurrentDateTime . ".csv" 

    if (FileExist(OutputFile)) {
        FileDelete, %OutputFile%
    }

    Data := "Governor,ID,Power,Kill_Points,Kills,Deads,RSS_Assitance,Helps,T1_Kills,T2_Kills,T3_Kills,T4_Kills,T5_Kills,Date`n"
    zml := FileOpen(OutputFile, "a", UTF-8)
    zml.write(Data)
    zml.close()

    return %OutputFile%
}

; -----------------------------
; Click the mouse at a location, sleep for a duration
; This is used all over the place
; -----------------------------
ClickSleep(mouseX, mouseY, sleepMSec) {
    MouseMove, mouseX, mouseY
    Click
    Sleep, sleepMSec
}


; -----------------------------
; OCR a section of the ROK Window
; Uses Capture2Text (CLI Version)
; -----------------------------
OcrArea(TopX, TopY, BotX, BotY) {
    global SavePath

    clipboard := "EMPTY"
    ; Capture2Text uses the SCREEN, not the WINDOW
    ; Get the top-left corner of the ROK window
    WinGetActiveStats, WinTitle, WinW, WinH, WinX, WinY
    ; Add those coordiantes to what was provided -- 
    TopX := TopX + WinX
    TopY := TopY + WinY
    BotX := BotX + WinX
    BotY := BotY + WinY
    ; Perform the OCR
    Coords = %TopX% %TopY% %BotX% %BotY%
    RunWait, C:\Progra~2\Capture2Text\Capture2Text_CLI.exe -s "%Coords%" --whitelist "0123456789" --clipboard --debug --debug-timestamp, , Hide
    ; Get the results from the clipboard
    ; Cleanup the output
    OCRText := trim(clipboard,"`n`r`t ")
    OCRText := RegExReplace(OCRText, "[^0-9]" ,"")
    return OCRText
}

