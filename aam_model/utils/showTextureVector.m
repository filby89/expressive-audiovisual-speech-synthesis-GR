function [I, h] = showTextureVector(textureCoords, textureVector, I)
% Shows a texture vector measured on the textureCoords
% If no background image I is provided, we create one.
% shape (optional) is the the shape mask; useful because it is much smaller
% than textureCoords thus making delaunay triangulation etc much easier


% Changing code by fildisis in order to work in parfor (imshow doesnt work in parallel sadly)
% Changing 

if nargin < 2
    error('You need to specify both textureCoords AND textureVector');
end
if nargin < 3
  I = makeImageFromTextureVector(textureCoords, textureVector);
else
  I = makeImageFromTextureVector(textureCoords, textureVector, I);
end

numPlanes = size(textureVector,2);

minVals = min(textureVector);
maxVals = max(textureVector);
if numPlanes==1 % gray texture
    range = max(maxVals) - min(minVals); % used to unveil range
    if range>0, h = imshow(I,[minVals maxVals]);
    else h = imshow(I-minVals);
    end
else            % color texture
    range = max(maxVals) - min(minVals);
    if range > 0, h = imshow(1/range*(I-min(minVals)));
    else h = imshow(I-min(minVals));
    end
end
%disp(['MinVals: ' num2str(minVals) ', MaxVals: ' num2str(maxVals) ', Range of values: ' num2str(range)]);

%axis on;
