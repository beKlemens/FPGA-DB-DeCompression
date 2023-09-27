import math

import pandas

def calculateEntropyOfTable(file_path, table_name):

    input_table = pandas.read_csv(file_path, delimiter='|', low_memory=False)
    print('Entropy of table:' + table_name)

    tableEntropy = 0
    numberColumns = 0

    for column_name in input_table:
        numberColumns = numberColumns + 1
        column_data = input_table[column_name]

        column_dtype = input_table[column_name].dtypes
        isText = False
        if column_dtype == 'O':
            try:
                pandas.to_datetime(input_table[column_name], format='mixed')
            except ValueError:
                #Is text -> then not count occurancy of complete elements-> count occurancy of each char
                isText = True

        #Count occurence of elements
        element_counts = dict()

        if isText: #count char occurance
            total_count = 0
            for element in column_data:
                for character in list(str(element)):
                    total_count += 1
                    if character in element_counts:
                        element_counts[character] += 1
                    else:
                        element_counts[character] = 1
        else: #count element occurance
            for element in column_data:
                if element in element_counts:
                    element_counts[element] += 1
                else:
                    element_counts[element] = 1

            total_count = len(column_data)

        entropy = 0.0

        for element, count in element_counts.items():
            probability = count / total_count #calculate the probability of each element
            entropy -= probability * math.log2(probability) #calculate the entropy of each element and sum it up

        tableEntropy += entropy
        print('Entropy of column:' + column_name + " Entropy:{:.2f}".format(entropy))

    tableEntropy = tableEntropy/numberColumns
    print("Entropy of table: {:.2f}".format(tableEntropy))
    print('===========================================')
