
#BooleanEncoder -> Counts how many trues are in sequence before a false appears. After each count > 0 a false follows even is the next
# number is also larger than 0
def compress_boolean2(input_data):
    encoding_result = []
    count = 0
    for value in input_data:
        if value:
            count += 1
        else:
            encoding_result.append(count)
            count = 0

    encoding_result.append(count)

    return encoding_result


#Runlength Boolean -> currently used, since decompresion on FPGA is implemented for that variant
def compress_boolean(input_data):
    encoding_result = []
    count = 0
    currentValue = True
    isFirstValue = True
    for value in input_data:
        if isFirstValue:
            encoding_result.append(int(value))
            isFirstValue = False
            currentValue = value

        if currentValue == value:
            count += 1
        else:
            encoding_result.append(count)
            count = 1

        currentValue = value

    encoding_result.append(count)

    return encoding_result