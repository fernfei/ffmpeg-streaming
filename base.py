#!/usr/bin/env python

import platform
import struct
import glob
import shutil
import os
import fnmatch
import subprocess
import sys
import re
import stat

__file__script__path__ = os.path.dirname(os.path.realpath(__file__))


# common functions --------------------------------------
def get_script_dir(file=""):
    test_file = file
    if ("" == file):
        test_file = __file__
    scriptPath = os.path.realpath(test_file)
    scriptDir = os.path.dirname(scriptPath)
    return scriptDir


def host_platform():
    ret = platform.system().lower()
    if (ret == "darwin"):
        return "mac"
    return ret


def is_centos():
    os_info = platform.linux_distribution(full_distribution_name=False)
    return "centos" in os_info[0].lower()


def is_ubuntu():
    os_info = platform.linux_distribution(full_distribution_name=False)
    return "ubuntu" in os_info[0].lower()


def install_package(package):
    if isinstance(package, list):
        package = " ".join(package)
    if is_centos():
        os.system("sudo yum install -y " + package)
    elif is_ubuntu():
        os.system("sudo apt-get install -y " + package)
    else:
        print_error("Unknown OS")
        sys.exit(1)


def is_os_64bit():
    return platform.machine().endswith('64')


def is_os_arm():
    if -1 == platform.machine().find('arm'):
        return False
    return True

def is_os_x86():
    return platform.machine().find('x86') != -1


def is_python_64bit():
    return (struct.calcsize("P") == 8)


def get_path(path):
    if "windows" == host_platform():
        return path.replace("/", "\\")
    return path


def get_env(name):
    return os.getenv(name, "")


def set_env(name, value):
    os.environ[name] = value
    return


def print_info(info=""):
    print("------------------------------------------")
    print(info)
    print("------------------------------------------")
    return


def print_error(error=""):
    print("\033[91m" + error + "\033[0m")


def print_list(list):
    print('[%s]' % ', '.join(map(str, list)))
    return


# file system -------------------------------------------
def is_file(path):
    return os.path.isfile(get_path(path))


def is_dir(path):
    return os.path.isdir(get_path(path))


def is_exist(path):
    if is_file(path) or is_dir(path):
        return True
    return False


def copy_file(src, dst):
    if is_file(dst):
        delete_file(dst)
    if not is_file(src):
        print("copy warning [file not exist]: " + src)
        return
    return shutil.copy2(get_path(src), get_path(dst))


def move_file(src, dst):
    if is_file(dst):
        delete_file(dst)
    if not is_file(src):
        print("move warning [file not exist]: " + src)
        return
    return shutil.move(get_path(src), get_path(dst))


def copy_files(src, dst, override=True):
    for file in glob.glob(src):
        file_name = os.path.basename(file)
        if is_file(file):
            if override and is_file(dst + "/" + file_name):
                delete_file(dst + "/" + file_name)
            if not is_file(dst + "/" + file_name):
                copy_file(file, dst)
        elif is_dir(file):
            if not is_dir(dst + "/" + file_name):
                create_dir(dst + "/" + file_name)
            copy_files(file + "/*", dst + "/" + file_name, override)
    return


def move_files(src, dst, override=True):
    for file in glob.glob(src):
        file_name = os.path.basename(file)
        if is_file(file):
            if override and is_file(dst + "/" + file_name):
                delete_file(dst + "/" + file_name)
            if not is_file(dst + "/" + file_name):
                move_file(file, dst)
        elif is_dir(file):
            if not is_dir(dst + "/" + file_name):
                create_dir(dst + "/" + file_name)
            move_files(file + "/*", dst + "/" + file_name, override)
    return


def copy_dir_content(src, dst, filterInclude="", filterExclude=""):
    src_folder = src
    if ("/" != src[-1:]):
        src_folder += "/"
    src_folder += "*"
    for file in glob.glob(src_folder):
        basename = os.path.basename(file)
        if ("" != filterInclude) and (-1 == basename.find(filterInclude)):
            continue
        if ("" != filterExclude) and (-1 != basename.find(filterExclude)):
            continue
        if is_file(file):
            copy_file(file, dst)
        elif is_dir(file):
            copy_dir(file, dst + "/" + basename)
    return


def delete_file(path):
    if not is_file(path):
        print("delete warning [file not exist]: " + path)
        return
    return os.remove(get_path(path))


def delete_exe(path):
    return os.remove(get_path(path) + (".exe" if "windows" == host_platform() else ""))


