function shape = synthesizeShape(shapes,p,t)
% Given a mean shape shapes(:,:,1) and eigenshapes shapes(:,:,2:end),
% and the shape coords p - corresponding to deformations W_p
% compute the deformed shape = meanShape + \sum p_i*eigenShape(i)
% If the parameters t of a similarity transform are also given, apply 
% it, too. 

if nargin <2, error('Not enough args provided'); end

numEigenShapes = length(p);
if size(shapes,3)-1 ~= numEigenShapes, error('incompatible dims'); end

% shape = shapes(:,:,1);
% for i=1:numEigenShapes
%     shape = shape + p(i)*shapes(:,:,i+1);
% end

[L num_dims num_shapes]=size(shapes);
shapes=reshape(shapes, [L*num_dims num_shapes]);
p_1=[1; p(:)];
shape = shapes*p_1;
shape=reshape(shape, [L num_dims]);

if nargin==3, shape = applySimilarityTransform(shape,t); end