#!/usr/bin/perl

# Settings ==============================

# ============================== Edit these variables to represent your system - required ============================== #

$prjdir = '/kalymnos_home/filby/workspace/expressive-audiovisual-speech-synthesis-GR'; # one dir above

# MATLAB & STRAIGHT
$MATLAB   = '/usr/local/MATLAB/R2015a/bin/matlab -nodisplay -nosplash -nojvm';
$STRAIGHT = '/home/filby/workspace/software/legacy_STRAIGHT/src';
$MATLABV  = '/usr/local/MATLAB/R2015a/bin/matlab';

$HTS_PATH = '/usr/local/HTS-2.3/bin';

$SPTK_PATH = "/usr/local/bin";

$emotion = "neutral";

$CVSP_EAV_DIR = "/gpu-data2/filby/EAVTTS/CVSP_EAV";
$SHAPE_DIR = "$CVSP_EAV_DIR/shape/$spkr/$emotion/";
$TEXTURE_DIR = "$CVSP_EAV_DIR/texture/$spkr/$emotion/";

# ============================== Variables to control output and directories ============================== #

# Directories & Commands ===============
# project directories
$fclf = 'HTS_EAVTTS_GR';
$fclv = '1.0';
$dset = 'cvsp_greek_voices';
$spkr = 'dt';
$qnum = '001';


$dataversion = "version1"; # the version of the features extracted in the data/ path
$fullversion = "${emotion}_v1"; # the version of this hmm training
$ver = "_$fullversion";

$useSpeech = '1';
$usestraight = '1';
$useVideo = '1';

# --- data & training versions and paths --- #

$mgcvsize = $ordr{'mgc'}-1;
$bapvsize = $ordr{'bap'}-1;
$spversion = "version1";

$SPFEATURES_DIR = "speechfeatures/$spkr/$emotion/$spversion";

# video analysis - synthesis settings 
$fps_synth = 29.97;
$num_sh = 9;
$num_te = 58;

# ------ aam model ------ #
$model = "all_emotions.mat";
$points_type = "1";
$aam_tools_dir = "$prjdir/aam_model";
$model_dir = "$prjdir/aam_model/model";
$full_model = "$model_dir/${model}";
$num_cores = 6; # number of cores to use for image synthesis

# ============================== You probably don't need to edit anything beyond this  ============================== #


@SET        = ('cmp','dur');

if ($useVideo) {
    @cmp        = ('mgc', 'shape', 'texture', 'lf0', 'bap');    
}
else { 
	@cmp        = ('mgc', 'lf0', 'bap');
}

@dur        = ('dur');
$ref{'cmp'} = \@cmp;
$ref{'dur'} = \@dur;

%vflr = ('mgc' => '0.01',           # variance floors
         'lf0' => '0.01',
         'bap' => '0.01',
         'shape' => '0.01',
         'texture' => '0.01',
         'dur' => '0.01');

%thr  = ('mgc' => '000',            # minimum likelihood gain in clustering
         'lf0' => '000',
         'bap' => '000',
         'shape' => '000',
         'texture' => '000',
         'dur' => '000');

%mdlf = ('mgc' => '1.0',            # tree size control param. for MDL
         'lf0' => '1.0',
         'bap' => '1.0',
         'shape' => '1.0',
         'texture' => '1.0',
         'dur' => '1.0');

%mocc = ('mgc' => '10.0',           # minimum occupancy counts
         'lf0' => '10.0',
         'bap' => '10.0',
         'shape' => '10.0',
         'texture' => '10.0',
         'dur' => '5.0');

%gam  = ('mgc' => '000',            # stats load threshold
         'lf0' => '000',
         'bap' => '000',
         'shape' => '000',
         'texture' => '000',
         'dur' => '000');

%t2s  = ('mgc' => 'cmp',            # feature type to mmf conversion
         'lf0' => 'cmp',
         'bap' => 'cmp',
         'shape' => 'cmp',
         'texture' => 'cmp',
         'dur' => 'dur');

