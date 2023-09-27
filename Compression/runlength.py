
def runlength_encode(input_data):
    encoding_result = []
    count = 1
    for i in range(1, len(input_data)):
        if input_data[i] == input_data[i - 1]:
            count += 1
        else:
            encoding_result.append(count)
            encoding_result.append(input_data[i - 1])
            count = 1

    encoding_result.append(count)
    encoding_result.append(input_data[-1])

    return encoding_result
