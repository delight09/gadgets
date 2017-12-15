; Helper script for ``Emily is away too'' the game, the chapter 3 gameplay is crazy
; FYI https://steamcommunity.com/sharedfiles/filedetails/?id=946209480

SetTimer Crazy, 10

F8::Toggle := !Toggle

Crazy:
    If (!Toggle)
        Return
    Send {Enter}

return
