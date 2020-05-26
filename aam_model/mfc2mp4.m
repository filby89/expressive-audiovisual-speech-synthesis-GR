function mfc2mp4(mfc_file_shape, mfc_file_texture, wav_file, mkv_file, params, nowav)
% params.model_file = 'models/katerina_greek.mat';
% params.image_dir = data/synimages/katerina_greek;
% params.num_sh = 12;
% params.num_te = 28;
% params.fps = 25;
% Convert an mfc file of facial aam params to a video of the face
ps_model = load(params.model_file, 'etuParams');

synthesis_dir = params.image_dir;

%%%%%% handle shape %%%%%%

[pth, file_id] = fileparts(mfc_file_shape);
    
[h_shape, q_shape] = readHTK(mfc_file_shape);

%lighting = q(1:2);
%q = q(3:end,:);
sPeriod = h_shape.sPeriod*10^-7;
frames_per_second = params.fps;
rate_shape = round((1/frames_per_second)/sPeriod);
n_frames_shape = size(q_shape,2);
image_dir = fullfile(synthesis_dir,file_id);

%%%%%% handle texture %%%%%%

[pth, file_id] = fileparts(mfc_file_texture);
    
[h_texture, q_texture] = readHTK(mfc_file_texture);
%lighting = q(1:2);
%q = q(3:end,:);
sPeriod = h_texture.sPeriod*10^-7;

frames_per_second = params.fps;
rate_texture = round((1/frames_per_second)/sPeriod);
n_frames_texture = size(q_texture,2);
image_dir = fullfile(synthesis_dir,file_id);

mkdir(image_dir);

qparl_shape = (resample(q_shape', 100*29.97, 100*200))';
qparl_texture = (resample(q_texture', 100*29.97, 100*200))';



if rate_shape~=rate_texture || size(qparl_shape,2)~=size(qparl_texture,2) || n_frames_shape~=n_frames_texture
	error('wtf');
end

obs_num = size(qparl_shape,2);

i_frame = 1;
[tmp, tmp2, tmp3] = synthesizeAppearance(ps_model.etuParams, qparl_shape(:,i_frame), qparl_texture(:,i_frame), params);
%size(tmp3)
[siza sizb] = size(tmp);
FullTextCoords = zeros(siza, sizb, obs_num);
[siza sizb] = size(tmp2);
FullTextureVec = zeros(siza, sizb, obs_num);


%size(qparl_texture)
%size(qparl_shape)

parfor i_frame = 1:obs_num
    [tmp tmp2 tmp3] = synthesizeAppearance(ps_model.etuParams, qparl_shape(:,i_frame),  qparl_texture(:,i_frame), params);
    %synthesizeAppearance(ps_model.etuParams, qparl(1:new_data_range,i_frame), params);	%uncomment for using less eigentextures

    FullTextCoords(:,:,i_frame) = tmp;
    FullTextureVec(:,:,i_frame) = tmp2;
    FullShapeVec(:,:,i_frame) = tmp3;
  
    set(gcf, 'color', 'k');
    set(gcf, 'InvertHardcopy', 'off');

    print('-r45', gcf, '-djpeg90', fullfile(image_dir,sprintf('img_%04d.jpg',i_frame)));

end

% this can be uncommented to print the shape
%parfor i_frame = 1:obs_num
%    scatterplot_options = { ...
%      'point_num',false, 'LineStyle','none','LineWidth',1,'Color','b', ...
%      'Marker','x','MarkerSize',10,'MarkerEdgeColor','b', ...
%      'draw_tri',true,'TriLineStyle','-','TriLineWidth',1,'TriColor','b'};

%   scatterPlot2DShape(FullShapeVec(:,:,i_frame),scatterplot_options{:});  title('');    

%   hold on;
%   quiver_options = { ...
% 'LineStyle','-','LineWidth',1,'Color1','r', 'Color2','g','v_scale',2};
%my_quiver(FullShapeVec(:,:,i_frame),ps_model.etuParams(1).shapes,quiver_options{:});
%hold off
%   print('-r45', gcf, '-djpeg90', fullfile(image_dir,sprintf('img_%04d.jpg',i_frame)));
%end

system(sprintf('ffmpeg -framerate 29.97 -i %s -i %s -c:v libx264 -c:a copy -r 29.97 -pix_fmt yuv420p -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" -y %s', ...
     fullfile(image_dir,'img_%04d.jpg'), wav_file, mkv_file));
