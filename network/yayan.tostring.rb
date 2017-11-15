#!/usr/bin/ruby
#一言API格式化输出 => ``内容'' s:来源

require 'json/pure'
require 'curb'

def fetch_yiyan()
  http = Curl.get("https://sslapi.hitokoto.cn/?encode=json")
  dom_body = http.body_str
  obj_yiyan = JSON.parse(dom_body)
  $str_content = obj_yiyan['hitokoto']
  $str_source = obj_yiyan['from']
end


while $str_source == nil || $str_source == "" do
  fetch_yiyan
end
puts '``' + $str_content + '\'\' s:' + $str_source
