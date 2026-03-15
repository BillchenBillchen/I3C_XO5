#!/usr/bin/env python3
"""Parse I3C Controller VCD file and analyze DAA sequence (14200ns~20500ns)."""

import sys

# VCD signal mapping (from header)
SIG_MAP = {
    '!': 'scl_i',
    '"': 'sda_i',
    '#': 'scl_oe',
    '$': 'sda_oe',
    '%': 'scl_o',
    '&': 'sda_o',
    "'": 'sda_spu',
}

# Time range in ps (timescale = 1ps)
T_START = 14200000  # 14200 ns
T_END   = 20500000  # 20500 ns

def parse_vcd(filename):
    """Parse VCD and return list of (timestamp, signal_name, value) in range."""
    events = []
    current_time = 0
    in_defs = True
    
    # Track signal states
    state = {name: 'x' for name in SIG_MAP.values()}
    
    # Capture initial state at T_START
    initial_captured = False
    
    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            
            if in_defs:
                if line == '$enddefinitions $end':
                    in_defs = False
                continue
            
            if line.startswith('#'):
                new_time = int(line[1:])
                
                # If we just crossed into range, capture initial state
                if not initial_captured and new_time >= T_START:
                    initial_captured = True
                    events.append(('INITIAL_STATE', current_time, dict(state)))
                
                current_time = new_time
                
                if current_time > T_END:
                    break
                continue
            
            # Parse value changes
            if len(line) >= 2 and line[-1] in SIG_MAP:
                val = line[0]
                sig_id = line[-1]
                sig_name = SIG_MAP[sig_id]
                state[sig_name] = val
                
                if T_START <= current_time <= T_END:
                    events.append(('CHANGE', current_time, sig_name, val))
    
    return events

def sample_bus_at_scl_rising(events):
    """Extract SDA values at SCL rising edges to decode bits."""
    scl_prev = '1'
    sda_val = 'x'
    sda_oe_val = '0'
    sda_o_val = 'x'
    
    bits = []
    bit_times = []
    
    # Build timeline
    timeline = []
    state = {}
    
    for ev in events:
        if ev[0] == 'INITIAL_STATE':
            state = ev[2].copy()
            continue
        _, t, sig, val = ev
        state[sig] = val
        timeline.append((t, sig, val, dict(state)))
    
    # Find SCL rising edges and sample SDA
    scl_prev_val = None
    for i, (t, sig, val, st) in enumerate(timeline):
        if sig == 'scl_i':
            if scl_prev_val == '0' and val == '1':
                # SCL rising edge - sample SDA
                sda = st['sda_i']
                bits.append((t, sda))
            scl_prev_val = val
        elif sig == 'scl_o':
            pass  # scl_o drives scl_i through pull-up
    
    return bits

def decode_daa(bits):
    """Attempt to decode I3C DAA from sampled bits."""
    print("\n" + "="*80)
    print("I3C DAA Bus Decode (14200ns ~ 20500ns)")
    print("="*80)
    
    print(f"\nTotal bits sampled at SCL rising edges: {len(bits)}")
    print("\nBit-by-bit (time_ns, SDA_value):")
    print("-" * 40)
    
    for i, (t, sda) in enumerate(bits):
        t_ns = t / 1000
        print(f"  Bit {i:3d}: {t_ns:10.1f} ns  SDA = {sda}")
    
    # Try to group into bytes (8 bits + ACK/NACK)
    if len(bits) >= 9:
        print("\n" + "="*80)
        print("Byte Decode Attempt (8 data bits + ACK/NACK)")
        print("="*80)
        
        idx = 0
        byte_num = 0
        while idx + 8 < len(bits):
            byte_bits = [b[1] for b in bits[idx:idx+8]]
            ack_bit = bits[idx+8][1] if idx+8 < len(bits) else '?'
            
            byte_val = 0
            for b in byte_bits:
                byte_val = (byte_val << 1) | (1 if b == '1' else 0)
            
            t_start = bits[idx][0] / 1000
            ack_str = "ACK" if ack_bit == '0' else "NACK" if ack_bit == '1' else "?"
            
            print(f"\n  Byte {byte_num} @ {t_start:.1f}ns:")
            print(f"    Bits: {''.join(byte_bits)}")
            print(f"    Hex:  0x{byte_val:02X} (dec: {byte_val})")
            print(f"    ACK:  {ack_bit} ({ack_str})")
            
            # Interpret if it's a broadcast address
            if byte_num == 0:
                addr_7bit = byte_val >> 1
                rw = byte_val & 1
                rw_str = "Read" if rw else "Write"
                print(f"    => 7-bit Addr: 0x{addr_7bit:02X}, R/W: {rw_str}")
                if addr_7bit == 0x7E:
                    print(f"    => This is the I3C Broadcast Address (0x7E)")
                    if rw == 0:
                        print(f"    => Broadcast Write (CCC follows)")
            
            # If byte 1 after broadcast, decode CCC
            if byte_num == 1:
                ccc_map = {
                    0x06: "RSTDAA (Reset Dynamic Address Assignment)",
                    0x07: "ENTDAA (Enter Dynamic Address Assignment)",
                    0x08: "DEFSLVS (Define List of Slaves)",
                    0x09: "SETMWL (Set Max Write Length)",
                    0x0A: "SETMRL (Set Max Read Length)",
                    0x87: "ENTDAA (Enter Dynamic Address Assignment) - Direct",
                }
                ccc_name = ccc_map.get(byte_val, f"Unknown CCC (0x{byte_val:02X})")
                print(f"    => CCC Command: {ccc_name}")
            
            idx += 9
            byte_num += 1

