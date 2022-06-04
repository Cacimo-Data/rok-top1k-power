; ==================================================
; FUNCTIONS SPECIFIC TO RISE OF KINGDOMS USER INTERFACE
;
; Created by: Đumoƞt KD2338
;
; CHANGE HISTORY
;    19 May 2022 - First Working Version
; ==================================================


; -----------------------------
; Verify that we are on the City View screen
; -----------------------------
CheckCityView() {
    ImageSearch, FoundX, FoundY, 16, 632, 120, 737, %A_ScriptDir%\ImageClips\CityView.png
    if (FoundX and FoundY) {
        return 1
    } else {
        return 0
    }
}

; -----------------------------
; Reliably and quickly load the Governor Profile
; -----------------------------
LoadGovenorProfile(ClickX, ClickY) {
    Found := 0
    Count := 1
    ClickSleep(ClickX, ClickY, 100)
    While (Count < 10) {
        ImageSearch, FoundX, FoundY, 490, 95, 815, 135, %A_ScriptDir%\ImageClips\GovernorProfile.png
        if (FoundX and FoundY) {
            Found := 1
            Break
        }
        Sleep 100
        Count := Count + 1
    }
    return Found        
}

; -----------------------------
; Load the Governor More Info page
; -----------------------------
LoadMoreInfo(ClickX, ClickY) {
    Found := 0
    Count := 1
    ClickSleep(ClickX, ClickY, 200)
    return 1   
}

; -----------------------------
; Load the Kill Points Breakdown
; -----------------------------
LoadKillPoints(ClickX, ClickY) {
    Found := 0
    Count := 1
    ClickSleep(ClickX, ClickY, 200)
    return 1        
}

; -----------------------------
; Reliably and quickly copy the governor's name
; -----------------------------
GetGovernorName() {
    GovName := ""
    Count := 1
    Clipboard := "" ; Clear the clipboard
    ClickSleep(600, 260, 50) ; Copy the governor's name
    While (Count < 40) { ; wait up to 40 x 50 ms (2000 ms) for the name to move to the clipboard
        if (Clipboard != "") {
            UniClipboard := Clipboard
            Return UniClipboard
        }
        Sleep 50
        Count := Count + 1
    }
    return ""  
}

; -----------------------------
; Capture one governor. 
;
; Parameters
;   ClickX - X-coordinate for the Governor's Profile Pic
;   ClickY - Y-coordinate for the Governor's Profile Pic
; 
; -----------------------------
CaptureGovernor(ClickX, ClickY) {
    global SaveFolder
    global OutputFile

    FormatTime, CurrentDateTime,, yyyy-MM-dd

    ; Check that we got the governor's info page
    if (!LoadGovenorProfile(ClickX, ClickY)) {
        return 0
    }

    ; Get the Governor Name
    GovernorName := GetGovernorName()
    ; Save the screencap for later
    SaveFile := SaveFolder . "\" . GovernorName . "--1.png"
    CaptureScreen(1, 0, SaveFile)
    ; OCR the contents
    Data_ID := OcrArea(630, 215, 790, 248) 
    Data_Power := OcrArea(734, 324, 880, 350) 
    Data_KP := OcrArea(910, 324, 1080, 350) 


    ; Click More Info
    if (!LoadMoreInfo(314, 552)) {
        MsgBox Could not load More Info!
        return 0
    }
    ; Save the screencap for later
    SaveFile := SaveFolder . "\" . GovernorName . "--2.png"
    CaptureScreen(1, 0, SaveFile)
    ; OCR the contents
    Data_Deads := OcrArea(925, 387, 1080, 417) 
    ;Data_RSS := OcrArea(900, 523, 1080, 553) 
    Data_Assist := OcrArea(925, 573, 1080, 605) 
    Data_Helps := OcrArea(925, 619, 1080, 652) 
    
    ; Click Kills Breakdown
    if (!LoadKillPoints(870, 155)) {
        MsgBox Could not load Kill Points!
        return 0
    }
    SaveFile := SaveFolder . "\" . GovernorName . "--3.png"
    CaptureScreen(1, 0, SaveFile)
    ; OCR the contents
    Data_T1 := OcrArea(875, 341, 1120, 371)
    Data_T2 := OcrArea(875, 375, 1120, 407)
    Data_T3 := OcrArea(875, 412, 1120, 444)
    Data_T4 := OcrArea(875, 450, 1120, 480)
    Data_T5 := OcrArea(875, 492, 1120, 518)

    Data_T1 := Format("{:d}", Data_T1 / 0.2) ; divide by 0.2 = kills
    Data_T2 := Format("{:d}", Data_T2 / 2)   ; divide by 2   = kills
    Data_T3 := Format("{:d}", Data_T3 / 4)   ; divide by 4   = kills 
    Data_T4 := Format("{:d}", Data_T4 / 10)  ; divide by 10  = kills 
    Data_T5 := Format("{:d}", Data_T5 / 20)  ; divide by 20  = kills 

    Data = %GovernorName%,%Data_ID%,%Data_Power%,%Data_KP%,%Data_Deads%,%Data_Assist%,%Data_Helps%,%Data_T1%,%Data_T2%,%Data_T3%,%Data_T4%,%Data_T5%,%CurrentDateTime%`n
    FileAppend, %Data%, %OutputFile%

    ; Back out
    ClickSleep(65, 345, 350)
    ClickSleep(65, 345, 350)

    Return 1
}
