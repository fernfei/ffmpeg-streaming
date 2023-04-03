#!/bin/bash
# 生成的脚本名称
new_script="ffmpeg-stream.sh"
new_script_dir="$(pwd)"
new_script_path="$new_script_dir/$new_script"
# 创建新脚本的目录结构
mkdir -p "$new_script_dir"
echo '#!/bin/bash' >> $new_script
echo 'PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin' >> $new_script
echo 'export PATH' >> $new_script
echo '#=================================================================#' >> $new_script
echo '#   System Required: CentOS7 X86_64 And Arm64                     #' >> $new_script
echo '#   Description: FFMPEG Stream Media Server                       #' >> $new_script
echo '#   Author: hufei                                                 #' >> $new_script
echo '#   Website: https://www.hi-hufei.com                             #' >> $new_script
echo '#=================================================================#' >> $new_script
echo '' >> $new_script
echo '#=================================用户自定义配置开始=================================#' >> $new_script
echo '# 默认是否跳过详细设置' >> $new_script
echo 'skip="yes"' >> $new_script
echo '# 水印是否开启' >> $new_script
echo 'watermark="no"' >> $new_script
echo '# 默认视频位置' >> $new_script
echo 'folder="/root/live/videos"' >> $new_script
echo '# 默认推流地址' >> $new_script
echo 'rtmp="rtmp://live-push.bilivideo.com/live-bvc/?streamname=live_105182778_88140690&key=15821d36ef2e34341cc2840736537535&schedule=rtmp&pflag=1"' >> $new_script
echo '# 默认码率' >> $new_script
echo '# 视频直播服务不限制推流码率，支持常见分辨率以及对应的码率。' >> $new_script
echo '# 以下列举常见分辨率及对应码率：' >> $new_script
echo '# 640×480：100 kbps~800 kbps。' >> $new_script
echo '# 1280×720：200 kbps~1500 kbps。' >> $new_script
echo '# 1920×1080：500 kbps~4000 kbps。' >> $new_script
echo '# 2K（2560×1440）：2000 kbps~8000 kbps。' >> $new_script
echo '# 4K（3840×2160）：4000 kbps~30000 kbps。' >> $new_script
echo 'rate="1000k"' >> $new_script
echo '# 默认帧率' >> $new_script
echo 'fps="30"' >> $new_script
echo '#=================================用户自定义配置结束=================================#' >> $new_script
echo '' >> $new_script
echo '# 颜色选择' >> $new_script
echo 'red="\033[0;31m"' >> $new_script
echo 'green="\033[0;32m"' >> $new_script
echo 'yellow="\033[0;33m"' >> $new_script
echo 'font="\033[0m"' >> $new_script
echo '' >> $new_script
echo '# operation type' >> $new_script
echo 'num=0' >> $new_script
echo '' >> $new_script
echo '# 安装x86_64位的ffmpeg' >> $new_script
echo 'ffmpeg_install_x86_64() {' >> $new_script
echo 'yum -y install wget' >> $new_script
echo 'wget --no-check-certificate https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-4.0.3-64bit-static.tar.xz' >> $new_script
echo 'tar -xJf ffmpeg-4.0.3-64bit-static.tar.xz' >> $new_script
echo 'cd ffmpeg-4.0.3-64bit-static || exit' >> $new_script
echo 'mv ffmpeg /usr/bin && mv ffprobe /usr/bin && mv qt-faststart /usr/bin && mv ffmpeg-10bit /usr/bin' >> $new_script
echo '}' >> $new_script
echo '# 安装arm64位的ffmpeg' >> $new_script
echo 'ffmpeg_install_arm64() {' >> $new_script
echo 'yum -y install wget' >> $new_script
echo 'wget --no-check-certificate https://www.johnvansickle.com/ffmpeg/old-releases/ffmpeg-5.0.1-arm64-static.tar.xz' >> $new_script
echo 'tar -xJf ffmpeg-4.0.3-arm64-static.tar.xz' >> $new_script
echo 'cd ffmpeg-4.0.3-arm64-static || exit' >> $new_script
echo 'mv ffmpeg /usr/bin && mv ffprobe /usr/bin && mv qt-faststart /usr/bin && mv ffmpeg-10bit /usr/bin' >> $new_script
echo '}' >> $new_script
echo '# 安装screen' >> $new_script
echo 'screen_install() {' >> $new_script
echo 'yum -y install screen' >> $new_script
echo '}' >> $new_script
echo '# 检查screen是否安装' >> $new_script
echo 'screen_exits() {' >> $new_script
echo 'if [ -f "/usr/bin/screen" ]; then' >> $new_script
echo 'echo -e "${green}检测到你的机器已经安装过screen,程序将跳过安装步骤.${font}"' >> $new_script
echo 'else' >> $new_script
echo 'screen_install' >> $new_script
echo 'fi' >> $new_script
echo '}' >> $new_script
echo '# 安装ffmpeg' >> $new_script
echo 'ffmpeg_install() {' >> $new_script
echo '# 查看系统版本amd64  or arm64 下载对应的版本的ffmpeg' >> $new_script
echo 'if [ "$(uname -m)" = "aarch64" ]; then' >> $new_script
echo 'echo -e "${green}检测到你的机器是arm64系统,程序将自动安装arm64FFmpeg. ${font}"' >> $new_script
echo 'ffmpeg_install_arm64' >> $new_script
echo 'fi' >> $new_script
echo 'if [ "$(uname -m)" = "x86_64" ]; then' >> $new_script
echo 'echo -e "${green}检测到你的机器是64位系统,程序将自动安装64位FFmpeg. ${font}"' >> $new_script
echo 'ffmpeg_install_x86_64' >> $new_script
echo 'fi' >> $new_script
echo '' >> $new_script
echo '}' >> $new_script
echo '# 判断ffmpeg是否已经安装函数' >> $new_script
echo 'ffmpeg_exits() {' >> $new_script
echo 'if [ -f "/usr/bin/ffmpeg" ]; then' >> $new_script
echo 'echo -e "${green}检测到你的机器已经安装过FFmpeg,程序将跳过安装步骤.${font}"' >> $new_script
echo 'else' >> $new_script
echo 'ffmpeg_install' >> $new_script
echo 'fi' >> $new_script
echo '}' >> $new_script
echo '# 定义函数，读取指定文件目录下的所有文件路径并存入队列中' >> $new_script
echo '# 参数1: 目录路径' >> $new_script
echo '# 返回值: 无' >> $new_script
echo 'read_files_into_queue() {' >> $new_script
echo 'local dir_path=$1' >> $new_script
echo 'shopt -s nullglob' >> $new_script
echo 'for file in "$dir_path/"*.{mp4,avi,mov,wmv}; do' >> $new_script
echo '[[ -f $file ]] || continue' >> $new_script
echo 'queue+=("$file")' >> $new_script
echo 'done' >> $new_script
echo 'shopt -u nullglob' >> $new_script
echo '}' >> $new_script
echo '# 定义函数，打印队列中的所有路径' >> $new_script
echo '# 参数: 无' >> $new_script
echo '# 返回值: 无' >> $new_script
echo 'print_queue() {' >> $new_script
echo 'echo "队列中的所有路径:"' >> $new_script
echo 'for file in "${queue[@]}"; do' >> $new_script
echo 'printf "%s\n" "$file"' >> $new_script
echo 'done' >> $new_script
echo '}' >> $new_script
echo '# 定义函数，弹出队列中的一个元素' >> $new_script
echo '# 参数1: 索引位置（可选）' >> $new_script
echo '# 返回值: 被弹出的文件路径' >> $new_script
echo 'pop_file_by_index() {' >> $new_script
echo 'local index=$1' >> $new_script
echo 'local file' >> $new_script
echo 'if [[ -n $index ]]; then' >> $new_script
echo '# 如果传入了索引，则更新 next_index 的值' >> $new_script
echo 'next_index=$index' >> $new_script
echo 'fi' >> $new_script
echo 'if [[ $next_index -lt ${#queue[@]} ]]; then' >> $new_script
echo '# 如果队列中还有元素，则弹出下一个元素' >> $new_script
echo 'file=${queue[$next_index]}' >> $new_script
echo 'unset 'queue[$next_index]'' >> $new_script
echo '((next_index++))' >> $new_script
echo 'else' >> $new_script
echo '# 如果队列中没有元素了，则重新加载数据进队列' >> $new_script
echo 'read_files_into_queue "$folder"' >> $new_script
echo 'if [[ ${#queue[@]} -eq 0 ]]; then' >> $new_script
echo 'echo "队列中没有元素了"' >> $new_script
echo 'return' >> $new_script
echo 'fi' >> $new_script
echo 'file=${queue[0]}' >> $new_script
echo 'unset 'queue[0]'' >> $new_script
echo 'next_index=1' >> $new_script
echo 'fi' >> $new_script
echo 'echo "$file"' >> $new_script
echo 'return' >> $new_script
echo '}' >> $new_script
echo '# 查看推流日志' >> $new_script
echo 'stream_log() {' >> $new_script
echo 'exec tail -n 50 -f output.log' >> $new_script
echo '}' >> $new_script
echo '# ffmpeg码率设置' >> $new_script
echo 'ffmpeg_rate() {' >> $new_script
echo 'read -p "请输入推流码率(直接回车将使用默认值[$rate]):" || true' >> $new_script
echo '# 如果用户有输入，使用用户的输入' >> $new_script
echo 'if [[ -n "$REPLY" ]]; then' >> $new_script
echo 'rate="$REPLY"' >> $new_script
echo 'fi' >> $new_script
echo '# 判断用户输入的是否是数字+k组合' >> $new_script
echo 'if [[ $rate =~ ^[0-9]+k$ ]]; then' >> $new_script
echo 'echo -e "${yellow}推流码率为:$rate ${font}"' >> $new_script
echo 'else' >> $new_script
echo 'echo -e "${red}你输入的码率不合法,请重新运行程序并输入! ${font}"' >> $new_script
echo 'exit 1' >> $new_script
echo 'fi' >> $new_script
echo 'echo -e "${yellow}推流码率为:$rate ${font}"' >> $new_script
echo '}' >> $new_script
echo '# ffmpeg帧率设置' >> $new_script
echo 'ffmpeg_fps() {' >> $new_script
echo 'read -p "请输入推率帧率(直接回车将使用默认值[$fps]):" || true' >> $new_script
echo '# 如果用户有输入，使用用户的输入' >> $new_script
echo 'if [[ -n "$REPLY" ]]; then' >> $new_script
echo 'fps="$REPLY"' >> $new_script
echo 'fi' >> $new_script
echo '# 判断码率输入的是否合法，只能是数字' >> $new_script
echo 'if [[ $fps =~ ^[0-9]+$ ]]; then' >> $new_script
echo 'echo -e "${yellow}推流帧率为:$fps ${font}"' >> $new_script
echo 'else' >> $new_script
echo 'echo -e "${red}你输入的帧率不合法,请重新运行程序并输入! ${font}"' >> $new_script
echo 'exit 1' >> $new_script
echo 'fi' >> $new_script
echo 'echo -e "${yellow}推流帧率为:$fps ${font}"' >> $new_script
echo '}' >> $new_script
echo '# ffmpeg视频源设置' >> $new_script
echo 'ffmpeg_video() {' >> $new_script
echo '# 定义视频存放目录' >> $new_script
echo 'read -p "请输入你的视频存放目录 (直接回车将使用默认值[$folder],格式支持mp4,avi,mov,wmv):" || true' >> $new_script
echo '# 如果用户有输入，使用用户的输入' >> $new_script
echo 'if [[ -n "$REPLY" ]]; then' >> $new_script
echo 'folder="$REPLY"' >> $new_script
echo 'fi' >> $new_script
echo 'echo -e "${yellow}视频存放目录为:$folder ${font}"' >> $new_script
echo '' >> $new_script
echo 'read -p "请输入你要开始的视频索引位置(直接回车将使用默认值[1]):" next_index' >> $new_script
echo 'if [ -z "$next_index" ]; then' >> $new_script
echo 'next_index=0' >> $new_script
echo 'else' >> $new_script
echo '((next_index--))' >> $new_script
echo 'fi' >> $new_script
echo '}' >> $new_script
echo '# ffmpeg rtmp' >> $new_script
echo 'ffmpeg_rtmp() {' >> $new_script
echo '# 定义推流地址和推流码' >> $new_script
echo 'read -p "请输入你的推流地址(rtmp协议，直接回车将使用默认值[$rtmp]):" || true' >> $new_script
echo '# 如果用户有输入，使用用户的输入' >> $new_script
echo 'if [[ -n "$REPLY" ]]; then' >> $new_script
echo 'rtmp="$REPLY"' >> $new_script
echo 'fi' >> $new_script
echo '' >> $new_script
echo '# 判断用户输入的地址是否合法' >> $new_script
echo 'if [[ $rtmp =~ "rtmp://" ]]; then' >> $new_script
echo 'echo -e "${yellow}推流地址为:$rtmp ${font}"' >> $new_script
echo 'else' >> $new_script
echo 'echo -e "${red}你输入的地址不合法,请重新运行程序并输入! ${font}"' >> $new_script
echo 'exit 1' >> $new_script
echo 'fi' >> $new_script
echo '}' >> $new_script
echo '# 定义函数，推流' >> $new_script
echo 'stream_start() {' >> $new_script
echo '# 如果num=1检查' >> $new_script
echo 'if [ $num -eq 1 ]; then' >> $new_script
echo '# 检查是否安装ffmpeg' >> $new_script
echo 'ffmpeg_exits' >> $new_script
echo '# 检查是否安装screen' >> $new_script
echo 'screen_exits' >> $new_script
echo 'fi' >> $new_script
echo '# ffmpeg rtmp' >> $new_script
echo 'ffmpeg_rtmp' >> $new_script
echo '# ffmpeg视频源设置' >> $new_script
echo 'ffmpeg_video' >> $new_script
echo '# 视频入队列' >> $new_script
echo 'read_files_into_queue "$folder"' >> $new_script
echo '' >> $new_script
echo 'read -p "是否跳过后续更专业化设置直接开始推流? (yes/no，直接回车将使用默认值[$skip]): " || true' >> $new_script
echo '# 如果用户有输入，使用用户的输入' >> $new_script
echo 'if [[ -n "$REPLY" ]]; then' >> $new_script
echo 'skip="$REPLY"' >> $new_script
echo 'fi' >> $new_script
echo '# 判断是否跳过' >> $new_script
echo 'if [ "$skip" = "yes" ]; then' >> $new_script
echo 'echo -e "${green}程序将跳过更专业配置,直接开始推流.${font}"' >> $new_script
echo 'else' >> $new_script
echo '# 设置码率' >> $new_script
echo 'ffmpeg_rate' >> $new_script
echo '# 设置帧率' >> $new_script
echo 'ffmpeg_fps' >> $new_script
echo '# 判断是否需要添加水印 默认no' >> $new_script
echo 'read -p "是否需要为视频添加水印? 水印位置默认在右上方, 需要较好CPU支持(yes/no，直接回车将使用默认值[$watermark]): " || true' >> $new_script
echo '# 如果用户有输入，使用用户的输入' >> $new_script
echo 'if [[ -n "$REPLY" ]]; then' >> $new_script
echo 'watermark="$REPLY"' >> $new_script
echo 'fi' >> $new_script
echo 'fi' >> $new_script
echo '' >> $new_script
echo 'if [ "$watermark" = "yes" ]; then' >> $new_script
echo 'read -p "请输入你的水印图片存放绝对路径,例如/opt/image/watermark.jpg (格式支持jpg/png/bmp):" image' >> $new_script
echo 'echo -e "${yellow}添加水印完成,程序将开始推流. ${font}"' >> $new_script
echo '# 循环' >> $new_script
echo 'while true; do' >> $new_script
echo 'video=$(pop_file_by_index $next_index)' >> $new_script
echo 'next_index=$((next_index + 1))' >> $new_script
echo 'nohup ffmpeg -re -i "$video" -i "$image" -preset ultrafast -vcodec libx264 -r "$fps" -g 60 -b:v "$rate" -c:a aac -b:a 92k -strict -2 -f flv "${rtmp}" > output.log 2>&1 &' >> $new_script
echo 'done' >> $new_script
echo 'fi' >> $new_script
echo 'if [ "$watermark" = "no" ]; then' >> $new_script
echo '# 循环' >> $new_script
echo 'while true; do' >> $new_script
echo 'video=$(pop_file_by_index "$next_index")' >> $new_script
echo 'next_index=$((next_index + 1))' >> $new_script
echo '#注释 -b:v 视频码率  -b:a 音频码率  -ss 00:01:40 从视频的第1分40秒开始推流 -r 60 帧率 -g 60 关键帧间隔' >> $new_script
echo 'nohup ffmpeg -re -i "$video" -preset ultrafast -vcodec libx264 -r "$fps" -g 60 -b:v "$rate" -c:a aac -b:a 92k -strict -2 -f flv "${rtmp}" > output.log 2>&1 &' >> $new_script
echo 'stream_log' >> $new_script
echo 'done' >> $new_script
echo 'fi' >> $new_script
echo '}' >> $new_script
echo '' >> $new_script
echo '# 停止推流' >> $new_script
echo 'stream_stop() {' >> $new_script
echo 'killall ffmpeg' >> $new_script
echo '}' >> $new_script
echo '# 开始菜单设置' >> $new_script
echo 'echo -e "######################################"' >> $new_script
echo 'echo -e "#                                    #"' >> $new_script
echo 'echo -e "#   Welcome to FFMPEG Stream Server  #"' >> $new_script
echo 'echo -e "#                                    #"' >> $new_script
echo 'echo -e "######################################"' >> $new_script
echo 'echo -e "${yellow}Select an option:${font}"' >> $new_script
echo 'echo -e "${green}0. Skip the check and Start Live Streaming"' >> $new_script
echo 'echo -e "${green}1. Start Live Streaming"' >> $new_script
echo 'echo -e "${green}2. Stop Live Streaming"' >> $new_script
echo 'start_menu() {' >> $new_script
echo 'read -p "请输入数字选择你要进行的操作(直接回车将使用默认值[$num]):" || true' >> $new_script
echo '# 如果用户有输入，使用用户的输入' >> $new_script
echo 'if [[ -n "$REPLY" ]]; then' >> $new_script
echo 'num="$REPLY"' >> $new_script
echo 'fi' >> $new_script
echo 'case "$num" in' >> $new_script
echo '0 | 1)' >> $new_script
echo 'stream_start' >> $new_script
echo ';;' >> $new_script
echo '2)' >> $new_script
echo 'stream_stop' >> $new_script
echo ';;' >> $new_script
echo '*)' >> $new_script
echo 'echo -e "${red} 请输入正确的数字 (0-2) ${font}"' >> $new_script
echo ';;' >> $new_script
echo 'esac' >> $new_script
echo '}' >> $new_script
echo '' >> $new_script
echo '# 运行开始菜单' >> $new_script
echo 'start_menu' >> $new_script
# 让新脚本可执行
chmod +x $new_script
