#!/usr/bin/env python3
import argparse
import subprocess

def tail_log():
    subprocess.call(["tail", "-f", "output.log"])

def start_app():
    print("Starting the app...")
    # 启动 nohup 进程
    cmd = "nohup python live-streaming.py > output.log 2>&1 &"
    process = subprocess.Popen(cmd, shell=True)

    # 将 PID 写入到文件中
    with open("live-streaming.pid", "w") as f:
        f.write(str(process.pid))

    tail_log()

def stop_app():
    print("Stopping the app...")
    # 从文件中读取 PID 并停止对应的进程
    with open("live-streaming.pid", "r") as f:
        pid = f.read().strip()
    subprocess.call(["kill", "-9", pid])

def restart_app():
    start_app()
    stop_app()

def main():
    parser = argparse.ArgumentParser(description='Control nohup process.')
    parser.add_argument('command', choices=['start', 'stop', 'restart'], help='Command to run.')

    args = parser.parse_args()
    if args.command == 'start':
        start_app()
    elif args.command == 'stop':
        stop_app()
    elif args.command == 'restart':
        start_app()


if __name__ == '__main__':
    main()
