# Copyright 2024 Toyota Motor Corporation.  All rights reserved.

FROM nvidia/cuda:11.3.1-devel-ubuntu20.04

# Set PROJECT to be consistent with what is defined in Makefile
ENV PROJECT=nrtdemo
RUN mkdir -p /workspace/${PROJECT}
# Set default directory
WORKDIR /workspace/${PROJECT}