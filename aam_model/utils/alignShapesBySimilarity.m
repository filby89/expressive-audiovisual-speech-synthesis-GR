function [alignedShape,t] = alignShapesBySimilarity(unAlignedShape, refShape)
% Align two shapes. Only similarities are allowed. 
% Return the alignedShape + the similitude to get there, s.t.
% S_t(unAlignedShape) \approxeq refShape
% For a derivation of the formulas, see report by Cootes.

if nargin < 1
    error('You did not provide shapes for alignment');
end
if nargin < 2
    alignedShape = unAlignedShape;
    warning('no reference shape was specified, so did nothing');
    return;
end
if size(refShape)~=size(unAlignedShape)
    error('incompatible shapes');
end

meanUnAlignedShape = mean(unAlignedShape);
meanRefShape = mean(refShape);
numPoints = size(refShape,1);

% center the shapes
unAlignedShape = unAlignedShape - repmat(meanUnAlignedShape,[numPoints 1]);
refShape       = refShape       - repmat(meanRefShape      ,[numPoints 1]);

normUnAlignedShape = norm(unAlignedShape(:));
if normUnAlignedShape == 0
    alignedShape = unAlignedShape;
    warning('zero unaligned shape, so did nothing');
    return;
end

invSquareNormUnAlignedShape = (1/normUnAlignedShape)^2;

a = invSquareNormUnAlignedShape*unAlignedShape(:)'*refShape(:);
b = invSquareNormUnAlignedShape*...
    ( unAlignedShape(:,1)'*refShape(:,2) - unAlignedShape(:,2)'*refShape(:,1) );

% s   = sqrt(a^2+b^2);
% phi = atan(b/a);
% alignedShape = rotateAndScaleShape(unAlignedShape,s,phi);

t1 = [0; 0; -meanUnAlignedShape'];
t2 = [a-1; b; 0; 0];
t3 = [0; 0; meanRefShape'];

alignedShape = applySimilarityTransform(unAlignedShape,t2);
t2t1 = composeSimilarityTransforms(t2,t1);
t    = composeSimilarityTransforms(t3,t2t1);