#!/usr/bin/env bash
# Pirate the baiduyun wenzhang pirater, cuz Baidu sucks at its service
# 
# NOTICE: Web pages will downloaded in this script's folder,
#             please make sure the write permission in folder.
# DEPENT: bash, wget, find, sed
# Tested: @Sat Feb  3 21:28:44 CST 2018
# By: delight09
# USAGE: bash yunwenzhang_pirater.sh

##########  Replace _your_own_command_ below
#
#
STR_CMD_CURL="curl 'https://wenzhang.baidu.com/page/view?key=f216167eeb2e7d30-1427444339' -H 'Pragma: no-cache' -H 'Accept-Encoding: gzip, deflate, br' -H 'Accept-Language: en-US,en;q=0.9' -H 'Upgrade-Insecure-Requests: 1' -H 'User-Agent: Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/63.0.3239.84 Safari/537.36' -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8' -H 'Referer: https://wenzhang.baidu.com/' -H 'Cookie: BAIDUID=6DFB403EC6CDA590D35C2D019BDC52ED:FG=1; BDUSS=1lZb2lMV3dIYko4TVV-cGI4T2tnRDdTNXRIY0J6QjhoUndGZWRyWW5VdFRGSjFhQUFBQUFBJCQAAAAAAAAAAAEAAADYQp4I08C2rze6xQAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAFOHdVpTh3VaY; BIDUPSID=6DFB403EC6CDA590D35C2D019BDC52ED; PSTM=1517652356; H_PS_PSSID=25639_1468_21104_20929; PSINO=2; BDORZ=B490B5EBF6F3CD402E515D22BCDA1598; BDRCVFR[feWj1Vr5u3D]=I67x6TjHwwYf0; SCMOBLE=00-00-0043EbaIfEgg; BDRCVFR[dG2JNJb_ajR]=mk3SLVN4HKm; BDRCVFR[-pGxjrCMryR]=mk3SLVN4HKm; SCPA_IMAGEPLACE=ok1108121153IMAGEPLACE; Hm_lvt_19f7e3b89626f41825e5c15696da95c5=1517652394,1517661458; Hm_lpvt_19f7e3b89626f41825e5c15696da95c5=1517664738' -H 'Connection: keep-alive' -H 'Cache-Control: no-cache' --compressed"
#
###########  Customize finished

##  Patch the cURL command, reform against wget options SPEC
patch_remove_option_compress() {
  # Remove compressed option
  STR_CMD_CURL=$(echo $STR_CMD_CURL | sed 's/--compressed//')

}

patch_fix_header_accept_encoding() {
  # Accept only the plain(text) encoding
  STR_CMD_CURL=$(echo $STR_CMD_CURL | sed -r "s/Accept-Encoding:[^']+/Accept-Encoding: plain/")

}

parse_url() {
  # Find URL
  echo $STR_CMD_CURL | sed -r 's>.*(https://wenzhang.baidu.com/page/view\?key=[a-z0-9-]+).*>\1>'

}

parse_arguments_for_wget() {
  local _d=$(parse_url)

  # strip metadata and convert argument SPEC
  echo $STR_CMD_CURL | sed -e 's/curl//' -e 's/-H/--header/g' -e "s>'${_d}'>>"

}

##  MAIN
set -e
if [[ -d ./wenzhang.baidu.com ]];then
  echo "/!\\Site seems downloaded, please remove \`\`wenzhang.baidu.com'' folder manually, \
before execute the script!"
  exit 1
fi
patch_remove_option_compress
patch_fix_header_accept_encoding

# eval wget command
eval "wget --mirror --span-hosts -e robots=off --restrict-file-names=ascii\
 --domains='wenzhang.baidu.com,swenzhang.baidu.com,wenzhang.bdstatic.com,img.baidu.com,hiphotos.baidu.com'\
 --page-requisites --convert-links $(parse_arguments_for_wget) $(parse_url)"

# make sure site is downloaded and patch the URL query string
# view?key --> view_key, css?v --> css_v, index.html?uid --> index.html_uid ...
patch_filename() {
  local _fd="$1"

  if $(echo $_fd | grep -q '?');then
    mv ${_fd} $(echo $_fd | sed -r 's/\?/_/g')
  fi

}

patch_content_css_js_jpg() {
  local _fd="$1"

  sed -i -r 's/css\?v/css_v/g' "${_fd}"
  sed -i -r 's/js\?v/js_v/g' "${_fd}"
  sed -i -r 's/jpg\?v/jpg_v/g' "${_fd}"
  sed -i -r 's/gif\?v/gif_v/g' "${_fd}"

}

patch_content_indexhtml_viewkey() {
  local _fd="$1"

  sed -i -r 's/view\?key/view_key/g' "${_fd}"
  sed -i -r 's/index\.html\?uid/index\.html_uid/g' "${_fd}"

}

echo "Patching query strings in URL, please wait..."
if [[ -d ./wenzhang.baidu.com/page ]];then
  for i in $(find ./*.com -type f)
  do
    patch_content_css_js_jpg "$i"
    patch_content_indexhtml_viewkey "$i"
    patch_filename "$i"
  done

# finally, patch the CSS, make next-article & prev-article content
# always visiable; file path is MAGIC
sed -i -r 's/display:[[:space:]]*block;/display: inline;/g'\
  swenzhang.baidu.com/css/pjt/site/page/detailArticle.css*

sed -i -r 's/padding:[ 0-9px]+;/padding: 3em;/g'\
  swenzhang.baidu.com/css/pjt/site/page/detailArticle.css*

fi
echo "Success!"
