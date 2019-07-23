#!/bin/bash

if test "$#" -ne 0; then
    echo "Usage: ./run_full_voice.sh"
    exit 1
fi

echo "Step 1: setting up experiments directory and the training data files..."
global_config_file=conf/global_settings.cfg
./scripts/setup.sh cvsp_greek_voices_dt angry
./scripts/prepare_config_files.sh $global_config_file
./scripts/prepare_config_files_for_synthesis.sh $global_config_file

source $global_config_file

echo "Step 2: training duration model..."
./scripts/submit.sh ${MerlinDir}/src/run_merlin.py conf/duration_${Voice}.conf

echo "Step 3: training acoustic model..."
./scripts/submit.sh ${MerlinDir}/src/run_merlin.py conf/acoustic_${Voice}.conf

# echo "Step 4: synthesizing speech..."
 ./scripts/submit.sh ${MerlinDir}/src/run_merlin.py conf/test_dur_synth_${Voice}.conf
 ./scripts/submit.sh ${MerlinDir}/src/run_merlin.py conf/test_synth_${Voice}.conf

# echo "synthesized audio files are in: experiments/${Voice}/test_synthesis/wav"
# echo "All successfull!! Your full voice is ready :)"

