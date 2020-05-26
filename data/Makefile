SHELL := /bin/bash

# ----------------- Edit these variables to represent your system - required ----------------- #
BASE_DIR = "/kalymnos_home/filby/workspace/hts-audiovisual-synthesis"
DB_DIR = /gpu-data2/filby/EAVTTS/CVSP_EAV

INSTALLED_SPTK_VERSION = "/usr/local/bin"

# directory to save straight features
STRFEATDIR = /gpu-data2/filby/straight_features/$(SPEAKER)/$(EMOTION)



# MATLAB and STRAIGHT
MATLAB   = /usr/local/MATLAB/R2015a/bin/matlab -nodisplay -nosplash -nojvm
STRAIGHT = /home/filby/workspace/software/legacy_STRAIGHT/src


# ----------------- Variables to control output feature types and directories ----------------- #

# USE VIDEO AND/OR SPEECH
useSpeech = 1
useVideo = 1

# this can be useful if you experiment with different feature settings
SPVERSION = version1

# name of training version
FULLVERSION = version1

# emotion
EMOTION = neutral

# setting
SPEAKER = dt
DATASET = cvsp_greek_voices

# ----------------- Edit these variables only if you want to extract your own labels ----------------- #

INSTALLED_FESTIVAL_EXAMPLES_DIR = /kalymnos_home/filby/workspace/software/festival-2.4-release/festival/examples


# HTK COMMANDS - these are needed only if you want to create your own labels
HCOPY = /usr/local/bin/HCopy
HVITE = /usr/local/bin/HVite 
MODELS    = scripts/greekdb_all_14/hmmdefs
MODELLIST = scripts/greekdb_all_14/tiedlist



# ----------------- You probably don't need to edit anything beyond this ----------------- #

# awk and perl
AWK  = gawk
PERL = /usr/bin/perl
PYTHON = /usr/bin/python


USESTRAIGHT = 1


# dumpfeats to extract utterance information
DUMPFEATS = $(INSTALLED_FESTIVAL_EXAMPLES_DIR)/dumpfeats

# make utts 
MAKEUTTS = $(INSTALLED_FESTIVAL_EXAMPLES_DIR)/make_utts


# SPTK commands
X2X     = $(INSTALLED_SPTK_VERSION)/x2x
MGCEP   = $(INSTALLED_SPTK_VERSION)/mgcep
MCEP   = $(INSTALLED_SPTK_VERSION)/mcep
LPC2LSP = $(INSTALLED_SPTK_VERSION)/lpc2lsp
MERGE   = $(INSTALLED_SPTK_VERSION)/merge
VSTAT   = $(INSTALLED_SPTK_VERSION)/vstat
SOPR    = $(INSTALLED_SPTK_VERSION)/sopr
NAN     = $(INSTALLED_SPTK_VERSION)/nan
MINMAX  = $(INSTALLED_SPTK_VERSION)/minmax
BCUT  = $(INSTALLED_SPTK_VERSION)/bcut


# SPTK commands for no straight TODO
PITCH   = $(INSTALLED_SPTK_VERSION)/pitch
FRAME   = $(INSTALLED_SPTK_VERSION)/frame
WINDOW  = $(INSTALLED_SPTK_VERSION)/windowsmake
RAW2WAV = $(INSTALLED_SPTK_VERSION)/raw2wav


# speech analysis conditions
SAMPFREQKHZ = 16
SAMPFREQ   = 16000# Sampling frequency (16kHz)
FRAMESHIFT = 80# Frame shift in point (80 = 16000 * 0.005)
FREQWARP   = 0.42#0.42# frequency warping factor
GAMMA      = 0#3# pole/zero weight for mel-generalized cepstral (MGC) analysis
MGCORDER   = 30#30# order of MGC analysis
BAPORDER   = 24#24# order of BAP analysis
LNGAIN     = 1#use logarithmic gain rather than linear gain
LOWERF0    = 60# lower limit for f0 extraction (Hz)
UPPERF0    = 550# upper limit for f0 extraction (Hz)

# windows for calculating delta features
MGCWIN   = win/mgc.win
LF0WIN   = win/lf0.win
BAPWIN   = win/bap.win
NMGCWIN  = 3
NLF0WIN  = 3
NBAPWIN  = 3

# video features windows
VIDWIN   = win/vfs.win
NVIDWIN  = 3
NTEXTUREWIN = 3
NSHAPEWIN = 3

# fft length for calculating mgc and bap coefficients from straight data
# if length of ap and sp 513 fftlen is 1024 # note this for different STRAIGHT versions
# if length is 1025 then fftlen is 2048
FFTLENSTR = 2048

