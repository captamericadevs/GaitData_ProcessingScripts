function [featuresX,featuresY,featuresZ,featuresM,featuresXY,featuresXZ,featuresYZ] = ProcFeatures(id,sesh,type)
%****************
%Read in Raw Data
filename = sprintf('g%s%senc',id,sesh);
folder = sprintf('c:\\users\\parker\\documents\\nps projects\\thesis\\status\\databases\\data\\%s',filename);
D = dir([folder, '\*.csv']);
Num = length(D(not([D.isdir])));

file = sprintf('%s\\0.csv',folder);
disp(file);
mRaw = csvread(file, 0, 0);
x = mRaw(:,1);
y = mRaw(:,2);
z = mRaw(:,3);
    
for j=1:Num-1,
    %Read in raw accel segments
    file = sprintf('%s\\%d.csv',folder,j); 
    mRaw = csvread(file, 0, 0);
    x = horzcat(x,mRaw(:,1));
    y = horzcat(y,mRaw(:,2));
    z = horzcat(z,mRaw(:,3));
end

%*******************************
%Means for each segment (column)
Xm = mean(x);
Ym = mean(y);
Zm = mean(z);

if type == 2 || type == 3
    %Normalize Data Segments
    Vf = [0.0,-9.81,0.0]; %Gravity Vector
    Vf = Vf/norm(Vf);
    %The initival vector is the average of the "standing" portion of the raw
    %data (the first segment)
    Vi = [Xm(1),Ym(1),Zm(1)];
    Vi = (Vi/norm(Vi));
    %Get the Axis-Angle
    angle = acos(dot(Vi,Vf));
    axis = cross(Vi,Vf);
    %use it to get the quaternion
    q = quaternion.angleaxis(angle,axis);
end

%loop through original values, create normalized matricies
for i=1:250,
    for j=1:Num,
        oldV = [x(i,j),y(i,j),z(i,j)];
        if type == 1 %if norming to 0
            xF(i,j)=oldV(1)-Xm(j); %x normalized to 0
            yF(i,j)=oldV(2)-Ym(j); %y normalized to 0
            zF(i,j)=oldV(3)-Zm(j); %z normalized to 0
            mF(i,j)=sqrt(xF(i,j)^2+yF(i,j)^2+zF(i,j)^2); %magnitude after normal
            xyF(i,j)=sqrt(xF(i,j)^2+yF(i,j)^2);
            xzF(i,j)=sqrt(xF(i,j)^2+zF(i,j)^2);
            yzF(i,j)=sqrt(yF(i,j)^2+zF(i,j)^2);
        elseif type == 2 || type == 3 
            newV = RotateVector(q,oldV);
            xF(i,j)=newV(1); %rotated x vectors 
            yF(i,j)=newV(2); %rotated y vectors
            zF(i,j)=newV(3); %rotated z vectors
            mF(i,j)=sqrt(xF(i,j)^2+yF(i,j)^2+zF(i,j)^2); %magnitude after rotation
            xyF(i,j)=sqrt(xF(i,j)^2+yF(i,j)^2);
            xzF(i,j)=sqrt(xF(i,j)^2+zF(i,j)^2);
            yzF(i,j)=sqrt(yF(i,j)^2+zF(i,j)^2);
        elseif type == 4
            xF(i,j)=oldV(1);
            yF(i,j)=oldV(2);
            zF(i,j)=oldV(3);
            mF(i,j)=sqrt(xF(i,j)^2+yF(i,j)^2+zF(i,j)^2);
            xyF(i,j)=sqrt(xF(i,j)^2+yF(i,j)^2);
            xzF(i,j)=sqrt(xF(i,j)^2+zF(i,j)^2);
            yzF(i,j)=sqrt(yF(i,j)^2+zF(i,j)^2);
        end
    end
end

if type == 3 %if norming to zero after rotation
    %Get mean of rotated vectors
    xRm = mean(xF);
    yRm = mean(yF);
    zRm = mean(zF);
    mRm = mean(mF);
    xyRm = mean(xyF);
    xzRm = mean(xzF);
    yzRm = mean(yzF);

    %Normalize rotated values to zero
    for i=1:250,
        for j=1:Num,
            oldV = [xF(i,j),yF(i,j),zF(i,j),mF(i,j),xyF(i,j),xzF(i,j),yzF(i,j)];
            xF(i,j)=oldV(1)-xRm(j); %xF normalized to 0
            yF(i,j)=oldV(2)-yRm(j); %yF normalized to 0
            zF(i,j)=oldV(3)-zRm(j); %zF normalized to 0
            mF(i,j)=oldV(4)-mRm(j); %mF normalized to 0
            xyF(i,j)=oldV(5)-xyRm(j);
            xzF(i,j)=oldV(6)-xzRm(j);
            yzF(i,j)=oldV(7)-yzRm(j);
        end
    end
