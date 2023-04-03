#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
#=================================================================#
#   System Required: CentOS7 X86_64 And Arm64                     #
#   Description: FFMPEG Stream Media Server                       #
#   Author: hufei                                                 #
#   Website: https://www.hi-hufei.com                             #
#=================================================================#

#=================================用户自定义配置开始=================================#
# 默认是否跳过详细设置
skip="yes"
# 水印是否开启
watermark="no"
# 默认视频位置
folder="/root/live/videos"
# 默认推流地址
rtmp="rtmp://live-push.bilivideo.com/live-bvc/?streamname=live_105182778_88140690&key=15821d36ef2e34341cc2840736537535&schedule=rtmp&pflag=1"
# 默认码率
# 视频直播服务不限制推流码率，支持常见分辨率以及对应的码率。
# 以下列举常见分辨率及对应码率：
# 640×480：100 kbps~800 kbps。
# 1280×720：200 kbps~1500 kbps。
# 1920×1080：500 kbps~4000 kbps。
# 2K（2560×1440）：2000 kbps~8000 kbps。
# 4K（3840×2160）：4000 kbps~30000 kbps。
rate="1000k"
# 默认帧率
fps="30"
#=================================用户自定义配置结束=================================#

# 颜色选择
red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
font="\033[0m"

# operation type
num=0