# max number of training data to use
NUMCMP = 900

# directory to store speech features
SPFEATURES_DIR = speechfeatures/$(SPEAKER)/$(EMOTION)


# speech features and version dir combined
SPFEATDIR = $(SPFEATURES_DIR)/$(SPVERSION)

VIDFEATDIR = $(VIDFEATURES_DIR)

SHDIM = 9 # dimension of shape eigenvector
TEDIM = 58 # dimension of texture eigenvector

# directory to store cmp files for training
TRAINDIR = train_files/$(SPEAKER)/$(EMOTION)/$(FULLVERSION)

# directory for wav files
WAVDIR = $(DB_DIR)/wav/$(SPEAKER)/$(EMOTION)

# directory for raw files
RAWDIR = $(DB_DIR)/raw/$(SPEAKER)/$(EMOTION)

# directory for shape files
SHAPE_DIR = $(DB_DIR)/shape/$(SPEAKER)/$(EMOTION)

# directory for texture files
TEXTURE_DIR = $(DB_DIR)/texture/$(SPEAKER)/$(EMOTION)

# directory for prompts
PROMPTSDIR = $(DB_DIR)/prompts/$(SPEAKER)/$(EMOTION)

# directory for aligned files (sail_align_adapted)
SAILALIGNADAPTEDDIR = $(DB_DIR)/sail_align_adapted/$(SPEAKER)/$(EMOTION)

# directory for lf0 files
LF0DIR = $(SPFEATDIR)/lf0

# directory for labels
LABELSDIR = labels/$(SPEAKER)/$(EMOTION)

# directory for scp files i.e. training lists
SCPDIR = scp/$(SPEAKER)/$(EMOTION)/$(FULLVERSION)

# directory for lists
LISTSDIR = lists/$(SPEAKER)/$(EMOTION)

# directory for aligned files (htk)
HTKALIGNDIR = htk_align/$(SPEAKER)/$(EMOTION)

# directory for aligned files (sail_align)
SAILALIGNDIR = sail_align/$(SPEAKER)/$(EMOTION)

# directory for utts files
UTTSDIR = utts/$(SPEAKER)/$(EMOTION)

# directory for festival features
FESTIVALDIR = festival_labels_build/$(EMOTION)/festival

# directory for phonemaps
PHONEMAPSDIR = phonemaps

# config files
HCOPYCFG  = configs/hcopy.cfg
HVITECFG  = configs/hvite.cfg

# htk dictionary
DICT = corpus_htk.dic

# dicstuffdir
DICSTUFFDIR = dicstuff

# option to create new dictionary or add to current
DIROP = >>

# alignment to use for creation of labels
ALIGNDIR = $(SAILALIGNADAPTEDDIR)

# mfcc directory
MFCCDIR = mfcc/$(SPEAKER)/$(EMOTION)


all: features labels

features: straight mgc lf0 bap cmp

labels: mlf list scp 

# labels: Relations label mlf list scp


straight:
	# Extracting f0, aperiodicity, and spectra using STRAIGHT
	mkdir -p $(WAVDIR) $(STRFEATDIR)/sp $(STRFEATDIR)/ap $(STRFEATDIR)/f0
	
	FRAMESHIFTMS=`echo $(FRAMESHIFT) | $(X2X) +af | $(SOPR) -m 1000 -d $(SAMPFREQ) | $(X2X) +fa`; \
	echo "path(path,'$(STRAIGHT)');"                      >  scripts/extract_$(EMOTION).m; \
	echo "prm.F0frameUpdateInterval=$${FRAMESHIFTMS};"    >> scripts/extract_$(EMOTION).m; \
	echo "prm.F0searchUpperBound=$(UPPERF0);"             >> scripts/extract_$(EMOTION).m; \
	echo "prm.F0searchLowerBound=$(LOWERF0);"             >> scripts/extract_$(EMOTION).m; \
	echo "prm.spectralUpdateInterval=$${FRAMESHIFTMS};"   >> scripts/extract_$(EMOTION).m; \
	echo ""                                               >> scripts/extract_$(EMOTION).m
	for wav in $(WAVDIR)/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.wav; do \
		base=`basename $${wav} .wav`; \
		if [ -s $${wav} ]; then \
			wav=$(WAVDIR)/$${base}.wav; \
			f0=$(STRFEATDIR)/f0/$${base}.f0; \
			ap=$(STRFEATDIR)/ap/$${base}.ap; \
			sp=$(STRFEATDIR)/sp/$${base}.sp; \
			echo "display('Processing $${wav}');"     >> scripts/extract_$(EMOTION).m; \
			echo "[x,fs]=wavread('$${wav}');"             >> scripts/extract_$(EMOTION).m; \
			echo "[f0, ap] = exstraightsource(x,fs,prm);" >> scripts/extract_$(EMOTION).m; \
			echo "[sp] = exstraightspec(x, f0, fs, prm);" >> scripts/extract_$(EMOTION).m; \
			echo "ap = ap';"                              >> scripts/extract_$(EMOTION).m; \
			echo "sp = sp';"                              >> scripts/extract_$(EMOTION).m; \
			echo "sp = sp*32768.0;"                       >> scripts/extract_$(EMOTION).m; \
			echo "save '$${f0}' f0 -ascii;"               >> scripts/extract_$(EMOTION).m; \
			echo "save '$${ap}' ap -ascii;"               >> scripts/extract_$(EMOTION).m; \
			echo "save '$${sp}' sp -ascii;"               >> scripts/extract_$(EMOTION).m; \
			echo ""                                       >> scripts/extract_$(EMOTION).m; \
		fi; \
	done; \
	echo "quit;"                                          >> scripts/extract_$(EMOTION).m
	$(MATLAB) < scripts/extract_$(EMOTION).m
	rm -f scripts/extract_$(EMOTION).m


