include makefile.opts

# # Sub-dirs
# DIRS     = opengl opencv

all: mexs dirs
mexs: gradientTimesJacobian.$(MXSFX) matMultThreeDim.$(MXSFX) \
      biHarmonicKernelOnPairwiseDistance.$(MXSFX) biHarmonicKernelDerivativeOnPairwiseDistance.$(MXSFX) 


dirs:
	for i in $(DIRS); do $(MAKE) -C $$i; done
clean:
	/bin/rm *.o
clean-all: clean
	/bin/rm *.$(MXSFX)

############## 
gradientTimesJacobian.$(MXSFX): gradientTimesJacobian.o
matMultThreeDim.$(MXSFX): matMultThreeDim.o
biHarmonicKernelOnPairwiseDistance.$(MXSFX): biHarmonicKernelOnPairwiseDistance.o
biHarmonicKernelDerivativeOnPairwiseDistance.$(MXSFX): biHarmonicKernelDerivativeOnPairwiseDistance.o

biHarmonicKernelOnPairwiseDistance.o : biHarmonicKernelOnPairwiseDistance.cpp biHarmonicKernel.h
biHarmonicKernelDerivativeOnPairwiseDistance.o : biHarmonicKernelDerivativeOnPairwiseDistance.cpp biHarmonicKernel.h
gradientTimesJacobian.o : gradientTimesJacobian.cpp


