; Helper script for ``Emily is away too'' the game, the chapter 3 gameplay is crazy
; FYI https://steamcommunity.com/sharedfiles/filedetails/?id=946209480
; Chapter 3 seems invincible, refer to https://www.reddit.com/r/EmilyIsAway/comments/7kbkf9/

SetTimer Crazy, 10

F8::Toggle := !Toggle

Crazy:
    If (!Toggle)
        Return
    Send {Enter}

return