if ($useVideo) {
    %strb = ('mgc' => '1',              # stream start
         'lf0' => '4',
         'bap' => '7',
         'shape' => '2',
         'texture' => '3',
         'dur' => '1');

    %stre = ('mgc' => '1',              # stream end
             'lf0' => '6',
             'bap' => '7',
            'shape' => '2',
             'texture' => '3',
             'dur' => '5');
}

    %msdi = ('mgc' => '0',              # msd information
             'lf0' => '1',
             'bap' => '0',
             'shape' => '0',
             'texture' => '0',
             'dur' => '0');

    %strw = ('mgc' => '1.0',            # stream weights
             'lf0' => '1.0',
             'bap' => '0.0',
             'shape' => '0.0',
             'texture' => '0.0',
             'dur' => '1.0');

    %ordr = ('mgc' => '31',     # feature order
             'lf0' => '1',
             'bap' => '25',
             'shape' => '9',
             'texture' => '58',
             'dur' => '5');

    %nwin = ('mgc' => '3',      # number of windows
             'lf0' => '3',
             'bap' => '3',
             'shape' => '3',
             'texture' => '3',
             'dur' => '0');

    %nblk = ('mgc' => '3', # number of blocks for transforms OPA 
             'lf0' => '1',
             'bap' => '3',
             'shape' => '3',
             'texture' => '3',
             'dur' => '1');

    %band = ('mgc' => '31', # band width for transforms
             'lf0' => '1',
             'bap' => '25',
             'shape' => '9',
             'texture' => '58',
             'dur' => '0');

    %gvthr  = ('mgc' => '000',          # minimum likelihood gain in clustering for GV
               'lf0' => '000',
               'bap' => '000',
             'shape' => '000',
             'texture' => '000');

    %gvmdlf = ('mgc' => '1.0',          # tree size control for GV
               'lf0' => '1.0',
               'bap' => '1.0',
             'shape' => '1.0',
             'texture' => '1.0');

    %gvgam  = ('mgc' => '000',          # stats load threshold for GV
               'lf0' => '000',
               'bap' => '000',
             'shape' => '000',
             'texture' => '000');

%usegvpst  = ('mgc' => '1',          # usegv
           'lf0' => '1',
           'bap' => '1',
         'shape' => '0',
         'texture' => '0');

%mspfe  = ('mgc' => '1.0');         # emphasis coefficient of modulation spectrum-based postfilter

@slnt = ('pau','h#','brth');        # silent and pause phoneme

# Speech Analysis/Synthesis Setting ==============

# Switch ================================
$MKEMV = 1; # preparing environments
$HCMPV = 1; # computing a global variance
$IN_RE = 1; # initialization & reestimation
$MMMMF = 1; # making a monophone mmf
$ERST0 = 1; # embedded reestimation (monophone)
$MN2FL = 1; # copying monophone mmf to fullcontext one
$ERST1 = 1; # embedded reestimation (fullcontext)
$CXCL1 = 1; # tree-based context clustering
$ERST2 = 1; # embedded reestimation (clustered)
$UNTIE = 1; # untying the parameter sharing structure
$ERST3 = 1; # embedded reestimation (untied)
$CXCL2 = 1; # tree-based context clustering
$ERST4 = 1; # embedded reestimation (re-clustered)
$FALGN = 1; # forced alignment for no-silent GV
$MCDGV = 1; # making global variance
$MKUNG = 1; # making unseen models (GV)
$TMSPF = 1; # training modulation spectrum-based postfilter
$MKUN1 = 1; # making unseen models (1mix)
$PGEN1 = 1; # generating speech parameter sequences (1mix)
$WGEN1 = 1; # synthesizing waveforms (1mix)

$FALGNS = 0; # state level forced alignment for no-silent GV
$WGENMERLIN = 0;
1;



# speech analysis
$sr = 16000;   # sampling rate (Hz)
$fs = 80; # frame period (point)
$fw = 0.42;   # frequency warping
$gm = 0;      # pole/zero representation weight
$lg = 1;     # use log gain instead of linear gain
$lowf0 = 50; # lower frequency for f0 extraction
$upf0 = 550; # upper frequency for f0 extraction

# speech synthesis
$pf_mcp = 1.4; # postfiltering factor for mel-cepstrum
$pf_lsp = 0.7; # postfiltering factor for LSP
if ($gm == 0){
    $fl     = 4096;        # length of impulse response
}
if ($gm == 1){
    $fl 	= 576;
}
$co     = 2047;            # order of cepstrum to approximate mel-cepstrum