mgc:
	# Extracting MGC or MGC-LSP coefficients from STRAIGHT spectra
	mkdir -p $(SPFEATDIR)/mgc
	
	SAMPKHZ=`echo $(SAMPFREQ) | $(X2X) +af | $(SOPR) -m 0.001 | $(X2X) +fa`; \
	for sp in $(STRFEATDIR)/sp/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.sp; do \
		base=`basename $${sp} .sp`; \
		if [ -s $${sp} ]; then \
			if [ $(GAMMA) -eq 0 ]; then \
				echo "Extracting MGC coefficients from $${sp}"; \
				$(X2X) +af $${sp} | \
				$(MCEP) -a $(FREQWARP) -m $(MGCORDER) -l $(FFTLENSTR) -e 1.0E-08 -j 0 -f 0.0 -q 3 > $(SPFEATDIR)/mgc/$${base}.mgc; \
			else \
				echo "Extracting MGC-LSP coefficients from $${sp}"; \
				if [ $(LNGAIN) -eq 1 ]; then \
					GAINOPT="-l"; \
				fi; \
				$(X2X) +af $${sp} | \
				$(MGCEP) -a $(FREQWARP) -c $(GAMMA) -m $(MGCORDER) -l $(FFTLENSTR) -e 1.0E-08 -j 0 -f 0.0 -q 3 -o 4 | \
				$(LPC2LSP) -m $(MGCORDER) -s $${SAMPKHZ} $${GAINOPT} -n $(FFTLENSTR) -p 8 -d 1.0E-08 > $(SPFEATDIR)/mgc/$${base}.mgc; \
			fi; \
			if [ -n "`$(NAN) $(SPFEATDIR)/mgc/$${base}.mgc`" ]; then \
				echo " Failed to extract MGC coefficients from $${sp}"; \
				rm -f $(SPFEATDIR)/mgc/$${base}.mgc; \
			fi; \
		fi; \
	done

	rm -f tmp

lf0:
	# Converting f0 to log f0
	mkdir -p $(LF0DIR)
	
	for f0 in $(STRFEATDIR)/f0/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.f0; do \
		base=`basename $${f0} .f0`; \
		if [ -s $${f0} ]; then \
			echo "Converting F0 file $${f0} to log F0 file $(LF0DIR)/$${base}.lf0"; \
			$(X2X) +af $${f0} | $(SOPR) -magic 0.0 -LN -MAGIC -1.0E+10 > $(LF0DIR)/$${base}.lf0; \
			if [ -n "`$(NAN) $(LF0DIR)/$${base}.lf0`" ]; then \
				echo " Failed to extract $${f0}"; \
				rm -f $(LF0DIR)/$${base}.lf0; \
			fi; \
		fi; \
	done
	rm -f tmp

bap:
	# Converting aperiodicity to band aperiodicity
	mkdir -p $(SPFEATDIR)/bap
	
	for ap in $(STRFEATDIR)/ap/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.ap; do \
		base=`basename $${ap} .ap`; \
		if [ -s $${ap} ]; then \
			echo "Converting aperiodicity file $${ap} to band aperiodicity file $(SPFEATDIR)/bap/$${base}.bap"; \
			$(X2X) +af $${ap} | \
			$(MCEP) -a $(FREQWARP) -m $(BAPORDER) -l $(FFTLENSTR) -e 1.0E-08 -j 0 -f 0.0 -q 1 > $(SPFEATDIR)/bap/$${base}.bap; \
			if [ -n "`$(NAN) $(SPFEATDIR)/bap/$${base}.bap`" ]; then \
				echo " Failed to extract aperiodicity coefficients $${ap}"; \
				rm -f $(SPFEATDIR)/bap/$${base}.bap; \
			fi; \
		fi; \
	done

