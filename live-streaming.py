#!/usr/bin/env python
import subprocess

import base
import json
import os
import argparse

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

def start_ffmpeg(video, fps, bitrate, rtmp):
    ffmpeg_process = subprocess.Popen(["ffmpeg", "-re", "-i", video, "-preset", "ultrafast", "-vcodec", "libx264", "-r", fps, "-g", "60", "-b:v", bitrate, "-c:a", "aac", "-b:a", "92k", "-strict", "-2", "-f", "flv", rtmp])
    ffmpeg_process.wait()
    return ffmpeg_process.pid

def start_streaming():
    ffmpeg_install()
    load_config()
    load_videos()
    while True:
        index = int(m_config.get("index", 0))
        if index < len(m_videos):
            video = m_videos[index]
            print("Streaming " + video)
            ffmpeg_pid = start_ffmpeg(video, m_config.get("fps", "30"), m_config.get("bitrate", "1000k"),m_config.get("rtmp", ""))
            # 将 PID 写入到文件中
            with open("ffmpeg.pid", "w") as f:
                f.write(str(ffmpeg_pid))
            index += 1
            m_config["index"] = index
        else:
            m_config["index"] = 0


def stop_streaming():
    with open("ffmpeg.pid", "r") as f:
        pid = f.read().strip()
    subprocess.call(["kill", "-9", pid])

def main():
    parser = argparse.ArgumentParser(description='FFMPEG Stream Server')
    parser.add_argument('command', choices=['start', 'stop',], help='Command to run.')
    parser.add_argument('-c', '--command', type=str, help='Enter choice')
    args = parser.parse_args()

    if args.command == "start":
        start_streaming()
    elif args.command == "stop":
        stop_streaming()

if __name__ == "__main__":
    main()