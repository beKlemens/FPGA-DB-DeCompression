
import pandas
import os

import build_binary
import delta
import booleanCompression
import convert
import time

import huffman_static_ascii
import huffman_static_date
import huffman_static_numbers
import ploting

from datetime import datetime

import runlength
from build_binary import build_binary_for_list_of_numbers, build_binary_for_list_of_text, size_int_in_binary

def compress_table_to_binary(database, file_path, table_name):
    #Create target folders
    if not os.path.exists(database + '/compressed/'):
        os.makedirs(database + '/compressed/')

    if not os.path.exists(database + '/plots/'):
        os.makedirs(database + '/plots/')

    input_table = pandas.read_csv(file_path, delimiter='|', low_memory=False)

    #Open CSV/TBL
    with open(database + '/compressed/' + table_name + '.bin', 'wb') as binaryFile:
        sizeOfTable = 0
        for column_name in input_table:
            start_time_column = time.time()
            #get datatype
            column_dtype = input_table[column_name].dtypes
            if column_dtype == 'O':
                try: #Date / Datetime compression

                    uncompressed_data = input_table[column_name]

                    try: #Check if Date or Datetime
                        isDate = bool(datetime.strptime(uncompressed_data[0], "%Y-%m-%d"))
                        input_bytes = len(uncompressed_data) * 3
                    except ValueError:
                        isDate = False
                        input_bytes = len(uncompressed_data) * 8

                    sizeOfTable = sizeOfTable + input_bytes

                    #Conv to datetime
                    input_table[column_name] = pandas.to_datetime(input_table[column_name], format='mixed')
                    data_size_dict = {'uncompressed_data': (100.0 * input_bytes / input_bytes)}

                    #Huffman compression
                    compressed_data_huff = huffman_static_date.huffman_encoding(uncompressed_data)
                    huff_compression_size = build_binary.size_text_in_binary(compressed_data_huff[0],input_bytes)
                    data_size_dict['huffman'] = huff_compression_size

                    #Convert datetime to float
                    converted_date = convert.convert_date_to_number(input_table[column_name])
                    data_size_dict['date_to_number'] = build_binary.size_float_in_binary(converted_date, input_bytes)

                    # Convert float to integer
                    if isDate:
                        uncompressed_converted_data = convert.cast_float_to_integer(converted_date)
                        data_size_dict['float_to_int'] = size_int_in_binary(uncompressed_converted_data, input_bytes, 0)
                    else:
                        decimal_places, uncompressed_converted_data = convert.convert_float_to_integer(converted_date)
                        data_size_dict['float_to_int'] = size_int_in_binary(uncompressed_converted_data, input_bytes, 0)

                    #Compression of integer
                    data_size_dict, compressed_data = integer_compressions(data_size_dict, uncompressed_converted_data, input_bytes)

                    #get best compression result
                    if len(compressed_data) < huff_compression_size:
                        binaries = compressed_data
                    else:
                        binaries = compressed_data_huff[0]

                    #Check if compression ratio smaller than 0.9
                    if (len(binaries) / input_bytes) > 0.9:
                        print('Compression less effect')
                        #Use uncompressed data
                        converted_date = convert.convert_date_to_number(input_table[column_name])
                        decimal_places, uncompressed_converted_data = convert.convert_float_to_integer(converted_date)
                        binaries = build_binary_for_list_of_numbers(3, uncompressed_converted_data)

                    binaryFile.write(binaries)

                    #Plot compression ratios
                    ploting.makePlotOfSingleColumn(database, table_name, column_name, data_size_dict, "Date")
                except ValueError: #Compress text
                    uncompressed_data = input_table[column_name].tolist()

                    #Calculate uncompressed size
                    input_bytes = b''.join(str(item).encode() for item in uncompressed_data)
                    data_size_dict = {'uncompressed_data': (100.0 * len(input_bytes) / len(input_bytes))}

                    # Huffman compression
                    compressed_data = huffman_static_ascii.huffman_encoding(uncompressed_data)
                    data_size_dict['huffman'] = build_binary.size_text_in_binary(compressed_data[0], len(input_bytes))

                    binaries = build_binary_for_list_of_text(compressed_data[0], True)

                    #Check if compression ratio smaller than 0.9
                    if (len(binaries) / len(input_bytes)) > 0.9:
                        print('Compression less effect')
                        binaries = build_binary_for_list_of_text(uncompressed_data, False)

                    binaryFile.write(binaries)

                    #Plot compression ratios
                    ploting.makePlotOfSingleColumn(database, table_name, column_name, data_size_dict, "Text")
            elif column_dtype == 'float64': #float compression
                uncompressed_data = input_table[column_name].tolist()

                #calculate uncompressed size
                input_bytes = len(uncompressed_data) * 4  # number floats mulitplied with 4 Bytes to get size in Bytes
                data_size_dict = {'uncompressed_data': (100.0 * input_bytes / input_bytes)}

                #try split float to exponent and mantissa and compress separate
                data_size_dict, compressed_data_split = float_compression(data_size_dict, uncompressed_data, input_bytes)

                #try float to integer convert and compression
                decimal_places, uncompressed_converted_data = convert.convert_float_to_integer(uncompressed_data)
                data_size_dict, compressed_data = integer_compressions(data_size_dict, uncompressed_converted_data, input_bytes)

                #get best result
                if len(compressed_data) <= len(compressed_data_split):
                    binaries = compressed_data
                else:
                    binaries = compressed_data_split

                # Check if compression ratio smaller than 0.9
                if (len(binaries) / input_bytes) > 0.9:
                    print('Compression less effect')
                    # convert to integer
                    binaries = build_binary_for_list_of_numbers(0, uncompressed_converted_data)

                binaryFile.write(binaries)

                #Plot ratios
                ploting.makePlotOfSingleColumn(database, table_name, column_name, data_size_dict, "Float")
            elif column_dtype == 'int64': #compress integer
                uncompressed_data = input_table[column_name].tolist()

                #calculate uncompressed size
                input_bytes = len(uncompressed_data) * 4  # number intergers mulitplied with 4 Bytes to get size in Bytes
                data_size_dict = {'uncompressed_data': (100 * input_bytes/ input_bytes)}

                #compress integer
                data_size_dict, compressed_data = integer_compressions(data_size_dict, uncompressed_data, input_bytes)
                binaries = compressed_data

                # Check if compression ratio smaller than 0.9
                if (len(binaries) / input_bytes) > 0.9:
                    print('Compression no effect')
                    binaries = build_binary_for_list_of_numbers(1, uncompressed_data)

                binaryFile.write(binaries)

                #Plot ratios
                ploting.makePlotOfSingleColumn(database, table_name, column_name, data_size_dict, "Integer")
            elif column_dtype == 'bool': #compress bool
                uncompressed_data = input_table[column_name].tolist()

                #calculate uncompressed size
                input_bytes = len(uncompressed_data) * 2  # number booleans multiplied with 2 Bytes to get size in Bytes
                data_size_dict = {'uncompressed_data': (100 * input_bytes / input_bytes)}

                #boolean compression
                compressed_data = booleanCompression.compress_boolean(uncompressed_data)
                data_size_dict['bit_packing'] = size_int_in_binary(compressed_data, input_bytes, 2)
                binaries_bitpacking = build_binary_for_list_of_numbers(2, compressed_data)

                #convert to integer and compress
                uncompressed_data_int = []
                for b in uncompressed_data:
                    uncompressed_data_int.append(int(b))
                data_size_dict['bool_as_bit'] = size_int_in_binary(uncompressed_data_int, input_bytes, 2)
                binaries_ints = build_binary_for_list_of_numbers(2, uncompressed_data_int)

                # Check if compression ratio smaller than 0.9
                if(len(binaries_bitpacking) <= len(binaries_ints)):
                    binaryFile.write(binaries_bitpacking)
                else:
                    binaryFile.write(binaries_ints)

                # Plot ratios
                ploting.makePlotOfSingleColumn(database, table_name, column_name, data_size_dict, "Boolean")

            end_time_column = time.time()
            compression_time_column = end_time_column - start_time_column
            print("Column Compression time: {:.2f} seconds".format(compression_time_column) + ' for table:' + table_name + '| Column:' + column_name)
            print("================================================================")


