################################################################################
# Automatically-generated file. Do not edit!
################################################################################

# Add inputs and outputs from these tool invocations to the build variables 
C_SRCS += \
../src/bsp/driver/riscv_mc/cache.c \
../src/bsp/driver/riscv_mc/exit.c \
../src/bsp/driver/riscv_mc/interrupt.c \
../src/bsp/driver/riscv_mc/iob.c \
../src/bsp/driver/riscv_mc/pic.c \
../src/bsp/driver/riscv_mc/reg_access.c \
../src/bsp/driver/riscv_mc/timer.c \
../src/bsp/driver/riscv_mc/util.c 

S_UPPER_SRCS += \
../src/bsp/driver/riscv_mc/crt0.S 

OBJS += \
./src/bsp/driver/riscv_mc/cache.o \
./src/bsp/driver/riscv_mc/crt0.o \
./src/bsp/driver/riscv_mc/exit.o \
./src/bsp/driver/riscv_mc/interrupt.o \
./src/bsp/driver/riscv_mc/iob.o \
./src/bsp/driver/riscv_mc/pic.o \
./src/bsp/driver/riscv_mc/reg_access.o \
./src/bsp/driver/riscv_mc/timer.o \
./src/bsp/driver/riscv_mc/util.o 

S_UPPER_DEPS += \
./src/bsp/driver/riscv_mc/crt0.d 

C_DEPS += \
./src/bsp/driver/riscv_mc/cache.d \
./src/bsp/driver/riscv_mc/exit.d \
./src/bsp/driver/riscv_mc/interrupt.d \
./src/bsp/driver/riscv_mc/iob.d \
./src/bsp/driver/riscv_mc/pic.d \
./src/bsp/driver/riscv_mc/reg_access.d \
./src/bsp/driver/riscv_mc/timer.d \
./src/bsp/driver/riscv_mc/util.d 


# Each subdirectory must supply rules for building sources it contributes
src/bsp/driver/riscv_mc/%.o: ../src/bsp/driver/riscv_mc/%.c src/bsp/driver/riscv_mc/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross C Compiler'
	riscv-none-embed-gcc -march=rv32imc -mabi=ilp32 -msmall-data-limit=8 -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -Wframe-larger-than=2560  -g3 -DLSCC_STDIO_UART_APB -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src" -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src/bsp" -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src/bsp/driver" -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src/bsp/driver/gpio" -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src/bsp/driver/i3c_controller" -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src/bsp/driver/i3c_target" -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src/bsp/driver/riscv_mc" -I"C:\Users\billzhang\Desktop\I3C_XO5\sw_I3C_XO5\i3c_sw/src/bsp/driver/uart" -std=gnu11 --specs=picolibc.specs -DPICOLIBC_INTEGER_PRINTF_SCANF -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '

src/bsp/driver/riscv_mc/%.o: ../src/bsp/driver/riscv_mc/%.S src/bsp/driver/riscv_mc/subdir.mk
	@echo 'Building file: $<'
	@echo 'Invoking: GNU RISC-V Cross Assembler'
	riscv-none-embed-gcc -march=rv32imc -mabi=ilp32 -msmall-data-limit=8 -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -Wframe-larger-than=2560  -g3 -x assembler-with-cpp -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -c -o "$@" "$<"
	@echo 'Finished building: $<'
	@echo ' '