cmp: 
	# Composing training data files from mgc and lf0 files
	mkdir -p $(TRAINDIR)/cmp
	cp Makefile $(TRAINDIR)/cmp
	for j in 1; do \
		MGCDIM=`expr $(MGCORDER) + 1`; \
		LF0DIM=1; \
		BAPDIM=`expr $(BAPORDER) + 1`; \
		SHAPEDIM=`expr $(SHDIM) + 0`; \
		TEXTUREDIM=`expr $(TEDIM) + 0`; \
		VIDDIM=`expr $(TEDIM) + $(SHDIM)`; \
		MGCWINDIM=`expr $(NMGCWIN) \* $${MGCDIM}`; \
		LF0WINDIM=`expr $(NLF0WIN) \* $${LF0DIM}`; \
		BAPWINDIM=`expr $(NBAPWIN) \* $${BAPDIM}`; \
		SHAPEWINDIM=`expr $(NVIDWIN) \* $${SHAPEDIM}`; \
		TEXTUREWINDIM=`expr $(NVIDWIN) \* $${TEXTUREDIM}`; \
		VIDWINDIM=`expr $(NVIDWIN) \* $${VIDDIM}`; \
		MGCLF0WINDIM=`expr $${MGCWINDIM} + $${LF0WINDIM}`; \
		SPEECHWINDIM=`expr $${MGCLF0WINDIM} + $${BAPWINDIM}`; \
		MGCLF0VIDWINDIM=`expr $${MGCLF0WINDIM} + $${VIDWINDIM}`; \
		MGCSHAPEWINDIM=`expr $${MGCWINDIM} + $${SHAPEWINDIM}`; \
		MGCVIDWINDIM=`expr $${MGCWINDIM} + $${VIDWINDIM}`; \
		if [ $(useSpeech) -eq 1 -a $(useVideo) -eq 1 ]; then \
			BYTEPERFRAME=`expr 4 \* \( $${MGCWINDIM} + $${LF0WINDIM} + $${BAPWINDIM} + $${VIDWINDIM} \)`; \
			for mgc in $(SPFEATDIR)/mgc/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.mgc; do \
				base=`basename $${mgc} .mgc`; \
				MGCWINS=""; \
				LF0WINS=""; \
				BAPWINS=""; \
				SHAPEWINS=""; \
				TEXTUREWINS=""; \
				VIDWINS=""; \
				if [ -s $${mgc} -a -s $(LF0DIR)/$${base}.lf0 -a -s $(SPFEATDIR)/bap/$${base}.bap -a -s $(SHAPE_DIR)/$${base}.mfc -a -s $(TEXTURE_DIR)/$${base}.mfc ]; then \
					i=1; \
					echo "Composing speech and video training data for $${base}"; \
					while [ $${i} -le $(NMGCWIN) ]; do \
						eval MGCWINS=\"$${MGCWINS} $(MGCWIN)$${i}\"; \
						i=`expr $${i} + 1`; \
					done; \
					$(PERL) scripts/window.pl $${MGCDIM} $${mgc} $${MGCWINS} > $(TRAINDIR)/cmp/tmp.mgc; \
					i=1; \
					while [ $${i} -le $(NLF0WIN) ]; do \
						eval LF0WINS=\"$${LF0WINS} $(LF0WIN)$${i}\"; \
						i=`expr $${i} + 1`; \
					done; \
					$(PERL) scripts/window.pl $${LF0DIM} $(LF0DIR)/$${base}.lf0 $${LF0WINS} > $(TRAINDIR)/cmp/tmp.lf0; \
					i=1; \
					while [ $${i} -le $(NBAPWIN) ]; do \
						eval BAPWINS=\"$${BAPWINS} $(BAPWIN)$${i}\"; \
						i=`expr $${i} + 1`; \
					done; \
					$(PERL) scripts/window.pl $${BAPDIM} $(SPFEATDIR)/bap/$${base}.bap $${BAPWINS} > $(TRAINDIR)/cmp/tmp.bap; \
					i=1; \
					while [ $${i} -le $(NVIDWIN) ]; do \
						eval SHAPEWINS=\"$${SHAPEWINS} $(VIDWIN)$${i}\"; \
						i=`expr $${i} + 1`; \
					done; \
					$(PERL) scripts/window.pl $${SHAPEDIM} $(SHAPE_DIR)/$${base}.mfc $${SHAPEWINS} > $(TRAINDIR)/cmp/tmp.shape; \
					i=1; \
					while [ $${i} -le $(NVIDWIN) ]; do \
						eval TEXTUREWINS=\"$${TEXTUREWINS} $(VIDWIN)$${i}\"; \
						i=`expr $${i} + 1`; \
					done; \
					$(PERL) scripts/window.pl $${TEXTUREDIM} $(TEXTURE_DIR)/$${base}.mfc $${TEXTUREWINS} > $(TRAINDIR)/cmp/tmp.texture; \
					$(MERGE) +f -s 0 -l $${SHAPEWINDIM} -L $${MGCWINDIM}     $(TRAINDIR)/cmp/tmp.mgc     < $(TRAINDIR)/cmp/tmp.shape > $(TRAINDIR)/cmp/tmp.mgc+shape; \
					$(MERGE) +f -s 0 -l $${TEXTUREWINDIM} -L $${MGCSHAPEWINDIM}     $(TRAINDIR)/cmp/tmp.mgc+shape     < $(TRAINDIR)/cmp/tmp.texture > $(TRAINDIR)/cmp/tmp.mgc+vid; \
					$(MERGE) +f -s 0 -l $${LF0WINDIM} -L $${MGCVIDWINDIM}     $(TRAINDIR)/cmp/tmp.mgc+vid < $(TRAINDIR)/cmp/tmp.lf0 > $(TRAINDIR)/cmp/tmp.mgc+lf0+vid; \
					$(MERGE) +f -s 0 -l $${BAPWINDIM} -L $${MGCLF0VIDWINDIM}  $(TRAINDIR)/cmp/tmp.mgc+lf0+vid < $(TRAINDIR)/cmp/tmp.bap > $(TRAINDIR)/cmp/tmp.cmp; \
					$(PERL) scripts/addhtkheader.pl $(SAMPFREQ) $(FRAMESHIFT) $${BYTEPERFRAME} 9 $(TRAINDIR)/cmp/tmp.cmp > $(TRAINDIR)/cmp/$${base}.cmp; \
				fi; \
			done; \
		fi; \
		if [ $(useSpeech) = 1 -a $(useVideo) = 0 ]; then \
					echo "UseSpeech 1 UseVideo 0"; \
					BYTEPERFRAME=`expr 4 \* \( $${MGCWINDIM} + $${LF0WINDIM} + $${BAPWINDIM} \)`; \
					for mgc in $(SPFEATDIR)/mgc/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.mgc; do \
						base=`basename $${mgc} .mgc`; \
						MGCWINS=""; \
						LF0WINS=""; \
						BAPWINS=""; \
						if [ -s $${mgc} -a -s "$(LF0DIR)/$${base}.lf0" -a -s $(SPFEATDIR)/bap/$${base}.bap ]; then \
							i=1; \
							echo "Composing speech training data for $${base}"; \
							while [ $${i} -le $(NMGCWIN) ]; do \
								eval MGCWINS=\"$${MGCWINS} $(MGCWIN)$${i}\"; \
								i=`expr $${i} + 1`; \
							done; \
							$(PERL) scripts/window.pl $${MGCDIM} $${mgc} $${MGCWINS} > $(TRAINDIR)/cmp/tmp.mgc; \
							i=1; \
							while [ $${i} -le $(NLF0WIN) ]; do \
								eval LF0WINS=\"$${LF0WINS} $(LF0WIN)$${i}\"; \
								i=`expr $${i} + 1`; \
							done; \
							$(PERL) scripts/window.pl $${LF0DIM} $(LF0DIR)/$${base}.lf0 $${LF0WINS} > $(TRAINDIR)/cmp/tmp.lf0; \
							i=1; \
							while [ $${i} -le $(NBAPWIN) ]; do \
								eval BAPWINS=\"$${BAPWINS} $(BAPWIN)$${i}\"; \
								i=`expr $${i} + 1`; \
							done; \
							$(PERL) scripts/window.pl $${BAPDIM} $(SPFEATDIR)/bap/$${base}.bap $${BAPWINS} > $(TRAINDIR)/cmp/tmp.bap; \
							$(MERGE) +f -s 0 -l $${LF0WINDIM} -L $${MGCWINDIM}     $(TRAINDIR)/cmp/tmp.mgc     < $(TRAINDIR)/cmp/tmp.lf0 > $(TRAINDIR)/cmp/tmp.mgc+lf0; \
							$(MERGE) +f -s 0 -l $${BAPWINDIM} -L $${MGCLF0WINDIM}  $(TRAINDIR)/cmp/tmp.mgc+lf0 < $(TRAINDIR)/cmp/tmp.bap > $(TRAINDIR)/cmp/tmp.cmp; \
							$(PERL) scripts/addhtkheader.pl $(SAMPFREQ) $(FRAMESHIFT) $${BYTEPERFRAME} 9 $(TRAINDIR)/cmp/tmp.cmp > $(TRAINDIR)/cmp/$${base}.cmp; \
						fi; \
					done; \
				fi; \
		if [ $(useSpeech) = 0 -a $(useVideo) = 1 ]; then \
					BYTEPERFRAME=`expr 4 \* \( $${VIDWINDIM} \)`; \
					for mfc in $(VIDFEATDIR)/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.mfc; do \
						base=`basename $${mfc} .mfc`; \
						VIDWINS=""; \
						if [ -s $${mfc} ]; then \
							i=1; \
							while [ $${i} -le $(NVIDWIN) ]; do \
								eval VIDWINS=\"$${VIDWINS} $(VIDWIN)$${i}\"; \
								i=`expr $${i} + 1`; \
							done; \
							$(PERL) scripts/window.pl $${VIDDIM} $(VIDFEATDIR)/$${base}.mfc $${VIDWINS} > $(TRAINDIR)/cmp/tmp.vid; \
							$(PERL) scripts/addhtkheader.pl $(SAMPFREQ) $(FRAMESHIFT) $${BYTEPERFRAME} 9 $(TRAINDIR)/cmp/tmp.vid > $(TRAINDIR)/cmp/$${base}.cmp; \
						fi; \
					done; \
				fi; \
	done
	rm -f $(TRAINDIR)/cmp/tmp*