def find_file(path, pattern):
    for root, dirnames, filenames in os.walk(path):
        for filename in fnmatch.filter(filenames, pattern):
            return os.path.join(root, filename)


def create_dir(path):
    path2 = get_path(path)
    if not os.path.exists(path2):
        os.makedirs(path2)
    return


def move_dir(src, dst):
    if is_dir(dst):
        delete_dir(dst)
    if is_dir(src):
        copy_dir(src, dst)
        delete_dir(src)
    return


def copy_dir(src, dst):
    if is_dir(dst):
        delete_dir(dst)
    try:
        shutil.copytree(get_path(src), get_path(dst))
    except:
        if ("windows" == host_platform()) and copy_dir_windows(src, dst):
            return
        print("Directory not copied")
    return


def copy_dir_windows(src, dst):
    if is_dir(dst):
        delete_dir(dst)
    err = cmd("robocopy", [get_path(src), get_path(dst), "/e", "/NFL", "/NDL", "/NJH", "/NJS", "/nc", "/ns", "/np"],
              True)
    if (1 == err):
        return True
    return False


def delete_dir_with_access_error(path):
    def delete_file_on_error(func, path, exc_info):
        if ("windows" != host_platform()):
            if not os.access(path, os.W_OK):
                os.chmod(path, stat.S_IWUSR)
                func(path)
            return
        elif (0 != path.find("\\\\?\\")):
            # abspath not work with long names
            full_path = path
            drive_pos = full_path.find(":")
            if (drive_pos < 0) or (drive_pos > 2):
                full_path = os.getcwd() + "\\" + full_path
            else:
                full_path = full_path
            if (len(full_path) >= 260):
                full_path = "\\\\?\\" + full_path
            if not os.access(full_path, os.W_OK):
                os.chmod(full_path, stat.S_IWUSR)
            func(full_path)
        return

    if not is_dir(path):
        print("delete warning [folder not exist]: " + path)
        return
    shutil.rmtree(os.path.normpath(get_path(path)), ignore_errors=False, onerror=delete_file_on_error)
    return


def delete_dir(path):
    if not is_dir(path):
        print("delete warning [folder not exist]: " + path)
        return
    if ("windows" == host_platform()):
        delete_dir_with_access_error(path)
    else:
        shutil.rmtree(get_path(path), ignore_errors=True)
    return


def copy_exe(src, dst, name):
    exe_ext = ""
    if ("windows" == host_platform()):
        exe_ext = ".exe"
    copy_file(src + "/" + name + exe_ext, dst + "/" + name + exe_ext)
    return


def replaceInFile(path, text, textReplace):
    if not is_file(path):
        print("[replaceInFile] file not exist: " + path)
        return
    filedata = ""
    with open(get_path(path), "r") as file:
        filedata = file.read()
    filedata = filedata.replace(text, textReplace)
    delete_file(path)
    with open(get_path(path), "w") as file:
        file.write(filedata)
    return


def replaceInFileUtf8(path, text, textReplace):
    if not is_file(path):
        print("[replaceInFile] file not exist: " + path)
        return
    filedata = ""
    with open(get_path(path), "rb") as file:
        filedata = file.read().decode("UTF-8")
    filedata = filedata.replace(text, textReplace)
    delete_file(path)
    with open(get_path(path), "wb") as file:
        file.write(filedata.encode("UTF-8"))
    return


def replaceInFileRE(path, pattern, textReplace):
    if not is_file(path):
        print("[replaceInFile] file not exist: " + path)
        return
    filedata = ""
    with open(get_path(path), "r") as file:
        filedata = file.read()
    filedata = re.sub(pattern, textReplace, filedata)
    delete_file(path)
    with open(get_path(path), "w") as file:
        file.write(filedata)
    return


def readFile(path):
    if not is_file(path):
        return ""
    filedata = ""
    with open(get_path(path), "r") as file:
        filedata = file.read()
    return filedata


def writeFile(path, data):
    if is_file(path):
        delete_file(path)
    with open(get_path(path), "w") as file:
        file.write(data)
    return


# system cmd methods ------------------------------------
def cmd(prog, args=[], is_no_errors=False):
    ret = 0
    if ("windows" == host_platform()):
        sub_args = args[:]
        sub_args.insert(0, get_path(prog))
        ret = subprocess.call(sub_args, stderr=subprocess.STDOUT, shell=True)
    else:
        command = prog
        for arg in args:
            command += (" \"" + arg + "\"")
        ret = subprocess.call(command, stderr=subprocess.STDOUT, shell=True)
    if ret != 0 and True != is_no_errors:
        sys.exit("Error (" + prog + "): " + str(ret))
    return ret


