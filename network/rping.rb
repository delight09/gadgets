#!/bin/env ruby
# USAGE: rping.rb http://sub.exmaple.com:1337/path/to/resource.mp4

require 'uri'
uri = URI(ARGV[0])

cmd = "ping " + uri.host
exec( cmd )
