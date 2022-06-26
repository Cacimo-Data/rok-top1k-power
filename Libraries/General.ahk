; ==================================================
; GENERAL FUNCTIONS NOT RELATED TO RISE OF KINGDOMS
;
; Created by: Đumoƞt KD2338
;
; CHANGE HISTORY
;    19 May 2022 - First Working Version
; ==================================================

#Include %A_ScriptDir%\Libraries\Gdip\Gdip_All.ahk

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
CreateSaveFolder(SavePath) {
    FormatTime, CurrentDateTime,, yyyy-MM-dd 
    FolderName := "\Screenshots-" . CurrentDateTime
    FolderName := SavePath . "\" . FolderName

    FileCreateDir, %FolderName%
    return %FolderName%
}

; -----------------------------
; Create and initialize the CSV file
; Overwrites an existing file with the same name+
; -----------------------------
CreateOutputFile(SavePath, ExtraNames := False, OtherDate := "") {
    FormatTime, CurrentDateTime,, yyyy-MM-dd 
    OutputFile := SavePath . "\Statistics-" . CurrentDateTime . ".csv" 
    if (ExtraNames) {
        OutputFile := SavePath . "\Statistics-Extra-" . CurrentDateTime . ".csv" 
    }
    if (OtherDate) {
        OutputFile := SavePath . "\Statistics-" . OtherDate . "-Reprocess.csv" 
    }
    if (FileExist(OutputFile)) {
        FileDelete, %OutputFile%
    }

    Data := "Governor,ID,Power,Kill_Points,Deads,RSS_Assitance,Helps,T1_Kills,T2_Kills,T3_Kills,T4_Kills,T5_Kills,Date`n"
    zml := FileOpen(OutputFile, "a", UTF-8)
    zml.write(Data)
    zml.close()

    return %OutputFile%
}

; -----------------------------
; Send a message to teh log file
; Create and initialize the Log file if needed
; -----------------------------

Log(Message) {
    ; Set up some variables
    FormatTime, CurrentDateTime,, yyyy-MM-dd 
    LogPath :=  A_ScriptDir . "\Logs"
    LogFile := LogPath . "\log-" . CurrentDateTime . ".txt"

    ; Make sure the file exists
    if (!FileExist(LogFile)) {
        ; Make sure the path exists
        if (!FileExist(LogPath)) {
            FileCreateDir, %LogPath%
        }
        ; Create the file, set the encoding, etc
        FormatTime, TS,, yyyy-MM-dd HH:mm:ss
        Data := "[" . TS . "] Log File Initialized with encoding " . A_FileEncoding . "`n"
        zml := FileOpen(LogFile, "a", A_FileEncoding)
        zml.write(Data)
        zml.close()
    }
    ; Write to the log file
    FormatTime, TS,, yyyy-MM-dd HH:mm:ss
    FileAppend [%TS%] %Message%`n, %LogFile%
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
    RunWait, C:\Progra~2\Capture2Text\Capture2Text_CLI.exe -s "%Coords%" --clipboard, , Hide ;  --debug --debug-timestamp
    ; Get the results from the clipboard
    ; Cleanup the output
    OCRText := trim(clipboard,"`n`r`t ")
    OCRText := RegExReplace(OCRText, "[^0-9]" ,"")
    return OCRText
}

ReOcrArea(ImageFileName, TopX, TopY, BotX, BotY ) {
    ; Calculate Height/Width from the Coords
    Width := BotX - TopX
    Height := BotY - TopY
    ; Crop the image using windows native tools
    pToken := Gdip_Startup()
    pBitmap := Gdip_CreateBitmapFromFile(ImageFileName)
    bm_cropped := Gdip_CloneBitmapArea(pBitmap, TopX, TopY, Width, Height)

    ; Save the cropped image to a temp file
    Gdip_SaveBitmapToFile(bm_cropped, A_ScriptDir . "\Temp.bmp")
    Gdip_DisposeImage(pBitmap)
    Gdip_DisposeImage(bm_cropped)
    Gdip_Shutdown(pToken)

    ; Send the temp image to OCR
    RunWait, C:\Progra~2\Capture2Text\Capture2Text_CLI.exe -i %A_ScriptDir%\Temp.bmp --clipboard, , Hide

    ; Get the results from the clipboard
    OCRText := trim(clipboard,"`n`r`t ")
    ; Cleanup the output
    OCRText := RegExReplace(OCRText, "[^0-9]" ,"")
    return OCRText
}

; -----------------------------
; Search an Array for a Value
; -----------------------------
InArray(Haystack, Needle) {
    Loop % Haystack.MaxIndex()
    {
        if (Haystack[A_Index] = Needle) {
            return true
        }
    }
    return false
}

; -------------------------------
; How many lines in a text file
; -------------------------------
CountFileLines(File) {
    numlines := 0
    
    Loop, Read, %File%
        If (Trim(A_LoopReadLine) != "") 
            numlines++ ; Add one

    Return numlines
}