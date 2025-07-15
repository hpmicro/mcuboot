# Copyright (c) 2023 HPMicro
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.13)

include(../../mcuboot_pre.cmake)
find_package(hpm-sdk REQUIRED HINTS $ENV{HPM_SDK_BASE})
include(../../mcuboot_post.cmake)

project(mcuboot_loader)

sdk_app_src(main.c)
generate_ide_projects()