# I3C Target IP Simulation Setup Plan

This plan outlines the steps to create a simulation environment for the I3C Target (Slave) IP, following the methodology used for the I3C Master IP.

## Proposed Changes

### Simulation Setup
Create a new simulation workspace for the I3C Target IP.

#### [NEW] [sim_target.f](file:///c:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/sim/sim_target/sim_target.f)
- Define library mappings (`-L work`, `-reflib pmi_work`, `-reflib ovi_lfmxo5`).
- Set SystemVerilog mode (`-sv`).
- Add include path: `sim/IPs/i3c_s/3.7.0/testbench`.
- List RTL source: `sim/IPs/i3c_s/3.7.0/rtl/i3c_s.v`.
- List Testbench sources:
    - `sim/IPs/i3c_s/3.7.0/testbench/dut_params.v`
    - `sim/IPs/i3c_s/3.7.0/testbench/tb_models.v`
    - `sim/IPs/i3c_s/3.7.0/testbench/tb_top.v`
- Set simulation options (suppress warnings, GUI mode, top module `tb_top`).
- Add initial run commands (view wave, add wave, run).

#### [NEW] [sim_target.vdo](file:///c:/Users/billzhang/Desktop/I3C_XO5/I3C_XO5/sim/sim_target/sim_target.vdo)
- Launch script to run `qrun` with `sim_target.f`.

## Verification Plan

### Automated Tests
- Run the simulation using the created `.vdo` script.
- Verify that the simulation initializes correctly (I3C Target Initialization, etc.).
- Check for "ERROR" or "FAILURE" messages in the simulation transcript.

### Manual Verification
- Open the waveform viewer and confirm that the I3C bus signals (`scl_io`, `sda_io`) are toggling.
- Confirm that the I3C Target responds to the Controller's commands (e.g., ENTDAA).
