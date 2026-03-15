################################################################################
# Automatically-generated file. Do not edit!
################################################################################

-include ../makefile.init

RM := rm -rf

# All of the sources participating in the build are defined here
-include sources.mk
-include src/bsp/driver/uart/subdir.mk
-include src/bsp/driver/riscv_mc/subdir.mk
-include src/bsp/driver/i3c_target/subdir.mk
-include src/bsp/driver/i3c_controller/subdir.mk
-include src/bsp/driver/gpio/subdir.mk
-include src/subdir.mk
-include subdir.mk
-include objects.mk

ifneq ($(MAKECMDGOALS),clean)
ifneq ($(strip $(ASM_DEPS)),)
-include $(ASM_DEPS)
endif
ifneq ($(strip $(S_UPPER_DEPS)),)
-include $(S_UPPER_DEPS)
endif
ifneq ($(strip $(C_DEPS)),)
-include $(C_DEPS)
endif
endif

-include ../makefile.defs

OPTIONAL_TOOL_DEPS := \
$(wildcard ../makefile.defs) \
$(wildcard ../makefile.init) \
$(wildcard ../makefile.targets) \


BUILD_ARTIFACT_NAME := gpi_i3c_led
BUILD_ARTIFACT_EXTENSION := elf
BUILD_ARTIFACT_PREFIX :=
BUILD_ARTIFACT := $(BUILD_ARTIFACT_PREFIX)$(BUILD_ARTIFACT_NAME)$(if $(BUILD_ARTIFACT_EXTENSION),.$(BUILD_ARTIFACT_EXTENSION),)

# Add inputs and outputs from these tool invocations to the build variables 
SECONDARY_LIST += \
gpi_i3c_led.lst \

SECONDARY_SIZE += \
gpi_i3c_led.siz \

SECONDARY_MEMORY += \
gpi_i3c_led.mem \


# All Target
all: main-build

# Main-build Target
main-build: gpi_i3c_led.elf secondary-outputs

# Tool invocations
gpi_i3c_led.elf: $(OBJS) $(USER_OBJS) makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Building target: $@'
	@echo 'Invoking: GNU RISC-V Cross C Linker'
	riscv-none-embed-gcc -march=rv32imc -mabi=ilp32 -msmall-data-limit=8 -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -Wframe-larger-than=2560  -g3 -T "C:/Users/billzhang/Desktop/I3C_XO5/sw_I3C_XO5/gpi_i3c_led/src/linker.ld" -nostartfiles -Xlinker --gc-sections -Wl,-Map,"gpi_i3c_led.map" -Xlinker --print-map --specs=picolibc.specs -DPICOLIBC_INTEGER_PRINTF_SCANF -o "gpi_i3c_led.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

gpi_i3c_led.lst: gpi_i3c_led.elf makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Invoking: GNU RISC-V Cross Create Listing'
	riscv-none-embed-objdump --source --all-headers --demangle --line-numbers --wide "gpi_i3c_led.elf" > "gpi_i3c_led.lst"
	@echo 'Finished building: $@'
	@echo ' '

gpi_i3c_led.siz: gpi_i3c_led.elf makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Invoking: GNU RISC-V Cross Print Size'
	riscv-none-embed-size --format=berkeley "gpi_i3c_led.elf"
	@echo 'Finished building: $@'
	@echo ' '

gpi_i3c_led.mem: gpi_i3c_led.elf makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Invoking: Lattice Create Memory Deployment'
	riscv-none-embed-objcopy -O binary --gap-fill 0 "gpi_i3c_led.elf" "gpi_i3c_led.bin"; srec_cat "gpi_i3c_led.bin" -Binary -byte-swap 4 -DISable Header -Output "gpi_i3c_led.mem" -MEM 32
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(SECONDARY_MEMORY)$(OBJS)$(SECONDARY_LIST)$(SECONDARY_SIZE)$(ASM_DEPS)$(S_UPPER_DEPS)$(C_DEPS) gpi_i3c_led.elf
	-@echo ' '

secondary-outputs: $(SECONDARY_LIST) $(SECONDARY_SIZE) $(SECONDARY_MEMORY)

.PHONY: all clean dependents main-build

-include ../makefile.targets
