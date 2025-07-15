# Copyright (c) 2025 HPMicro
# SPDX-License-Identifier: BSD-3-Clause

include(${PROJECT_ROOT_DIR}/tools/utils.cmake)

if (NOT DEFINED MCUBOOT_CONFIG_FILE)
    set(MCUBOOT_CONFIG_FILE "${HPMICRO_PORT_DIR}/boards/${BOARD}/bootloader.conf")
endif()

string(REPLACE " " ";" MCUBOOT_CONFIG_FILE_LIST "${MCUBOOT_CONFIG_FILE}")
foreach(CONFIG_FILE ${MCUBOOT_CONFIG_FILE_LIST})
    if (NOT EXISTS "${CONFIG_FILE}")
        message(FATAL_ERROR "MCUboot configuration file does not exist at ${CONFIG_FILE}")
    endif()
    message(STATUS "parse config file ${CONFIG_FILE}")
    parse_and_set_config_file(${CONFIG_FILE})
endforeach()

if (DEFINED PROJECT_TYPE_APP)
    if (DEFINED PROJECT_APP_TYPE_UPGRADE)
        add_custom_command(
            TARGET ${APP_ELF_NAME}
            COMMAND "python" ${MCUBOOT_ROOT_DIR}/scripts/imgtool.py sign --header-size ${MCUBOOT_IMAGE_HEADER_SIZE} --align 8 --version ${PROJECT_APP_VERSION} --slot-size ${MCUBOOT_APPLICATION_SIZE} --pad ${EXECUTABLE_OUTPUT_PATH}/${APP_BIN_NAME} ${EXECUTABLE_OUTPUT_PATH}/${APP_NAME}_signed.bin
        )
    else()
        add_custom_command(
            TARGET ${APP_ELF_NAME}
            COMMAND "python" ${MCUBOOT_ROOT_DIR}/scripts/imgtool.py sign --header-size ${MCUBOOT_IMAGE_HEADER_SIZE} --align 8 --version ${PROJECT_APP_VERSION} --slot-size ${MCUBOOT_APPLICATION_SIZE} ${EXECUTABLE_OUTPUT_PATH}/${APP_BIN_NAME} ${EXECUTABLE_OUTPUT_PATH}/${APP_NAME}_signed.bin
        )
    endif()
    sdk_compile_definitions(-DPROJECT_APP_VERSION=${PROJECT_APP_VERSION})
endif()

if(DEFINED PROJECT_APP_TYPE_UPGRADE)
    sdk_compile_definitions(-DMCUBOOT_APP_UPGRADE_MODE=1)
endif()

if (DEFINED PROJECT_TYPE_APP)
    sdk_compile_definitions(-DPROJECT_TYPE_APP=1)
endif()
sdk_compile_definitions(-DBOARD_SHOW_CLOCK=0)

sdk_app_inc(${CMAKE_CURRENT_LIST_DIR}/hal/include)
sdk_app_inc(${BOOTUTIL_DIR}/include)
sdk_app_inc(${PROJECT_ROOT_DIR}/include)

set(bootutil_srcs
    ${BOOTUTIL_DIR}/src/boot_record.c
    ${BOOTUTIL_DIR}/src/bootutil_misc.c
    ${BOOTUTIL_DIR}/src/bootutil_public.c
    ${BOOTUTIL_DIR}/src/caps.c
    ${BOOTUTIL_DIR}/src/encrypted.c
    ${BOOTUTIL_DIR}/src/fault_injection_hardening.c
    ${BOOTUTIL_DIR}/src/fault_injection_hardening_delay_rng_mbedtls.c
    ${BOOTUTIL_DIR}/src/image_ec.c
    ${BOOTUTIL_DIR}/src/image_ec256.c
    ${BOOTUTIL_DIR}/src/image_ed25519.c
    ${BOOTUTIL_DIR}/src/image_rsa.c
    ${BOOTUTIL_DIR}/src/image_validate.c
    ${BOOTUTIL_DIR}/src/loader.c
    ${BOOTUTIL_DIR}/src/swap_misc.c
    ${BOOTUTIL_DIR}/src/swap_move.c
    ${BOOTUTIL_DIR}/src/swap_scratch.c
    ${BOOTUTIL_DIR}/src/tlv.c
    )
set(port_srcs
    ${PROJECT_ROOT_DIR}/port/flash_hpmicro.c
    ${PROJECT_ROOT_DIR}/port/flash_map_extended.c
    ${PROJECT_ROOT_DIR}/port/flash_map_layout.c
    ${PROJECT_ROOT_DIR}/port/flash_page_layout.c
    ${PROJECT_ROOT_DIR}/port/hpm_flash_areas.c
    ${PROJECT_ROOT_DIR}/port/hpm_bootutil_ex.c
    ${PROJECT_ROOT_DIR}/os.c
    )

sdk_app_src(${bootutil_srcs})
sdk_app_src(${port_srcs})
