import os

import matplotlib.pyplot as plt

# function to add value labels
def addlabels(x,y):
    for i in range(len(x)):
        plt.text(i, y[i], y[i], ha = 'center')

#Input dict with compression types and bytes per compression
def makePlotOfSingleColumn(database, table_name, column_name, data, datatype):
    if not os.path.exists(database + '/plots/' + table_name +'/'):
        os.makedirs(database + '/plots/'+ table_name +'/')

    courses = list(data.keys())
    values = list(data.values())

    fig = plt.figure(figsize=(20, 5))

    # creating the bar plot
    plt.bar(courses, values, color='maroon', width=0.4)

    # calling the function to add value labels
    addlabels(courses, values)

    plt.xlabel("Compression Methods")
    plt.ylabel("Ratio")
    plt.title("Ratio of Compression (" + datatype +")")
    plt.savefig(database + '/plots/' + table_name + '/' + column_name + '.png')
    #plt.show()
