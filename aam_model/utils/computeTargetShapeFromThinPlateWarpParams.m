function targetShape = computeTargetShapeFromThinPlateWarpParams(thinPlateParams, refShape, sourceShape)
% Given the thinPlateParams, which correspond to a reference shape
% refShape, compute the warp of another shape sourceShape.
% 
% Remember that thinPlateParams = W = (W_1; ... ;W_d) , with dims d x (n+d+1)
%
% If x is a single point, we compute the warp sx->tx=f(x) by f(x) = W*u(x), 
% where u(x) = [U(|x-x_1|); U(|x-x_2|); ...; U(|x-x_n|; 1; x];
%
%   See also computeThinPlateWarpParams.


if nargin < 3
    error('You did not provide thinPlateParams, the reference shape and the shape to be transformed');
end

[n,d] = size(refShape);
if sum([d,n+d+1] ~= size(thinPlateParams)) ~= 0 || d ~= size(sourceShape,2)
    error('Incompatible dimensionalities');
end
m = size(sourceShape,1);

% kernelName = sprintf('biHarmonicKernel%dD',d);
% kernel = @(r) kernelName(r);
%kernel = @biHarmonicKernel2D;

% Compute u(x)
% $$$ pairDist = computePairwiseDistance(refShape,sourceShape);
% $$$ % For one point, u(x) = [U(|x-x_1|); U(|x-x_2|); ...; U(|x-x_n|; 1; x];
% $$$ u = [kernel(pairDist); repmat(1,[1 m]); sourceShape'];

%kernel_pairDist = biHarmonicKernelOnPairwiseDistance(refShape,sourceShape);
%u = [kernel_pairDist; ones(1,m); sourceShape'];
u = [biHarmonicKernelOnPairwiseDistance(refShape,sourceShape); ones(1,m); sourceShape'];

targetShape = (thinPlateParams*u)';