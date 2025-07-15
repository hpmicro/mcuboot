# Copyright (c) 2025 HPMicro
# SPDX-License-Identifier: BSD-3-Clause

cmake_minimum_required(VERSION 3.13)


set(CONFIG_TINYCRYPT 1)
set(PROJECT_ROOT_DIR ${CMAKE_CURRENT_LIST_DIR})
set(MCUBOOT_ROOT_DIR ${PROJECT_ROOT_DIR}/../..)
set(BOOTUTIL_DIR ${MCUBOOT_ROOT_DIR}/boot/bootutil)
set(BOOT_SERIAL_DIR ${MCUBOOT_ROOT_DIR}/boot/boot_serial)
set(HPMICRO_PORT_DIR ${PROJECT_ROOT_DIR}/port)

if (DEFINED PROJECT_TYPE_APP)
    set(EXCLUDE_BOOTHEADER 1)
    set(HPM_SDK_BASE $ENV{HPM_SDK_BASE})
    # Include basic extensions
    include($ENV{HPM_SDK_BASE}/cmake/python.cmake)
    include($ENV{HPM_SDK_BASE}/cmake/cmake-ext.cmake)
    # Find board directory
    if(BOARD_SEARCH_PATH AND EXISTS ${BOARD_SEARCH_PATH})
        find_path(BOARD_SEARCH_DIR NAMES ${BOARD}.yaml PATHS ${BOARD_SEARCH_PATH}/* NO_DEFAULT_PATH)
        
        if(BOARD_SEARCH_DIR)
            set(BOARD_MESSAGE "Board (custom board): ${BOARD} from ${BOARD_SEARCH_PATH}")
            set(HPM_BOARD_DIR ${BOARD_SEARCH_PATH}/${BOARD})
        endif()
    endif()

    if(NOT HPM_BOARD_DIR OR NOT EXISTS ${HPM_BOARD_DIR})
        find_path(SDK_BOARD_DIR NAMES ${BOARD}.yaml PATHS $ENV{HPM_SDK_BASE}/boards/* NO_DEFAULT_PATH)
        if(SDK_BOARD_DIR)
            set(BOARD_MESSAGE "Board: ${BOARD} from $ENV{HPM_SDK_BASE}/boards")
            set(HPM_BOARD_DIR $ENV{HPM_SDK_BASE}/boards/${BOARD})
        endif()
    endif()

    # Set BOARD_YAML path
    set(BOARD_YAML ${HPM_BOARD_DIR}/${BOARD}.yaml)
    if(NOT HPM_BOARD_DIR OR NOT EXISTS ${BOARD_YAML})
        message(FATAL_ERROR "No board named '${BOARD}' found")
    endif()
    message(STATUS "${BOARD_MESSAGE}")
    # Get SOC name of the board
    get_soc_name_of_board(${BOARD_YAML} soc_name)
    set(HPM_SOC ${soc_name})

    # Get SOC series name
    # Example: SOC: HPM6750 is under soc/HPM6700 folder, SOC series name is HPM6700
    set(HPM_SOC_DIR $ENV{HPM_SDK_BASE}/soc)
    file(GLOB SUBDIRECTORIES LIST_DIRECTORIES true ${HPM_SOC_DIR}/*)
    foreach(SUBDIR ${SUBDIRECTORIES})
        if(IS_DIRECTORY ${SUBDIR}/${HPM_SOC})
            get_filename_component(SOC_SERIES_NAME ${SUBDIR} NAME)
            set(HPM_SOC_SERIES ${SOC_SERIES_NAME})
            break()
        endif()
    endforeach()

    # Check if SOC series name is defined
    if(NOT DEFINED HPM_SOC_SERIES)
        message(FATAL_ERROR "\n!!! not found HPM_SOC_SERIES name for SOC: ${HPM_SOC}")
    endif()
    string(TOLOWER ${HPM_BUILD_TYPE} hpm_build_type)
    string(FIND ${hpm_build_type} "flash_xip" found)
    if(${found} GREATER_EQUAL 0)
        set(CUSTOM_GCC_LINKER_FILE ${HPMICRO_PORT_DIR}/soc/${HPM_SOC_SERIES}/${HPM_SOC}/toolchains/gcc/flash_xip_swap.ld)
    endif()
    string(FIND ${hpm_build_type} "flash_sdram_xip" found)
    if(${found} GREATER_EQUAL 0)
        set(CUSTOM_GCC_LINKER_FILE ${HPMICRO_PORT_DIR}/soc/${HPM_SOC_SERIES}/${HPM_SOC}/toolchains/gcc/flash_sdram_xip_swap.ld)
    endif()

endif()