#!/usr/bin/env python3
import argparse
import subprocess

m_is_log = False
def start_app():
    # 启动 nohup 进程
    process = subprocess.Popen(["python","live-streaming.py",">","output.log", "&"], stdout=subprocess.PIPE,
                               stderr=subprocess.PIPE)
    # 将 PID 写入到文件中
    with open("live-streaming.pid", "w") as f:
        f.write(str(process.pid))

    subprocess.call(["tail", "-f", "output.log"])

def stop_app():
    # 从文件中读取 PID 并停止对应的进程
    with open("live-streaming.pid", "r") as f:
        pid = f.read().strip()
    subprocess.call(["kill", "-9", pid])

def restart_app():
    start_app()
    stop_app()

def main():
    parser = argparse.ArgumentParser(description='Control nohup process.')
    parser.add_argument('command', choices=['start', 'stop', 'restart','log'], help='Command to run.')

    args = parser.parse_args()

    if args.command == 'log':
        global m_is_log
        m_is_log = True
    if args.command == 'start':
        start_app()
    elif args.command == 'stop':
        stop_app()
    elif args.command == 'restart':
        start_app()

main()

if __name__ == '__main__':
    main()