def analyze_bus_events(events):
    """Analyze START/STOP/RESTART conditions."""
    print("\n" + "="*80)
    print("Bus Condition Detection (START / STOP / RESTART)")
    print("="*80)
    
    state = {}
    prev_state = {}
    
    conditions = []
    
    for ev in events:
        if ev[0] == 'INITIAL_STATE':
            state = ev[2].copy()
            prev_state = state.copy()
            continue
        
        _, t, sig, val = ev
        prev_state = state.copy()
        state[sig] = val
        
        t_ns = t / 1000
        
        # START condition: SDA falls while SCL is high
        if sig == 'sda_i' and val == '0' and prev_state.get('sda_i') == '1' and state.get('scl_i') == '1':
            conditions.append((t_ns, 'START'))
            print(f"  {t_ns:10.1f} ns: *** START condition detected ***")
        
        # SDA_OE drives SDA - detect START via sda_o falling while SCL high
        if sig == 'sda_o' and val == '0' and prev_state.get('sda_o') == '1' and state.get('scl_i') == '1':
            conditions.append((t_ns, 'START (via sda_o)'))
            print(f"  {t_ns:10.1f} ns: *** START condition (sda_o) ***")
        
        # STOP condition: SDA rises while SCL is high
        if sig == 'sda_i' and val == '1' and prev_state.get('sda_i') == '0' and state.get('scl_i') == '1':
            conditions.append((t_ns, 'STOP'))
            print(f"  {t_ns:10.1f} ns: *** STOP condition detected ***")
        
        if sig == 'sda_o' and val == '1' and prev_state.get('sda_o') == '0' and state.get('scl_i') == '1':
            conditions.append((t_ns, 'STOP (via sda_o)'))
            print(f"  {t_ns:10.1f} ns: *** STOP condition (sda_o) ***")
    
    return conditions

def print_full_timeline(events):
    """Print full signal change timeline."""
    print("\n" + "="*80)
    print("Complete Signal Timeline (14200ns ~ 20500ns)")
    print("="*80)
    print(f"{'Time(ns)':>12} | {'Signal':>10} | {'Value':>5} | Full State")
    print("-" * 70)
    
    state = {}
    for ev in events:
        if ev[0] == 'INITIAL_STATE':
            state = ev[2].copy()
            t_ns = ev[1] / 1000
            state_str = ' '.join(f"{k}={v}" for k, v in sorted(state.items()))
            print(f"{'INIT':>12} | {'(all)':>10} | {'':>5} | {state_str}")
            continue
        
        _, t, sig, val = ev
        state[sig] = val
        t_ns = t / 1000
        state_str = f"SCL_i={state.get('scl_i','?')} SDA_i={state.get('sda_i','?')} SCL_oe={state.get('scl_oe','?')} SDA_oe={state.get('sda_oe','?')} SCL_o={state.get('scl_o','?')} SDA_o={state.get('sda_o','?')} SDA_spu={state.get('sda_spu','?')}"
        print(f"{t_ns:12.1f} | {sig:>10} | {val:>5} | {state_str}")

def main():
    vcd_file = r"c:\Users\billzhang\Desktop\I3C_XO5\I3C_XO5\sim\sim_controller\i3c_controller.vcd"
    
    print("Parsing VCD file...")
    events = parse_vcd(vcd_file)
    print(f"Found {len(events)} events in range 14200ns~20500ns")
    
    # Print full timeline
    print_full_timeline(events)
    
    # Detect bus conditions
    conditions = analyze_bus_events(events)
    
    # Sample and decode
    bits = sample_bus_at_scl_rising(events)
    decode_daa(bits)

if __name__ == '__main__':
    main()
