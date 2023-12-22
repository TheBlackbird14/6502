rom = bytearray([1, 2, 3, 4, 5, 6, 7, 8, 9, 10])

with open("rom.bin", "wb") as out_file:
    out_file.write(rom);