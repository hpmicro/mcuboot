/*
 * Copyright (c) 2023-2025 HPMicro
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
#include "hpm_gpio_drv.h"

extern int swap_set_image_ok(uint8_t image_index);
#define LED_FLASH_PERIOD_IN_MS 1000

int main(void)
{
    uint8_t image_ok = -1;

    board_init();
    board_init_led_pins();
    board_init_gpio_pins();
    gpio_set_pin_input(BOARD_APP_GPIO_CTRL, BOARD_APP_GPIO_INDEX, BOARD_APP_GPIO_PIN);

    board_timer_create(LED_FLASH_PERIOD_IN_MS, board_led_toggle);

    printf("hpmicro hello world app v%.1f for mcuboot(UPGRADE MODE)\n", PROJECT_APP_VERSION);
    if (boot_read_image_state_by_id(0, &image_ok)) {
        printf("failed read image state\n");
        while (1) {

        }
    }
    if (image_ok == 1) {
        printf("image upgrade is permanent\n");
    } else if (image_ok == 3) {
        printf("image_ok is not set\n");
        printf("press button to write image ok flag so that the upgrade process will be permanent, otherwise bootloader will revert the upgrade process at next reboot.\r\n");
        while(1) {
            if (gpio_read_pin(BOARD_APP_GPIO_CTRL, BOARD_APP_GPIO_INDEX, BOARD_APP_GPIO_PIN) == BOARD_BUTTON_PRESSED_VALUE)
                break;
        }
        printf("writing image ok flag to flash, if failed revert proccess will run at next reboot\n");
        swap_set_image_ok(0);
        printf("written image ok flag success, next reboot upgrade will be permanent\n");
    } else {
        printf("image_ok flag is wrong, please check whether bootloader and app use same version of bootutil\n");
    }
    return 0;
}
