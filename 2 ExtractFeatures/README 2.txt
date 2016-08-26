Process signal segments
PullData.m, ExtFeatures.m, ProcFeatures.m, scaleVals.m
Will Parker, 2013
***********************

Run PullData.m
This reads in data from ALL of the subjects (declared in a list on line 1).

Takes training session letter(s): A-Back pocket, B-Front pocket, C-Hip
Takes in test session.
Takes in Normalization technique: 1-Zero Scale, 2-Rotation, 3-Rotation/Zero, 4-None
Takes in Axis selection (only used X, Y, Z, XY, and XYZ in thesis)

Data segments are read and divided into training (session 1) and test (session 2) sets  passed into (ExtFeatures.m).

The features are extracted in ProcFeatures.m.

Filename paths are hard coded into ProcFeatures.m (line 4/5) and each file's data is loaded into x, y, and z arrays. This data is normalized, then passed into Dan Ellis' MFCC function (settings declared on lines 114-126) and the BFCCs are returned (for all possible axis selections).

These results are vertically concatonated into test and training data passed from ExtFeatures back to PullData.

PullData then labels the feature matrix by horizonally concatonating a column of labels.

The training and test matrices have their values scaled to between 0-1 using scaleVals.m.

The scaled feature matrices are then written out to hardcoded file paths (lines 50 and 62) by PullData.m