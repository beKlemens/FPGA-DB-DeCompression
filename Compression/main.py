# This is a sample Python script.
import numpy as np
# Press Umschalt+F10 to execute it or replace it with your code.
# Press Double Shift to search everywhere for classes, files, tool windows, actions, and settings.

import compression
import os
import time
import shutil

import entropyCalculation


def compress_file(database, file_path, tablename):
    print('Start Compression of table ' + tablename)
    start_time = time.time()
    compression.compress_table_to_binary(database, file_path, tablename)
    end_time = time.time()
    compression_time = end_time - start_time
    print('Finished Compression of table:' + tablename + "|Compression time: {:.2f} seconds".format(compression_time))
    print('++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++')


if __name__ == '__main__':

    #Set name of database folder to be compressed
    database = 'database_tpch'

    #Set functionalities
    calculateEntropy = True
    doCompression = True
    doDecompression = False

    #Start entropy calculation
    if calculateEntropy:
        listOfFilesToCompress = os.listdir('C:/Users/kleme/OneDrive/Dokumente/Studium/MTI3/Studienarbeit/Simple_Compression/' + database + '/raw_data')
        file_names = [os.path.splitext(file)[0] for file in listOfFilesToCompress]

        for i in range(0, len(listOfFilesToCompress)):
            entropyCalculation.calculateEntropyOfTable(database + '/raw_data/' + listOfFilesToCompress[i], file_names[i])
        #entropyCalculation.calculateEntropyOfTable(database + '/raw_data/lineitem.tbl', 'lineitem')

    #Do compression
    if doCompression:
        """============== Compression =================="""
        compressed_folder = 'C:/Users/kleme/OneDrive/Dokumente/Studium/MTI3/Studienarbeit/Simple_Compression/' + database +'/compressed'
        splitted_tables = 'C:/Users/kleme/OneDrive/Dokumente/Studium/MTI3/Studienarbeit/Simple_Compression/' + database +'/splitted_tables'
        plots_folder = 'C:/Users/kleme/OneDrive/Dokumente/Studium/MTI3/Studienarbeit/Simple_Compression/' + database +'/plots'

        if os.path.exists(compressed_folder):
            shutil.rmtree(compressed_folder)

        if os.path.exists(splitted_tables):
            shutil.rmtree(splitted_tables)

        if os.path.exists(plots_folder):
            shutil.rmtree(plots_folder)

        #Start compression itself
        start_time = time.time()

        listOfFilesToCompress = os.listdir('C:/Users/kleme/OneDrive/Dokumente/Studium/MTI3/Studienarbeit/Simple_Compression/' + database +'/raw_data')
        file_names = [os.path.splitext(file)[0] for file in listOfFilesToCompress]

        for i in range(0, len(listOfFilesToCompress)):
            compress_file(database, database + '/raw_data/' + listOfFilesToCompress[i], file_names[i])
        #compress_file(database, database + '/raw_data/lineitem.tbl', 'lineitem')

        end_time = time.time()
        compression_time = end_time - start_time
        print("Overall compression time: {:.2f} seconds".format(compression_time))