; Trigger the script with F8 key, 50ms per click

SetTimer Click, 50

F8::Toggle := !Toggle

Click:
    If (!Toggle)
        Return
    Send {Click}
	;sendinput {LButton Down}
	;sleep 100
	;sendinput {LButton Up}

return
