function result = ExtFeatures(iid,sesh,type,axis,no)
%Concatenate each additional false training set
for i = 1:size(iid,2),
    for j = sesh,
        if i == 1 && strcmpi(j{1},sesh{1})
            if no == 1
                nsesh = sprintf('%s2',j{1}); %get walk 2
            else
                nsesh = j{1};
            end
            disp(nsesh);
            [Xf,Yf,Zf,Mf,XYf,XZf,YZf] = ProcFeatures(iid{i},nsesh,type);
        else
            if no == 1
                nsesh = sprintf('%s2',j{1}); %get walk 2
            else
                nsesh = j{1};
            end
            disp(nsesh);
            [X,Y,Z,M,XY,XZ,YZ] = ProcFeatures(iid{i},nsesh,type);
            Xf = vertcat(Xf,X);
            Yf = vertcat(Yf,Y);
            Zf = vertcat(Zf,Z);
            Mf = vertcat(Mf,M);
            XYf = vertcat(XYf,XY);
            XZf = vertcat(XZf,XZ);
            YZf = vertcat(YZf,YZ);
        end
    end
end

%Append Data
fData = [];
for i=1:size(axis,2),
    if axis{i} == '1'
        fData = [fData;Xf];
    elseif axis{i} == '2'
        fData = [fData;Yf];
    elseif axis{i} == '3'
        fData = [fData;Zf];
    elseif axis{i} == '4'
        fData = [fData;Mf];
    elseif axis{i} == '5'
        fData = [fData;XYf];
    elseif axis{i} == '6'
        fData = [fData;XZf];
    elseif axis{i} == '7'
        fData = [fData;YZf];
    end
end

%Return the data    
result = fData;