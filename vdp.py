import argparse

def extract_23bit_address(byte0, byte1, byte2):
    # Ensure inputs are bytes (0-255)
    byte0 &= 0xFF
    byte1 &= 0xFF
    byte2 &= 0xFF

    address = byte2 << 16 | byte1 << 8 | byte0
    address <<= 1
    
    return address

def vdp_reg_print(reg_num, value, ext_vram, w320_mode):
    # Register write

    print(f"→ Write to register ${reg_num:02X} with value ${value:02X}")
    match reg_num:
        case 0x80:
            print("  - Set Mode Register 1:")
            print(f"  - 8 pix Blank: {'on' if value & 0x20 else 'off'}")
            print(f"  - Enable H-int: {'on' if value & 0x10 else 'off'}")
            print(f"  - Freeze H/V counter on level 2 int: {'on' if value & 0x02 else 'off'}")
            print(f"  - Disable Display: {'on' if value & 0x01 else 'off'}")
        case 0x81:
            print(f"  - Set Mode Register 2:")
            print(f"  - Use 128 kB if VRAM: {'on' if value & 0x80 else 'off'}")
            print(f"  - Display: {'on' if value & 0x40 else 'off'}")
            print(f"  - V-int: {'on' if value & 0x20 else 'off'}")
            print(f"  - DMA Enabled: {'on' if value & 0x10 else 'off'}")
            print(f"  - PAL or NTSC Mode: {'PAL' if value & 0x08 else 'NTSC'}")
            print(f"  - Mega Drive or Master System Display: {'MD' if value & 0x04 else 'MS'}")
        case 0x82:
            if ext_vram:
                print(f"  - Set Plane A nametable address to: ${((value & 0x78) >> 3) << 10:05X}")
            else:
                print(f"  - Set Plane A nametable address to: ${((value & 0x38) >> 3) << 10:05X}")
        case 0x83:
            print(f"  - Set Window nametable address to: ${(value & 0x3F) << 10:05X}")
        case 0x84:
            print(f"  - Set Plane B nametable address to: ${(value & 0x0F) << 13:05X}")
        case 0x85:
            print(f"  - Set Sprite Table base address to: ${(value & 0x7F) << 9:05X}")
        #case 0x86:
        #    print(f"Bit 16 of Sprite Table address in 128kb VRAM: {v & 0x20}")
        case 0x87:
            print(f"Set Background Color: ")
            print(f"  - Color: {value & 0xF}")
            print(f"  - Palette Line: {(value & 0x30) >> 4}")
        case 0x8A:
            print(f"  - Number of scanlines between horizontal interupts: {value}")
        case 0x8B:
            h_scroll_modes = ['full screen', 'invalid', '8 pixel rows', '1 pixel row']
            print(f"  - Mode Register 3:")
            print(f"  - Enable External Interupts: {'on' if value & 0x04 else 'off'}")
            print(f"  - Vertical Scrolling Mode: {'16 pixel columns' if value & 0x02 else 'Full screen'}")
            print(f"  - Horizontal Scrolling Mode: {h_scroll_modes[value & 0x3]}")
        case 0x8C:
            interlace_modes = ['no interlace',
                               'interlace normal resolution',
                               'no interlace',
                               'interlace double resolution']
            print(f"  - Mode Register 4:")
            print(f"  - 320 or 256 width mode: {'320' if value & 0x1 else '256'}")
            print(f"  - Interlace Mode: {interlace_modes[(value & 0x6) >> 1]}")
            print(f"  - Shadow/Highlight Mode: {'on' if value & 0x8 else 'off'}")
            print(f"  - Enable Ext Pixel Bus: {'on' if value & 0x10 else 'off'}")
            print(f"  - HS: {'HS' if value & 0x20 else ''}")
            print(f"  - VS: {'VS' if value & 0x40 else ''}")
        case 0x8D:
            print(f"  - Set H-scroll table base address to: ${(value & 0x3F) << 10:05X}")
        #case 0x8E:
        #    print(f"")
        case 0x8F:
            print(f"  - Set auto-increment value to: {value}")
        case 0x90:
            h_size = (value & 0x30) >> 4
            w_size = value & 0x3
            plane_sizes = ['256 pixels(32 cells)', '512 pixels(64 cells)', 'invalid', '1024 pixels(128 cells)']
            print(f"Plane Size: ")
            print(f"  - Height Setting: {plane_sizes[h_size]}")
            print(f"  - Width Setting: {plane_sizes[w_size]}")
        case 0x91:
            print(f"Window Plane Horizontal Pos: ")
            print(f"  - Edge to start from: {'right' if value & 0x80 else 'left'}")
            print(f"  - HPos on screen to start(in units of 8 pixels): {value & 0x0F}")
        case 0x92:
            print(f"Window Plane Vertical Pos: ")
            print(f"  - Edge to start from: {'bottom' if value & 0x80 else 'top'}")
            print(f"  - VPos on screen to start(in units of 8 pixels): {value & 0x0F}")
        case 0x93:
            print(f"  - Set DMA length low byte to: ${value:02X}")
        case 0x94:
            print(f"  - Set DMA length high byte to: ${value:02X}")
        case 0x95:
            print(f"  - Set DMA source address low byte to: ${value:02X}")
        case 0x96:
            print(f"  - Set DMA source address mid byte to: ${value:02X}")
        case 0x97:
            dma_types = ['68K to VRAM', '68K to VRAM', 'VRAM fill', 'VRAM to VRAM']
            print(f"  - Set DMA source address high byte to: ${value & 0x7F:02X}")
            print(f"  - DMA type: {dma_types[(value & 0xC0) >> 6]}")
        case _:
            print("Unknown or undocumented register")    

