#include "i3c_controller.h"
#include "i3c_target.h"      // 新增：引入 Target 驅動標頭檔
#include "uart.h"
#include "utils.h"
#include "reg_access.h"
#include <stdio.h>
#include <stdbool.h>
#include "sys_platform.h"
#include "iob.h"

#define I3C_SLAVE_NUMS 1
#define DATA_LENGTH 32
#define SLAVE_ADDR 0x20

#ifdef GPIO_INST_BASE_ADDR
#include "gpio.h"
struct gpio_instance gpio_inst;
#endif

struct uart_instance uart_core_uart;
struct i3c_master_instance i3cm;
struct i3c_dev_info i3c_devinfo;

// 新增：宣告 I3C Target 的 Instance
struct i3c_target_handle_t i3cs;

const uint8_t wr_buf[DATA_LENGTH] = {0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
                   0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17, 0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F};
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

// Simple blocking delay
static void simple_delay_ms(uint32_t ms) {
	for (volatile uint32_t i = 0; i < (ms * 10000); i++);
}

static void set_led_all_off() {
#ifdef GPIO_INST_BASE_ADDR
    for (int i = 0; i < GPIO_INST_LINES_NUM; i++) {
        gpio_output_write(&gpio_inst, i, 0xFF);
    }
#endif
}

static void set_led_on(uint8_t id) {
#ifdef GPIO_INST_BASE_ADDR
    gpio_output_write(&gpio_inst, id, 0x00);
#endif
}

static void bsp_init(void)
{
#ifdef GPIO_INST_BASE_ADDR
	gpio_inst.instance_name = GPIO_INST_NAME;
	gpio_init(&gpio_inst, GPIO_INST_BASE_ADDR, GPIO_INST_LINES_NUM, GPIO_INST_GPIO_DIRS);
    set_led_all_off();
#endif

	unsigned char uart_status = uart_init(&uart_core_uart, UART0_INST_BASE_ADDR, UART0_INST_SYS_CLK, UART0_INST_BAUD_RATE, 1, 8);
	
	if (uart_status != 0) {
#ifdef GPIO_INST_BASE_ADDR
		set_led_on(7); // Error state
#endif
		while(1); 
	}

	iob_init(lscc_uart_putc, lscc_uart_getc, lscc_uart_flush);
}

