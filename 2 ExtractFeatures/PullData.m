subj = {'122' '201' '203' '209' '210' '211' '218' '222' '223' '229' '235' '241' '253' '266' '283' '287' '299' '301' '310' '336' '347' '372' '381'};
sesh = input('Enter the train session letter(s) (A,B,C): ', 's');
sesh = strsplit(sesh);

%added for final expr
sesht = input('Enter the test session letter (A,B,C): ', 's');
sesht = strsplit(sesht);
%*****

type = input('Enter the normalization technique (1-0,2-R,3-R0,4-N): ');
axis = input('Enter the Axes (1-X,2-Y,3-Z,4-XYZ,5-XY,6-XZ,7-YZ): ', 's');
axis = strsplit(axis);

%Get a feature matrix
train = ExtFeatures(subj,sesh,type,axis,0);
test = ExtFeatures(subj,sesht,type,axis,1);

% %Loop variables and vectors
featLenTr = size(train,1);
featLenTs = size(test,1);

%loop through each subject
tr = 1;
ts = 1;
for in = 1:length(subj),
    labelTr = zeros(featLenTr,1);
    labelTs = zeros(featLenTs,1);
    %populate label vector
    j = tr;
    while j < tr+(8*length(sesh))
        labelTr(j) = 1;
        j = j+1;
    end
    j = ts;
    while j < ts+(8*length(sesht))
        labelTs(j) = 1;
        j = j+1;
    end
    tr = tr +(8*length(sesh));
    ts = ts +(8*length(sesht));
    trainF = horzcat(train,labelTr);
    testF = horzcat(test,labelTs);
    
    disp(trainF);
    disp(testF);
    %Scale the training values, and use the same parameters to scale the test values
    [trainF,testF] = scaleVals(trainF,testF); 

    %Create CSV File
    header = {'pow','co1','co2','co3','co4','co5','co6','co7','co8','co9','co10','co11','co12','c#truth'};
    filename = sprintf('c:\\users\\parker\\documents\\nps projects\\thesis\\status\\Databases\\train\\%dtrain.csv',in);   
    fid = fopen(filename, 'w');
    [rows,cols]=size(header);
    for i=1:rows
        fprintf(fid,'%s,',header{i,1:end-1});
        fprintf(fid,'%s\n',header{i,end});
    end
    fclose(fid);
    %Write it out to training file    
    dlmwrite(filename,trainF,'-append');

    filename = sprintf('c:\\users\\parker\\documents\\nps projects\\thesis\\status\\Databases\\train\\%dtest.csv',in);
    fid = fopen(filename, 'w');
    [rows,cols]=size(header);
    for i=1:rows
        fprintf(fid,'%s,',header{i,1:end-1});
        fprintf(fid,'%s\n',header{i,end});
    end
    fclose(fid);
    %Write it out to test file    
    dlmwrite(filename,testF,'-append');
end