#################################

mlf:
	# Generating monophone and fullcontext Master Label Files (MLF)
	echo "#!MLF!#" > $(LABELSDIR)/mono.mlf
	echo "\"*/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.lab\" -> \"$(BASE_DIR)/data/$(LABELSDIR)/mono\"" >> $(LABELSDIR)/mono.mlf
	
	echo "#!MLF!#" > $(LABELSDIR)/full.mlf
	echo "\"*/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.lab\" -> \"$(BASE_DIR)/data/$(LABELSDIR)/full\"" >> $(LABELSDIR)/full.mlf


list:
	# Generating a fullcontext model list file
	mkdir -p $(LISTSDIR)
	
	rm -f tmp

	while read p; do \
	  base="$${p/dt/dt_$(EMOTION)}" ;\
	  lab=$(LABELSDIR)/full/$$base.lab ;\
	  sed -e "s/.* //g" $${lab} >> tmp; \
	done <scp/train.scp
	sort -u tmp > $(LISTSDIR)/full.list

# 	# Generating a fullcontext model list file which includes unseen models

	rm -f tmp
	cat $(LISTSDIR)/full.list > tmp

	while read p; do \
	  base="$${p/dt/dt_$(EMOTION)}" ;\
	  sed -e "s/.* //g" $(LABELSDIR)/full/$$base.lab >> tmp; \
	done <scp/test.scp

	sort -u tmp > $(LISTSDIR)/full_all.list

	rm -f tmp
	# Generating a monophone list file
	rm -f tmp
	while read p; do \
	  base="$${p/dt/dt_$(EMOTION)}" ;\
	  sed -e "s/.* //g" $(LABELSDIR)/mono/$$base.lab >> tmp; \
	done <scp/train.scp

	sort -u tmp > $(LISTSDIR)/mono.list
	rm -f tmp



