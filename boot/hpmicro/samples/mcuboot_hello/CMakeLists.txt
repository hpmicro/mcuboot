# Copyright (c) 2023 HPMicro
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.13)

set(PROJECT_TYPE_APP 1)
#set(PROJECT_APP_TYPE_UPGRADE  1)
set(PROJECT_APP_VERSION 1.0)

include(../../mcuboot_pre.cmake)
find_package(hpm-sdk REQUIRED HINTS $ENV{HPM_SDK_BASE})
include(../../mcuboot_post.cmake)

project(mcuboot_hello)

sdk_compile_definitions(-DBOARD_SHOW_CLOCK=0)

sdk_app_src(hello_world.c)
generate_ide_projects()