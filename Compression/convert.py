"""Convert date and datetime to Integer value"""
import math


def convert_date_to_number(input_data):
    converted_values = []
    for dt in input_data:
        converted_values.append(dt.timestamp())

    return converted_values

def convert_float_to_integer(input_data):
    convert_result = []

    max_decimal_places = 0
    for index in range(0, len(input_data)):
        decimal_places = len(str(input_data[index]).split('.')[-1])
        max_decimal_places = max(max_decimal_places, decimal_places)

    for i in range(0, len(input_data)):
        if input_data[i] is None or math.isnan(input_data[i]):
            convert_result.append(None)
        else:
            int_value = int(input_data[i] * 10 ** max_decimal_places)
            convert_result.append(int_value)

    return max_decimal_places, convert_result

def convert_float_to_integer_split(input_data):
    convert_result_exponent = []
    convert_result_mantissa = []

    for i in range(0, len(input_data)):
        if input_data[i] is None or math.isnan(input_data[i]):
            convert_result_exponent.append(None)
            convert_result_mantissa.append(None)
        else:
            mantissa, exponent = math.frexp(input_data[i])
            convert_result_exponent.append(exponent)
            convert_result_mantissa.append(mantissa)

    return convert_result_exponent, convert_result_mantissa
