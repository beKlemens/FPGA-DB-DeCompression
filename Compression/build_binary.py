import struct
import bitarray


def build_binary_for_list_of_numbers(datatype, compressed_data):

    bit_size = 2
    if all(x is not None for x in compressed_data):
        largest_number = max(list(filter(None, compressed_data)), key=abs)
        if datatype == 2:
            bit_size = largest_number.bit_length() #is bool datatype, no need for signs
        else:
            bit_size = largest_number.bit_length() + 1

    data_of_column = bitarray.bitarray()

    for num in compressed_data:
        if num != None:
            bits = bin(abs(num))[2:].zfill(bit_size)
            if num < 0:
                #set sign for negativ value
                string_list = list(bits)
                string_list[0] = "1"
                bits = ''.join(string_list)

                #build twos complement
                #inverted_binary = ''.join('1' if bit == '0' else '0' for bit in bits)
                #bits = bin(int(inverted_binary, 2) + 1)[2:].zfill(bit_size)
        else:
            num = 0
            bits = bin(abs(num))[2:].zfill(bit_size)

        data_of_column += bitarray.bitarray(bits)

    compressed_bytes = data_of_column.tobytes()

    return compressed_bytes


def build_binary_for_list_of_text(compressed_data, is_compressed):

    if is_compressed:
        return compressed_data
    else:
        sign = "|"
        plain = sign.join(str(item) if item is not None else 'null' for item in compressed_data).encode('utf-8')
        data_of_column = bytearray(plain)
        return data_of_column

def size_text_in_binary(compressed_data, max_value):
    normalized = 100.0 * len(compressed_data) / max_value
    return normalized

def size_float_in_binary(compressed_data, max_value):
    buf = struct.pack('%sf' % len(compressed_data), *compressed_data)
    normalized = 100.0 * len(buf) / max_value
    return normalized

def size_int_in_binary(compressed_data, max_value, datatype):
    size_binary = len(build_binary_for_list_of_numbers(datatype, compressed_data))
    normalized = 100.0 * size_binary / max_value
    return normalized
