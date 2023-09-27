import time

from bitarray import bitarray
from bitarray.util import (deserialize)

from huffman_functions import write_dot, make_tree

#Static huffman tree generated by a variance of my database values.
def get_ascii_code_db():
    ascii_binary_tree = {}

    ascii_binary_tree[87]= bitarray('00000000')
    ascii_binary_tree[120]= bitarray('00000001')
    ascii_binary_tree[68]= bitarray('0000001')
    ascii_binary_tree[45]= bitarray('000001')
    ascii_binary_tree[56]= bitarray('000010')
    ascii_binary_tree[58]= bitarray('0000110')
    ascii_binary_tree[78]= bitarray('0000111')
    ascii_binary_tree[97]= bitarray('0001')
    ascii_binary_tree[124]= bitarray('0010')
    ascii_binary_tree[47]= bitarray('001100')
    ascii_binary_tree[44]= bitarray('0011010')
    ascii_binary_tree[82]= bitarray('0011011')
    ascii_binary_tree[117]= bitarray('00111')
    ascii_binary_tree[109]= bitarray('010000')
    ascii_binary_tree[103]= bitarray('010001')
    ascii_binary_tree[53]= bitarray('010010')
    ascii_binary_tree[52]= bitarray('010011')
    ascii_binary_tree[69]= bitarray('0101000')
    ascii_binary_tree[77]= bitarray('0101001')
    ascii_binary_tree[121]= bitarray('010101')
    ascii_binary_tree[67]= bitarray('0101100')
    ascii_binary_tree[74]= bitarray('01011010')
    ascii_binary_tree[70]= bitarray('01011011')
    ascii_binary_tree[51]= bitarray('010111')
    ascii_binary_tree[101]= bitarray('0110')
    ascii_binary_tree[48]= bitarray('01110')
    ascii_binary_tree[72]= bitarray('01111000')
    ascii_binary_tree[35]= bitarray('01111001')
    ascii_binary_tree[65]= bitarray('0111101')
    ascii_binary_tree[57]= bitarray('011111')
    ascii_binary_tree[71]= bitarray('10000000')
    ascii_binary_tree[75]= bitarray('10000001')
    ascii_binary_tree[83]= bitarray('1000001')
    ascii_binary_tree[50]= bitarray('100001')
    ascii_binary_tree[98]= bitarray('1000100')
    ascii_binary_tree[107]= bitarray('1000101')
    ascii_binary_tree[100]= bitarray('100011')
    ascii_binary_tree[115]= bitarray('10010')
    ascii_binary_tree[111]= bitarray('10011')
    ascii_binary_tree[108]= bitarray('10100')
    ascii_binary_tree[110]= bitarray('10101')
    ascii_binary_tree[105]= bitarray('10110')
    ascii_binary_tree[114]= bitarray('10111')
    ascii_binary_tree[112]= bitarray('110000')
    ascii_binary_tree[122]= bitarray('110001000')
    ascii_binary_tree[88]= bitarray('110001001')
    ascii_binary_tree[90]= bitarray('110001010')
    ascii_binary_tree[89]= bitarray('110001011')
    ascii_binary_tree[85]= bitarray('11000110')
    ascii_binary_tree[84]= bitarray('11000111')
    ascii_binary_tree[46]= bitarray('110010')
    ascii_binary_tree[104]= bitarray('110011')
    ascii_binary_tree[116]= bitarray('11010')
    ascii_binary_tree[118]= bitarray('11011000')
    ascii_binary_tree[80]= bitarray('11011001')
    ascii_binary_tree[86]= bitarray('110110100')
    ascii_binary_tree[106]= bitarray('110110101')
    ascii_binary_tree[76]= bitarray('11011011')
    ascii_binary_tree[99]= bitarray('110111')
    ascii_binary_tree[119]= bitarray('1110000')
    ascii_binary_tree[102]= bitarray('1110001')
    ascii_binary_tree[49]= bitarray('111001')
    ascii_binary_tree[55]= bitarray('1110100')
    ascii_binary_tree[73]= bitarray('11101010')
    ascii_binary_tree[113]= bitarray('111010110')
    ascii_binary_tree[63]= bitarray('11101011100')
    ascii_binary_tree[95]= bitarray('111010111010')
    ascii_binary_tree[64]= bitarray('1110101110110000')
    ascii_binary_tree[37]= bitarray('11101011101100010')
    ascii_binary_tree[43]= bitarray('11101011101100011')
    ascii_binary_tree[39]= bitarray('111010111011001')
    ascii_binary_tree[59]= bitarray('11101011101101')
    ascii_binary_tree[33]= bitarray('11101011101110')
    ascii_binary_tree[126]= bitarray('111010111011110')
    ascii_binary_tree[41]= bitarray('111010111011111000')
    ascii_binary_tree[91]= bitarray('11101011101111100100000')
    ascii_binary_tree[93]= bitarray('11101011101111100100001')
    ascii_binary_tree[94]= bitarray('11101011101111100100010')
    ascii_binary_tree[96]= bitarray('11101011101111100100011')
    ascii_binary_tree[36]= bitarray('1110101110111110010010')
    ascii_binary_tree[62]= bitarray('11101011101111100100110')
    ascii_binary_tree[125]= bitarray('11101011101111100100111')
    ascii_binary_tree[92]= bitarray('111010111011111001010')
    ascii_binary_tree[123]= bitarray('11101011101111100101100')
    ascii_binary_tree[60]= bitarray('11101011101111100101101')
    ascii_binary_tree[42]= bitarray('1110101110111110010111')
    ascii_binary_tree[40]= bitarray('1110101110111110011')
    ascii_binary_tree[38]= bitarray('11101011101111101')
    ascii_binary_tree[61]= bitarray('1110101110111111')
    ascii_binary_tree[81]= bitarray('1110101111')
    ascii_binary_tree[66]= bitarray('11101100')
    ascii_binary_tree[79]= bitarray('11101101')
    ascii_binary_tree[54]= bitarray('1110111')
    ascii_binary_tree[32]= bitarray('1111')

    return ascii_binary_tree

