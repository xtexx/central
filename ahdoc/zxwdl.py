#!/usr/bin/python3

import os

import pyperclip
import subprocess
from crc import Calculator, Crc8

url = pyperclip.paste().strip()
print(url)
if not (url.startswith("https://") and ".m3u8" in url):
    print("剪贴板中未能识别到链接")
    exit()

out = os.path.curdir

calculator = Calculator(Crc8.CCITT)
cksum = calculator.checksum(url.encode())

outFile = os.path.join(out, str(cksum) + ".%(ext)s")
args = ["yt-dlp", "-N6", "--cookies-from-browser=Edge", "-v", url]

print("输出文件：" + outFile)
print("参数：", args)

subprocess.check_call(args)

print("下载完成，已保存至 " + outFile)
