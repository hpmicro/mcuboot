# SPDX-FileCopyrightText: 2022 Espressif Systems (Shanghai) CO LTD
#                         2025 HPMicro
# SPDX-License-Identifier: Apache-2.0

# Parse config files (.conf, format: <CONFIG_NAME>=<VALUE>) and set each as
# definitions and variables
function(parse_and_set_config_file CONFIG_FILE)
    set(generated_file_path "${__build_dir}/generated")
    set(CUSTOM_INC_DIR ${generated_file_path}/include)
    configure_file(${CONFIG_FILE} ${CUSTOM_INC_DIR}/mcuboot_conf.txt COPYONLY)
    file(STRINGS ${CONFIG_FILE} BOOTLOADER_CONF)
    foreach(config ${BOOTLOADER_CONF})
        if (NOT (${config} MATCHES "#"))
            string(REGEX REPLACE "^[ ]+" "" config ${config})
            string(REGEX MATCH "^[^=]+" CONFIG_NAME ${config})
            string(REPLACE "${CONFIG_NAME}=" "" CONFIG_VALUE ${config})
            # Overrides if already defined (definitions from latter file prevails over the former)
            if (DEFINED ${CONFIG_NAME})
                set(CONFIG_OLD "${CONFIG_NAME}")
                remove_definitions(-D${CONFIG_NAME}=${${CONFIG_OLD}})
            endif()
            if (NOT ("${CONFIG_VALUE}" STREQUAL "n"
                OR "${CONFIG_VALUE}" STREQUAL "N"))

                if (("${CONFIG_VALUE}" STREQUAL "y")
                    OR ("${CONFIG_VALUE}" STREQUAL "Y"))
                    set(CONFIG_VALUE 1)
                endif()
                sdk_compile_definitions(-D${CONFIG_NAME}=${CONFIG_VALUE})
                sdk_linker_global_symbols("${CONFIG_NAME}=${CONFIG_VALUE}")
                set(${CONFIG_NAME} ${CONFIG_VALUE} PARENT_SCOPE)
            endif()
        endif()
    endforeach()
endfunction()
