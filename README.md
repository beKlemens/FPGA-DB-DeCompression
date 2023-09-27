# FPGA-DB-DeCompression
Compression of Databases to receive a high thoughput decompression on FPGAs


Repository of the student project. Containing a Python implemented compression of Database exported to CSV or tbl. files. Different compression algorithms like delta, huffman and runlength are  test and the results on the different datatypes(Int, Float, Date, Datetime, boolean and Text) analysed. The best compression result is used to create binary file. 

The decompression is fulfilled on FPGAs with the target to create a maximal data throughput. 

The folder compression contains the implementation for the compressions in python

The decompression folder contains the FPGA implementation for the decompression
