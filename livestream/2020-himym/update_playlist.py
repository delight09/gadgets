#!/usr/bin/python3
# OBS自启推流启动器
# 特性：结合OBS的VLC源和tuna插件，每次开播从上次断开的一集继续播放推流

import argparse as ap
import re
from pathlib import Path
import subprocess 

def fetch_curr_sp():
    with open(url_tuna_txt, encoding='utf-8-sig') as fd:
        str_tuna = fd.readline()
        str_tuna  = re.sub("^S([0-9]*)E([0-9\-]*).*",r'\1%\2', str_tuna)
        s = re.sub("^([0-9]*)%.*",r'\1', str_tuna)
        p = re.sub(".*%([0-9]*)-?.*",r'\1', str_tuna)
        try:
            int(s)
        except:
            s = p = 1
        return int(s), int(p)


arr_himym_sp = [22, 22, 20, 24, 24, 24, 24, 24, 24]
url_tuna_txt = r"C:\Users\jiahao\Documents\2020-himym.txt"
url_output_m3u = r"C:\Users\jiahao\Documents\himym_playlist.m3u"
url_dir_video = r"C:\Users\jiahao\Desktop\tio"
url_dir_obs_wd = r"C:\Program Files\obs-studio\bin\64bit"
list_pattern_video = ["*.mp4", "*.mkv"]


# 处理程序参数
parser = ap.ArgumentParser()
parser.add_argument("-s", help="输入第几季 eg:S01输入01",dest="series",
                    type=int)
parser.add_argument("-e", help="输入第几集 eg:E22输入22",dest="episode",
                    type=int)
args = parser.parse_args()


# 根据是否有参数进行变量赋值
int_s = 0
int_p = 0
if args.series is None and args.episode is None:
    int_s, int_p = fetch_curr_sp()
else:
    int_s = args.series or 1
    int_p = args.episode or 1
    int_s = int_s if 0 < int_s < 10 else 1
    int_p = int_p if 0 < int_p <= arr_himym_sp[int_s - 1] else 1


# 得到文件夹内原始视频顺序列表
list_url_video = []
for i in list_pattern_video:
    t = Path(url_dir_video).glob(i)
    for ii in t:
        list_url_video.append(str(ii))
list_url_video.sort()


# 根据变量编排新的视频列表
int_init_play = 0
for idx in range(int_s -1):
    int_init_play += arr_himym_sp[idx]
int_init_play += int_p - 1
list_url_video = list_url_video[int_init_play:] + list_url_video[:int_init_play]


# 将视频列表写入m3u播放文件
with open(url_output_m3u , 'w') as fd:
    for url_curr in list_url_video:
        fd.write('%s\n' % url_curr)


# 调用运行OBS开始推流
cmd = [
        "{}\obs64.exe".format(url_dir_obs_wd),
        '--startstreaming',
        '--minimize-to-tray',
        '--scene "v0310"',
        '--profile "himym"'
      ]
subprocess.run(cmd,shell=False,stdin=None,stdout=None,stderr=None,cwd=url_dir_obs_wd,close_fds=True)

