#!/bin/sh --
# Run inox with preference

## inox --proxy-pac-url=file:///var/cache/pacfile/my.pac
inox --proxy-server=http://doorkeeper:3128 --proxy-bypass-list="*.djh.im;localhost"