# 安装x86_64位的ffmpeg
ffmpeg_install_x86_64() {
  yum -y install wget
  wget --no-check-certificate https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-4.0.3-64bit-static.tar.xz
  tar -xJf ffmpeg-4.0.3-64bit-static.tar.xz
  cd ffmpeg-4.0.3-64bit-static || exit
  mv ffmpeg /usr/bin && mv ffprobe /usr/bin && mv qt-faststart /usr/bin && mv ffmpeg-10bit /usr/bin
}
# 安装arm64位的ffmpeg
ffmpeg_install_arm64() {
  yum -y install wget
  wget --no-check-certificate https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-5.0.1-arm64-static.tar.xz
  tar -xJf ffmpeg-4.0.3-arm64-static.tar.xz
  cd ffmpeg-4.0.3-arm64-static || exit
  mv ffmpeg /usr/bin && mv ffprobe /usr/bin && mv qt-faststart /usr/bin && mv ffmpeg-10bit /usr/bin
}
# 安装screen
screen_install() {
  yum -y install screen
}
# 检查screen是否安装
screen_exits() {
  if [ -f "/usr/bin/screen" ]; then
    echo -e "${green}检测到你的机器已经安装过screen,程序将跳过安装步骤.${font}"
  else
    screen_install
  fi
}
# 安装ffmpeg
ffmpeg_install() {
  # 查看系统版本amd64  or arm64 下载对应的版本的ffmpeg
  if [ "$(uname -m)" = "aarch64" ]; then
    echo -e "${green}检测到你的机器是arm64系统,程序将自动安装arm64FFmpeg. ${font}"
    ffmpeg_install_arm64
  fi
  if [ "$(uname -m)" = "x86_64" ]; then
    echo -e "${green}检测到你的机器是64位系统,程序将自动安装64位FFmpeg. ${font}"
    ffmpeg_install_x86_64
  fi

}
# 判断ffmpeg是否已经安装函数
ffmpeg_exits() {
  if [ -f "/usr/bin/ffmpeg" ]; then
    echo -e "${green}检测到你的机器已经安装过FFmpeg,程序将跳过安装步骤.${font}"
  else
    ffmpeg_install
  fi
}
# 定义函数，读取指定文件目录下的所有文件路径并存入队列中
# 参数1: 目录路径
# 返回值: 无
read_files_into_queue() {
  local dir_path=$1
  shopt -s nullglob
  for file in "$dir_path/"*.{mp4,avi,mov,wmv}; do
    [[ -f $file ]] || continue
    queue+=("$file")
  done
  shopt -u nullglob
}
# 定义函数，打印队列中的所有路径
# 参数: 无
# 返回值: 无
print_queue() {
  echo "队列中的所有路径:"
  for file in "${queue[@]}"; do
    printf "%s\n" "$file"
  done
}
# 定义函数，弹出队列中的一个元素
# 参数1: 索引位置（可选）
# 返回值: 被弹出的文件路径
pop_file_by_index() {
  local index=$1
  local file
  if [[ -n $index ]]; then
    # 如果传入了索引，则更新 next_index 的值
    next_index=$index
  fi
  if [[ $next_index -lt ${#queue[@]} ]]; then
    # 如果队列中还有元素，则弹出下一个元素
    file=${queue[$next_index]}
    unset 'queue[$next_index]'
    ((next_index++))
  else
    # 如果队列中没有元素了，则重新加载数据进队列
    read_files_into_queue "$folder"
    if [[ ${#queue[@]} -eq 0 ]]; then
      echo "队列中没有元素了"
      return
    fi
    file=${queue[0]}
    unset 'queue[0]'
    next_index=1
  fi
  echo "$file"
  return
}
# 查看推流日志
stream_log() {
  exec tail -n 50 -f output.log
}
# ffmpeg码率设置
ffmpeg_rate() {
  read -p "请输入推流码率(直接回车将使用默认值[$rate]):" || true
  # 如果用户有输入，使用用户的输入
  if [[ -n "$REPLY" ]]; then
    rate="$REPLY"
  fi
  # 判断用户输入的是否是数字+k组合
  if [[ $rate =~ ^[0-9]+k$ ]]; then
    echo -e "${yellow}推流码率为:$rate ${font}"
  else
    echo -e "${red}你输入的码率不合法,请重新运行程序并输入! ${font}"
    exit 1
  fi
  echo -e "${yellow}推流码率为:$rate ${font}"
}
# ffmpeg帧率设置
ffmpeg_fps() {
  read -p "请输入推率帧率(直接回车将使用默认值[$fps]):" || true
  # 如果用户有输入，使用用户的输入
  if [[ -n "$REPLY" ]]; then
    fps="$REPLY"
  fi
  # 判断码率输入的是否合法，只能是数字
  if [[ $fps =~ ^[0-9]+$ ]]; then
    echo -e "${yellow}推流帧率为:$fps ${font}"
  else
    echo -e "${red}你输入的帧率不合法,请重新运行程序并输入! ${font}"
    exit 1
  fi
  echo -e "${yellow}推流帧率为:$fps ${font}"
}
# ffmpeg视频源设置
ffmpeg_video() {
  # 定义视频存放目录
  read -p "请输入你的视频存放目录 (直接回车将使用默认值[$folder],格式支持mp4,avi,mov,wmv):" || true
  # 如果用户有输入，使用用户的输入
  if [[ -n "$REPLY" ]]; then
    folder="$REPLY"
  fi
  echo -e "${yellow}视频存放目录为:$folder ${font}"

  read -p "请输入你要开始的视频索引位置(直接回车将使用默认值[1]):" next_index
  if [ -z "$next_index" ]; then
    next_index=0
  else
    ((next_index--))
  fi
}
# ffmpeg rtmp
ffmpeg_rtmp() {
  # 定义推流地址和推流码
  read -p "请输入你的推流地址(rtmp协议，直接回车将使用默认值[$rtmp]):" || true
  # 如果用户有输入，使用用户的输入
  if [[ -n "$REPLY" ]]; then
    rtmp="$REPLY"
  fi

  # 判断用户输入的地址是否合法
  if [[ $rtmp =~ "rtmp://" ]]; then
    echo -e "${yellow}推流地址为:$rtmp ${font}"
  else
    echo -e "${red}你输入的地址不合法,请重新运行程序并输入! ${font}"
    exit 1
  fi
}
# 定义函数，推流
stream_start() {
  # 如果num=1检查
  if [ $num -eq 1 ]; then
    # 检查是否安装ffmpeg
    ffmpeg_exits
    # 检查是否安装screen
    screen_exits
  fi
  # ffmpeg rtmp
  ffmpeg_rtmp
  # ffmpeg视频源设置
  ffmpeg_video
  # 视频入队列
  read_files_into_queue "$folder"

  read -p "是否跳过后续更专业化设置直接开始推流? (yes/no，直接回车将使用默认值[$skip]): " || true
  # 如果用户有输入，使用用户的输入
  if [[ -n "$REPLY" ]]; then
    skip="$REPLY"
  fi
  # 判断是否跳过
  if [ "$skip" = "yes" ]; then
    echo -e "${green}程序将跳过更专业配置,直接开始推流.${font}"
  else
    # 设置码率
    ffmpeg_rate
    # 设置帧率
    ffmpeg_fps
    # 判断是否需要添加水印 默认no
    read -p "是否需要为视频添加水印? 水印位置默认在右上方, 需要较好CPU支持(yes/no，直接回车将使用默认值[$watermark]): " || true
    # 如果用户有输入，使用用户的输入
    if [[ -n "$REPLY" ]]; then
      watermark="$REPLY"
    fi
  fi

  if [ "$watermark" = "yes" ]; then
    read -p "请输入你的水印图片存放绝对路径,例如/opt/image/watermark.jpg (格式支持jpg/png/bmp):" image
    echo -e "${yellow}添加水印完成,程序将开始推流. ${font}"
    # 循环
    while true; do
      video=$(pop_file_by_index $next_index)
      next_index=$((next_index + 1))
      nohup ffmpeg -re -i "$video" -i "$image" -preset ultrafast -vcodec libx264 -r "$fps" -g 60 -b:v "$rate" -c:a aac -b:a 92k -strict -2 -f flv "${rtmp}" > output.log 2>&1 &
    done
  fi
  if [ "$watermark" = "no" ]; then
    # 循环
    while true; do
      video=$(pop_file_by_index "$next_index")
      next_index=$((next_index + 1))
      #注释 -b:v 视频码率  -b:a 音频码率  -ss 00:01:40 从视频的第1分40秒开始推流 -r 60 帧率 -g 60 关键帧间隔
      nohup ffmpeg -re -i "$video" -preset ultrafast -vcodec libx264 -r "$fps" -g 60 -b:v "$rate" -c:a aac -b:a 92k -strict -2 -f flv "${rtmp}" > output.log 2>&1 &
      stream_log
    done
  fi
}

# 停止推流
stream_stop() {
  killall ffmpeg
}
# 开始菜单设置
echo -e "######################################"
echo -e "#                                    #"
echo -e "#   Welcome to FFMPEG Stream Server  #"
echo -e "#                                    #"
echo -e "######################################"
echo -e "${yellow}Select an option:${font}"
echo -e "${green}0. Skip the check and Start Live Streaming"
echo -e "${green}1. Start Live Streaming"
echo -e "${green}2. Stop Live Streaming"
start_menu() {
  read -p "请输入数字选择你要进行的操作(直接回车将使用默认值[$num]):" || true
  # 如果用户有输入，使用用户的输入
  if [[ -n "$REPLY" ]]; then
    num="$REPLY"
  fi
  case "$num" in
  0 | 1)
    stream_start
    ;;
  2)
    stream_stop
    ;;
  *)
    echo -e "${red} 请输入正确的数字 (0-2) ${font}"
    ;;
  esac
}

# 运行开始菜单
start_menu
