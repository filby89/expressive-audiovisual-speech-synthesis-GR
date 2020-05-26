function convert_to_vid(model, mfc_file_shape, mfc_file_texture, wav_file, mkv_file, image_dir, params)
params.model_file = model;
params.image_dir = image_dir;
mfc2mp4(mfc_file_shape, mfc_file_texture, wav_file, mkv_file, params);

