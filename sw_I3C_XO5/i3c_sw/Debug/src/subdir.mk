################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/main.c \
../src/terminal.c \
../src/utils.c 

OBJS += \
./src/main.o \
./src/terminal.o \
./src/utils.o 

C_DEPS += \
./src/main.d \
./src/terminal.d \
./src/utils.d 


# Each subdirectory must supply rules for building sources it contributes
src/%.o: ../src/%.c src/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-none-embed-gcc -march=rv32imc -mabi=ilp32 -msmall-data-limit=8 -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -Wframe-larger-than=2560  -g3 -DLSCC_STDIO_UART_APB -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src" -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src/bsp" -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src/bsp/driver" -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src/bsp/driver/gpio" -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src/bsp/driver/i3c_controller" -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src/bsp/driver/i3c_target" -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src/bsp/driver/riscv_mc" -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src/bsp/driver/uart" -std=gnu11 --specs=picolibc.specs -DPICOLIBC_INTEGER_PRINTF_SCANF -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