scp:
	# menei to list kai trexume peiramata!
	mkdir -p $(SCPDIR)
	rm -f $(SCPDIR)/train.scp
	while read p; do \
	  base="$${p/dt/dt_$(EMOTION)}" ;\
	  echo $(BASE_DIR)/data/$(TRAINDIR)/cmp/$$base.cmp >> $(SCPDIR)/train.scp ;\
	done <scp/train.scp

	rm -f $(SCPDIR)/test.scp
	while read p; do \
	  base="$${p/dt/dt_$(EMOTION)}" ;\
	  echo $(BASE_DIR)/data/$(LABELSDIR)/full/$$base.lab >> $(SCPDIR)/test.scp ;\
	done <scp/test.scp


#-------------------------------- MAKEFILE RULES TO CREATE LABELS --------------------------------#


label:
	# Extracting monophone and fullcontext labels from utterance files
	mkdir -p $(LABELSDIR)/mono
	mkdir -p $(LABELSDIR)/full
	
	for utt in $(FESTIVALDIR)/utts/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.utt; do \
		base=`basename $${utt} .utt`; \
		if [ -s $${utt} ]; then \
			$(DUMPFEATS)    -eval     scripts/extra_feats.scm \
					-relation Segment \
					-feats    scripts/label.feats \
					-output   tmp \
					$${utt}; \
		fi; \
		$(AWK) -f scripts/label-full.awk tmp > $(LABELSDIR)/full/$${base}.lab; \
		$(AWK) -f scripts/label-mono.awk tmp > $(LABELSDIR)/mono/$${base}.lab; \
	done
	rm -f tmp