# Modeling/Generation Setting ==============
# modeling
$nState      = 5;        # number of states
$nIte        = 5;         # number of iterations for embedded training ##################
$beam        = '1500 100 5000'; # initial, inc, and upper limit of beam width
$maxdev      = 10;        # max standard dev coef to control HSMM maximum duration
$mindur      = 5;        # min state duration to be evaluated
$wf          = 5000;        # mixture weight flooring
$initdurmean = 3.0;             # initial mean of state duration
$initdurvari = 10.0;            # initial variance of state duration
$daem        = 0;          # DAEM algorithm based parameter estimation
$daem_nIte   = 10;     # number of iterations of DAEM-based embedded training
$daem_alpha  = 1.0;     # schedule of updating temperature parameter for DAEM

# generation
$pgtype     = 0;     # parameter generation algorithm (0 -> Cholesky,  1 -> MixHidden,  2 -> StateHidden)
$maxEMiter  = 20;  # max EM iteration
$EMepsilon  = 0.0001;  # convergence factor for EM iteration
$useGV      = 1;      # turn on GV ########################
$maxGViter  = 50;  # max GV iteration
$GVepsilon  = 0.0001;  # convergence factor for GV iteration
$minEucNorm = 0.01; # minimum Euclid norm for GV iteration
$stepInit   = 1.0;   # initial step size
$stepInc    = 1.2;    # step size acceleration factor
$stepDec    = 0.5;    # step size deceleration factor
$hmmWeight  = 1.0;  # weight for HMM output prob.
$gvWeight   = 1.0;   # weight for GV output prob.
$optKind    = 'NEWTON';  # optimization method (STEEPEST, NEWTON, or LBFGS)
$nosilgv    = 1;    # GV without silent and pause phoneme
$cdgv       = 1;       # context-dependent GV
$useMSPF    = 0;    # use modulation spectrum-based postfilter
$mspfLength = 25;           # frame length of modulation spectrum-based postfilter (odd number)
$mspfFFTLen = 64;           # FFT length of modulation spectrum-based postfilter (even number)
$fftlengthstr = 2048; # FFT length for STRAIGHT vocoder




# Perl
$PERL = '/usr/bin/perl';

# wc
$WC = '/usr/bin/wc';

# tee
$TEE = '/usr/bin/tee';

# HTS commands
$HCOMPV    = "$HTS_PATH/HCompV";
$HLIST     = "$HTS_PATH/HList";
$HINIT     = "$HTS_PATH/HInit";
$HREST     = "$HTS_PATH/HRest";
$HEREST    = "$HTS_PATH/HERest";
$HHED      = "$HTS_PATH/HHEd";
$HSMMALIGN = "$HTS_PATH/HSMMAlign";
$HMGENS    = "$HTS_PATH/HMGenS";

# SPTK commands
$X2X          = "$SPTK_PATH/x2x";
$FREQT        = "$SPTK_PATH/freqt";
$C2ACR        = "$SPTK_PATH/c2acr";
$VOPR         = "$SPTK_PATH/vopr";
$VSUM         = "$SPTK_PATH/vsum";
$MC2B         = "$SPTK_PATH/mc2b";
$SOPR         = "$SPTK_PATH/sopr";
$B2MC         = "$SPTK_PATH/b2mc";
$EXCITE       = "$SPTK_PATH/excite";
$LSP2LPC      = "$SPTK_PATH/lsp2lpc";
$MGC2MGC      = "$SPTK_PATH/mgc2mgc";
$MGLSADF      = "$SPTK_PATH/mglsadf";
$MERGE        = "$SPTK_PATH/merge";
$BCP          = "$SPTK_PATH/bcp";
$LSPCHECK     = "$SPTK_PATH/lspcheck";
$MGC2SP       = "$SPTK_PATH/mgc2sp";
$BCUT         = "$SPTK_PATH/bcut";
$VSTAT        = "$SPTK_PATH/vstat";
$NAN          = "$SPTK_PATH/nan";
$DFS          = "$SPTK_PATH/dfs";
$SWAB         = "$SPTK_PATH/swab";
$RAW2WAV      = "$SPTK_PATH/raw2wav";
$FRAME        = "$SPTK_PATH/frame";
$WINDOW       = "$SPTK_PATH/window";
$SPEC         = "$SPTK_PATH/spec";
$TRANSPOSE    = "$SPTK_PATH/transpose";
$PHASE        = "$SPTK_PATH/phase";
$IFFTR        = "$SPTK_PATH/ifftr";



