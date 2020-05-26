function newPointCoords = applySimilarityTransform(pointCoords,t)
% Given a 2d shape vector with coords pointCoords and a
% similarity transform S_t(x,y) = [1+s_x -s_y; s_y 1+s_x]*[x y]'+[t_x t_y]'
% with parameter vector t=[s_x s_y t_x t_y]', return the map of the input
% shape under this similarity transform. 

if nargin < 2, error('not enough params provided'); end
if length(t)~=4, error('similarity transform not as expected'); end
if size(pointCoords,2)~=2, error('can only handle 2d vectors-shapes'); end

A = [1+t(1) -t(2); t(2) 1+t(1)];
b = [t(3) t(4)];
numPoints = size(pointCoords,1);
newPointCoords = pointCoords*A' + repmat(b,[numPoints 1]);