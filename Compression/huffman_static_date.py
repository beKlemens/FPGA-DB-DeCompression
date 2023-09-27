import time

from bitarray import bitarray
from bitarray.util import (deserialize)

from huffman_functions import write_dot, make_tree

#Static huffman tree for date/dateime compression
def get_date_code():
    ascii_binary_tree = {}

    ascii_binary_tree[45]= bitarray('1111')
    ascii_binary_tree[49]= bitarray('0101')
    ascii_binary_tree[48]= bitarray('110')
    ascii_binary_tree[50]= bitarray('001')
    ascii_binary_tree[51]= bitarray('1011')
    ascii_binary_tree[52]= bitarray('1001')
    ascii_binary_tree[53]= bitarray('0111')
    ascii_binary_tree[54]= bitarray('0100')
    ascii_binary_tree[55]= bitarray('1110')
    ascii_binary_tree[56]= bitarray('0001')
    ascii_binary_tree[57]= bitarray('0000')
    ascii_binary_tree[124]= bitarray('1010')
    ascii_binary_tree[58]= bitarray('1000')
    ascii_binary_tree[46]= bitarray('01101')
    ascii_binary_tree[32]= bitarray('01100')

    return ascii_binary_tree

#start encoding with huffman tree
def encode(plain):
    code = get_date_code()
    write_dot(make_tree(code), 'tree.dot', 0 in plain)
    a = bitarray(endian='big')
    a.encode(code, plain)
    compressed_data = a.tobytes()

    if len(plain) == 0:
        assert len(a) == 0

    return compressed_data


def huffman_encoding(input_data):
    encoding_result = []
    #set separator between each entry
    sign = "|"
    plain = sign.join(str(item) if item is not None else 'null' for item in input_data).encode('utf-8')
    #start encoding
    encoded_data = encode(plain)

    encoding_result.append(encoded_data)

    return encoding_result

