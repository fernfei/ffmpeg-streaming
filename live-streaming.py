#!/usr/bin/env python

import base
import json
import os

m_config = {};
m_videos = []
m_skip = False

def load_config():
    global m_config
    with open('config.json', 'r') as f:
        m_config = json.load(f)

def load_videos():
    folder_path = m_config.get("video", "")
    global m_videos
    if folder_path:
        for root, dirs, files in os.walk(folder_path):
            for file in files:
                m_videos.append(os.path.join(root, file))
    m_videos = sorted(m_videos, key=os.path.basename)
    return m_videos

def ffmpeg_install():
    if not base.is_file("/usr/bin/ffmpeg"):
        base.install_package("tar")
        base.install_package("wget")
        ffmpeg_url = ""
        if base.is_os_x86():
            ffmpeg_url = "https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-4.0.3-64bit-static.tar.xz"
        if base.is_os_arm64():
            ffmpeg_url = "https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-4.0.3-arm64-static.tar.xz"
        base.cmd("wget", ["--no-check-certificate",ffmpeg_url])
        base.cmd("tar", ["-xf", "ffmpeg-4.0.3-64bit-static.tar.xz"])
        base.cmd("cp", ["ffmpeg-4.0.3-64bit-static/ffmpeg", "/usr/bin/"])
        base.cmd("cp", ["ffmpeg-4.0.3-64bit-static/ffprobe", "/usr/bin/"])
        base.cmd("cp", ["ffmpeg-4.0.3-64bit-static/qt-faststart", "/usr/bin/"])
        base.cmd("cp", ["ffmpeg-4.0.3-64bit-static/ffmpeg-10bit", "/usr/bin/"])
    else:
        print("ffmpeg already installed")

def start_streaming():
    ffmpeg_install()
    load_config()
    load_videos()
    while True:
        index = int(m_config.get("index", 0))
        if index < len(m_videos):
            video = m_videos[index]
            print("Streaming " + video)
            base.cmd("ffmpeg", ["-re", "-i", video, "-preset", "ultrafast", "-vcodec", "libx264", "-r", m_config.get("fps", "30"), "-g", "60", "-b:v", m_config.get("bitrate", "1000k"), "-c:a", "aac", "-b:a", "92k", "-strict", "-2", "-f", "flv", m_config.get("rtmp", "")])
            index += 1
            m_config["index"] = index
        else:
            m_config["index"] = 0


def stop_streaming():
    print("Stopping live streaming")


start_streaming()