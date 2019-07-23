#!/bin/bash

if test "$#" -ne 2; then
    echo "Usage: ./scripts/setup.sh <voice_directory_name> <emotion>"
    exit 1
fi

current_working_dir=$(pwd)
merlin_dir=$(dirname $(dirname $(dirname $current_working_dir)))
experiments_dir=${current_working_dir}/experiments
data_dir=${data_dir}

matlab_terminal='/usr/local/MATLAB/R2015a/bin/matlab& -nodisplay -nosplash -nojvm'

voice_name=$1_$2
emotion=$2
voice_dir=${experiments_dir}/${voice_name}

acoustic_dir=${voice_dir}/acoustic_model
duration_dir=${voice_dir}/duration_model
synthesis_dir=${voice_dir}/test_synthesis

mkdir -p ${experiments_dir}
mkdir -p ${voice_dir}
mkdir -p ${acoustic_dir}
mkdir -p ${duration_dir}
mkdir -p ${synthesis_dir}

mkdir -p ${acoustic_dir}/data/label_phone_align
mkdir -p ${duration_dir}/data/label_phone_align
mkdir -p ${acoustic_dir}/data/label_state_align
mkdir -p ${duration_dir}/data/label_state_align
mkdir -p ${acoustic_dir}/data/shape
mkdir -p ${acoustic_dir}/data/texture
mkdir -p ${acoustic_dir}/data/lf0
mkdir -p ${acoustic_dir}/data/emo


if [ ${emotion} == 'all' ]; then
	all_emotions=( 'neutral' 'angry' 'happy' 'sad')
	for i in "${all_emotions[@]}"
	do
		# duration dir
		cp -r /home/filby/av_synthesis/data/labels/dt/${i}/full/* ${duration_dir}/data/label_phone_align/
		cp -r /home/filby/av_synthesis/training/gv/qst001/ver_base_${i}_for_state_align/fal/* ${duration_dir}/data/label_state_align/

		# acoustic dir
		cp -r /home/filby/av_synthesis/data/labels/dt/${i}/full/* ${acoustic_dir}/data/label_phone_align/
		cp -r /home/filby/av_synthesis/training/gv/qst001/ver_base_${i}_for_state_align/fal/* ${acoustic_dir}/data/label_state_align/

		cp -r /home/filby/av_synthesis/data/speechfeatures/dt/${i}/special_issue_speech_features/bap ${acoustic_dir}/data
		cp -r /home/filby/av_synthesis/data/speechfeatures/dt/${i}/special_issue_speech_features/mgc ${acoustic_dir}/data
		cp -r /home/filby/av_synthesis/data/speechfeatures/dt/${i}/special_issue_speech_features/lf0 ${acoustic_dir}/data

		cp -r /home/filby/av_synthesis/data/emotion_specific_features/${i}/* ${acoustic_dir}/data/emo/

		for mfc in /home/filby/av_synthesis/data/shape/dt/${i}/*.mfc; do
			n=${mfc##*/}
			n=${n%.*}
			cp ${mfc} ${acoustic_dir}/data/shape/${n}.shape
		done

		for mfc in /home/filby/av_synthesis/data/texture/dt/${i}/*.mfc; do
			n=${mfc##*/}
			n=${n%.*}
			cp ${mfc} ${acoustic_dir}/data/texture/${n}.texture
		done
	done

	cp train_scps/base_train_${emotion}.scp ${acoustic_dir}/data/file_id_list.scp

	# cp ${acoustic_dir}/data/file_id_list.scp ${duration_dir}/data/file_id_list.scp

	# duration dir
	# cp -r /home/filby/av_synthesis/data/labels/dt/${emotion}/full/* ${duration_dir}/data/label_phone_align/
	# cp -r /home/filby/av_synthesis/training/gv/qst001/ver_base_${emotion}_for_state_align/fal/* ${duration_dir}/data/label_state_align/

	# # acoustic dir
	# cp -r /home/filby/av_synthesis/data/labels/dt/${emotion}/full/* ${acoustic_dir}/data/label_phone_align/
	# cp -r /home/filby/av_synthesis/training/gv/qst001/ver_base_${emotion}_for_state_align/fal/* ${acoustic_dir}/data/label_state_align/

	# cp -r /home/filby/av_synthesis/data/speechfeatures/dt/${emotion}/special_issue_speech_features/bap ${acoustic_dir}/data
	# cp -r /home/filby/av_synthesis/data/speechfeatures/dt/${emotion}/special_issue_speech_features/mgc ${acoustic_dir}/data
	# cp -r /home/filby/av_synthesis/data/speechfeatures/dt/${emotion}/special_issue_speech_features/lf0 ${acoustic_dir}/data

	# for mfc in /home/filby/av_synthesis/data/shape/dt/${emotion}/*.mfc; do
	# 	n=${mfc##*/}
	# 	n=${n%.*}
	# 	cp ${mfc} ${acoustic_dir}/data/shape/${n}.shape
	# done

	# for mfc in /home/filby/av_synthesis/data/texture/dt/${emotion}/*.mfc; do
	# 	n=${mfc##*/}
	# 	n=${n%.*}
	# 	cp ${mfc} ${acoustic_dir}/data/texture/${n}.texture
	# done

	# # synthesis dir
	# cp -r /home/filby/av_synthesis/merlin/egs/greek/s1/test_${emotion}/* ${synthesis_dir}
	# mv ${synthesis_dir}/test.review.scp ${synthesis_dir}/test_id_list.scp

	# cp train_scps/base_train_${emotion}.review.scp ${acoustic_dir}/data/file_id_list.scp

	# # python scripts/generate_scp.py ${acoustic_dir}/data

	# cp ${acoustic_dir}/data/file_id_list.scp ${duration_dir}/data/file_id_list.scp