def cmd2(prog, args=[], is_no_errors=False):
    ret = 0
    command = prog if ("windows" != host_platform()) else get_path(prog)
    for arg in args:
        command += (" " + arg)
    print(command)
    ret = subprocess.call(command, stderr=subprocess.STDOUT, shell=True)
    if ret != 0 and True != is_no_errors:
        sys.exit("Error (" + prog + "): " + str(ret))
    return ret


def cmd_exe(prog, args):
    prog_dir = os.path.dirname(prog)
    env_dir = os.environ
    if ("linux" == host_platform()):
        old = os.getenv("LD_LIBRARY_PATH", "")
        env_dir["LD_LIBRARY_PATH"] = prog_dir + ("" if "" == old else (":" + old))
    elif ("mac" == host_platform()):
        old = os.getenv("DYLD_LIBRARY_PATH", "")
        env_dir["DYLD_LIBRARY_PATH"] = prog_dir + ("" if "" == old else (":" + old))

    ret = 0
    if ("windows" == host_platform()):
        sub_args = args[:]
        sub_args.insert(0, get_path(prog + ".exe"))
        process = subprocess.Popen(sub_args, stderr=subprocess.STDOUT, shell=True, env=env_dir)
        ret = process.wait()
    else:
        command = prog
        for arg in args:
            command += (" \"" + arg + "\"")
        process = subprocess.Popen(command, stderr=subprocess.STDOUT, shell=True, env=env_dir)
        ret = process.wait()
    if ret != 0:
        sys.exit("Error (" + prog + "): " + str(ret))
    return ret


def cmd_in_dir(directory, prog, args=[], is_no_errors=False):
    dir = get_path(directory)
    cur_dir = os.getcwd()
    os.chdir(dir)
    ret = cmd(prog, args, is_no_errors)
    os.chdir(cur_dir)
    return ret


def cmd_and_return_cwd(prog, args=[], is_no_errors=False):
    cur_dir = os.getcwd()
    ret = cmd(prog, args, is_no_errors)
    os.chdir(cur_dir)
    return ret


def run_command(sCommand):
    popen = subprocess.Popen(sCommand, stdout=subprocess.PIPE, stderr=subprocess.PIPE, shell=True)
    result = {'stdout': '', 'stderr': ''}
    try:
        stdout, stderr = popen.communicate()
        popen.wait()
        result['stdout'] = stdout.strip().decode('utf-8', errors='ignore')
        result['stderr'] = stderr.strip().decode('utf-8', errors='ignore')
    finally:
        popen.stdout.close()
        popen.stderr.close()

    return result


def run_command_in_dir(directory, sCommand):
    host = host_platform()
    if (host == 'windows'):
        dir = get_path(directory)
        cur_dir = os.getcwd()
        os.chdir(dir)

    ret = run_command(sCommand)

    if (host == 'windows'):
        os.chdir(cur_dir)
    return ret


def exec_command_in_dir(directory, sCommand):
    host = host_platform()
    if (host == 'windows'):
        dir = get_path(directory)
        cur_dir = os.getcwd()
        os.chdir(dir)

    ret = os.system(sCommand)

    if (host == 'windows'):
        os.chdir(cur_dir)
    return ret


def run_process(args=[]):
    subprocess.Popen(args)


def run_process_in_dir(directory, args=[]):
    dir = get_path(directory)
    cur_dir = os.getcwd()
    os.chdir(dir)
    run_process(args)
    os.chdir(cur_dir)


# nodejs ------------------------------------------------
def run_nodejs(args=[]):
    args.insert(0, 'node')
    run_process(args)


def run_nodejs_in_dir(directory, args=[]):
    args.insert(0, 'node')
    run_process_in_dir(directory, args)


def bash(path):
    command = get_path(path)
    command += (".bat" if "windows" == host_platform() else ".sh")
    return cmd(command, [])


def get_cwd():
    return os.getcwd()


def set_cwd(dir):
    os.chdir(dir)
    return


# common ------------------------------------------------
def is_windows():
    if "windows" == host_platform():
        return True
    return False


def platform_is_32(platform):
    if (-1 != platform.find("_32")):
        return True
    return False


def host_platform_is64():
    return platform.machine().endswith("64")
