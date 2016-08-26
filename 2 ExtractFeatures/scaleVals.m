function [train,test] = scaleVals(A,B)
%********************
%Scale our input values
minimums = min(A, [], 1);
ranges = max(A, [], 1) - minimums;

train = (A - repmat(minimums, size(A, 1), 1)) ./ repmat(ranges, size(A, 1), 1);
test = (B - repmat(minimums, size(B, 1), 1)) ./ repmat(ranges, size(B, 1), 1);