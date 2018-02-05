#!/usr/bin/env sh
# Trigger the music playing status,
#   non-start --> start & show UI
#   playing   --> paused
#   paused    --> playing


check_server_started() {
  [ -f ~/.moc/pid ]
  return $?

}

if $(check_server_started); then
  mocp -G
else
  st -f "MesloLGLDZ-Regular:pixelsize=18:antialias=true" -e mocp &
fi
