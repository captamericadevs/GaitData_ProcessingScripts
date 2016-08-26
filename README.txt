Evaluation of Data Processing Techniques for Unobtrusive Gait Authentication 
(Data/Code)
Will Parker, LT, USN
Naval Postgraduate School
March 2014
*************************

The RawData folder contains the raw gait databases from the subjects for two walking sessions (a-back pocket, b-front pocket, c-hip).

The ProcData folder contains the data processed by the Python script located in the <1 Process> directory.

The 1 Process directory contains a Python 3.2 script that interpolates and segments the raw databases.

The 2 ExtractFeatures directory contains MATLAB functions (PullData.m is main script) that extract the cepstral coefficient features from the processed data with user supplied settings.

The 3 Classify directory contains a Python 2.7/Orange script that builds SVM and kNN for the extracted feature sets (train on walk session 1 and test on walk session 2) then returns the FMR/FNMR results from the voting scheme described in the thesis text. 


