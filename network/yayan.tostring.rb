#!/usr/bin/ruby
# 一言API格式化输出 => ``内容'' s:来源, 同时排除 ARGV[0]的类型
# NOTICE: API doc, http://hitokoto.cn/api
# USAGE: yayan.tostring.rb 'g,f,e'

require 'json/pure'
require 'curb'

def fetch_yiyan(str_filter)
  arr_filter = str_filter.split(',')
  arr_support_type = Array('a'..'g') # refer API doc
  arr_query_type = arr_support_type.delete_if { |x| arr_filter.include? x }
  str_query_type = arr_query_type.sample

  http = Curl.get("https://sslapi.hitokoto.cn/?encode=json&c=" + str_query_type)
  dom_body = http.body_str
  obj_yiyan = JSON.parse(dom_body)
  $str_content = obj_yiyan['hitokoto']
  $str_source = obj_yiyan['from']
end

arg_filter = ARGV[0]
while $str_source == nil || $str_source == "" do
  if arg_filter == nil
    arg_filter = ""
  end
  fetch_yiyan(arg_filter)
end
puts '``' + $str_content + '\'\' s:' + $str_source
