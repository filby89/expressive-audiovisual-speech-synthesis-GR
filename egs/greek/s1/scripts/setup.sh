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

#if [[ ! -f ${data_dir}.zip ]]; then
#    echo "downloading data....."
    # rm -f ${data_dir}.zip
    # data_url=http://104.131.174.95/${data_dir}.zip
    # if hash curl 2>/dev/null; then
    #     curl -O $data_url
    # elif hash wget 2>/dev/null; then
    #     wget $data_url
    # else
    #     echo "please download the data from $data_url"
    #     exit 1
    # fi
    # do_unzip=true
#fi
#if [[ ! -d ${data_dir} ]] || [[ -n "$do_unzip" ]]; then
    # echo "unzipping files......"
    # rm -fr ${data_dir}
    # rm -fr ${duration_dir}/data
    # rm -fr ${acoustic_dir}/data
    # unzip -q ${data_dir}.zip -d .
    cp -r ${data_dir}/merlin_baseline_practice/acoustic_data/label_phone_align ${duration_dir}/data
    cp -r ${data_dir}/merlin_baseline_practice/acoustic_data/label_state_align ${duration_dir}/data
    cp ${data_dir}/merlin_baseline_practice/acoustic_data/file_id_list_full.scp ${duration_dir}/data
    cp -r ${data_dir}/merlin_baseline_practice/acoustic_data/ ${acoustic_dir}/data
    cp -r ${data_dir}/merlin_baseline_practice/test_data/ ${synthesis_dir}
#fi
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

echo "FileIDList=file_id_list_full.scp" >> $global_config_file
echo "Train=800" >> $global_config_file 
echo "Valid=47" >> $global_config_file 
echo "Test=48" >> $global_config_file 

echo "Merlin default voice settings configured in $global_config_file"
echo "setup done...!"