# list of words in all sentences
word_list:
	s=`find prompts/dt/ -name "*.txt" -exec cat {} +`; \
	for i in $${s}; do \
		echo $${i}; \
	done | sort -u > prompts/dt/words.list;


# list of stressed words
word_prons:
	word_list=prompts/dt/words.list;\
	$(PYTHON) scripts/get_word_prons_filby.py $${word_list} $(DICSTUFFDIR)/corpus_stressed.dico;

# phoneset
get_phoneset:
	dic=$(DICSTUFFDIR)/corpus_stressed.dico;\
	$(PYTHON) scripts/get_phoneset.py $${dic} > $(DICSTUFFDIR)/corpus_phoneset_full.list;


# htk dictionary
htk_dico:
	dic="$(DICSTUFFDIR)/corpus_stressed.dico";\
	phonemap=$(PHONEMAPSDIR)/ups2htk_phoneset.map;\
	rm -f $${htk_dic} $${htk_dic}.tmp;\
	$(PYTHON) scripts/convert_phoneset.py $${dic} $${phonemap} | while read line; do \
		 echo "$${line} sp" >> dico.tmp; \
	done;\
	echo "silence sil" >> dico.tmp; \
	$(PYTHON) scripts/unicode_sort.py dico.tmp | iconv -f utf-8 -t iso-8859-7 >  "$(DICSTUFFDIR)/$(DICT)"; \
	rm dico.tmp

# master label file
prompts_mlf:
	# Collecting all prompt files in an mlf
	mlf_file=$(PROMPTSDIR)/prompts.mlf; \
	echo "#!MLF!#" > $${mlf_file}; \
	for raw in $(RAWDIR)/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.raw; do \
		base=`basename $${raw} .raw`; \
		echo "\"*/$${base}.lab\"" >> $${mlf_file}; \
		cat $(PROMPTSDIR)/$${base}.txt | tr " " "\n" | iconv -f utf-8 -t iso-8859-7 >> $${mlf_file}; \
		echo "." >> $${mlf_file}; \
	done

raw:
	# Converting to wav files to raw for straight
	mkdir -p $(RAWDIR); \
	for wav in $(WAVDIR)/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.wav; do \
		base=`basename $${wav} .wav`; \
		sox -e signed-integer -c 1 -r $(SAMPFREQ) -b 16 $${wav} -r 16000 -b 16 $(RAWDIR)/$${base}.raw; \
	done


rawtowav:
	# convert raw to wav files
	mkdir -p $(WAVDIR); \
	for raw in $(RAWDIR)/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.raw; do \
		base=`basename $${raw} .raw`; \
		$(RAW2WAV) -s $(SAMPFREQ) -d $(WAVDIR) $${raw}; \
	done

mfcc:
	mkdir -p $(MFCCDIR); \
	hcopy_scp_file=$(MFCCDIR)/hcopy.scp; \
	rm -f $${hcopy_scp_file}; \
	for wav in $(WAVDIR)/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.wav; do \
		base=`basename $${wav} .wav`; \
		echo "$${wav} $(MFCCDIR)/$${base}.mfc" >> $${hcopy_scp_file}; \
	done; \
	$(HCOPY) -T 1 -C $(HCOPYCFG) -S $${hcopy_scp_file};

align:
	mkdir -p $(HTKALIGNDIR); \
	hvite_scp_file=$(HTKALIGNDIR)/hvite.scp; \
	rm -f $${hvite_scp_file}; \
	for mfc in $(MFCCDIR)/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.mfc; do \
		base=`basename $${mfc} .mfc`; \
		echo "$(MFCCDIR)/$${base}.mfc" >> $${hvite_scp_file}; \
	done; \
	$(HVITE) -l $(HTKALIGNDIR) -a -o S -b silence -C $(HVITECFG) -S $${hvite_scp_file} -H $(MODELS) -m -y lab \
			-I $(PROMPTSDIR)/prompts.mlf $(DICSTUFFDIR)/$(DICT) $(MODELLIST);