#Static huffman tree from ian with the added missing characters
def get_ascii_code_ian():
    ascii_binary_tree = {}

    # Add items with string keys and bitarray values -> ascii value in integer, coding_bits in tree
    ascii_binary_tree[32] = bitarray('001') #space
    ascii_binary_tree[101] = bitarray('110')  # e
    ascii_binary_tree[116] = bitarray('0101')  # t
    ascii_binary_tree[97] = bitarray('0111')  # a
    ascii_binary_tree[111] = bitarray('1000')  # o
    ascii_binary_tree[110] = bitarray('1001')  # n
    ascii_binary_tree[105] = bitarray('1011')  # i
    ascii_binary_tree[104] = bitarray('1110')  # h
    ascii_binary_tree[114] = bitarray('1111')  # r
    ascii_binary_tree[115] = bitarray('00000')  # s
    ascii_binary_tree[100] = bitarray('01100')  # d
    ascii_binary_tree[124] = bitarray('01101')  # |
    ascii_binary_tree[117] = bitarray('000011')  # u
    ascii_binary_tree[73] = bitarray('000100')  # I
    ascii_binary_tree[109] = bitarray('000101')  # m
    ascii_binary_tree[99] = bitarray('000110')  # c
    ascii_binary_tree[121] = bitarray('010000')  # y
    ascii_binary_tree[102] = bitarray('010001')  # f
    ascii_binary_tree[119] = bitarray('010010')  # w
    ascii_binary_tree[103] = bitarray('101000')  # g
    ascii_binary_tree[44] = bitarray('101010')  # ,
    ascii_binary_tree[112] = bitarray('101011')  # p
    ascii_binary_tree[98] = bitarray('0000100')  # b
    ascii_binary_tree[46] = bitarray('0001111')  # .
    ascii_binary_tree[118] = bitarray('0100111')  # v
    ascii_binary_tree[34] = bitarray('00001011')  # "
    ascii_binary_tree[107] = bitarray('00011101')  # k
    ascii_binary_tree[108] = bitarray('10100100')  # l
    ascii_binary_tree[77] = bitarray('000111000')  # M
    ascii_binary_tree[59] = bitarray('010011001')  # ;
    ascii_binary_tree[45] = bitarray('101001100')  # -
    ascii_binary_tree[66] = bitarray('101001111')  # B
    ascii_binary_tree[122] = bitarray('0000101001')  # z
    ascii_binary_tree[84] = bitarray('0000101011')  # T
    ascii_binary_tree[120] = bitarray('0001110010')  # x
    ascii_binary_tree[69] = bitarray('0001110011')  # E
    ascii_binary_tree[95] = bitarray('0100110000')  # _
    ascii_binary_tree[76] = bitarray('0100110001')  # L
    ascii_binary_tree[39] = bitarray('0100110101')  # '
    ascii_binary_tree[72] = bitarray('0100110110')  # H
    ascii_binary_tree[67] = bitarray('0100110111')  # C
    ascii_binary_tree[87] = bitarray('1010010101')  # W
    ascii_binary_tree[106] = bitarray('1010010110')  # j
    ascii_binary_tree[113] = bitarray('1010010111')  # q
    ascii_binary_tree[68] = bitarray('1010011010')  # D
    ascii_binary_tree[83] = bitarray('1010011100')  # S
    ascii_binary_tree[65] = bitarray('00001010000')  # A
    ascii_binary_tree[33] = bitarray('00001010001')  # !
    ascii_binary_tree[63] = bitarray('00001010100')  # ?
    ascii_binary_tree[89] = bitarray('01001101001')  # Y
    ascii_binary_tree[74] = bitarray('10100101000')  # J
    ascii_binary_tree[80] = bitarray('10100110110')  # P
    ascii_binary_tree[78] = bitarray('10100110111')  # N
    ascii_binary_tree[71] = bitarray('10100111010')  # G
    ascii_binary_tree[33] = bitarray('000010100011')  # !
    ascii_binary_tree[79] = bitarray('000010101010')  # O
    ascii_binary_tree[70] = bitarray('010011010000')  # F
    ascii_binary_tree[82] = bitarray('101001010010')  # R
    ascii_binary_tree[96] = bitarray('0000101000100')  # `
    ascii_binary_tree[126] = bitarray('0000101000101')  # ~
    ascii_binary_tree[75] = bitarray('0000101010111')  # K
    ascii_binary_tree[49] = bitarray('0100110100011')  # 1
    ascii_binary_tree[85] = bitarray('1010011101110')  # U
    ascii_binary_tree[42] = bitarray('00001010101101')  # *
    ascii_binary_tree[38] = bitarray('10100101001100')  # &
    ascii_binary_tree[58] = bitarray('10100101001111')  # :
    ascii_binary_tree[40] = bitarray('10100111011000')  # (
    ascii_binary_tree[41] = bitarray('10100111011001')  # )
    ascii_binary_tree[51] = bitarray('10100111011011')  # 3
    ascii_binary_tree[50] = bitarray('10100111011110')  # 2
    ascii_binary_tree[53] = bitarray('10100111011111')  # 5
    ascii_binary_tree[52] = bitarray('000010101011000')  # 4
    ascii_binary_tree[86] = bitarray('010011010001000')  # V
    ascii_binary_tree[48] = bitarray('010011010001001')  # 0
    ascii_binary_tree[47] = bitarray('010011010001010')  # /
    ascii_binary_tree[54] = bitarray('010011010001011')  # 6
    ascii_binary_tree[61] = bitarray('101001010011010')  # =
    ascii_binary_tree[60] = bitarray('101001010011100')  # <
    ascii_binary_tree[56] = bitarray('101001110110100')  # 8
    ascii_binary_tree[57] = bitarray('0000101010110010')  # 9
    ascii_binary_tree[55] = bitarray('0000101010110011')  # 7
    ascii_binary_tree[62] = bitarray('1010010100110111')  # >
    ascii_binary_tree[92] = bitarray('1010010100111010')  # \
    ascii_binary_tree[123] = bitarray('10100101001101100')  # {
    ascii_binary_tree[125] = bitarray('10100101001101101')  # }
    ascii_binary_tree[43] = bitarray('10100101001110110')  # +
    ascii_binary_tree[94] = bitarray('10100101001110111')  # ^
    ascii_binary_tree[90] = bitarray('10100111011010100')  # Z
    ascii_binary_tree[88] = bitarray('101001110110101100')  # X
    ascii_binary_tree[93] = bitarray('101001110110101101')  # ]
    ascii_binary_tree[64] = bitarray('101001110110101110')  # @
    ascii_binary_tree[36] = bitarray('101001110110101111')  # $
    ascii_binary_tree[81] = bitarray('1010011101101010100')  # Q
    ascii_binary_tree[91] = bitarray('1010011101101010101')  # [
    ascii_binary_tree[37] = bitarray('1010011101101010110')  # %
    ascii_binary_tree[35] = bitarray('1010011101101010111')  # #


    return ascii_binary_tree

#encode the single characters
def encode(plain):
    code = get_ascii_code_db()
    write_dot(make_tree(code), 'tree.dot', 0 in plain)
    a = bitarray(endian='big')
    a.encode(code, plain)
    compressed_data = a.tobytes()

    if len(plain) == 0:
        assert len(a) == 0

    return compressed_data

def huffman_encoding(input_data):
    encoding_result = []
    #set separator sign between each entry
    sign = "|"
    plain = sign.join(str(item) if item is not None else 'null' for item in input_data).encode('utf-8')
    #start encoding
    encoded_data = encode(plain)

    encoding_result.append(encoded_data)

    return encoding_result

