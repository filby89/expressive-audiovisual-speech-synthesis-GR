function thinPlateParams = computeThinPlateWarpParams(sourceShape, targetShape, tps)
% Suppose that we have two shapes in the d-dimensional space, each
% consisting of n points, and we want to generate a function that smoothly warps the
% source shape to the target shape, making sure that corresponding landmarks
% exactly match each other. A satisfactory solution is given by the thin
% plate spline [Bookstein (pami99), Cootes (rep04), Hastie et al (book01)].
% 
% f_i(x) = a_0 + a'*x + \sum_{j=1}^n w_j(i)*U(|x-x_j|), for each coord. i=1:d
%
% The unknown thinPlateParams for each coord are in the vector 
% W_i = (w_1(i):w_n(i), a_0(i), a_1(i):a_d(i))' 
% and can be computed taking into account the n exact correspondence relationships 
% f_i(sx_j)=tx_j(i), the zero-mean relationship \sum_{j=1}^n w_j(i) = 0 and
% the d zero cross-product relationships \sum_{j=1}^n w_j(i)*x_j(i) = 0.
%
% Collectively, thinPlateParams = W = (W_1; ... ;W_d) , with dims d x (n+d+1)
%
% After computing the thinPlateParams W, one can compute the warp sx->tx=f(x) in
% compact form by f(x) = W*u(x), 
% where u(x) = [U(|x-x_1|); U(|x-x_2|); ...; U(|x-x_n|; 1; x];

if nargin < 2
    error('You did not provide two shapes to be warped to each other');
end

if sum(size(sourceShape)~=size(targetShape)) ~= 0
    error('The two shapes to be warpped must have the same number of points and must live in the same dimensionality');
end

[n,d] = size(sourceShape);

% If the LU decomposition of the system matrix A is not given, then we have to compute it anew
if nargin < 3
   % warning(['When computing the thinPlateParams multiple times with the same' ...
   %          'source shape, you should separately compute and re-use the LU decomposition.']);
    tps = computeLUDecompositionForThinPlateWarpParams(sourceShape);
end

%
% Set the right hand side
%
%B = [targetShape; zeros(d+1,d)];
B = cat(1,targetShape,zeros(d+1,d));
%size(tps.U)
%size(tps.L)
%size(B)
% Compute the thin plate params, which is d x (n+d+1)
thinPlateParams = (tps.U\(tps.L\B))';
