import os

def extract_hex_values(file_path):
    with open(file_path, 'rb') as file:
        hex_values = file.read()
        hex_string = ', '.join([f'0x{val:02x}' for val in hex_values])
        return f'byte data[] = {{ {hex_string} }}'

def create_modified_file(original_file_path, new_file_path, hex_values):
    with open(original_file_path, 'r') as original_file:
        original_content = original_file.read()

    with open(new_file_path, 'w') as new_file:
        new_file.write(hex_values + ';\n\n' + original_content)

# Extract hex values from rom.bin
rom_data = extract_hex_values('rom.bin')

# Create a new file with modified content
create_modified_file('EEPROM_Programmer/EEPROM_Programmer.ino', 'EEPROM_Programmer_mod/EEPROM_Programmer_mod.ino', rom_data)


# #compile sketch
os.system('arduino-cli compile --fqbn arduino:megaavr:nona4809 EEPROM_Programmer_mod')

# #upload sketch
os.system('arduino-cli upload -p /dev/cu.usbmodem3101 --fqbn arduino:megaavr:nona4809 EEPROM_Programmer_mod')