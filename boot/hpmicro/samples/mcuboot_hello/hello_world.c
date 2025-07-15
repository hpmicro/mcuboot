/*
 * Copyright (c) 2023 HPMicro
 *
 * SPDX-License-Identifier: BSD-3-Clause
 *
 */

#include <stdio.h>
#include "board.h"
#include "hpm_debug_console.h"
#include "bootutil/bootutil_log.h"
#include "bootutil/image.h"
#include "bootutil/bootutil.h"
#include "bootutil/fault_injection_hardening.h"
#include "bootutil/mcuboot_status.h"
#include "flash_map_backend/flash_map_backend.h"
#include "hpm_bootutil_ex.h"

extern int swap_set_image_ok(uint8_t image_index);
#define LED_FLASH_PERIOD_IN_MS 300

int main(void)
{
    board_init();
    board_init_led_pins();

    board_timer_create(LED_FLASH_PERIOD_IN_MS, board_led_toggle);

    printf("hpmicro hello world app for mcuboot(BOOT MODE)\n");

    return 0;
}