Relations: Segment Word Syllable Phrase IntEvent Target 
	rm -rf $(FESTIVADIR)/utts;\
	mkdir -p $(FESTIVALDIR)/utts;\
	cd $(FESTIVALDIR); \
	cd ..; \
	$(MAKEUTTS) festival/relations/Segment/*.Segment; \
	cd ..; \
	cd ..

Segment:
	mkdir -p $(FESTIVALDIR)/relations/Segment; \
	for lab in $(ALIGNDIR)/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.lab; do \
		bn=`basename $${lab} .lab`;\
		$(PYTHON) scripts/lab2segment.py $(PHONEMAPSDIR)/htk2hts_phoneset.map < $${lab} > $(FESTIVALDIR)/relations/Segment/$${bn}.Segment; \
	done;

Word: 
	mkdir -p $(FESTIVALDIR)/relations/Word; \
	for lab in $(ALIGNDIR)/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.lab; do \
		bn=`basename $${lab} .lab`;\
		$(PYTHON) scripts/lab2word.py < $${lab} > $(FESTIVALDIR)/relations/Word/$${bn}.Word; \
	done;

Syllable: 
	mkdir -p $(FESTIVALDIR)/relations/Syllable; \
	for seg in $(FESTIVALDIR)/relations/Segment/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.Segment; do \
		echo $${seg}; \
		bn=`basename $${seg} .Segment`;\
		$(PYTHON) scripts/segment2syllable.py $(PROMPTSDIR)/$${bn}.txt.stressed.Syllable $${seg} $(PHONEMAPSDIR)/ups2hts_phoneset.map > $(FESTIVALDIR)/relations/Syllable/$${bn}.Syllable; \
	done;

Phrase: 
	mkdir -p $(FESTIVALDIR)/relations/Phrase; \
	for seg in $(FESTIVALDIR)/relations/Segment/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.Segment; do\
		bn=`basename $${seg} .Segment`;\
		$(PYTHON) scripts/segment2phrase.py $${seg} > $(FESTIVALDIR)/relations/Phrase/$${bn}.Phrase; \
	done;

IntEvent: 
	mkdir -p $(FESTIVALDIR)/relations/IntEvent; \
	for syl in $(FESTIVALDIR)/relations/Syllable/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.Syllable; do \
		bn=`basename $${syl} .Syllable`; \
		$(PYTHON) scripts/syllable2intevent.py < $${syl} > $(FESTIVALDIR)/relations/IntEvent/$${bn}.IntEvent;\
	done;

Target: 
	target_dir=$(FESTIVALDIR)/relations/Target;\
	mkdir -p $${target_dir}; \
	rm -f $${target_dir}/target.log; \
	for seg in $(FESTIVALDIR)/relations/Segment/$(DATASET)_$(SPEAKER)_$(EMOTION)_*.Segment; do \
		bn=`basename $${seg} .Segment`;\
		$(X2X) +fa $(LF0DIR)/$${bn}.lf0 > $${target_dir}/$${bn}.tmp;\
		$(PYTHON) scripts/segment2target.py $${seg} $${target_dir}/$${bn}.tmp 0.005 > $${target_dir}/$${bn}.Target;\
		s=`grep 0.0000 $${target_dir}/$${bn}.Target | wc -l`; \
		echo "$${bn} $${s}" >> $${target_dir}/target.log; \
		rm $${target_dir}/$${bn}.tmp; \
	done;


################################# MISCELLANEOUS ####################################################

stressed_corpus:
	for txt in prompts/$(SPEAKER)/$(EMOTION)/*.txt; do\
		$(PYTHON) scripts/get_phrase_prons.py $${txt} > $${txt}.stressed; \
	done;

syllabified_corpus:
	for txt in prompts/$(SPEAKER)/$(EMOTION)/*.txt.stressed; do\
		$(PYTHON) scripts/syllabify.py $${txt} dicstuff/corpus_stressed.dico $${txt}.Syllable; \
	done;



clean: clean-straight clean-mgc clean-lf0 clean-bap clean-cmp clean-label clean-mlf clean-list clean-scp

clean-straight: clean-wav clean-sp clean-f0 clean-ap

clean-wav:
	rm -rf wav

clean-sp:
	rm -rf sp

clean-f0:
	rm -rf f0

clean-ap:
	rm -rf ap

clean-mgc:
	rm -rf mgc

clean-lf0:
	rm -rf lf0

clean-bap:
	rm -rf bap

clean-cmp:
	rm -rf cmp

clean-label:
	rm -rf labels/mono
	rm -rf labels/full

clean-mlf:
	rm -f labels/*.mlf

clean-list:
	rm -rf lists

clean-scp:
	rm -rf scp

distclean: clean
	rm -f Makefile

.PHONY: all analysis labels mgc lf0 bap f0 cmp label mlf list scp clean mfcc Relations ffo stats
