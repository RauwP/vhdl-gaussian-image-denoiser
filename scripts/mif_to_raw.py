import re

def parse_mif_file_1024bit(filename):
    """
    Parse a MIF file with:
      DEPTH = 512
      WIDTH = 1024  (i.e., each line is 1024 bits = 128 bytes, stored as 256 hex characters)

    After 'CONTENT BEGIN', each line is like:
       0 : c7db2253de...89d;
    We remove "0 :" and the semicolon, then parse the 256 hex chars in pairs -> 128 bytes.

    We end up with a 2D list [512][128]. Then we merge pairs of rows into 256 wide:
      [256][256].
    """

    # This will collect rows of 128 bytes each
    data_512x128 = []

    reading_content = False

    with open(filename, 'r') as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith('--') or line.startswith('%'):
                continue

            # Detect start of content
            if 'CONTENT' in line.upper() and 'BEGIN' in line.upper():
                reading_content = True
                continue

            # Detect end of content
            if line.upper().startswith('END'):
                reading_content = False
                continue

            if reading_content:
                # Example line:
                # 0 : c7db2253debabfbfb3...9845b1989d;
                #  or
                # 12 : 1234ABCD...9999;

                # Remove trailing semicolon
                line = line.replace(';', '')

                # Remove address portion ("0 :" or "1F :") using regex
                line = re.sub(r'^[0-9A-Fa-f]+\s*:\s*', '', line)

                # Now line should be a single long hex string of length 256
                hex_str = line.strip()

                if len(hex_str) != 256:
                    raise ValueError(
                        f"Expected 256 hex characters (128 bytes), got {len(hex_str)} in line: '{line}'"
                    )

                # Parse this 256-hex-character string in 2-char increments
                row_bytes = []
                for i in range(0, 256, 2):
                    byte_hex = hex_str[i:i+2]
                    byte_val = int(byte_hex, 16)  # convert from hex to 0–255
                    row_bytes.append(byte_val)

                if len(row_bytes) != 128:
                    raise ValueError(
                        f"Parsing error: expected 128 bytes, got {len(row_bytes)}"
                    )

                data_512x128.append(row_bytes)

    # We expect exactly 512 lines of data
    if len(data_512x128) != 512:
        raise ValueError(
            f"Expected 512 lines of data, got {len(data_512x128)} from file '{filename}'."
        )

    # Combine each pair of 128-wide rows into one 256-wide row
    data_256x256 = []
    for i in range(0, 512, 2):
        combined = data_512x128[i] + data_512x128[i+1]
        if len(combined) != 256:
            raise ValueError(
                f"Row pairing error at index {i//2}: length {len(combined)} instead of 256."
            )
        data_256x256.append(combined)

    return data_256x256  # shape: [256][256]


def build_raw_from_mifs(mif_r, mif_g, mif_b, out_raw):
    """
    Reads three MIF files (R, G, B), each with DEPTH=512 and WIDTH=1024,
    forming three 256x256 images. Then interleaves them (R,G,B) into a 24-bit RAW file.
    """
    # Parse each color channel -> 256x256
    r_data = parse_mif_file_1024bit(mif_r)
    g_data = parse_mif_file_1024bit(mif_g)
    b_data = parse_mif_file_1024bit(mif_b)

    # Interleave
    with open(out_raw, 'wb') as f:
        for row in range(256):
            for col in range(256):
                f.write(bytes([
                    r_data[row][col],
                    g_data[row][col],
                    b_data[row][col]
                ]))

    print(f"Created RAW file: {out_raw}")



red_mif = "r_output.mif"
green_mif = "g_output.mif"
blue_mif = "b_output.mif"

output_raw = "petruha_noise.raw"

build_raw_from_mifs(red_mif, green_mif, blue_mif, output_raw)