def convert_hex_string(string):
    if isinstance(string, str):
        if string.startswith("$"):
            string = string[1:]
        elif string.startswith("0x"):
            string = string[2:]
        string_length = len(string)
        string = int(string, 16)    
    return string, string_length

def decode_vdp_command(command, ext_vram=False, w320_mode=False):
    command, string_length = convert_hex_string(command)
    #print(string_length)
    print(f"VDP Command: 0x{command:08X}" if command > 0xFFFF else f"VDP Command: 0x{command:04X}")

    if string_length == 4:
        reg_num = (command & 0xFF00) >> 8
        value   = command & 0x00FF
        vdp_reg_print(reg_num, value, ext_vram, w320_mode)
    else:
        # Full 32-bit control word
        high_word = command >> 16
        low_word = command & 0xFFFF
        
        if ((high_word & 0xE000) >> 13) == 0b100:
            reg_num_h = (high_word & 0xFF00) >> 8
            value_h   = high_word & 0x00FF
            reg_num_l = (low_word & 0xFF00) >> 8
            value_l   = low_word & 0x00FF
            
            vdp_reg_print(reg_num_h, value_h, ext_vram, w320_mode)
            vdp_reg_print(reg_num_l, value_l, ext_vram, w320_mode)
            
            if reg_num_h == 0x93 and reg_num_l == 0x94:
                dma_len = value_h << 8 | value_l
                print(f"Set DMA length to: ${dma_len:04X} (${dma_len << 1:05X} / {dma_len << 1} bytes)")
            elif reg_num_l == 0x93 and reg_num_h == 0x94:
                dma_len = value_l << 8 | value_h
                print(f"Set DMA length to: ${dma_len:04X} (${dma_len << 1:05X} / {dma_len << 1} bytes)")
        else:
            CD0 = (high_word >> 14) & 1  # bit 30 = bit 14 of upper word
            CD1 = (high_word >> 15) & 1  # bit 31 = bit 15 of upper word
            CD2 = (low_word >> 4) & 1
            CD3 = (low_word >> 5) & 1
            
            type_bits = (CD3 << 3) | (CD2 << 2) | (CD1 << 1) | CD0

            is_read = (high_word >> 13) & 1
            dma_enabled = low_word & 0x80
            vram_copy = low_word & 0x40
            
            A15_A14 = low_word & 0x3
            addr = (A15_A14 << 14) |  (high_word & 0x3FFF) # 16-bit address
            
            port_lookup = {
                0b0000: "VRAM_READ",
                0b1100: "VRAM_BYTE_READ",
                0b1101: "VRAM_BYTE_READ",
                0b0001: "VRAM_WRITE",
                0b1000: "CRAM_READ",
                0b0011: "CRAM_WRITE",
                0b0100: "VSRAM_READ",
                0b0101: "VSRAM_WRITE"
            }

            target = port_lookup.get(type_bits, "Unknown")

            print(f"→ Operation {target} at address ${addr:04X}")
            print(f"  - DMA Enabled: {'on' if dma_enabled else 'off'}")
            print(f"  - VRAM to VRAM Copy: {'on' if vram_copy else 'off'}")
            print(f"  - Address: ${addr:05X}")
            
def main():
    parser = argparse.ArgumentParser(
        description="Decode a Sega Genesis VDP command (16-bit or 32-bit hex)."
    )
    parser.add_argument(
        "commands",
        metavar="CMD",
        type=str,
        nargs="+",
        help="VDP command in hex (e.g., 0x8F02 or 0xC0000000)"
    )
    
    parser.add_argument(
        "--dma",
        metavar="23BIT ADDRESS",
        type=str,
        nargs=3,
        help="DMA address bytes in the order: low, mid, high"
    )
    
    args = parser.parse_args()

    for cmd in args.commands:
        print("=" * 40)
        try:
            decode_vdp_command(cmd)
        except Exception as e:
            print(f"Error decoding {cmd}: {e}")
    print("=" * 40)
    if args.dma:
        low_byte = convert_hex_string(args.dma[0])
        mid_byte = convert_hex_string(args.dma[1])
        high_byte = convert_hex_string(args.dma[2])
        dma_address = extract_23bit_address(low_byte, mid_byte, high_byte)
        print(f"DMA Source Address: ${dma_address:04X}")
        print("=" * 40)

if __name__ == "__main__":
    main()
