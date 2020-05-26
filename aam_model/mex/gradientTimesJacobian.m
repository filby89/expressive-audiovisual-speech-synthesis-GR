function steepDesc = gradientTimesJacobian(grad, jac)
% GRADIENTTIMESJACOBIAN - multiplies gradient and jacobian and
% yields a steepest descent template image, with dim
% [N numColors n] = [N numColors dims] x [N dims n]

  steepDesc = matMultThreeDim(grad, jac, 1, 1, 1);

% $$$   [N numColors dims] = size(grad);
% $$$   [N1 dims1 n] = size(jac);
% $$$   
% $$$   if any([N dims]~=[N1 dims1])
% $$$     error('gradientTimesJacobian: incompatible grad-jac dims');
% $$$   end
% $$$   
% $$$   steepDesc=zeros([N numColors n]);
% $$$ 
% $$$   for i=1:N
% $$$     steepDesc(i,:,:) = reshape(grad(i,:,:),[numColors dims])*...
% $$$         reshape(jac(i,:,:),[dims n]);
% $$$   end
