function [I,t] = makeImageFromTextureVector(textureCoords, textureVector, I)
% Given the texture samples in textureVector, defined on textureCoords,
% create an image I defined on an orthogonal grid.
% If the background image I is provided, the texture mask is overlaid on I.
% In the case we create the image, we also transform the textureCoords
% vector by similarity. Then it makes sense to return the parameters t of
% the similarity, such that S_t(tC)=ntC
  
% The image value I(x) at a pixel x in the convex hull of textureCoords is
% given by the average of the image values at the nodes of the
% corresponding delaunay triangle.

if nargin < 2
    error('You need to specify both textureCoords AND textureVector');
end

if size(textureCoords,1) ~= size(textureVector,1)
    error('textureCoords and textureVector have incompatible dimensions');
end

dims = size(textureCoords,2);
[numSampleTexturePixels, numPlanes] = size(textureVector);
if dims~=2
    error('Sorry, as yet I can only visualize 2D vectors');
end
if numPlanes~=1 && numPlanes~=3
    error('Sorry, as yet I can only visualize gray or color vectors');
end

% True, if a bkgnd image has been provided
imageProvided = (nargin>2);
if imageProvided && size(I,3)~=numPlanes
    error('Sorry, the bgnd image and the texture vector must both be color or gray');
end

if ~imageProvided
%    showTextureVectorFast(textureCoords, textureVector);
%    return;
    % If I is not provided, we have to make it
    % Find the pixel side dx so that the mean shape contains approx.
    % numSampleTexturePixels pixels
    meanTextCoords = mean(textureCoords);
    newTextureCoords  = textureCoords-repmat(meanTextCoords,[numSampleTexturePixels 1]);
    [ConvexHullIndices,ConvexHullArea] = convhull(newTextureCoords(:,1),newTextureCoords(:,2));
    dx = sqrt(ConvexHullArea/numSampleTexturePixels);
    %dx = sqrt(polyarea(newTextureCoords(:,1),newTextureCoords(:,2))/numSampleTexturePixels);
    newTextureCoords = 1/dx*newTextureCoords;
    rangeCoords = [floor(min(newTextureCoords)); ceil(max(newTextureCoords))];
    newTextureCoords = 1 + newTextureCoords - repmat(rangeCoords(1,:), [numSampleTexturePixels 1]);
    
    [dummyShape t] = alignShapesBySimilarity(textureCoords, newTextureCoords); % dummyShape==newTextureCoords
    textureCoords = newTextureCoords;
    % update rangeCoords
    rangeCoords = rangeCoords+1-repmat(rangeCoords(1,:), [2 1]);
    sidesLength = 1 + rangeCoords(2,:) - rangeCoords(1,:);
    I = ones([sidesLength(end:-1:1) numPlanes]); % [My Mx numPlanes]
    minVals = min(textureVector);
    for k=1:numPlanes
        I(:,:,k) = I(:,:,k)*minVals(k);
    end
else
% If I is provided, we have to check if it contains all pixels
    t = [0 0 0 0]; % parameters of the identity similitude
    [My Mx numPlanes] = size(I);
    rangeCoords = [floor(min(textureCoords)); ceil(max(textureCoords))];
    if sum(rangeCoords(1,:)<ones([1,dims]))~=0 || sum(rangeCoords(2,:)>[Mx My])~=0
        error('The texture coords are out-of-range of the background image.');
    end
    sidesLength = 1 + rangeCoords(2,:) - rangeCoords(1,:);
end

% the coords of all points in a rectangle grid containing 
% all points in texture coords, in row-wise order
rectangleCoords = my_cartprod(rangeCoords(1,1):rangeCoords(2,1),...
                              rangeCoords(1,2):rangeCoords(2,2));

% Find those pixels in the rectangleCoords that lie in 
% the convex hull of the shape, using a Delaunay Triangulation
tri = delaunay(textureCoords(:,1),textureCoords(:,2));
%T   = tsearch(textureCoords(:,1),textureCoords(:,2),tri,rectangleCoords(:,1),rectangleCoords(:,2));
T   = tsearchn(textureCoords,tri,rectangleCoords);
% T = tsearch(x,y,TRI,xi,yi)
% returns an index into the rows of TRI for each point in xi, yi. 
% The tsearch command returns NaN for all points outside the convex hull. 
% Requires a triangulation TRI of the points x,y obtained from delaunay.

% If I don't want to compute I in the whole convex hull, I should add
% another check:
% "if  ||(rectangleCoords(i,2),rectangleCoords(i,1)), tri(T(i),:)||<dx"
for i=1:size(rectangleCoords,1)
    if ~isnan(T(i))
        I(rectangleCoords(i,2),rectangleCoords(i,1),:) =...
            mean(textureVector(tri(T(i),:),:)); 
    end
end

% $$$ minVals = min(textureVector);
% $$$ maxVals = max(textureVector);
% $$$ if numPlanes==1 % gray texture
% $$$     imshow(I,[minVals maxVals]);
% $$$     range = max(maxVals) - min(minVals); % used to unveil range
% $$$ else            % color texture
% $$$     range = max(maxVals) - min(minVals);
% $$$     if range > 0 imshow(1/range*(I-min(minVals)));
% $$$     else imshow(I-min(minVals));
% $$$     end
% $$$ end
%disp(['MinVals: ' num2str(minVals) ', MaxVals: ' num2str(maxVals) ', Range of values: ' num2str(range)]);

%axis on;