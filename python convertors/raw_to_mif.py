import sys
input_file = "lena_noise.raw"
output_file_r = "lena_noise_r.mif"
output_file_g = "lena_noise_g.mif"
output_file_b = "lena_noise_b.mif"
with open(input_file, 'rb') as f:
    raw_data = f.read(256*256*3)
red_channel = []
green_channel = []
blue_channel = []
for i in range(0, len(raw_data), 3):
    red_channel.append(raw_data[i])
    green_channel.append(raw_data[i+1])
    blue_channel.append(raw_data[i+2])
with open(output_file_r, 'w') as f:
    f.write(f"DEPTH = 512;\n")
    f.write(f"WIDTH = 1024;\n")
    f.write(f"ADDRESS_RADIX = HEX;\n")
    f.write(f"DATA_RADIX = HEX;\n")
    f.write(f"CONTENT BEGIN\n")
    for address in range(0,512,1):
        addr_str = f"{address:X}"
        data = red_channel[address*128:(address+1)*128]
        data_str = ''.join(format(x, '02x') for x in data)
        f.write(f"    {addr_str} : {data_str};\n")
    f.write("END;\n")
with open(output_file_g, 'w') as f:
    f.write(f"DEPTH = 512;\n")
    f.write(f"WIDTH = 1024;\n")
    f.write(f"ADDRESS_RADIX = HEX;\n")
    f.write(f"DATA_RADIX = HEX;\n")
    f.write(f"CONTENT BEGIN\n")
    for address in range(0,512,1):
        addr_str = f"{address:X}"
        data = green_channel[address*128:(address+1)*128]
        data_str = ''.join(format(x, '02x') for x in data)
        f.write(f"    {addr_str} : {data_str};\n")
    f.write("END;\n")
with open(output_file_b, 'w') as f:
    f.write(f"DEPTH = 512;\n")
    f.write(f"WIDTH = 1024;\n")
    f.write(f"ADDRESS_RADIX = HEX;\n")
    f.write(f"DATA_RADIX = HEX;\n")
    f.write(f"CONTENT BEGIN\n")
    for address in range(0,512,1):
        addr_str = f"{address:X}"
        data = blue_channel[address*128:(address+1)*128]
        data_str = ''.join(format(x, '02x') for x in data)
        f.write(f"    {addr_str} : {data_str};\n")
    f.write("END;\n")