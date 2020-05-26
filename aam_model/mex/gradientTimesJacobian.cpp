/* 
function sd = gradientTimesJacobian(grad, jac)
% GRADIENTTIMESJACOBIAN - multiplies gradient and jacobian and
% yields a steepest descent template image, with dim
% [N numColors n] = [N numColors dims] x [N dims n]

Note that this is equivalent to
sd = matMultThreeDim(grad, jac, 1, 1, 1)

gpapan, November 24, 2005

Useful mex functions:
int mxGetNumberOfDimensions(const mxArray *array_ptr);
const int *mxGetDimensions(const mxArray *array_ptr);
mxArray *mxCreateNumericArray(int ndim, const int *dims, 
         mxClassID class, mxComplexity ComplexFlag);

*/

// Matlab related
#include <mex.h>
//#include <mat.h>
//#include <engine.h>
//#include <matrix.h>

#include <cmath>

#define Scalar double

#define notDblMtx(it) (!mxIsNumeric(it) || !mxIsDouble(it) || mxIsSparse(it) || mxIsComplex(it))

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])  {

    // Parse arguments to matlab function
    if (nrhs<2) mexErrMsgTxt("requires at least 2 arg.");
    if (nlhs>1) mexErrMsgTxt("ouputs only 1 arg.");

    // ARG 1: input gradient matrix, with [N numColors dims] = size(grad);
    const mxArray *grad = prhs[0];
    if notDblMtx(grad) mexErrMsgTxt("grad must be a non-sparse double float matrix.");
    const int grad_dim = mxGetNumberOfDimensions(grad);
    if (grad_dim!=3) mexErrMsgTxt("grad must be a 3-dimensional matrix.");
    const mwSize *grad_size = mxGetDimensions(grad);
    const mwSize N = grad_size[0];
    const mwSize numColors = grad_size[1];
    const mwSize dims = grad_size[2];
    Scalar *grad_ptr = mxGetPr(grad);
 
    // ARG 2: input shape jacobian matrix, with [N dims n] = size(jac);
    const mxArray *jac = prhs[1];
    if notDblMtx(jac) mexErrMsgTxt("jac must be a non-sparse double float matrix.");
    const int jac_dim = mxGetNumberOfDimensions(jac);
    if (jac_dim<2 || jac_dim>4) mexErrMsgTxt("jac must be a 2 or 3-dimensional matrix.");
    const mwSize *jac_size = mxGetDimensions(jac);
    if (jac_size[0]!=N || jac_size[1]!=dims) mexErrMsgTxt("grad and jac have incompatible dims.");
    unsigned int n = 1; // default
    if (jac_dim>2) n = jac_size[2];
    Scalar *jac_ptr = mxGetPr(jac);
 
    // OUTPUT ARG: shape steepest descent images, with [N numColors n] = size(sd)
    const unsigned int sd_dim = 3;
    mwSize sd_size[3];
    sd_size[0] = N; sd_size[1] = numColors; sd_size[2] = n;
    plhs[0] = (mxArray *) mxCreateNumericArray(sd_dim, sd_size, mxDOUBLE_CLASS, mxREAL);
    if (plhs[0] == NULL) mexErrMsgTxt("Cannot allocate result matrix");
    Scalar *sd_ptr = mxGetPr(plhs[0]);

    // Compute the result
    // [N numColors n] = [N numColors dims] x [N dims n]
    const mwSize N_numColors = N*numColors;
    const mwSize N_dims      = N*dims;
    for (unsigned int i_n=0; i_n<n; i_n++) {
	for (unsigned int i_c=0; i_c<numColors; i_c++) {
	    for (mwSize i_N=0; i_N<N; i_N++) {
		Scalar tmp = 0.0;
		for (unsigned int i_d=0; i_d<dims; i_d++)
		    tmp += grad_ptr[i_N + i_c*N + i_d*N_numColors] * jac_ptr[i_N + i_d*N + i_n*N_dims];
		//sd_ptr[i_N + i_c*N + i_n*N*numColors]
		*sd_ptr++ = tmp;
	    }
	}
    }
		
    return;
}