def integer_compressions(data_size_dict, uncompressed_data, input_bytes):
    # Do different compression methods and get the results
    delta_compressed_data, factor_changes = delta.delta_encode(uncompressed_data)
    delta_compression_size = size_int_in_binary(delta_compressed_data, input_bytes, 1)
    data_size_dict['delta'] = delta_compression_size

    delta_run_compressed_data = runlength.runlength_encode(delta_compressed_data)
    delta_run_compression_size = size_int_in_binary(delta_run_compressed_data, input_bytes, 1)
    data_size_dict['delta_run'] = delta_run_compression_size

    delt_run_huff_compressed_data = huffman_static_numbers.huffman_encoding(delta_run_compressed_data)
    delta_run_huff_compression_size = build_binary.size_text_in_binary(delt_run_huff_compressed_data[0], input_bytes)
    data_size_dict['delta_run_huffman'] = delta_run_huff_compression_size

    delta_huff_compressed_data = huffman_static_numbers.huffman_encoding(delta_compressed_data)
    delta_huff_compression_size = build_binary.size_text_in_binary(delta_huff_compressed_data[0], input_bytes)
    data_size_dict['delta_huffman'] = delta_huff_compression_size

    huff_compressed_data = huffman_static_numbers.huffman_encoding(uncompressed_data)
    huff_compression_size = build_binary.size_text_in_binary(huff_compressed_data[0], input_bytes)
    data_size_dict['huffman'] = huff_compression_size

    smallest = min(delta_compression_size, delta_run_compression_size, delta_run_huff_compression_size, delta_huff_compression_size, huff_compression_size)

    # Depending on the smallest value, return a corresponding value
    if smallest == delta_compression_size:
        result = build_binary_for_list_of_numbers(1, delta_compressed_data)
    elif smallest == delta_run_compression_size:
        result = build_binary_for_list_of_numbers(1, delta_run_compressed_data)
    elif smallest == delta_run_huff_compression_size:
        result = delt_run_huff_compressed_data[0]
    elif smallest == delta_huff_compression_size:
        result = delta_huff_compressed_data[0]
    else:
        result = huff_compressed_data[0]

    return data_size_dict, result


