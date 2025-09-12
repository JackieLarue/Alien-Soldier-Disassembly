from io import BufferedReader
import os

import argparse
import struct
from array import array

from sys import exc_info
from traceback import format_exception

DATA_FOLDER = '../tiles'
DEFAULT_ROM_NAME = '../Alien Soldier (J) [!].bin'
ADDRS_FILE = 'tile_headers.txt'

#class BE_BufferedReader(BufferedReader):
#    pass

def read_u8(reader : BufferedReader) -> int:
    return struct.unpack(">B", reader.read(1))[0]

def read_s8(reader : BufferedReader) -> int:
    return struct.unpack(">b", reader.read(1))[0]

def read_u16(reader : BufferedReader) -> int:
    return struct.unpack(">H", reader.read(2))[0]

def read_s16(reader : BufferedReader) -> int:
    return struct.unpack(">h", reader.read(2))[0]

def read_u32(reader : BufferedReader) -> int:
    return struct.unpack(">I", reader.read(4))[0]

def read_s32(reader : BufferedReader) -> int:
    return struct.unpack(">i", reader.read(4))[0] 

def skip_bytes(reader : BufferedReader, len : int):
    reader.seek(len, os.SEEK_CUR)

class TileLogger:
    output_raw : list
    output_rle : list
    output_ghd : list
    seen_output : set

    def __init__(self):
        self.output_raw = []
        self.output_rle = []
        self.output_ghd = []
        self.seen_output = set()

    def get_id_output(self, id: int) -> list:
        match id:
            case 0:
                return self.output_raw
            case 1:
                return self.output_ghd
            case 2:
                return self.output_rle
            case _:
                return self.output_raw

    def append_unique(self, value : int, out_id: int) -> bool:
        output = self.get_id_output(out_id)
        if value not in self.seen_output:
            self.seen_output.add(value)
            output.append(value)
            return True
        return False

    def log_unique(self, filename : str, out_id):
        addrs = self.get_id_output(out_id)

        with open(os.path.join(DATA_FOLDER, filename), 'w+') as outfile:
            outfile.writelines(f"{i:X}" + '\n' for i in addrs)
    
    def log_all(self):
        self.log_unique('tile_raw.txt', 0)
        self.log_unique('tile_ghd.txt', 1)
        self.log_unique('tile_rle.txt', 2)

def unpack_rle(reader : BufferedReader):
    addr = reader.tell()
    decomp_buffer = array('B')
    decomp_buffer_cursor = 0
    
    size = read_u16(reader)
    #print(f'Address: {addr:02X}, size: {size:02X}')

    while reader.tell() <= addr + size:
        control_byte = read_u8(reader)
        if control_byte >= 0x80:
            tmp = control_byte
            cnt = ((control_byte >> 2) & 0x1F) + 1
            tmp = (tmp << 8) & 0xFFFF
            s = read_u8(reader)
            tmp += s
            tmp = (tmp & 0x3FF) + 1
            cursor_window = decomp_buffer_cursor - tmp
            for _ in range(cnt + 1):
                s = decomp_buffer[cursor_window]
                cursor_window += 1
                decomp_buffer.append(s)
                decomp_buffer_cursor += 1
        else:
            if (control_byte & (1 << 5)) != 0:
                if (control_byte & (1 << 6)) != 0:
                    cnt = (control_byte & 0x1F) + 1
                    z = read_u8(reader)
                    for _ in range(cnt + 1):
                        decomp_buffer.append(z)
                        s = read_u8(reader)
                        decomp_buffer.append(s)
                        decomp_buffer_cursor += 2
                else:
                    cnt = (control_byte & 0x1F) + 1
                    s = read_u8(reader)
                    for _ in range(cnt + 1):
                        decomp_buffer.append(s)
                        decomp_buffer_cursor += 1
            else:
                if (control_byte & (1 << 6)) != 0:
                    cnt = (control_byte & 0x1F) + 1
                    s1 = read_u8(reader)
                    s2 = read_u8(reader)
                    for _ in range(cnt + 1):
                        decomp_buffer.append(s1)
                        decomp_buffer.append(s2)
                        decomp_buffer_cursor += 2
                else:
                    cnt = (control_byte & 0x1F)
                    for _ in range(cnt + 1):
                        s = read_u8(reader)
                        decomp_buffer.append(s)
                        decomp_buffer_cursor += 1

    with open(os.path.join(DATA_FOLDER, 'rle', 'decompressed', f'tiles_{reader.tell():02X}.bin'), 'w+b') as binary_file:
        decomp_buffer.tofile(binary_file)

