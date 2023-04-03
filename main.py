import os


def generate_script():
    # 读取原始脚本
    with open('origin_script.sh', 'r') as f:
        original_script = f.readlines()

    # 生成新脚本文件名
    new_script_name = 'screen-stream.sh'

    # 遍历原始脚本，逐行生成新脚本
    with open(new_script_name, 'w') as f:
        f.write('#!/bin/bash\n')  # 写入新脚本的头部
        f.write('# 生成的脚本名称\n')
        f.write('new_script=\"ffmpeg-stream.sh\"\n')
        f.write('new_script_dir=\"$(pwd)\"\n')
        f.write('new_script_path=\"$new_script_dir/$new_script\"\n')
        f.write('# 创建新脚本的目录结构\n')
        f.write('mkdir -p \"$new_script_dir\"\n')


        # 遍历原始脚本每一行，生成新脚本
        for line in original_script:
            new_line = line.strip().replace('"', '\"').replace("'", "\'")
            f.write(f'echo \'{new_line}\' >> $new_script\n')  # 将新行写入新脚本

        f.write('# 让新脚本可执行\n')
        f.write('chmod +x $new_script\n')

    # 赋予新脚本执行权限
    os.chmod(new_script_name, 0o755)

# 测试
if __name__ == '__main__':
    generate_script()
