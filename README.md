# ROK Top 1K Power

A tool for gathering statisics of the top 1000 Governors by Power in Rise of Kingdoms. Optionally may be used to gather the same statistics for a list of governors not in the top 1000 power listing.

## Requirements

* Rise of Kingdoms for PC -- https://roc.lilithgames.com/ (not BlueStacks)
* AutoHotKey -- https://www.autohotkey.com/
* Capture2Text -- https://sourceforge.net/projects/capture2text/

## Setup

### Rise of Kingdoms

* Download and Install the PC version of ROK
* Set the Display Mode: Windowed 1280x720
* Optionally: Set Music Volume and SFX Volume to Zero
* Turn off Kingdom Title Notifications (Your Governor Profile > Settings > General Settings > Kingdom Title Notifications = OFF>

### Capture2Text

* Download and unzip Capture2Text
* Copy the extracted files to C:\Prorgram Files (x86)
* Ensure `C:\Program Files (x86)\Capture2Text\Capture2Text.exe` exists. That's where the macro will look for it

### AutoHotKey

No special setup is needed.

## Using the macro

1. To start, in Rise of Kingdoms, you should be at the main viewer looking at your city.
1. Double-click the `ROK Screenshots.ahk` script to start. The macro reqires admin privileges. In the *User Account Control* popup window, click **OK**
1. Watch and Pray
1. Screenshots will be placed in an output folder with today's date. Example: `Output\Screenshots 2022-05-18`
1. OCR Content will be placed in a CSV file in the output folder. Example: `Statistics-2022-05-18.csv`

## Additional Info

### Extra Governors

Create a file called **extra-names.txt** in the same folder as the **ROK Screenshots.ahk** script. The governor names in there will be searched one by one to capture the statsistics after the top 1000 governors are captured.

* You may optionally choose to start with someone other than the first governor. This may be used for recovery should something go wrong. **Back up the output CSV file before restarting halfway through, It will wipe create the fine anew!**
* The starting governor box waits 10 seconds and then automatically continues for unattended operations.
* To skip the top 1000 completely, enter 9999 in the text entry box

### Configuration

A configuration file is offered, but there is nothing to change there. The default delay is not used everywhere in the code and has been already set to be as fast as possible without affecting accuracy.

### Performance

It takes approximately 1h 40m to process all 1000 governors. Your computer cannot be used for anything else while the macro is running.

## Odd things to Remember

New Windows installations will ask to save screenshots to OneDrive. You may not want this. To change it, take a screenshot (Alt-PrtScn) and select "No Thanks".