# i am so sorry for all this atrocious ass code bro
def read_bits(
        num_required_bits : int, 
        num_valid_bits : int, 
        bits_to_process : int, 
        reader : BufferedReader
    ):
    mask = create_bit_mask(num_required_bits)
    output : int
    if (num_valid_bits > num_required_bits):
        output = (bits_to_process >> (16-num_required_bits)) & mask
        bits_to_process = bits_to_process << num_required_bits
        num_valid_bits -= num_required_bits
    elif (num_valid_bits == num_required_bits):
        # Extract required bits
        output = (bits_to_process >> (16 - num_required_bits)) & mask

        # Read in next word to process
        bits_to_process = read_u16(reader)
        num_valid_bits = 16
    else: # less that X bits to proccess
        # First gather remaining bits
        output = (bits_to_process >> (16 - num_required_bits)) & mask
        num_oustanding_bits = num_required_bits - num_valid_bits
        # Read in next word to process
        bits_to_process = read_u16(reader)
        num_valid_bits = 16
        # And extract the outstanding bits
        output |= (bits_to_process >> (16 - num_oustanding_bits)) & mask
        bits_to_process = bits_to_process << num_oustanding_bits
        num_valid_bits -= num_oustanding_bits
    return output, num_valid_bits, bits_to_process

def create_bit_mask(num_bits: int):
    mask = 0
    for i in range(0, num_bits):
        mask |= (1 << i)
    return mask

class ArrayStreamThing:
    buffer = array('B')
    cursor: int
    temp_cursor : int

    def __init__(self):
        #self.buffer = array('B')
        self.buffer = [0] * 256
        self.cursor = 0
        self.temp_cursor = 0

    def write(self, value):
        self.buffer[self.cursor] = (value >> 8) & 0xFF
        self.cursor += 1
        self.buffer[self.cursor] = (value & 0xFF)
        self.cursor += 1
    
    def read(self) -> int:
        return (self.buffer[self.cursor] << 8) | self.buffer[self.cursor+1]

    def read_u16(self) -> int:
        slice = self.buffer[self.cursor:self.cursor + 2]
        return struct.unpack(">H", bytes(slice))[0]     
    
    def read_u32(self) -> int:
        slice = self.buffer[self.cursor:self.cursor + 4]
        self.temp_cursor += 4
        return struct.unpack(">I", bytes(slice))[0]

    def write_offset(self, value, offset):
        lo = (value & 0xFF)
        hi = ((value >> 8) & 0xFF)

        self.buffer[self.cursor + offset]     = hi
        self.buffer[self.cursor + offset + 1] = lo

    def compact_to_output(self, output_data):
        for i in range(0, 32):
            output_data.append(self.read_u32())