end

%*******************************
featuresX = zeros(8,13); %so that's how many feature vectors we need
featuresY = zeros(8,13); %so that's how many feature vectors we need
featuresZ = zeros(8,13);
featuresM = zeros(8,13); %so that's how many feature vectors we need
featuresXY = zeros(8,13);
featuresXZ = zeros(8,13);
featuresYZ = zeros(8,13);

%MFCC Parameters based on Brandt
sr = 16000;
minfq = 0;
maxfq = 1200;
numcp = 13;
lifter = 0;
bands = 40;
type = 'bark';
dct = 1;
usec = 0;
winlgn = 0.007;
winhp = 0.0002;
pre = 0.97;
dith = 1;

%Extract Cepstral Features
for i=4:Num, %i iterates on segments, start at 4 since 1/2/3 are not walks
    [cepstrum,aspectrum] = melfcc(xF(:,i), sr, 'minfreq', minfq, 'maxfreq', maxfq, 'numcep', numcp, 'lifterexp', lifter,'nbands', bands, 'fbtype', type, 'dcttype', dct, 'usecmp', usec, 'wintime', winlgn, 'hoptime', winhp, 'preemph', pre, 'dither', dith);
    featuresX(i-3,:) = mean(cepstrum,2);
    [cepstrum,aspectrum] = melfcc(yF(:,i), sr, 'minfreq', minfq, 'maxfreq', maxfq, 'numcep', numcp, 'lifterexp', lifter,'nbands', bands, 'fbtype', type, 'dcttype', dct, 'usecmp', usec, 'wintime', winlgn, 'hoptime', winhp, 'preemph', pre, 'dither', dith);
    featuresY(i-3,:) = mean(cepstrum,2);
    [cepstrum,aspectrum] = melfcc(zF(:,i), sr, 'minfreq', minfq, 'maxfreq', maxfq, 'numcep', numcp, 'lifterexp', lifter,'nbands', bands, 'fbtype', type, 'dcttype', dct, 'usecmp', usec, 'wintime', winlgn, 'hoptime', winhp, 'preemph', pre, 'dither', dith);
    featuresZ(i-3,:) = mean(cepstrum,2);
    [cepstrum,aspectrum] = melfcc(mF(:,i), sr, 'minfreq', minfq, 'maxfreq', maxfq, 'numcep', numcp, 'lifterexp', lifter,'nbands', bands, 'fbtype', type, 'dcttype', dct, 'usecmp', usec, 'wintime', winlgn, 'hoptime', winhp, 'preemph', pre, 'dither', dith);
    featuresM(i-3,:) = mean(cepstrum,2);
    [cepstrum,aspectrum] = melfcc(xyF(:,i), sr, 'minfreq', minfq, 'maxfreq', maxfq, 'numcep', numcp, 'lifterexp', lifter,'nbands', bands, 'fbtype', type, 'dcttype', dct, 'usecmp', usec, 'wintime', winlgn, 'hoptime', winhp, 'preemph', pre, 'dither', dith);
    featuresXY(i-3,:) = mean(cepstrum,2);
    [cepstrum,aspectrum] = melfcc(xzF(:,i), sr, 'minfreq', minfq, 'maxfreq', maxfq, 'numcep', numcp, 'lifterexp', lifter,'nbands', bands, 'fbtype', type, 'dcttype', dct, 'usecmp', usec, 'wintime', winlgn, 'hoptime', winhp, 'preemph', pre, 'dither', dith);
    featuresXZ(i-3,:) = mean(cepstrum,2);
    [cepstrum,aspectrum] = melfcc(yzF(:,i), sr, 'minfreq', minfq, 'maxfreq', maxfq, 'numcep', numcp, 'lifterexp', lifter,'nbands', bands, 'fbtype', type, 'dcttype', dct, 'usecmp', usec, 'wintime', winlgn, 'hoptime', winhp, 'preemph', pre, 'dither', dith);
    featuresYZ(i-3,:) = mean(cepstrum,2);
end