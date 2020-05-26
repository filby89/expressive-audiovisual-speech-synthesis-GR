function t = composeSimilarityTransforms(t2,t1)
% Given two 2d similarity transforms of the type
% S_t(x,y) = [1+s_x -s_y; s_y 1+s_x]*[x y]'+[t_x t_y]'
% with parameter vector t=[s_x s_y t_x t_y]', return the map of their
% composition S_t = S_t2(S_t1). 

if nargin < 2
    error('not enough args provided');
end
if length(t1)~=4 || length(t2)~=4
    error('similarity transforms not as expected');
end

t = [(1+t2(1))*(1+t1(1))-t1(2)*t2(2)-1;...
     (1+t2(1))*t1(2)+t2(2)*(1+t1(1))  ;...
     t2(3)+(1+t2(1))*t1(3)-t2(2)*t1(4);...
     t2(4)+(1+t2(1))*t1(4)+t2(2)*t1(3)];