#include "i3c_controller.h"
#include "i3c_target.h"
#include "uart.h"
#include "utils.h"
#include "reg_access.h"
#include <stdio.h>
#include <stdbool.h>
#include "sys_platform.h"
#include "iob.h"

#define I3C_SLAVE_NUMS    1
#define DATA_LENGTH       1
#define SLAVE_ADDR        0x20
#define DAA_WARN_RETRY    20

#ifdef GPIO_INST_BASE_ADDR
#include "gpio.h"
struct gpio_instance gpio_inst;
#endif

struct uart_instance uart_core_uart;
struct i3c_master_instance i3cm;
struct i3c_dev_info i3c_devinfo;
struct i3c_target_handle_t i3cs;

// 傳遞 1 個資料，值由 GPIO 9~11 動態決定
uint8_t wr_buf[DATA_LENGTH];
uint8_t rd_buf[DATA_LENGTH];

// --- stdio routing functions for printf ---
static int lscc_uart_putc(char c, FILE *file) {
    int ret = uart_putc(&uart_core_uart, c);
    if (c == '\n' && ret == 0)
        ret = uart_putc(&uart_core_uart, '\r');
    return ret;
}
static int lscc_uart_getc(FILE *file) { return EOF; }
static int lscc_uart_flush(FILE *file) { return EOF; }
// ------------------------------------------

static void simple_delay_ms(uint32_t ms) {
    for (volatile uint32_t i = 0; i < (ms * 10000); i++);
}

static void set_led_all_off(void) {
#ifdef GPIO_INST_BASE_ADDR
    for (int i = 0; i < 8; i++)
        gpio_output_write(&gpio_inst, i, 0xFF); // 輸出 1 關閉 LED (Active Low)
#endif
}

static void set_led_on(uint8_t id) {
#ifdef GPIO_INST_BASE_ADDR
    gpio_output_write(&gpio_inst, id, 0x00); // 輸出 0 點亮該 LED
#endif
}

static void set_led_all_on(void) {
#ifdef GPIO_INST_BASE_ADDR
    for (int i = 0; i < 8; i++)
        gpio_output_write(&gpio_inst, i, 0x00); // 輸出 0 點亮 LED (Active Low)
#endif
}

// 將 0~7 的數值轉換成 Bar Graph (柱狀圖) 顯示，亮 N 顆燈 (GPIO 0 ~ N-1)
static void set_led_bar(uint8_t count) {
#ifdef GPIO_INST_BASE_ADDR
    for (int i = 0; i < 8; i++) {
        if (i < count) {
            gpio_output_write(&gpio_inst, i, 0x00); // 點亮
        } else {
            gpio_output_write(&gpio_inst, i, 0xFF); // 關閉
        }
    }
#endif
}

// 錯誤發生時：GPIO 0 閃爍
static void halt_with_blink_error(void) {
    printf("SYSTEM HALTED WITH ERROR.\n");
    while(1) {
        set_led_all_off();
        set_led_on(0); // 點亮 GPIO0
        simple_delay_ms(200);
        set_led_all_off(); // 關閉全燈
        simple_delay_ms(200);
    }
}

static void bsp_init(void) {
#ifdef GPIO_INST_BASE_ADDR
    gpio_inst.instance_name = GPIO_INST_NAME;
    gpio_init(&gpio_inst, GPIO_INST_BASE_ADDR, GPIO_INST_LINES_NUM, GPIO_INST_GPIO_DIRS);
    set_led_all_off();
#endif

    unsigned char uart_status = uart_init(
        &uart_core_uart, UART0_INST_BASE_ADDR,
        UART0_INST_SYS_CLK, UART0_INST_BAUD_RATE, 1, 8);

    if (uart_status != 0) {
        set_led_all_on();
        while(1);
    }
    iob_init(lscc_uart_putc, lscc_uart_getc, lscc_uart_flush);
}

