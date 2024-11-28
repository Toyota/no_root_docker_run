# Copyright 2024 Toyota Motor Corporation.  All rights reserved.

import argparse
from typing import Dict
import string
import os
import subprocess
from subprocess import PIPE
from pathlib import Path

NO_ROOT_TOOLS_DIR = os.path.dirname(__file__)
if Path(NO_ROOT_TOOLS_DIR).is_absolute():
    NO_ROOT_TOOLS_DIR = NO_ROOT_TOOLS_DIR.replace(os.getcwd(), '')[1:]


def command2str(command: str) -> str:
    command_out = subprocess.run(command, shell=True, stdout=PIPE, stderr=PIPE, text=True)
    return command_out.stdout[:-1]


def gen_dockerfile(var_dict: Dict):
    template_file = open(os.path.join(NO_ROOT_TOOLS_DIR, 'src/Dockerfile.no_root.template'), 'r')
    template_text = string.Template(template_file.read())
    template_file.close()
    cfg_file = open(os.path.join(NO_ROOT_TOOLS_DIR, 'dist/Dockerfile.no_root'), 'w')
    cfg_file.write(template_text.safe_substitute(var_dict))
    cfg_file.close()
    pass


def gen_entrypoint(var_dict: Dict):
    template_file = open(os.path.join(NO_ROOT_TOOLS_DIR, 'src/entrypoint.sh.template'), 'r')
    template_text = string.Template(template_file.read())
    template_file.close()
    cfg_file = open(os.path.join(NO_ROOT_TOOLS_DIR, 'dist/entrypoint.sh'), 'w')
    cfg_file.write(template_text.safe_substitute(var_dict))
    cfg_file.close()
    pass


if __name__ == '__main__':
    # Source dockerfile
    parser = argparse.ArgumentParser()
    parser.add_argument("from_image", default="nvidia/cuda:11.3.1-devel-ubuntu20.04")
    args = parser.parse_args()

    # Host infromation
    username = command2str('echo $USER')
    userid = command2str('echo $(id -u $USER)')
    groupid = command2str('echo $(id -g $USER)')

    var_dict = {
        'host_user_generated': username,
        'host_user_uid': userid,
        'host_user_gid': groupid,
        'from_image': args.from_image,
        'where_no_root_tools_is': NO_ROOT_TOOLS_DIR
    }

    if not os.path.exists(os.path.join(NO_ROOT_TOOLS_DIR, "dist")):
        os.makedirs(os.path.join(NO_ROOT_TOOLS_DIR, "dist"))
        pass

    gen_dockerfile(var_dict)
    gen_entrypoint(var_dict)
    pass
