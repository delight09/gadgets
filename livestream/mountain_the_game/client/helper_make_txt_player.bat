SET PATH=c:\cygwin64\bin;%PATH%
SET arg1=%1
SET arg2="%~2"
:: arg2 Credit to https://stackoverflow.com/a/4388728

c:\cygwin64\bin\bash.exe "/home/dummyred/mountain_livestream/make_txt_player.sh" "ptr" %arg1% %arg2%