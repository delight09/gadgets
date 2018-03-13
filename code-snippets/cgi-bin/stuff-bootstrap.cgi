#!/bin/sh
# Bootstrap the application before redirect client with contents

do_not_exist() {
  if $(ps aux | grep -v 'grep' | grep -q "$1"); then
    return 255
  else
    return 0 #not exists and bootstrap it
  fi

}

redirect_client() {
  echo "Content-type: text/html"
  echo ''
  echo "<html><meta http-equiv=\"refresh\" content=\"0;${1}\"></html>"

}

bootstrap_app() {
  /usr/bin/bash /srv/http/cgi-bin/app.sh

}


if do_not_exist "infamous_app"; then
  bootstrap_app
fi
redirect_client "http://example.com/path"
