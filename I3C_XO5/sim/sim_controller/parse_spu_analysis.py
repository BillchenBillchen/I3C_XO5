#!/usr/bin/env python3
"""Detailed analysis of sda_spu behavior during RSTDAA (7980ns~13180ns) and ENTDAA (14460ns~20500ns)."""

SIG_MAP = {
    '!': 'scl_i', '"': 'sda_i', '#': 'scl_oe',
    '$': 'sda_oe', '%': 'scl_o', '&': 'sda_o', "'": 'sda_spu',
}

T_START = 7000000
T_END   = 135000000

def parse_vcd(filename):
    events = []
    current_time = 0
    in_defs = True
    state = {name: 'x' for name in SIG_MAP.values()}
    initial_captured = False
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if not line: continue
            if in_defs:
                if line == '$enddefinitions $end': in_defs = False
                continue
            if line.startswith('#'):
                new_time = int(line[1:])
                if not initial_captured and new_time >= T_START:
                    initial_captured = True
                    events.append(('INITIAL_STATE', current_time, dict(state)))
                current_time = new_time
                if current_time > T_END: break
                continue
            if len(line) >= 2 and line[-1] in SIG_MAP:
                val = line[0]
                sig_id = line[-1]
                sig_name = SIG_MAP[sig_id]
                state[sig_name] = val
                if T_START <= current_time <= T_END:
                    events.append(('CHANGE', current_time, sig_name, val))
    return events

def analyze_spu_detail(events):
    state = {}
    
    # Track sda_spu transitions
    spu_transitions = []
    # Track open-drain vs push-pull phases
    phases = []
    
    print("="*100)
    print("sda_spu Transition Analysis")
    print("="*100)
    
    for ev in events:
        if ev[0] == 'INITIAL_STATE':
            state = ev[2].copy()
            continue
        _, t, sig, val = ev
        old_val = state.get(sig, 'x')
        state[sig] = val
        t_ns = t / 1000
        
        if sig == 'sda_spu':
            direction = "↑ HIGH" if val == '1' else "↓ LOW"
            sda_oe_val = state.get('sda_oe', '?')
            scl_oe_val = state.get('scl_oe', '?')
            scl_i_val = state.get('scl_i', '?')
            sda_i_val = state.get('sda_i', '?')
            sda_o_val = state.get('sda_o', '?')
            print(f"  {t_ns:10.1f}ns: sda_spu {direction}  "
                  f"[sda_oe={sda_oe_val} sda_o={sda_o_val} sda_i={sda_i_val} "
                  f"scl_oe={scl_oe_val} scl_i={scl_i_val}]")
            spu_transitions.append((t_ns, val, dict(state)))
    
    # Now analyze the relationship between sda_spu and bus mode
    print("\n" + "="*100)
    print("Open-Drain vs Push-Pull Phase Analysis")
    print("="*100)
    
    # Reset state
    state = {}
    scl_period_samples = []
    last_scl_rise = None
    last_scl_fall = None
    
    bit_count = 0
    current_byte_bits = []
    
    # Detect SCL frequency changes to identify OD vs PP mode
    scl_rises = []
    for ev in events:
        if ev[0] == 'INITIAL_STATE':
            state = ev[2].copy()
            continue
        _, t, sig, val = ev
        state[sig] = val
        t_ns = t / 1000
        
        if sig == 'scl_i' and val == '1':
            scl_rises.append(t_ns)
    
    print("\nSCL Period Analysis (time between rising edges):")
    print(f"{'From (ns)':>12} → {'To (ns)':>12}  Period = {'ns':>8}  {'Mode':>15}")
    print("-" * 65)
    for i in range(1, len(scl_rises)):
        period = scl_rises[i] - scl_rises[i-1]
        if scl_rises[i] <= 140000:  # Limit output
            mode = "Open-Drain (OD)" if period > 200 else "Push-Pull (PP)"
            print(f"  {scl_rises[i-1]:10.1f} → {scl_rises[i]:10.1f}  Period = {period:8.1f}  {mode}")

    # Correlate sda_spu with bus mode
    print("\n" + "="*100)
    print("Key Observation: sda_spu correlation with Open-Drain/Push-Pull transition")
    print("="*100)
    
    # Find where mode switches from OD to PP
    for i in range(1, len(scl_rises)):
        period = scl_rises[i] - scl_rises[i-1]
        if i > 1:
            prev_period = scl_rises[i-1] - scl_rises[i-2]
            if prev_period > 200 and period < 200:
                print(f"\n  *** OD→PP transition at ~{scl_rises[i]:.1f}ns ***")
                print(f"      Previous period: {prev_period:.1f}ns (Open-Drain)")
                print(f"      Current period:  {period:.1f}ns (Push-Pull)")
                # Find nearest sda_spu transition
                for t_spu, val_spu, st in spu_transitions:
                    if abs(t_spu - scl_rises[i]) < 500:
                        print(f"      Nearest sda_spu transition: {t_spu:.1f}ns → {val_spu}")
            elif prev_period < 200 and period > 200:
                print(f"\n  *** PP→OD transition at ~{scl_rises[i]:.1f}ns ***")
                print(f"      Previous period: {prev_period:.1f}ns (Push-Pull)")
                print(f"      Current period:  {period:.1f}ns (Open-Drain)")

def main():
    vcd_file = r"c:\Users\billzhang\Desktop\I3C_XO5\I3C_XO5\sim\sim_controller\i3c_controller.vcd"
    print("Parsing VCD for sda_spu analysis...")
    events = parse_vcd(vcd_file)
    analyze_spu_detail(events)

if __name__ == '__main__':
    main()
