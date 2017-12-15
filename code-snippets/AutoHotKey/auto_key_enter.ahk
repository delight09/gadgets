; Trigger the script with F8 key, 500ms per keypress

SetTimer Keypress, 500

F8::Toggle := !Toggle

Keypress:
    If (!Toggle)
        Return
    Send {Enter}

return