#this shit dont work yet. figure it out
def unpack_ghd(reader: BufferedReader):
    addr = reader.tell()
    decomp_buf = ArrayStreamThing()
    output_data = array('L')

    d4 = d5 = d6 = 0

    num_decompress_steps = read_u8(reader)
    bits_to_process = read_u8(reader) << 8
    num_valid_bits = 8
    iteration_count = 0

    for i in range(0, num_decompress_steps):
        decomp_buf.cursor = 0
        while (True):
            if (decomp_buf.cursor >= 128):
                break
			# ---- Top Prep ----
			# Read the next data chunk of 5 bits
            data_chunk, num_valid_bits, bits_to_process = read_bits(5, num_valid_bits, bits_to_process, reader)
            
            is_lsb_set = (data_chunk & 0x1) > 0
            data_chunk = (data_chunk >> 1) & 0xF
            if (is_lsb_set):
                # Write nibble then do inner loop
                output = data_chunk
                decomp_buf.write(output)

                d4 = output
                d5 = output | 0x8000
                d6 = 0; # write offset
                # Inner Loop
                while (True):
                    # Process next two bits from the stream
                    bit_pair, num_valid_bits, bits_to_process = read_bits(2, num_valid_bits, bits_to_process, reader)
                    # After inner branch
                    if (bit_pair == 0):
                        # inner continues
                        tst: int
                        tst, num_valid_bits, bits_to_process = read_bits(1, num_valid_bits, bits_to_process, reader)
                        if (tst == 0): break

                        tst, num_valid_bits, bits_to_process = read_bits(1, num_valid_bits, bits_to_process, reader)
                        if (tst == 1):
                            # write ahead method 3
                            d6 += 20
                            decomp_buf.write_offset(d5, d6 - 1)
                        else:
                            # write ahead method 2
                            d6 += 12
                            decomp_buf.write_offset(d5, d6-2)
                    else:
                        # write ahead method 1
                        inc = (bit_pair + 6) * 2
                        d6 += inc
                        # D5 probably has hi bit set at this point
                        decomp_buf.write_offset(d5, d6-2);            
            else:
                # lower bit clear
                # Direct byte write
                output = data_chunk
                decomp_buf.write(output)

                d4 = output
                d5 = (output | 0x8000)
			
            # ---- Shunt Loop ----
            run_length = 0
            run_multiplier = 1

            while (True):
                run_length += 1
                run_multiplier *= 2

                data, num_valid_bits, bits_to_process = read_bits(1, num_valid_bits, bits_to_process, reader)
                if (data == 0):
                    # Found end of run
                    break
            # ---- Prep For Write (After Shunt Loop) ----
            working_bits, num_valid_bits, bits_to_process = read_bits(run_length, num_valid_bits, bits_to_process, reader)

            loop_amount = (run_multiplier + working_bits) - 3
            loop_amount += 1
            # ---- Write Loop ----
            if (loop_amount > 0):
                # todo: do we need to add one to the run_multiplier because of how the asm handles it's loop counter check at the end of the loop?
                for i in range(0, loop_amount):
                    d7 = decomp_buf.read()
                    if ((d7 & 0x8000) > 0):
                        d5 = d7
                        d4 = (d5 & 0xF) # just take data nibble, clear bit 15
                    decomp_buf.write(d4)
            iteration_count += 1
        decomp_buf.compact_to_output(output_data)

    with open(os.path.join(DATA_FOLDER, 'ghd', 'decompressed', f'tiles_{addr:02X}.bin'), 'w+b') as binary_file:
        output_data.tofile(binary_file)

hint_addrs_big = [ 
    0x14, 0x18, 
    0x15, 0x28, 
    0x15, 0x94, 
    0x16, 0xE6, 
    0x17, 0x64, 
    0x18, 0x3C, 
    0x19, 0x3E, 
    0x19, 0xCC, 
    0x1A, 0xC8, 
    0x1B, 0x6E, 
    0x1C, 0x6C 
]
hint_addrs_little = list(struct.unpack('>HHHHHHHHHHH', bytes(hint_addrs_big)))

def unpack_raw(reader: BufferedReader):
    addr = reader.tell()
    if addr not in hint_addrs_little:
        len = read_u16(reader)
        gfx_data = array('B')
        gfx_data.frombytes(reader.read(len))

        with open(os.path.join(DATA_FOLDER, 'raw', 'no_size', f'tiles_{addr:02X}.bin'), 'w+b') as binary_file:
            gfx_data.tofile(binary_file)    
    
#see gfx_read_data for reference
def unpack_tiles(reader: BufferedReader, log : TileLogger):
    while(True):
        cmp_type = read_u16(reader)
        if (cmp_type == 0xFFFF): break
        
        offset = read_u32(reader)
        saved_position = reader.tell()

        match cmp_type:
            case 0 | 1 | 4 | 5:
                if logger.append_unique(offset, 0):
                    reader.seek(offset)
                    #unpack_raw(reader)
            case 2 | 3:
                if logger.append_unique(offset, 1):
                    reader.seek(offset)
                    #unpack_ghd(reader)
            case 6 | 7:
                if logger.append_unique(offset, 2):
                    reader.seek(offset)
                    unpack_rle(reader)
        reader.seek(saved_position)
        skip_bytes(reader, 2) # for dest addr, but we don't need that

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('-f', '--file', help='ROM filename', dest='file',
                        default=DEFAULT_ROM_NAME, type=str)
    args = parser.parse_args()

    rom = open(args.file, 'rb')
    
    with open(os.path.join(DATA_FOLDER, ADDRS_FILE), 'r') as f:
        tiles_addrs = f.readlines()
        tiles_addrs = [int(hex_string, 16) for hex_string in tiles_addrs]

    logger = TileLogger()
    for addr in tiles_addrs:
        try:
            rom.seek(addr)
            unpack_tiles(rom, logger)
        except:
            etype, value, tb = exc_info()
            info, error = format_exception(etype, value, tb)[-2:]
            print(f'Exception in:\n{info}\n{error}')

    logger.log_all()
