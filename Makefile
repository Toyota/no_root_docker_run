# Demonstration Makefile; 
# This source code is derived from PackNet-SfM (https://github.com/TRI-ML/packnet-sfm)
# -----
# Copyright 2024 Toyota Motor Corporation.  All rights reserved. 

PROJECT ?= nrtdemo
VERSION ?= latest

WORKSPACE ?= /workspace/$(PROJECT)
DOCKER_IMAGE ?= ${PROJECT}:${VERSION}

# As a showcase, our sample code makes `~/nrt-demo/` 
# and demonstrate the permission test~/nrt-demo/${PROJECT}/checkpoints
CKPT_MNT ?= ~/nrt-demo/${PROJECT}/checkpoints
# (Optional) TMUX support: Allow tmux to create temporal file
TMUX_MNT  ?= ~/.tmux

# Docker options: -v ${CKPT_MNT} ... and -v ${TMUX_MNT} .. are for this example
SHMSIZE ?= 444G
WANDB_MODE ?= run
DOCKER_OPTS := \
			--name ${PROJECT} \
			--rm -it \
			--shm-size=${SHMSIZE} \
			-e DISPLAY=${DISPLAY} \
			-e XAUTHORITY \
			-e NVIDIA_DRIVER_CAPABILITIES=all \
			-v ~/.aws:/home/${USER}/.aws \
			-v ~/.cache:/home/${USER}/.cache \
			-v ${CKPT_MNT}:/data/checkpoints \
			-v ${TMUX_MNT}:/home/${USER}/.tmux \
			-v /dev/null:/dev/raw1394 \
			-v /tmp/.X11-unix/X0:/tmp/.X11-unix/X0 \
			-v /var/run/docker.sock:/var/run/docker.sock \
			-v ${PWD}:${WORKSPACE} \
			-w ${WORKSPACE} \
			--privileged \
			--ipc=host \
			--network=host

NGPUS=$(shell nvidia-smi -L | wc -l)

docker-build:
	docker build \
		-f docker/Dockerfile \
		-t ${DOCKER_IMAGE} .

docker-interactive: docker-build
	docker run --gpus all ${DOCKER_OPTS} ${DOCKER_IMAGE} bash

docker-run: docker-build
	docker run --gpus all ${DOCKER_OPTS} ${DOCKER_IMAGE} bash -c "${COMMAND}"

# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# ---------- FRC NO-ROOT-TOOLS COMMAND PART ----------
PATH2NRT ?= ${PWD}
initialize-scripts:
	python3 ${PATH2NRT}/run_setup.py ${DOCKER_IMAGE}

mkdir-writable:
	python3 ${PATH2NRT}/mk_writable.py --dirs \
		${CKPT_MNT} ${TMUX_MNT}

noroot-build: docker-build initialize-scripts
	docker build \
		-f ${PATH2NRT}/dist/Dockerfile.no_root \
		-t ${DOCKER_IMAGE}-${USER} .

noroot-interactive: mkdir-writable
	docker run --gpus all ${DOCKER_OPTS} \
    --name ${PROJECT}-${USER} ${DOCKER_IMAGE}-${USER} bash
# ----------------------------------------------------
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
