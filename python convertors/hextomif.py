def hextomif(read_file_name,write_file_name): 
    # Define the replacement lines for the first three lines
    header_lines = [
        "DEPTH = 512;\n",
        "WIDTH = 1024;\n",
        "ADDRESS_RADIX = HEX;\n",
        "DATA_RADIX = HEX;\n",
        "CONTENT BEGIN\n"
    ]
    
    # Read the original file
    with open(read_file_name, "r") as infile:
        lines = infile.readlines()
    
    # Prepare the output list
    modified_lines = []
    
    # 1. Replace the first three lines with the specified header lines
    #    We will ignore the original first three lines in the output.
    modified_lines.extend(header_lines)
    
    # 2. Process the rest of the lines
    #    - Replace all occurrences of " @" with " ".
    #    - Add a semicolon at the end of each line.
    for line in lines[3:]:
        # Replace "@" with "   "
        line = line.replace("@", "   ")
        # Add the neccessary ':' between the address and the data
        line = line.replace("0 ", "0 : ")
        line = line.replace("1 ", "1 : ")
        line = line.replace("2 ", "2 : ")
        line = line.replace("3 ", "3 : ")
        line = line.replace("4 ", "4 : ")
        line = line.replace("5 ", "5 : ")
        line = line.replace("6 ", "6 : ")
        line = line.replace("7 ", "7 : ")
        line = line.replace("8 ", "8 : ")
        line = line.replace("9 ", "9 : ")
        line = line.replace("a ", "a : ")
        line = line.replace("b ", "b : ")
        line = line.replace("c ", "c : ")
        line = line.replace("d ", "d : ")
        line = line.replace("e ", "e : ")
        line = line.replace("f ", "f : ")
        # Strip off any trailing newline before adding the semicolon
        line = line.rstrip("\n") + ";"
        # Add back a newline
        line += "\n"
        modified_lines.append(line)
    
    # 3. Finish the file with "END;\n"
    modified_lines.append("END;\n")
    
    # Write the modified lines to a new file
    with open(write_file_name, "w") as outfile:
        outfile.writelines(modified_lines)

read_red = "r_output.mem"
write_red = "r_output.mif"

read_green = "g_output.mem"
write_green = "g_output.mif"

read_blue = "b_output.mem"
write_blue = "b_output.mif"

hextomif(read_red,write_red)
hextomif(read_green,write_green)
hextomif(read_blue,write_blue)
