import os

def extract_hex_values(file_path):
    with open(file_path, 'rb') as file:
        hex_values = file.read()
        
        counter = 0
        len = 0
        result_string = 'dataPoint data[len] = {'

        for value in hex_values:
            if value != 0xea and value != 0x00:
                result_string += f'{{ {counter}, {value} }}, '
                len += 1
            
            counter += 1

        result_string += '};'
        result_string = f'\n\n#define len { len }\n' + result_string + '\n\n'
        return result_string




def create_modified_file(original_file_path, new_file_path, hex_values):
    with open(original_file_path, 'r') as original_file:
        original_content = original_file.readlines()

    original_content.insert(5, hex_values)

    with open(new_file_path, 'w') as new_file:
        original_content = "".join(original_content)
        new_file.write(original_content)


# Extract hex values from rom.bin
rom_data = extract_hex_values('../a.out')

# Create a new file with modified content
create_modified_file('EEPROM_Programmer/EEPROM_Programmer.ino', 'EEPROM_Programmer_mod/EEPROM_Programmer_mod.ino', rom_data)


# #compile sketch
os.system('../bin/arduino-cli compile --fqbn arduino:megaavr:nona4809 EEPROM_Programmer_mod')

# #upload sketch
os.system('../bin/arduino-cli upload -p /dev/cu.usbmodem1101 --fqbn arduino:megaavr:nona4809 EEPROM_Programmer_mod')

#open serial connection
os.system('../bin/arduino-cli monitor -p /dev/cu.usbmodem1101 -c baudrate=57600')