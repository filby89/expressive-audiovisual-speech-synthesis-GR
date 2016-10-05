#!/bin/bash

if test "$#" -ne 1; then
    echo "Usage: ./scripts/setup.sh <voice_directory_name>"
    exit 1
fi

current_working_dir=$(pwd)
merlin_dir=$(dirname $(dirname $(dirname $current_working_dir)))
experiments_dir=${current_working_dir}/experiments

voice_name=$1
voice_dir=${experiments_dir}/${voice_name}

acoustic_dir=${voice_dir}/acoustic_model
duration_dir=${voice_dir}/duration_model
synthesis_dir=${voice_dir}/test_synthesis

mkdir -p ${experiments_dir}
mkdir -p ${voice_dir}
mkdir -p ${acoustic_dir}
mkdir -p ${duration_dir}

data_dir=cvsp_ip_data


cp -r ${data_dir}/merlin_baseline_practice/acoustic_data/label_phone_align ${duration_dir}/data
cp -r ${data_dir}/merlin_baseline_practice/acoustic_data/label_state_align ${duration_dir}/data
cp ${data_dir}/merlin_baseline_practice/acoustic_data/file_id_list_full.scp ${duration_dir}/data
cp -r ${data_dir}/merlin_baseline_practice/acoustic_data/ ${acoustic_dir}/data
cp -r ${data_dir}/merlin_baseline_practice/test_data/ ${synthesis_dir}

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
echo "Visual=true" >> $global_config_file
echo "STRAIGHT_M_TRIAL_DIR='/home/filby/workspace/phd/audiovisual_speech_synthesis/STRAIGHTtrial/Resources/STRAIGHTV40pcode'"
echo "FileIDList=file_id_list_full.scp" >> $global_config_file
echo "Train=800" >> $global_config_file 
echo "Valid=47" >> $global_config_file 
echo "Test=48" >> $global_config_file 
echo "matlab_command='/usr/local/MATLAB/MATLAB_Production_Server/R2015a/bin -nodisplay -nosplash -nojvm'"

echo "Merlin default voice settings configured in $global_config_file"
echo "setup done...!"

