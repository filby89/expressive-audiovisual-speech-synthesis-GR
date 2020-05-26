function [textureCoords, texture, shape] = synthesizeAppearance(aamParams, q_shape, q_texture, params)
% Changing code by fildisis in order to work in parfor (imshow doesnt work in parallel sadly)
% Changing 
%  te_ind_s = params.num_sh + 1;
%  te_ind_e = params.num_sh + params.num_te;
  shape = synthesizeShape(aamParams(1).shapes, q_shape);
%	[numSampleTexturePixels numPlanes numShapes] = size(aamParams(1).textures);
%	display(numShapes);
%	display(length(q_texture));
  texture = synthesizeTexture(aamParams(1).textures, q_texture);




  thinPlateParams = computeThinPlateWarpParams(aamParams(1).shapes_mean, shape, aamParams(1).tps);
  textureCoords = computeTargetShapeFromThinPlateWarpParams(thinPlateParams, ...
                          aamParams(1).shapes_mean, aamParams(1).textMap.textureCoords); 
  [I, h] = showTextureVector(textureCoords, texture);
