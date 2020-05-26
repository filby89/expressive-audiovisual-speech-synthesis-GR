function texture = synthesizeTexture(textures,lambda)
% Texture synthesis by texture = textures(:,:,1) + \sum lambda_i*textures(:,:,i),

if nargin<2, error('Not enough args provided'); end

[numSampleTexturePixels numPlanes numShapes] = size(textures);

if length(lambda) ~= numShapes-1, error('Incompatible dims'); end
if numShapes < 1, error('Texture basis needs to contain at least one texture vector.'); end

textures = reshape(textures,[numSampleTexturePixels*numPlanes numShapes]);
lambda_1=[1; lambda(:)];
texture = textures*lambda_1;
texture = reshape(texture,[numSampleTexturePixels numPlanes]);
