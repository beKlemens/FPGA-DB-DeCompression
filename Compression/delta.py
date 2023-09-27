"""Should be used to encode/decode numbers in the columns"""

def delta_encode(input_data):
    encoding_result = [input_data[0]]
    number_difference_changes = 0
    previous_change = 0

    for i in range(1, len(input_data)):
        if input_data[i] is None: #None handling for empty cells
            current_change = None
            encoding_result.append(current_change)
        elif input_data[i - 1] is None:
            current_change = input_data[i]
            encoding_result.append(current_change)
        else:
            current_change = input_data[i] - input_data[i - 1]
            encoding_result.append(round(current_change, 10))

        if current_change != previous_change:
            number_difference_changes += 1

        previous_change = current_change

    factor_changes = number_difference_changes/len(input_data)
    return encoding_result, factor_changes
