################################################################################
#           The Neural Network (NN) based Speech Synthesis System
#                https://svn.ecdf.ed.ac.uk/repo/inf/dnn_tts/
#                
#                Centre for Speech Technology Research                 
#                     University of Edinburgh, UK                       
#                      Copyright (c) 2014-2015
#                        All Rights Reserved.                           
#                                                                       
# The system as a whole and most of the files in it are distributed
# under the following copyright and conditions
#
#  Permission is hereby granted, free of charge, to use and distribute  
#  this software and its documentation without restriction, including   
#  without limitation the rights to use, copy, modify, merge, publish,  
#  distribute, sublicense, and/or sell copies of this work, and to      
#  permit persons to whom this work is furnished to do so, subject to   
#  the following conditions:
#  
#   - Redistributions of source code must retain the above copyright  
#     notice, this list of conditions and the following disclaimer.   
#   - Redistributions in binary form must reproduce the above         
#     copyright notice, this list of conditions and the following     
#     disclaimer in the documentation and/or other materials provided 
#     with the distribution.                                          
#   - The authors' names may not be used to endorse or promote products derived 
#     from this software without specific prior written permission.   
#                                  
#  THE UNIVERSITY OF EDINBURGH AND THE CONTRIBUTORS TO THIS WORK        
#  DISCLAIM ALL WARRANTIES WITH REGARD TO THIS SOFTWARE, INCLUDING      
#  ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS, IN NO EVENT   
#  SHALL THE UNIVERSITY OF EDINBURGH NOR THE CONTRIBUTORS BE LIABLE     
#  FOR ANY SPECIAL, INDIRECT OR CONSEQUENTIAL DAMAGES OR ANY DAMAGES    
#  WHATSOEVER RESULTING FROM LOSS OF USE, DATA OR PROFITS, WHETHER IN   
#  AN ACTION OF CONTRACT, NEGLIGENCE OR OTHER TORTIOUS ACTION,          
#  ARISING OUT OF OR IN CONNECTION WITH THE USE OR PERFORMANCE OF       
#  THIS SOFTWARE.
################################################################################

#/usr/bin/python -u

'''
This script assumes c-version STRAIGHT which is not available to public. Please use your 
own vocoder to replace this script. 
'''
import sys, os, subprocess, glob, commands
#from utils import GlobalCfg

from io_funcs.binary_io import  BinaryIOCollection
import numpy as np

import logging

#import configuration

# cannot have these outside a function - if you do that, they get executed as soon
# as this file is imported, but that can happen before the configuration is set up properly
# SPTK     = cfg.SPTK
# NND      = cfg.NND
# STRAIGHT = cfg.STRAIGHT


def run_process(args,log=True):

    logger = logging.getLogger("subprocess")
    
    # a convenience function instead of calling subprocess directly
    # this is so that we can do some logging and catch exceptions
    
    # we don't always want debug logging, even when logging level is DEBUG
    # especially if calling a lot of external functions
    # so we can disable it by force, where necessary
    if log:
        logger.debug('%s' % args)

    try:
        # the following is only available in later versions of Python
        # rval = subprocess.check_output(args)
        
        # bufsize=-1 enables buffering and may improve performance compared to the unbuffered case
        p = subprocess.Popen(args, bufsize=-1, shell=True, 
                        stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE,
                        close_fds=True)
        # better to use communicate() than read() and write() - this avoids deadlocks
        (stdoutdata, stderrdata) = p.communicate()

        if p.returncode != 0:
            # for critical things, we always log, even if log==False
            logger.critical('exit status %d' % p.returncode )
            logger.critical(' for command: %s' % args )
            logger.critical('      stderr: %s' % stderrdata )
            logger.critical('      stdout: %s' % stdoutdata )
            raise OSError
            
        return (stdoutdata, stderrdata)
        
    except subprocess.CalledProcessError as e:
        # not sure under what circumstances this exception would be raised in Python 2.6
        logger.critical('exit status %d' % e.returncode )
        logger.critical(' for command: %s' % args )
        # not sure if there is an 'output' attribute under 2.6 ? still need to test this...
        logger.critical('  output: %s' % e.output )
        raise

    except ValueError:
        logger.critical('ValueError for %s' % args )
        raise
        
    except OSError:
        logger.critical('OSError for %s' % args )
        raise

    except KeyboardInterrupt:
        logger.critical('KeyboardInterrupt during %s' % args )
        try:
            # try to kill the subprocess, if it exists
            p.kill()
        except UnboundLocalError:
            # this means that p was undefined at the moment of the keyboard interrupt
            # (and we do nothing)
            pass

        raise KeyboardInterrupt
        

