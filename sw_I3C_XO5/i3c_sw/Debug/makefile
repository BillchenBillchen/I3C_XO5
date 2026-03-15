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


BUILD_ARTIFACT_NAME := i3c_sw
BUILD_ARTIFACT_EXTENSION := elf
BUILD_ARTIFACT_PREFIX :=
BUILD_ARTIFACT := $(BUILD_ARTIFACT_PREFIX)$(BUILD_ARTIFACT_NAME)$(if $(BUILD_ARTIFACT_EXTENSION),.$(BUILD_ARTIFACT_EXTENSION),)

# Add inputs and outputs from these tool invocations to the build variables 
SECONDARY_LIST += \
i3c_sw.lst \

SECONDARY_SIZE += \
i3c_sw.siz \

SECONDARY_MEMORY += \
i3c_sw.mem \


# All Target
all: main-build

# Main-build Target
main-build: i3c_sw.elf secondary-outputs

# Tool invocations
i3c_sw.elf: $(OBJS) $(USER_OBJS) makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Building target: $@'
	@echo 'Invoking: GNU RISC-V Cross C Linker'
	riscv-none-embed-gcc -march=rv32imc -mabi=ilp32 -msmall-data-limit=8 -mno-save-restore -O0 -fmessage-length=0 -fsigned-char -ffunction-sections -fdata-sections -Wframe-larger-than=2560  -g3 -T "C:/Users/billzhang/Desktop/I3C_XO5/sw_I3C_XO5/i3c_sw/src/linker.ld" -nostartfiles -Xlinker --gc-sections -Wl,-Map,"i3c_sw.map" --specs=picolibc.specs -DPICOLIBC_INTEGER_PRINTF_SCANF -o "i3c_sw.elf" $(OBJS) $(USER_OBJS) $(LIBS)
	@echo 'Finished building target: $@'
	@echo ' '

i3c_sw.lst: i3c_sw.elf makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Invoking: GNU RISC-V Cross Create Listing'
	riscv-none-embed-objdump --source --all-headers --demangle --line-numbers --wide "i3c_sw.elf" > "i3c_sw.lst"
	@echo 'Finished building: $@'
	@echo ' '

i3c_sw.siz: i3c_sw.elf makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Invoking: GNU RISC-V Cross Print Size'
	riscv-none-embed-size --format=berkeley "i3c_sw.elf"
	@echo 'Finished building: $@'
	@echo ' '

i3c_sw.mem: i3c_sw.elf makefile objects.mk $(OPTIONAL_TOOL_DEPS)
	@echo 'Invoking: Lattice Create Memory Deployment'
	riscv-none-embed-objcopy -O binary --gap-fill 0 "i3c_sw.elf" "i3c_sw.bin"; srec_cat "i3c_sw.bin" -Binary -byte-swap 4 -DISable Header -Output "i3c_sw.mem" -MEM 32
	@echo 'Finished building: $@'
	@echo ' '

# Other Targets
clean:
	-$(RM) $(SECONDARY_MEMORY)$(OBJS)$(SECONDARY_LIST)$(SECONDARY_SIZE)$(ASM_DEPS)$(S_UPPER_DEPS)$(C_DEPS) i3c_sw.elf
	-@echo ' '

secondary-outputs: $(SECONDARY_LIST) $(SECONDARY_SIZE) $(SECONDARY_MEMORY)

.PHONY: all clean dependents main-build

-include ../makefile.targets