int main(void) {
	bsp_init();

	printf("Started! Running 3-second LED breathing effect...\n");

	// Step 1: 3 Seconds "Breathing" (or sweeping) LED startup
	uint32_t sweep_time_ms = 0;
	uint8_t sweep_idx = 0;
//	while (sweep_time_ms < 3000) {
//        set_led_on(sweep_idx);
//		simple_delay_ms(100);
//		set_led_all_off();
		
//		sweep_idx++;
//		if (sweep_idx >= 8) {
//			sweep_idx = 0;
//		}
//		sweep_time_ms += 100;
//	}

	// Step 2: Initialize I3C Master and Auto-Tune Timing Parameters
	printf("Starting I3C Master Configuration...\n");

	if (i3c_master_init(&i3cm, I3C_M_INST_BASE_ADDR, 0, I3C_M_INST_GUI_I2C_SCL_PULSE_WIDTH - 1, 1) != 0) {
		printf("I3C master base initialization FAILED! Cannot proceed.\n");
		set_led_all_off();
		set_led_on(7); // LED 7 恆亮代表硬體 IP Init 初始化發生錯誤
        while(1);
	} 
	
    printf("I3C Master init OK.\n");

    // ==========================================
    // 新增：初始化並啟用 I3C Target (Slave)
    // 這是單板 Loopback 測試必須的，Target IP 需要被 CPU 喚醒
    // ==========================================
    printf("Starting I3C Target Configuration...\n");
    
    // 設定 Target IP 的 Base Address (使用系統產生的 sys_platform.h 裡的定義)
    i3cs.base_addr = I3C_S_INST_BASE_ADDR;
    
    // 呼叫驅動程式裡的初始化函式
    if (i3c_target_init(&i3cs) != SUCCESS) {
        printf("I3C Target initialization FAILED! Cannot proceed.\n");
        set_led_all_off();
        set_led_on(6); // 亮第 6 顆燈表示 Target 初始化失敗
        while(1);
    }
    
    printf("I3C Target init OK. STARTING DAA TEST...\n");
    // ==========================================
    
    // We will test timing parameters. For simplicity, let's test a stable safe value 
    uint8_t clk_val = 15; // Slower clock for better stability
    uint8_t od_val = 15;  // Max OD timer for stability

    // Apply safe timing parameters once
    uint8_t ctrl_val = 0;
    reg_8b_read(i3cm.base_addr | 0x04, &ctrl_val);
    reg_8b_write(i3cm.base_addr | 0x04, ctrl_val & ~0x01); // Disable
    reg_8b_write(i3cm.base_addr | 0x00, clk_val); 
    reg_8b_write(i3cm.base_addr | 0x1A, od_val);
    reg_8b_write(i3cm.base_addr | 0x04, ctrl_val | 0x01); // Enable

    // Process DAA
    i3c_devinfo.pid = 0;
    uint8_t dyn_address = 0;
    
    // Block until DAA is successful.
    uint8_t daa_toggle = 0;
    while(1) {
        if (daa_toggle) {
            set_led_on(1); // 燈號 1 閃爍代表正在不間斷發送 DAA 尋找 Target
        } else {
            set_led_all_off();
        }
        daa_toggle = !daa_toggle;

        uint8_t ret = i3c_master_daa(&i3cm, &i3c_devinfo, &dyn_address, I3C_SLAVE_NUMS, SLAVE_ADDR);
        if (ret == 0) {
            printf("\n>> SUCCESS! I3C Slave Found and Assigned!\n");
            break;
        }
        printf(".");
        reg_8b_write(i3cm.base_addr | 0x0C, 0x01);
        simple_delay_ms(5);
        reg_8b_write(i3cm.base_addr | 0x0C, 0x00);
    }
    
    // DAA -> Write Indicator: LED 0 Constants ON
    set_led_all_off();
    set_led_on(0);

    // Step 3: Write and Read process
    printf("STARTING I3C TESTS: Private Write ...\n");
    printf("Writing data from I3C controller to the target\n");
    i3c_master_private_i3c_write(&i3cm, (uint8_t *) wr_buf, DATA_LENGTH, SLAVE_ADDR);
    
    simple_delay_ms(100); // Give slave a little time to process

    printf("STARTING I3C TESTS: Private Read ...\n");
    i3c_master_private_i3c_read(&i3cm, (uint8_t *) rd_buf, DATA_LENGTH-2, SLAVE_ADDR);
    
    bool data_match = true;
    for (int i = 0; i < DATA_LENGTH-2; i++) {
        printf("Read back data from I3C slave at count %d: %x\n", i, rd_buf[i]);

        if (rd_buf[i] != wr_buf[i]) {
            printf("Data mismatch %x != %x\n", rd_buf[i], wr_buf[i]);
            data_match = false;
        }
    }

    i3c_master_private_i3c_read(&i3cm, (uint8_t *) rd_buf, 2, SLAVE_ADDR);
    printf("Read back data from I3C target: %x\n", rd_buf[0]);
    printf("Read back data from I3C target: %x\n", rd_buf[1]);
    
    if (data_match) {
        printf("All Data Matches Write!\n");
        
        printf("TEST FINISHED\n");

        // Success Loop: Provide the original "Breathing/Sweeping" effect indefinitely
        set_led_all_off();
        sweep_idx = 0;
        while(1) {
            set_led_on(sweep_idx);
            simple_delay_ms(100); 
            set_led_all_off();
            
            sweep_idx++;
            if (sweep_idx >= 8) {
                sweep_idx = 0;
            }
        }
    } else {
        printf("Data mismatch error!\n");
        // Error Loop: Blink LED 6 continuously if data verfication failed
        while(1) {
            set_led_all_off();
            set_led_on(6);
            simple_delay_ms(500); 
            set_led_all_off();
            simple_delay_ms(500); 
        }
    }
    
	return 0;
}
