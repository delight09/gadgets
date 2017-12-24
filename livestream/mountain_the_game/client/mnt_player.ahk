; MAGIC global variables
wait_beat = 400 ; fallback not defined within sheet file
overwrite_beat=0

; Wake Mountain.exe to accept notations
WinActivate ahk_exe Mountain.exe

; Read sheet file from the first parameter
NumberOfParameters = %0%
If ( NumberOfParameters >= 1 )
{
    if (NumberOfParameters == 2) {
        overwrite_beat = 1
	    wait_beat = %2%
    }
	rURL_sheet = %1%
} else {
    return
}

; Parse 
cur_line = 1
Loop {
    FileReadLine, line, %A_ScriptDir%\%rURL_sheet%, %A_Index%
	; Process metadata
    if ErrorLevel
        break
	if (SubStr(line, 1, 1) == "#") {
	    continue ;Skip comment lines in sheet
	}
	if (SubStr(line, 1, 1) == "%") {
	    if (overwrite_beat == 0) {
		    wait_beat := SubStr(line, 2, -1) , wait_beat += 0
	    }
		continue
	}
	
	; Update current note on player.txt
	Run, %A_ScriptDir%\helper_make_txt_player.bat %cur_line% "%line%"
	cur_line += 1
	
	; Player logic TODO boost with []
	wait_pulse = %wait_beat% / 2.22 ; the 2.22 is MAGIC
    i = 1 ;SubStr() takes first char with index 1
    StringLen, range, line
    Loop %range% {
        note := SubStr(line, i, 1)
        i += 1

        If ( note != " " ) {
            Send {%note%}
			Sleep %wait_beat%
        } else {
            Sleep %wait_pulse%
        }

    }
}
