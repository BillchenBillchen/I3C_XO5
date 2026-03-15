
#include "i3c_target.h"
#include "uart.h"
#include "utils.h"
#include <stdio.h>

#define DATA_LENGTH 32
#define I3C_TARGET_BASE_ADDR U_I3C_S0_BASE_ADDR  // Replace with actual base address

struct uart_instance uart_core_uart;
struct i3c_target_handle_t i3c_target;

uint8_t wr_buf[DATA_LENGTH] = {
    0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07,
    0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F,
    0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x16, 0x17,
    0x18, 0x19, 0x1A, 0x1B, 0x1C, 0x1D, 0x1E, 0x1F
};
uint8_t rd_buf[DATA_LENGTH];

int main(void) {
    uint8_t ret = 0;
    int i;

    uart_init(&uart_core_uart, UART0_INST_BASE_ADDR, UART0_INST_SYS_CLK, UART0_INST_BAUD_RATE, 1, 8);

#ifdef LSCC_STDIO_UART_APB
    extern struct uart_instance *g_stdio_uart;
    g_stdio_uart = &uart_core_uart;
#endif

    // Step 1: Initialize I3C Target
    i3c_target.base_addr = I3C_TARGET_BASE_ADDR;
    printf("Initializing I3C Target...\n");
    ret = i3c_target_init(&i3c_target);
    if (ret != SUCCESS) {
        printf("I3C Target initialization failed!\n");
        return -1;
    }
    printf("I3C Target initialization successful.\n");

    // Step 2: I2C Write (Controller writes → Target stores in rd_buf)
    printf("Starting I2C Write (store to rd_buf)...\n");
    i3c_target.buf = rd_buf;      // Target stores incoming data
    i3c_target.len = DATA_LENGTH;
    ret = i2c_target_read(&i3c_target);  // Target reads data from controller
    if (ret != SUCCESS) {
        printf("I2C Write failed!\n");
        return -1;
    }
    printf("Data received from Controller via I2C:\n");
    for (i = 0; i < DATA_LENGTH; i++) {
        printf("rd_buf[%d] = 0x%02X\n", i, rd_buf[i]);
    }

    // Step 3: I2C Read (Controller reads → Target sends wr_buf)
    printf("Starting I2C Read (send wr_buf)...\n");
    i3c_target.buf = wr_buf;      // Target sends data to controller
    i3c_target.len = DATA_LENGTH;
    ret = i2c_target_write(&i3c_target); // Target writes data to controller
    if (ret != SUCCESS) {
        printf("I2C Read failed!\n");
        return -1;
    }
    printf("I2C Read successful.\n");

    // Step 4: Wait for Dynamic Address Assignment
    printf("Waiting for Dynamic Address Assignment...\n");
    ret = i3c_target_daa_wait(&i3c_target);
    if (ret != SUCCESS) {
        printf("DAA wait failed!\n");
        return -1;
    }
    printf("Dynamic Address Assigned.\n");

    // Step 5: Private Write (Controller writes → Target stores in rd_buf)
    printf("Starting Private Write (store to rd_buf)...\n");
    i3c_target.buf = rd_buf;
    i3c_target.len = DATA_LENGTH;
    ret = i3c_target_private_read(&i3c_target);
    if (ret != SUCCESS) {
        printf("Private Write failed!\n");
        return -1;
    }
    printf("Data received from Controller via I3C:\n");
    for (i = 0; i < DATA_LENGTH; i++) {
        printf("rd_buf[%d] = 0x%02X\n", i, rd_buf[i]);
    }

    // Step 6: Private Read (Controller reads → Target sends wr_buf)
    printf("Starting Private Read (send wr_buf)...\n");
    i3c_target.buf = wr_buf;
    i3c_target.len = DATA_LENGTH;
    ret = i3c_target_private_write(&i3c_target);
    if (ret != SUCCESS) {
        printf("Private Read failed!\n");
        return -1;
    }
    printf("Data sent to Controller from wr_buf.\n");

    printf("I3C Target Test Finished.\n");
    return 0;
}