fi

# ## count number of non zero files in train
# num_train=wc -l ${acoustic_dir}/data/file_id_list.scp
# num_valid=10
# num_train=`expr ${num_train} - ${num_valid}`
num_test=10
num_valid=20
num_train=744


echo "data is ready!"

global_config_file=conf/global_settings.cfg

### default settings ###
echo "MerlinDir=${merlin_dir}" >  $global_config_file
echo "WorkDir=${current_working_dir}" >>  $global_config_file
echo "Voice=${voice_name}" >> $global_config_file
echo "Labels=state_align" >> $global_config_file
echo "QuestionFile=questions-greek.hed" >> $global_config_file
echo "Vocoder=STRAIGHT_M_TRIAL" >> $global_config_file
echo "SamplingFreq=16000" >> $global_config_file
echo "Audio=true" >> $global_config_file
echo "STRAIGHT_M_TRIAL_DIR=/home/filby/av_synthesis/STRAIGHTtrial/Resources/STRAIGHTV40pcode" >> $global_config_file
echo "FileIDList=file_id_list.scp" >> $global_config_file
echo "Train=${num_train}" >> $global_config_file 
echo "Valid=${num_valid}" >> $global_config_file 
echo "Test=${num_test}" >> $global_config_file 
echo "matlab_command=${matlab_terminal}" $global_config_file
echo "emotion=${emotion}" $global_config_file
echo "Visual=true" >> $global_config_file
echo "MATLAB='/usr/local/MATLAB/R2014a/bin/matlab -nodisplay -nosplash -nojvm'" >> $global_config_file
echo "MATLAB_V=/usr/local/MATLAB/R2014a/bin/matlab" >> $global_config_file
echo "addhtkheader=/home/filby/av_synthesis/data/scripts/addhtkheader.pl" >> $global_config_file
echo "aam_tools_path=/home/filby/av_synthesis/visual_data/aam-tools" >> $global_config_file
echo "aam_tools_extra_scripts=/home/filby/av_synthesis/visual_data/aam-tools/filby/scripts" >> $global_config_file
echo "aam_model=/home/filby/av_synthesis/visual_data/aam-tools/filby/trained_models/all_emotions.mat" >> $global_config_file
echo "test_synth_dir=/test_synthesis/wav_2048x4_joint" >> $global_config_file

echo "Merlin default voice settings configured in $global_config_file"
echo "setup done...!"

