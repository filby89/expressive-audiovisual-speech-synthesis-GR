function [warpDeriv, Ux] = computeTargetShapeDerivativeFromThinPlateWarpParams(thinPlateParams, refShape, shapeCoords)
% Given the thinPlateParams, which correspond to a reference shape
% refShape, evaluate the spatial derivative dW/dx of the warp on the
% coords in shapeCoords.
% 
% Remember that thinPlateParams = W = (W_1; ... ;W_d) , with dims d x (n+d+1)
%
% If x is a single point, we compute the derivative of the warp sx->tx=f(x) by f'(x) = W*u'(x), 
% where u'(x) = [dU(|x-x_1|)/dx; dU(|x-x_2|)/dx; ...; dU(|x-x_n|)/dx; 0_{1xd}; I_d];
%
%   See also computeThinPlateWarpParams.


if nargin<3, error('You did not provide all params needed'); end

[n,d] = size(refShape);
if sum([d,n+d+1] ~= size(thinPlateParams)) ~= 0 || d ~= size(shapeCoords,2)
    error('Incompatible dimensionalities');
end
L = size(shapeCoords,1);

% size(u') = [n,d,L]

Ux = zeros([n+d+1 d L]);
Ux(1:n,:,:) = biHarmonicKernelDerivativeOnPairwiseDistance(refShape,shapeCoords);
%Ux(n+1,:,:) = zeros([d L]); % redundant
for i=1:L
  Ux(n+2:n+d+1,:,i) = eye(d);
end
Ux = reshape(Ux,[n+d+1 d*L]);

warpDeriv1 = thinPlateParams*Ux;
warpDeriv = reshape(warpDeriv1,[d d L]);