def bark_alpha(sr):
    return 0.8517*np.sqrt(np.arctan(0.06583*sr/1000.0))-0.1916

def erb_alpha(sr):
    return 0.5941*np.sqrt(np.arctan(0.1418*sr/1000.0))+0.03237


def generate_wav(gen_dir, file_id_list, cfg):
        
    logger = logging.getLogger("wav_generation")
    
    SPTK     = cfg.SPTK
#    NND      = cfg.NND
    STRAIGHT = cfg.STRAIGHT
    WORLD    = cfg.WORLD

    ## to be moved
    pf_coef = cfg.pf_coef
    if isinstance(cfg.fw_alpha, basestring):
        if cfg.fw_alpha=='Bark':
            fw_coef = bark_alpha(cfg.sr)
        elif cfg.fw_alpha=='ERB':
            fw_coef = bark_alpha(cfg.sr)
        else:
            raise ValueError('cfg.fw_alpha='+cfg.fw_alpha+' not implemented, the frequency warping coefficient "fw_coef" cannot be deduced.')
    else:
        fw_coef = cfg.fw_alpha
    co_coef = cfg.co_coef
    fl_coef = cfg.fl

    if cfg.apply_GV:
        io_funcs = BinaryIOCollection()

        logger.info('loading global variance stats from %s' % (cfg.GV_dir))

        ref_gv_mean_file = os.path.join(cfg.GV_dir, 'ref_gv.mean')
        gen_gv_mean_file = os.path.join(cfg.GV_dir, 'gen_gv.mean')
        ref_gv_std_file  = os.path.join(cfg.GV_dir, 'ref_gv.std')
        gen_gv_std_file  = os.path.join(cfg.GV_dir, 'gen_gv.std')

        ref_gv_mean, frame_number = io_funcs.load_binary_file_frame(ref_gv_mean_file, 1)
        gen_gv_mean, frame_number = io_funcs.load_binary_file_frame(gen_gv_mean_file, 1)
        ref_gv_std, frame_number = io_funcs.load_binary_file_frame(ref_gv_std_file, 1)
        gen_gv_std, frame_number = io_funcs.load_binary_file_frame(gen_gv_std_file, 1)

    counter=1
    max_counter = len(file_id_list)

    for filename in file_id_list:

        logger.info('creating waveform for %4d of %4d: %s' % (counter,max_counter,filename) )
        counter=counter+1
        base   = filename
        files = {'sp'  : base + cfg.sp_ext,
                 'mgc' : base + cfg.mgc_ext,
                 'f0'  : base + '.f0',
                 'lf0' : base + cfg.lf0_ext,
                 'ap'  : base + '.ap',
                 'bap' : base + cfg.bap_ext,
                 'sha' : base + cfg.sha_ext,
                 'tex' : base + cfg.tex_ext,
                 'wav' : base + '.wav'}

        mgc_file_name = files['mgc']
        bap_file_name = files['bap']
        
        cur_dir = os.getcwd()
        os.chdir(gen_dir)

        ### post-filtering
        if cfg.do_post_filtering:
            line = "echo 1 1 "
            for i in range(2, cfg.mgc_dim):
                line = line + str(pf_coef) + " "

            run_process('{line} | {x2x} +af > {weight}'
                        .format(line=line, x2x=SPTK['X2X'], weight=os.path.join(gen_dir, 'weight')))

            run_process('{freqt} -m {order} -a {fw} -M {co} -A 0 < {mgc} | {c2acr} -m {co} -M 0 -l {fl} > {base_r0}'
                        .format(freqt=SPTK['FREQT'], order=cfg.mgc_dim-1, fw=fw_coef, co=co_coef, mgc=files['mgc'], c2acr=SPTK['C2ACR'], fl=fl_coef, base_r0=files['mgc']+'_r0'))

            run_process('{vopr} -m -n {order} < {mgc} {weight} | {freqt} -m {order} -a {fw} -M {co} -A 0 | {c2acr} -m {co} -M 0 -l {fl} > {base_p_r0}'
                        .format(vopr=SPTK['VOPR'], order=cfg.mgc_dim-1, mgc=files['mgc'], weight=os.path.join(gen_dir, 'weight'),
                                freqt=SPTK['FREQT'], fw=fw_coef, co=co_coef, 
                                c2acr=SPTK['C2ACR'], fl=fl_coef, base_p_r0=files['mgc']+'_p_r0'))

            run_process('{vopr} -m -n {order} < {mgc} {weight} | {mc2b} -m {order} -a {fw} | {bcp} -n {order} -s 0 -e 0 > {base_b0}'
                        .format(vopr=SPTK['VOPR'], order=cfg.mgc_dim-1, mgc=files['mgc'], weight=os.path.join(gen_dir, 'weight'),
                                mc2b=SPTK['MC2B'], fw=fw_coef, 
                                bcp=SPTK['BCP'], base_b0=files['mgc']+'_b0'))

            run_process('{vopr} -d < {base_r0} {base_p_r0} | {sopr} -LN -d 2 | {vopr} -a {base_b0} > {base_p_b0}'
                        .format(vopr=SPTK['VOPR'], base_r0=files['mgc']+'_r0', base_p_r0=files['mgc']+'_p_r0', 
                                sopr=SPTK['SOPR'], 
                                base_b0=files['mgc']+'_b0', base_p_b0=files['mgc']+'_p_b0'))
          
            run_process('{vopr} -m -n {order} < {mgc} {weight} | {mc2b} -m {order} -a {fw} | {bcp} -n {order} -s 1 -e {order} | {merge} -n {order2} -s 0 -N 0 {base_p_b0} | {b2mc} -m {order} -a {fw} > {base_p_mgc}'
                        .format(vopr=SPTK['VOPR'], order=cfg.mgc_dim-1, mgc=files['mgc'], weight=os.path.join(gen_dir, 'weight'),
                                mc2b=SPTK['MC2B'],  fw=fw_coef, 
                                bcp=SPTK['BCP'], 
                                merge=SPTK['MERGE'], order2=cfg.mgc_dim-2, base_p_b0=files['mgc']+'_p_b0',
                                b2mc=SPTK['B2MC'], base_p_mgc=files['mgc']+'_p_mgc'))

            mgc_file_name = files['mgc']+'_p_mgc'
            
        if (cfg.vocoder_type == "STRAIGHT" or cfg.vocoder_type == "STRAIGHT_M_TRIAL") and cfg.apply_GV:
            gen_mgc, frame_number = io_funcs.load_binary_file_frame(mgc_file_name, cfg.mgc_dim)

            gen_mu  = np.reshape(np.mean(gen_mgc, axis=0), (-1, 1))
            gen_std = np.reshape(np.std(gen_mgc, axis=0), (-1, 1))
   
            local_gv = (ref_gv_std/gen_gv_std) * (gen_std - gen_gv_mean) + ref_gv_mean;
   
            enhanced_mgc = np.repeat(local_gv, frame_number, 1).T / np.repeat(gen_std, frame_number, 1).T * (gen_mgc - np.repeat(gen_mu, frame_number, 1).T) + np.repeat(gen_mu, frame_number, 1).T;
            
            new_mgc_file_name = files['mgc']+'_p_mgc'
            io_funcs.array_to_binary_file(enhanced_mgc, new_mgc_file_name) 
            
            mgc_file_name = files['mgc']+'_p_mgc'
        
        if cfg.do_post_filtering and cfg.apply_GV:
            logger.critical('Both smoothing techniques together can\'t be applied!!\n' )
            raise

        ###mgc to sp to wav
        if cfg.vocoder_type == 'STRAIGHT':
            run_process('{mgc2sp} -a {alpha} -g 0 -m {order} -l {fl} -o 2 {mgc} > {sp}'
                        .format(mgc2sp=SPTK['MGC2SP'], alpha=cfg.fw_alpha, order=cfg.mgc_dim-1, fl=cfg.fl, mgc=mgc_file_name, sp=files['sp']))
            run_process('{sopr} -magic -1.0E+10 -EXP -MAGIC 0.0 {lf0} > {f0}'.format(sopr=SPTK['SOPR'], lf0=files['lf0'], f0=files['f0']))
            run_process('{x2x} +fa {f0} > {f0a}'.format(x2x=SPTK['X2X'], f0=files['f0'], f0a=files['f0'] + '.a'))

            if cfg.use_cep_ap:
                run_process('{mgc2sp} -a {alpha} -g 0 -m {order} -l {fl} -o 0 {bap} > {ap}'
                            .format(mgc2sp=SPTK['MGC2SP'], alpha=cfg.fw_alpha, order=cfg.bap_dim-1, fl=cfg.fl, bap=files['bap'], ap=files['ap']))
            else:
                run_process('{bndap2ap} {bap} > {ap}' 
                             .format(bndap2ap=STRAIGHT['BNDAP2AP'], bap=files['bap'], ap=files['ap']))

            run_process('{synfft} -f {sr} -spec -fftl {fl} -shift {shift} -sigp 0.0 -cornf 400 -float -apfile {ap} {f0a} {sp} {wav}'
                        .format(synfft=STRAIGHT['SYNTHESIS_FFT'], sr=cfg.sr, fl=cfg.fl, shift=cfg.shift, ap=files['ap'], f0a=files['f0']+'.a', sp=files['sp'], wav=files['wav']))

            run_process('rm -f {sp} {f0} {f0a} {ap}'
                        .format(sp=files['sp'],f0=files['f0'],f0a=files['f0']+'.a',ap=files['ap']))
        ###mgc to sp to wav
        if cfg.vocoder_type == 'STRAIGHT_M_TRIAL':
            run_process('{mgc2sp} -a {alpha} -g 0 -m {order} -l {fl} -o 2 {mgc} > {sp}'
                        .format(mgc2sp=SPTK['MGC2SP'], alpha=cfg.fw_alpha, order=cfg.mgc_dim-1, fl=cfg.fl, mgc=mgc_file_name, sp=files['sp']))
            run_process('{sopr} -magic -1.0E+10 -EXP -MAGIC 0.0 {lf0} > {f0}'.format(sopr=SPTK['SOPR'], lf0=files['lf0'], f0=files['f0']))
            run_process('{x2x} +fa {f0} > {f0a}'.format(x2x=SPTK['X2X'], f0=files['f0'], f0a=files['f0'] + '.a'))

            if cfg.use_cep_ap:
                run_process('{mgc2sp} -a {alpha} -g 0 -m {order} -l {fl} -o 0 {bap} > {ap}'
                            .format(mgc2sp=SPTK['MGC2SP'], alpha=cfg.fw_alpha, order=cfg.bap_dim-1, fl=cfg.fl, bap=files['bap'], ap=files['ap']))
            else:
                run_process('{bndap2ap} {bap} > {ap}' 
                             .format(bndap2ap=STRAIGHT['BNDAP2AP'], bap=files['bap'], ap=files['ap']))


            # added by filntisis 5/10/2016
            # copied from hts

            size = os.path.getsize(files['f0'])
            straight_normalization = 1024.0 / ( 2200.0 * 32768.0 )

            spectralUpdateInterval = 1000.0 * cfg.shift / cfg.sr
            synth_straight_file_name = base + '_synth.m'
            synth_straight_file = open(synth_straight_file_name, "w")
            synth_straight_file.write("path(path,'%s');\n" % cfg.STRAIGHT_M_TRIAL_DIR)
            synth_straight_file.write("prm.spectralUpdateInterval = %f;\n" % spectralUpdateInterval)
            synth_straight_file.write("prm.levelNormalizationIndicator = 0;\n\n")
            synth_straight_file.write("fprintf(1,'\\nSynthesizing %s\\n');\n"% files['wav'])
            synth_straight_file.write("fid1 = fopen('%s','r','%s');\n"%        (files['sp'], "ieee-le"))
            synth_straight_file.write("fid2 = fopen('%s','r','%s');\n"%        (files['ap'], "ieee-le"))
            synth_straight_file.write("fid3 = fopen('%s','r','%s');\n"%        (files['f0'], "ieee-le"))
            synth_straight_file.write("sp = fread(fid1,[%d, %d],'float');\n" % (513, size) )
            synth_straight_file.write("ap = fread(fid2,[%d, %d],'float');\n" % (513, size))
            synth_straight_file.write("f0 = fread(fid3,[%d, %d],'float');\n" % (1, size))
            synth_straight_file.write("fclose(fid1);\n")
            synth_straight_file.write("fclose(fid2);\n")
            synth_straight_file.write("fclose(fid3);\n")
