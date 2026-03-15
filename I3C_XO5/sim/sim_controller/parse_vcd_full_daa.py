#!/usr/bin/env python3
"""Parse I3C Controller VCD - Full DAA analysis with bus-level START/STOP/byte decode."""

SIG_MAP = {
    '!': 'scl_i',
    '"': 'sda_i',
    '#': 'scl_oe',
    '$': 'sda_oe',
    '%': 'scl_o',
    '&': 'sda_o',
    "'": 'sda_spu',
}

# Analyze from just before first ENTDAA trigger to DAA complete
# From qrun.log: ENTDAA starts at ~7820ns (RSTDAA trigger), 
# first ENTDAA bus activity after 14860ns trigger
# DAA completes at ~133380ns
T_START = 7000000   # 7000 ns (before RSTDAA)
T_END   = 140000000 # 140000 ns (after DAA complete)

def parse_vcd(filename):
    events = []
    current_time = 0
    in_defs = True
    state = {name: 'x' for name in SIG_MAP.values()}
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
                if not initial_captured and new_time >= T_START:
                    initial_captured = True
                    events.append(('INITIAL_STATE', current_time, dict(state)))
                current_time = new_time
                if current_time > T_END:
                    break
                continue
            if len(line) >= 2 and line[-1] in SIG_MAP:
                val = line[0]
                sig_id = line[-1]
                sig_name = SIG_MAP[sig_id]
                state[sig_name] = val
                if T_START <= current_time <= T_END:
                    events.append(('CHANGE', current_time, sig_name, val))
    return events

def analyze_full_daa(events):
    """Full bus-level decode: detect START/STOP, sample bits, decode bytes."""
    
    state = {}
    bus_transactions = []  # list of (type, time_ns, details)
    
    # Build a consolidated state timeline
    timeline = []
    for ev in events:
        if ev[0] == 'INITIAL_STATE':
            state = ev[2].copy()
            continue
        _, t, sig, val = ev
        old_state = state.copy()
        state[sig] = val
        timeline.append((t, sig, val, old_state, state.copy()))
    
    # Phase 1: Detect START/STOP conditions using sda_i and scl_i
    conditions = []
    for t, sig, val, old_st, new_st in timeline:
        t_ns = t / 1000
        # START: SDA falls while SCL high
        if sig == 'sda_i' and val == '0' and old_st.get('sda_i') == '1' and new_st.get('scl_i') == '1':
            conditions.append((t_ns, 'START'))
        # STOP: SDA rises while SCL high
        if sig == 'sda_i' and val == '1' and old_st.get('sda_i') == '0' and new_st.get('scl_i') == '1':
            conditions.append((t_ns, 'STOP'))
    
    print("="*80)
    print("Bus START/STOP Conditions (7000ns ~ 140000ns)")
    print("="*80)
    for t_ns, cond in conditions:
        print(f"  {t_ns:12.1f} ns: {cond}")
    
    # Phase 2: Segment by START/STOP and decode bytes
    # Find SCL rising edges and sample SDA_i
    scl_edges = []
    for t, sig, val, old_st, new_st in timeline:
        if sig == 'scl_i' and old_st.get('scl_i') == '0' and val == '1':
            sda_val = new_st.get('sda_i', 'x')
            scl_edges.append((t / 1000, sda_val))
    
    print(f"\nTotal SCL rising edges: {len(scl_edges)}")
    
    # Group edges between START/STOP conditions into transactions
    print("\n" + "="*80)
    print("Transaction Decode")
    print("="*80)
    
    # Build segments: each segment starts at a START and ends at STOP or next START
    segments = []
    cond_idx = 0
    edge_idx = 0
    
    for i, (t_cond, cond_type) in enumerate(conditions):
        if cond_type == 'START':
            # Find next STOP or next START
            end_t = T_END / 1000
            end_type = 'END_OF_DATA'
            for j in range(i+1, len(conditions)):
                end_t = conditions[j][0]
                end_type = conditions[j][1]
                break
            
            # Collect edges in this segment
            seg_edges = [(t, v) for t, v in scl_edges if t_cond < t < end_t]
            segments.append((t_cond, end_t, end_type, seg_edges))
    
    for seg_idx, (start_t, end_t, end_type, edges) in enumerate(segments):
        print(f"\n--- Segment {seg_idx}: START @ {start_t:.1f}ns  →  {end_type} @ {end_t:.1f}ns ---")
        print(f"    SCL rising edges in segment: {len(edges)}")
        
        if not edges:
            print("    (no data bits)")
            continue
        
        # Decode bytes (8 bits + ACK)
        byte_num = 0
        idx = 0
        while idx + 8 <= len(edges):
            byte_bits = [b[1] for b in edges[idx:idx+8]]
            byte_val = 0
            for b in byte_bits:
                byte_val = (byte_val << 1) | (1 if b == '1' else 0)
            
            ack_bit = edges[idx+8][1] if idx+8 < len(edges) else '?'
            ack_str = "ACK" if ack_bit == '0' else "NACK" if ack_bit == '1' else "?"
            
            t_byte = edges[idx][0]
            
            interpretation = ""
            if seg_idx == 0 and byte_num == 0:
                # RSTDAA broadcast header
                addr_7bit = byte_val >> 1
                rw = byte_val & 1
                rw_str = "Read" if rw else "Write"
                interpretation = f"7-bit Addr=0x{addr_7bit:02X} R/W={rw_str}"
                if addr_7bit == 0x7E:
                    interpretation += " [I3C Broadcast]"
            elif byte_num == 0:
                addr_7bit = byte_val >> 1
                rw = byte_val & 1
                rw_str = "Read" if rw else "Write"
                interpretation = f"7-bit Addr=0x{addr_7bit:02X} R/W={rw_str}"
                if addr_7bit == 0x7E:
                    interpretation += " [I3C Broadcast]"
            
            # CCC decode
            ccc_map = {
                0x06: "RSTDAA",
                0x07: "ENTDAA",
                0x08: "DEFSLVS",
                0x09: "SETMWL",
                0x29: "SETAASA",
                0x87: "ENTDAA (Direct)",
            }
            if byte_num == 1 and byte_val in ccc_map:
                interpretation = f"CCC: {ccc_map[byte_val]}"
            
            print(f"    Byte {byte_num} @ {t_byte:10.1f}ns: bits={''.join(byte_bits)} "
                  f"hex=0x{byte_val:02X} {ack_str}  {interpretation}")
            
            idx += 9
            byte_num += 1
        
        # Show remaining bits
        remaining = len(edges) - idx
        if remaining > 0:
            rem_bits = [b[1] for b in edges[idx:]]
            print(f"    Remaining {remaining} bits: {''.join(rem_bits)}")

def main():
    vcd_file = r"c:\Users\billzhang\Desktop\I3C_XO5\I3C_XO5\sim\sim_controller\i3c_controller.vcd"
    print("Parsing VCD file for full DAA analysis...")
    events = parse_vcd(vcd_file)
    print(f"Found {len(events)} events in range {T_START/1000:.0f}ns ~ {T_END/1000:.0f}ns")
    analyze_full_daa(events)

if __name__ == '__main__':
    main()