def float_compression(data_size_dict, uncompressed_data, input_bytes):
    #do different compression methods and get the results
    uncompressed_data_exponent, uncompressed_data_mantissa = convert.convert_float_to_integer_split(uncompressed_data)

    delta_compressed_data_exponent, factor_changes_exponent = delta.delta_encode(uncompressed_data_exponent)
    delta_compression_exponent_size = size_int_in_binary(delta_compressed_data_exponent, input_bytes, 1)
    data_size_dict['exp_delta'] = delta_compression_exponent_size

    delta_run_compressed_data_exponent = runlength.runlength_encode(delta_compressed_data_exponent)
    delta_run_compression_exponent_size = size_int_in_binary(delta_run_compressed_data_exponent, input_bytes, 1)
    data_size_dict['exp_del_run'] = delta_run_compression_exponent_size

    delta_run_huff_compressed_data_exponent = huffman_static_numbers.huffman_encoding(delta_run_compressed_data_exponent)
    delta_run_huff_compression_exponent_size = build_binary.size_text_in_binary(delta_run_huff_compressed_data_exponent[0], input_bytes)
    data_size_dict['exp_del_run_huff'] = delta_run_huff_compression_exponent_size

    delta_huff_compressed_data_exponent = huffman_static_numbers.huffman_encoding(delta_compressed_data_exponent)
    delta_huff_compression_exponent_size = build_binary.size_text_in_binary(delta_huff_compressed_data_exponent[0],input_bytes)
    data_size_dict['exp_del_huff'] = delta_huff_compression_exponent_size


    decimal_places_mantissa, uncompressed_converted_data_mantissa = convert.convert_float_to_integer(uncompressed_data_mantissa)
    delta_compressed_data_mantissa, factor_changes_mantissa = delta.delta_encode(uncompressed_converted_data_mantissa)
    delta_compression_mantissa_size = size_int_in_binary(delta_compressed_data_mantissa, input_bytes, 1)
    data_size_dict['man_delta'] = delta_compression_mantissa_size

    delta_run_compressed_data_mantissa = runlength.runlength_encode(delta_compressed_data_mantissa)
    delta_run_compression_mantissa_size = size_int_in_binary(delta_run_compressed_data_mantissa, input_bytes, 0)
    data_size_dict['man_del_run'] = delta_run_compression_mantissa_size

    delta_run_huff_compressed_data_mantissa = huffman_static_numbers.huffman_encoding(delta_run_compressed_data_mantissa)
    delta_run_huff_compression_mantissa_size = build_binary.size_text_in_binary(delta_run_huff_compressed_data_mantissa[0], input_bytes)
    data_size_dict['man_del_run_huff'] = delta_run_huff_compression_mantissa_size

    delta_huff_compressed_data_mantissa = huffman_static_numbers.huffman_encoding(delta_compressed_data_mantissa)
    delta_huff_compression_size_mantissa = build_binary.size_text_in_binary(delta_huff_compressed_data_mantissa[0], input_bytes)
    data_size_dict['man_del_huff'] = delta_huff_compression_size_mantissa

    smallestExponent = min(delta_compression_exponent_size, delta_run_compression_exponent_size,
                           delta_run_huff_compression_exponent_size, delta_huff_compression_exponent_size)
    smallestMantissa = min(delta_compression_mantissa_size, delta_run_compression_mantissa_size,
                           delta_run_huff_compression_mantissa_size, delta_huff_compression_size_mantissa)

    # Depending on the smallest value, return a corresponding value
    if smallestExponent == delta_compression_exponent_size:
        resultExponent = build_binary_for_list_of_numbers(1, delta_compressed_data_exponent)
    elif smallestExponent == delta_run_compression_exponent_size:
        resultExponent = build_binary_for_list_of_numbers(1, delta_run_compressed_data_exponent)
    elif smallestExponent == delta_run_huff_compression_exponent_size:
        resultExponent = delta_run_huff_compressed_data_exponent[0]
    else:
        resultExponent = delta_huff_compressed_data_exponent[0]

    # Depending on the smallest value, return a corresponding value
    if smallestMantissa == delta_compression_mantissa_size:
        resultMantissa = build_binary_for_list_of_numbers(1, delta_compressed_data_mantissa)
    elif smallestMantissa == delta_run_compression_mantissa_size:
        resultMantissa = build_binary_for_list_of_numbers(1, delta_run_compressed_data_mantissa)
    elif smallestMantissa == delta_run_huff_compression_mantissa_size:
        resultMantissa = delta_run_huff_compressed_data_mantissa[0]
    else:
        resultMantissa = delta_huff_compressed_data_mantissa[0]

    result = resultExponent + resultMantissa

    return data_size_dict, result