#            synth_straight_file.write("sp = sp/32768.0;\n")
            synth_straight_file.write("sp = sp*(%f);\n" % straight_normalization)    # normalization for STRAIGHT (sdev of amplitude is set to 1024)         printf SYN "wavwrite( sy, %d, '%s');\n\n", $sr, "$gendir/$base.wav";

            synth_straight_file.write("[sy] = exstraightsynth(f0,sp,ap,%d,prm);\n" % cfg.sr)
            synth_straight_file.write("wavwrite( sy, %d, '%s');\n\n" % (cfg.sr, files['wav']))
            synth_straight_file.write("quit;\n")
            
            synth_straight_file.close()

            run_process("%s < %s" % (cfg.MATLAB_COMMAND, synth_straight_file_name))


        #   generate talking head
            # synth_straight_file_name = base + '_vid_synth.m'
            # synth_straight_file = open(synth_straight_file_name, "w")

            # bytes_per_frame_shape = cfg.sha_dim * 4
            # output_name_shape = base + '.sha_h'
            # run_process('/usr/bin/perl /home/filby/workspace/phd/audiovisual_speech_synthesis/data/scripts/addhtkheader.pl %d %d %d 9 %s > %s' % (cfg.sr, cfg.shift, bytes_per_frame_shape, files['sha'], output_name_shape))

            # bytes_per_frame_texture = cfg.tex_dim * 4
            # output_name_texture = base + '.tex_h'
            # run_process('/usr/bin/perl /home/filby/workspace/phd/audiovisual_speech_synthesis/data/scripts/addhtkheader.pl %d %d %d 9 %s > %s' % (cfg.sr, cfg.shift, bytes_per_frame_texture, files['tex'], output_name_texture))

            # synth_straight_file.write("cd /home/filby/workspace/phd/audiovisual_speech_synthesis/visual_data/aam-tools;\n")
            # synth_straight_file.write("addAamPaths;\n")
            # synth_straight_file.write("addpath /home/filby/workspace/phd/audiovisual_speech_synthesis/visual_data/aam-tools/filby/scripts\n")
            # synth_straight_file.write("params.num_sh = %d;\n" % cfg.sha_dim)
            # synth_straight_file.write("params.num_te = %d;\n" % cfg.tex_dim)
            # synth_straight_file.write("params.fps = %f;\n" % 29.97)
            # synth_straight_file.write("figure('Visible','Off')\n")
            # synth_straight_file.write("convert_to_vid_divided('%s', '%s', '%s', '%s', '%s', '%s', params);\n" % ("/home/filby/workspace/phd/audiovisual_speech_synthesis/visual_data/aam-tools/filby/trained_models/neutral/25SOSLATEST.mat", os.path.join(gen_dir, output_name_shape), os.path.join(gen_dir, output_name_texture), os.path.join(gen_dir, (base + '.wav')), os.path.join(gen_dir, (base + '.mkv')), gen_dir))
            # synth_straight_file.write("quit;\n")


            # run_process("%s < %s" % ('/usr/local/MATLAB/MATLAB_Production_Server/R2015a/bin/matlab', synth_straight_file_name))

