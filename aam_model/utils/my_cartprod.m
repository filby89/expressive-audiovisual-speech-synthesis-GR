function X = my_cartprod(varargin)
%MYCARTPROD Cartesian product of multiple ordered sets.
%
%   X = MYCARTPROD(A,B,C,...) returns the cartesian product of the sets 
%   A,B,C, etc, where A,B,C, are numerical vectors.  
%
%
%   This function requires IND2SUBVECT, also available (I hope) on the MathWorks 
%   File Exchange site.

numSets = length(varargin);
sizeThisSet = zeros(1,numSets);
for i = 1:numSets,
    if ~isequal(prod(size(varargin{i})),length(varargin{i})),
        error('All inputs must be vectors.')
    end
    if ~isnumeric(varargin{i}),
        error('All inputs must be numeric.')
    end
    sizeThisSet(i) = length(varargin{i});
end

X = zeros(prod(sizeThisSet),numSets);
for i = 1:size(X,1)    
    ixVect = ind2subVect(sizeThisSet,i);
    for j = 1:numSets
        X(i,j) = varargin{j}(ixVect(j));
    end
end
