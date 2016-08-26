classify.py
Will Parker, 2013
Runs in PYTHON 2.7
******************

Takes in the number of genuine instances in the training data.

Then reads in hardcoded training and test files (lines 19 and 20) from the MATLAB feature extractor.

The SVM and KNN classifiers are then training on the training data (SVM parameters are autotuned). Then tested on the test matrix.

The voting system is implemented. 

Then the results of the votes are used to compute the FNMR and FMR for both the SVM and kNN. 

May take a while to run. 