#            run_process('rm -f {sp} {f0} {f0a} {ap}'
 #                       .format(sp=files['sp'],f0=files['f0'],f0a=files['f0']+'.a',ap=files['ap']))
  
        elif cfg.vocoder_type == 'WORLD':        

            run_process('{sopr} -magic -1.0E+10 -EXP -MAGIC 0.0 {lf0} | {x2x} +fd > {f0}'.format(sopr=SPTK['SOPR'], lf0=files['lf0'], x2x=SPTK['X2X'], f0=files['f0']))        
            
            run_process('{sopr} -c 0 {bap} | {x2x} +fd > {ap}'.format(sopr=SPTK['SOPR'],bap=files['bap'],x2x=SPTK['X2X'],ap=files['ap']))
            
            ### If using world v2, please comment above line and uncomment this
            #run_process('{mgc2sp} -a {alpha} -g 0 -m {order} -l {fl} -o 0 {bap} | {sopr} -d 32768.0 -P | {x2x} +fd > {ap}'
            #            .format(mgc2sp=SPTK['MGC2SP'], alpha=cfg.fw_alpha, order=cfg.bap_dim, fl=cfg.fl, bap=bap_file_name, sopr=SPTK['SOPR'], x2x=SPTK['X2X'], ap=files['ap']))

            run_process('{mgc2sp} -a {alpha} -g 0 -m {order} -l {fl} -o 2 {mgc} | {sopr} -d 32768.0 -P | {x2x} +fd > {sp}'
                        .format(mgc2sp=SPTK['MGC2SP'], alpha=cfg.fw_alpha, order=cfg.mgc_dim-1, fl=cfg.fl, mgc=mgc_file_name, sopr=SPTK['SOPR'], x2x=SPTK['X2X'], sp=files['sp']))

            run_process('{synworld} {fl} {sr} {f0} {sp} {ap} {wav}'
                         .format(synworld=WORLD['SYNTHESIS'], fl=cfg.fl, sr=cfg.sr, f0=files['f0'], sp=files['sp'], ap=files['ap'], wav=files['wav']))
            
            run_process('rm -f {ap} {sp} {f0}'.format(ap=files['ap'],sp=files['sp'],f0=files['f0']))

        else:
        
            logger.critical('The vocoder %s is not supported yet!\n' % cfg.vocoder_type )
            raise
        
        os.chdir(cur_dir)

