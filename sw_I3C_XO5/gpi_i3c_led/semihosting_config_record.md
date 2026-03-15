# Lattice Propel SDK Semihosting Configuration Record

## Context
Date: 2026-03-08
Project: `gpi_i3c_led`
Goal: Route `printf` output to the Propel IDE Console instead of the physical UART TX/RX pins.

## Action Taken
The Eclipse IDE GUI for Lattice Propel locked the Linker and Compiler flags, preventing manual injection of the Picolibc semihosting parameters. 
To bypass this, direct modifications were made to the `.cproject` XML file.

### Modifications in `.cproject`:

1.  **C Compiler Flags:**
    *   **Original:** `--specs=picolibc.specs -DPICOLIBC_INTEGER_PRINTF_SCANF`
    *   **Changed to:** `--specs=semihosting.specs --oslib=semihost -DPICOLIBC_INTEGER_PRINTF_SCANF`
2.  **C Linker Flags:**
    *   **Original:** `--specs=picolibc.specs -DPICOLIBC_INTEGER_PRINTF_SCANF`
    *   **Changed to:** `--specs=semihosting.specs --oslib=semihost -DPICOLIBC_INTEGER_PRINTF_SCANF`

### How to Revert (Rollback):
If the user needs to undo these changes and return to physical UART output:
1. Open `.cproject` in a text editor (or ask Antigravity to revert).
2. Search for `--specs=semihosting.specs --oslib=semihost`.
3. Replace those instances back with `--specs=picolibc.specs`.
4. Refresh the project in Propel (F5), Clean, and Rebuild.

## IDE Settings Required
To view the output after these changes, the user must:
1. Go to **Run -> Debug Configurations**.
2. Select the active GDB OpenOCD debugging profile.
3. In the **Debugger** tab, ensure **Enable Semihosting** is checked.
