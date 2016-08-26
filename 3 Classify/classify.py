import Orange
from Orange import data
from Orange.classification import svm, knn
import numpy as np

Num = 23 #number of subjects
goalV = 2 #required number of votes
numV = 8 #number of votes taken

gen = input("Enter number of genuine instances: ")
length = Num*gen #length of input matrices

svmVotesFinal = np.zeros(length/numV) #create arrays for each voting block
knnVotesFinal = np.zeros(length/numV)

for i in range(Num):
    svmCnt = []
    knnCnt = []
    traFile = "C:\\Users\\Parker\\Documents\\NPS Projects\\thesis\\status\\Databases\\train\\%strain.csv" % str(i+1)
    testFile = "C:\\Users\\Parker\\Documents\\NPS Projects\\thesis\\status\\Databases\\train\\%stest.csv" % str(i+1)
    train = data.Table(traFile)
    test = data.Table(testFile)

    svmLearner = svm.SVMLearner(svm_type=svm.SVMLearner.C_SVC, kernel_type=svm.SVMLearner.RBF, kernel_func=None, \
               C=1, nu=0.5, p=0.1, gamma=0.0, degree=3, coef0=0, \
               shrinking=True, probability=True, verbose=False, \
               cache_size=200, eps=0.001, normalization=False)

    svmLearner.tune_parameters(train, parameters=["gamma","C"], folds=8)

    svmClassifier = svmLearner(train)
    knnClassifier = knn.kNNLearner(train, k=8)

    for t in test:
        svmCnt.append(svmClassifier(t))
        knnCnt.append(knnClassifier(t))

    voteIdx = 0
    imp = (length - gen)
    svmVotes = np.zeros(length/numV) #create arrays for each voting block
    knnVotes = np.zeros(length/numV)

    j = 0
    while j < length : #for the length of the vector
        svm_neigh = 0
        knn_neigh = 0

        q = j 
        while q < j+numV : #count the number of votes following segment
            svm_neigh = svm_neigh + svmCnt[q]
            knn_neigh = knn_neigh + knnCnt[q]
            q = q+1

        if svm_neigh >= goalV : #check if number of votes is > goal
            svmVotes[voteIdx] = 1 #accept whole block if so
        if knn_neigh >= goalV :
            knnVotes[voteIdx] = 1

        j = j+numV #increment + number of vote segms
        voteIdx = voteIdx + 1 #incremeber voteIdx

    if i == 0 :
        svmVotesFinal = svmVotes #fill matrix with ind vote vector
        knnVotesFinal = knnVotes
    else :
        u = 0
        while u < gen/numV:
            Idx = u + (i*(gen/numV))
            temp = svmVotes[u] #swap rows
            svmVotes[u] = svmVotes[Idx]
            svmVotes[Idx] = temp
            temp = knnVotes[u]
            knnVotes[u] = knnVotes[Idx]
            knnVotes[Idx] = temp
            u = u+1

        svmVotesFinal = svmVotesFinal + svmVotes
        knnVotesFinal = knnVotesFinal + knnVotes

#Get FNMR from number of zeros in row 1
svmFNMR_cnt = 0
knnFNMR_cnt = 0
for z in range(gen/numV):
    svmFNMR_cnt = svmFNMR_cnt + (Num-svmVotesFinal[z])
    knnFNMR_cnt = knnFNMR_cnt + (Num-knnVotesFinal[z])

sFNMRt = svmFNMR_cnt / (Num*(gen/numV))
kFNMRt = knnFNMR_cnt / (Num*(gen/numV))

#get FMR from number of 1s in all rows minus row 1
for z in range(gen/numV):
    svmVotesFinal[z] = 0
    knnVotesFinal[z] = 0

sFMRt = sum(svmVotesFinal) / (Num*((length-gen)/numV))
kFMRt = sum(knnVotesFinal) / (Num*((length-gen)/numV))

print sFMRt
print sFNMRt
print kFMRt
print kFNMRt
    
