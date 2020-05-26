#!/bin/bash

if test "$#" -ne 2; then
    echo "Usage: ./scripts/setup.sh <voice_directory_name> <emotion>"
    exit 1
fi

matlab_terminal='/usr/local/MATLAB/R2015a/bin/matlab& -nodisplay -nosplash -nojvm'
speechfeatures_version='version1' # same with SPVERSION variable of data/ Makefile
db_dir="/gpu-data2/filby/EAVTTS/CVSP_EAV"

current_working_dir=$(pwd)
merlin_dir=$(dirname $(dirname $(dirname $current_working_dir)))
experiments_dir=${current_working_dir}/experiments
project_dir=$(dirname $merlin_dir)
extracted_features_dir=${project_dir}/data

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


# duration dir
cp -r ${project_dir}/data/labels/dt/${emotion}/full/* ${duration_dir}/data/label_phone_align/
cp -r ${db_dir}/state_align_labels/dt/${emotion}/label_state_align/* ${duration_dir}/data/label_state_align/

# acoustic dir
cp -r ${project_dir}/data/labels/dt/${emotion}/full/* ${acoustic_dir}/data/label_phone_align/
cp -r ${db_dir}/state_align_labels/dt/${emotion}/label_state_align/* ${acoustic_dir}/data/label_state_align/

cp -r ${project_dir}/data/speechfeatures/dt/${emotion}/${speechfeatures_version}/bap ${acoustic_dir}/data
cp -r ${project_dir}/data/speechfeatures/dt/${emotion}/${speechfeatures_version}/mgc ${acoustic_dir}/data
cp -r ${project_dir}/data/speechfeatures/dt/${emotion}/${speechfeatures_version}/lf0 ${acoustic_dir}/data

for mfc in ${db_dir}/shape/dt/${emotion}/*.mfc; do
	n=${mfc##*/}
	n=${n%.*}
	cp ${mfc} ${acoustic_dir}/data/shape/${n}.shape
done

for mfc in ${db_dir}/texture/dt/${emotion}/*.mfc; do
	n=${mfc##*/}
	n=${n%.*}
	cp ${mfc} ${acoustic_dir}/data/texture/${n}.texture
done

cp train_scps/base_train_${emotion}.scp ${duration_dir}/data/file_id_list.scp
cp train_scps/base_train_${emotion}.scp ${acoustic_dir}/data/file_id_list.scp

# ## count number of non zero files in train
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
echo "Vocoder=STRAIGHT" >> $global_config_file
echo "SamplingFreq=16000" >> $global_config_file
echo "Audio=true" >> $global_config_file
echo "FileIDList=file_id_list.scp" >> $global_config_file
echo "Train=${num_train}" >> $global_config_file 
echo "Valid=${num_valid}" >> $global_config_file 
echo "Test=${num_test}" >> $global_config_file 
echo "emotion=${emotion}" $global_config_file
echo "Visual=true" >> $global_config_file
echo "addhtkheader=${project_dir}/data/scripts/addhtkheader.pl" >> $global_config_file

#========== Edit these paths ==========#
echo "MATLAB='/usr/local/MATLAB/R2015a/bin/matlab -nodisplay -nosplash -nojvm'" >> $global_config_file
echo "MATLAB_V=/usr/local/MATLAB/R2015a/bin/matlab" >> $global_config_file
echo "SPTK_=/usr/local/bin" >> $global_config_file
echo "STRAIGHT_DIR=/home/filby/workspace/software/legacy_STRAIGHT/src" >> $global_config_file
echo "aam_tools_path=${project_dir}/aam_model" >> $global_config_file
echo "aam_model=${project_dir}/aam_model/model/all_emotions.mat" >> $global_config_file
echo "test_synth_dir=/test_synthesis/wav_2048x4_joint" >> $global_config_file

echo "Merlin default voice settings configured in $global_config_file"
echo "setup done...!"

