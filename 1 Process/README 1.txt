SigSegm.py
By Will Parker, 2013
Runs on PYTHON 3.2+
********************

Takes a .db file as input, then selects the id, timestamp, x, y, z values from the db object.

Interpolates the signal to 50Hz (defined as a global var).

Then segments the signal into 5 second segments (global) with 2.5 second overlap (global).

Then writes these segments to separate .csv files inside a new folder.

