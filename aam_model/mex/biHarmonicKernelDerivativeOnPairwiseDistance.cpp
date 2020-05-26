/* 
function u = biHarmonicKernelDerivativeOnPairwiseDistance(refShape, sourceShape)
% Given a reference shape and a source shape, compute kernel(pairdist).
% 
% Context:
%
% Remember that thinPlateParams = W = (W_1; ... ;W_d) , with dims d x (n+d+1)
%
% If x is a single point, we compute the derivative of the warp sx->tx=f(x) by f'(x) = W*u'(x), 
% where u'(x) = [dU(|x-x_1|)/dx; dU(|x-x_2|)/dx; ...; dU(|x-x_n|)/dx; 0_{1xd}; I_d];
%
% This function computes the [dU(|x-x_1|)/dx; dU(|x-x_2|)/dx; ...; dU(|x-x_n|)/dx] part of u'

[n,d] = size(refShape);
[m,d] = size(sourceShape);

kernel = @biHarmonicKernelND;

% Compute u = kernel(pairDist)
% For one point, u'(x) = [dU(|x-x_1|)/dx; dU(|x-x_2|)/dx; ...; dU(|x-x_n|)/dx];
% size(u') = [n,d,m]

U_2(r) = r^2 ln(r^2)
U_3(r) = r

dU_2(|x|)/dx = 2(1+ln(|x|^2))x
dU_3(|x|)/dx = x/|x|

cf Tim Cootes' vxl class mbl_thin_plate_spline_2d

gpapan, February 06, 2006
*/

// Matlab related
#include <mex.h>
#define notDblMtx(it) (!mxIsNumeric(it) || !mxIsDouble(it) || mxIsSparse(it) || mxIsComplex(it))

#include "biHarmonicKernel.h"
#define Scalar double

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])  {

    // Parse arguments to matlab function
    if (nrhs!=2) mexErrMsgTxt("requires exactly 2 input arg.");
    if (nlhs>1) mexErrMsgTxt("outputs at most 1 arg.");

    // ARG 1: reference shape, with size [n,d]
    const mxArray *ref_shape = prhs[0];
    if notDblMtx(ref_shape) mexErrMsgTxt("ref_shape must be a non-sparse double float matrix.");
    const mwSize n = mxGetM(ref_shape);
    const mwSize d = mxGetN(ref_shape);
    Scalar *ref_shape_ptr = mxGetPr(ref_shape);
 
    // ARG 2: source shape, with size [m,d]
    const mxArray *src_shape = prhs[1];
    if notDblMtx(src_shape) mexErrMsgTxt("src_shape must be a non-sparse double float matrix.");
    const mwSize m = mxGetM(src_shape);
    if (mxGetN(src_shape) != d) mexErrMsgTxt("src_shape and ref_shape have incompatible dims.");
    Scalar *src_shape_ptr = mxGetPr(src_shape);
 
    if (nlhs>0) {
	// OUTPUT ARG: kernelDerivative(pairDist), with size(u') = [n,d,m] 
	mwSize res_size[3];     const unsigned int res_dim = 3;
	res_size[0] = n; res_size[1] = d; res_size[2] = m;
	plhs[0] = (mxArray *) mxCreateNumericArray(res_dim, res_size, mxDOUBLE_CLASS, mxREAL);
	if (plhs[0] == NULL) mexErrMsgTxt("Cannot allocate result matrix");
	Scalar *res_ptr = mxGetPr(plhs[0]);

	const int two_m = 2*m; const int two_n = 2*n;
	const int dn = d*n;
	switch(d) {
	    case 2: // 2-d
		for (mwSize i_m=0; i_m<m; i_m++)
		    for (mwSize i_n=0; i_n<n; i_n++)
			biHarmonicKernelDerivative2d(src_shape_ptr[i_m]-ref_shape_ptr[i_n],     // x_m-x_n
						     src_shape_ptr[i_m+m]-ref_shape_ptr[i_n+n], // y_m-y_n
						     res_ptr+ i_n +     i_m*dn,                 // ux=res[i_m][0][i_n]
						     res_ptr+ i_n + n + i_m*dn);                // uy=res[i_m][1][i_n]
		break;
	    case 3: // 3-d
		for (mwSize i_m=0; i_m<m; i_m++)
		    for (mwSize i_n=0; i_n<n; i_n++)
			biHarmonicKernelDerivative3d(src_shape_ptr[i_m]-ref_shape_ptr[i_n],   // x_m-x_n
						     src_shape_ptr[i_m+m]-ref_shape_ptr[i_n+n],         // y_m-y_n
						     src_shape_ptr[i_m+two_m]-ref_shape_ptr[i_n+two_n], // z_m-z_n
						     res_ptr+ i_n +         i_m*dn,           // ux=res[i_m][0][i_n]
						     res_ptr+ i_n +     n + i_m*dn,           // uy=res[i_m][1][i_n]
						     res_ptr+ i_n + two_n + i_m*dn);          // uy=res[i_m][2][i_n]
		break;
	    default:
		mexErrMsgTxt("Can only handle 2D and 3D case for the time being");
		break;
	}
    }  

    return;
}