int main(void) {
    bsp_init();

    printf("\n\n--- System Initialization Complete ---\n");
    
    // ── Step 0: I3C Initialization (Master & Target) ─────────────────
    printf("Starting I3C Master init...\n");
    if (i3c_master_init(&i3cm, I3C_M_INST_BASE_ADDR, 0,
                        I3C_M_INST_GUI_I2C_SCL_PULSE_WIDTH - 1, 1) != 0) {
        printf("ERROR: I3C Master init FAILED.\n");
        halt_with_blink_error();
    }
    
    printf("Starting I3C Target init...\n");
    i3cs.base_addr = I3C_S_INST_BASE_ADDR;
    if (i3c_target_init(&i3cs) != SUCCESS) {
        printf("ERROR: I3C Target init FAILED.\n");
        halt_with_blink_error();
    }

    if (i3c_target_fifo_loopback_enable(&i3cs) != SUCCESS) {
        printf("ERROR: Target FIFO loopback enable FAILED.\n");
        halt_with_blink_error();
    }

    // ── Step 1: Timing Parameters ────────────────────────────────────
    uint8_t clk_val  = 15;
    uint8_t od_val   = 15;
    uint8_t ctrl_val = 0;
    reg_8b_read(i3cm.base_addr | 0x04, &ctrl_val);
    reg_8b_write(i3cm.base_addr | 0x04, ctrl_val & ~0x01);
    reg_8b_write(i3cm.base_addr | 0x00, clk_val);
    reg_8b_write(i3cm.base_addr | 0x1A, od_val);
    reg_8b_write(i3cm.base_addr | 0x04, ctrl_val | 0x01);

    // ── Step 2: DAA ───────────────────────────────────────────────────
    printf("Starting DAA...\n");
    i3c_devinfo.pid    = 0;
    uint8_t dyn_address = 0;
    uint32_t daa_retry  = 0;

    while (1) {
        uint8_t ret = i3c_master_daa(&i3cm, &i3c_devinfo, &dyn_address,
                                     I3C_SLAVE_NUMS, SLAVE_ADDR);
        if (ret == 0) {
            printf(">> DAA SUCCESS! Dynamic Addr = 0x%02X\n", dyn_address);
            break;
        }

        daa_retry++;
        if (daa_retry >= DAA_WARN_RETRY) {
            printf("ERROR: DAA failed too many times.\n");
            halt_with_blink_error();
        }

        reg_8b_write(i3cm.base_addr | 0x0C, 0x01);
        simple_delay_ms(5);
        reg_8b_write(i3cm.base_addr | 0x0C, 0x00);
    }

    printf("\n--- I3C Initialization Complete. Entering Main Loop ---\n");

    // ── Step 3: Main Infinite Loop ───────────────────────────────────
    while (1) {
#ifdef GPIO_INST_BASE_ADDR
        uint32_t gpio_all = 0;

        printf("\n[WAIT] Waiting for GPIO8 to become 0 (Reset State)...\n");
        while (1) {
            gpio_input_get(&gpio_inst, 0, &gpio_all);
            if (!(gpio_all & (1 << 8))) {
                break; // 等待開關復位到 0
            }
            simple_delay_ms(50);
        }
        
        // 當 GPIO8 = 0 時，燈號全暗，代表系統已準備好接收新的觸發
        set_led_all_off();

        printf("[WAIT] GPIO8 is 0. Now waiting for GPIO8 = 1 to TRIGGER...\n");
        while (1) {
            gpio_input_get(&gpio_inst, 0, &gpio_all);
            if (gpio_all & (1 << 8)) {
                break; // 偵測到開關由 0 變 1
            }
            simple_delay_ms(50);
        }

        // 擷取 GPIO 9, 10, 11 (3個位元)
        uint8_t tx_val = (gpio_all >> 9) & 0x07;
        wr_buf[0] = tx_val;
#else
        // 防止沒有 GPIO 定義時卡死
        wr_buf[0] = 5; 
#endif

        printf("[RUN] Switch TRIGGERED! GPIO[9:11] value = %d. Starting Test...\n", wr_buf[0]);

        // ── 3.1: Master Private Write ────────────────────────────────
        printf("      Starting Private Write...\n");
        i3c_master_private_i3c_write(&i3cm, (uint8_t *)wr_buf, DATA_LENGTH, SLAVE_ADDR);
        simple_delay_ms(100);

        // ── 3.2: Master Private Read ─────────────────────────────────
        printf("      Starting Private Read...\n");
        rd_buf[0] = 0x00; // 清除初始值，確保測試公平
        i3c_master_private_i3c_read(&i3cm, (uint8_t *)rd_buf, DATA_LENGTH, SLAVE_ADDR);

        // ── 3.3: Result Verification ─────────────────────────────────
        printf("      Transmitted: %d, Received: %d\n", wr_buf[0], rd_buf[0]);

        if (rd_buf[0] == wr_buf[0]) {
            printf(">>    All data match! TEST PASSED. Displaying %d LEDs.\n", rd_buf[0]);
            // 成功：點亮對應數量的 LED (例如值為 5，則點亮 GPIO 0~4)
            set_led_bar(rd_buf[0]);
        } else {
            printf(">>    ERROR: Data mismatch! TEST FAILED.\n");
            // 失敗：GPIO 0 閃爍 5 次，然後回歸等待狀態
            for(int k = 0; k < 5; k++) {
                set_led_all_off();
                set_led_on(0);
                simple_delay_ms(200);
                set_led_all_off();
                simple_delay_ms(200);
            }
        }
    }
    
    return 0;
}
