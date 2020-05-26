/* 
function c = matMultThreeDim(a, b, i_a, i_b, i_c)
% matMultThreeDim - multiplies 3-D matrices a and b to give the 3-D result c.
% It is assumed that size(a,i_a)=size(b,i_b)=size(c,i_c), with one exception:
% If size(a,i_a)=1 and size(a,i_b)>1 (or vice versa), we take the same slice
% of a multiple times.
%
% For example, c = matMultThreeDim(a, b, 1, 3, 2)
%         c =         a x b
% [M1 N M3] = [N M1 M2] x [M2 M3 N]

George Papandreou, June 7, 2007

Useful mex functions:
int mxGetNumberOfDimensions(const mxArray *array_ptr);
const mwSize *mxGetDimensions(const mxArray *array_ptr);
mxArray *mxCreateNumericArray(int ndim, const int *dims, 
         mxClassID class, mxComplexity ComplexFlag);

*/

// Matlab related
#include <mex.h>

#include <cmath>

#define Scalar double

#define notDblMtx(it) (!mxIsNumeric(it) || !mxIsDouble(it) || mxIsSparse(it) || mxIsComplex(it))
#define max(x,y) ((x)>(y)?(x):(y))

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])  {

    // Parse arguments to matlab function
    if (nrhs<5) mexErrMsgTxt("too few args.");
    if (nlhs>1) mexErrMsgTxt("too many ouputs.");

    // ARG 0: input matrix a [* M1 * M2 *], with i_a * equal N
    const mxArray *a_mx = prhs[0];
    if notDblMtx(a_mx) mexErrMsgTxt("a must be a non-sparse double matrix.");
    const int a_dim = mxGetNumberOfDimensions(a_mx);
    if (a_dim>3) mexErrMsgTxt("a can be 3-dimensional at most.");
    const mwSize *a_size1 = mxGetDimensions(a_mx);
    int a_size[3];
    for(int i=0; i<a_dim; i++) a_size[i] = a_size1[i]; 
    for(int i=a_dim; i<3; i++) a_size[i] = 1; 
    Scalar *a_ptr_0 = mxGetPr(a_mx);
    
    // ARG 1: input matrix b [* M2 * M3 *], with i_b * equal N
    const mxArray *b_mx = prhs[1];
    if notDblMtx(b_mx) mexErrMsgTxt("b must be a non-sparse double matrix.");
    const int b_dim = mxGetNumberOfDimensions(b_mx);
    if (b_dim>3) mexErrMsgTxt("b can be 3-dimensional at most.");
    const mwSize *b_size1 = mxGetDimensions(b_mx);
    int b_size[3];
    for(int i=0; i<b_dim; i++) b_size[i] = b_size1[i]; 
    for(int i=b_dim; i<3; i++) b_size[i] = 1; 
    Scalar *b_ptr_0 = mxGetPr(b_mx);
    
    // ARG 2: i_a
    const mxArray *i_a_mx = prhs[2];
    if notDblMtx(i_a_mx) mexErrMsgTxt("i_c must be a non-sparse double matrix.");
    const int i_a = (int) mxGetScalar(i_a_mx);
    if (i_a<1 || i_a>3) mexErrMsgTxt("i_a can be one of 1, 2, 3.");

    // ARG 3: i_b
    const mxArray *i_b_mx = prhs[3];
    if notDblMtx(i_b_mx) mexErrMsgTxt("i_b must be a non-sparse double matrix.");
    const int i_b = (int) mxGetScalar(i_b_mx);
    if (i_b<1 || i_b>3) mexErrMsgTxt("i_b can be one of 1, 2, 3.");
 
    // ARG 4: i_c
    const mxArray *i_c_mx = prhs[4];
    if notDblMtx(i_c_mx) mexErrMsgTxt("i_c must be a non-sparse double matrix.");
    const int i_c = (int) mxGetScalar(i_c_mx);
    if (i_c<1 || i_c>3) mexErrMsgTxt("i_c can be one of 1, 2, 3.");
 
    // Find interesting dimensions and strides

    // N
    const int N_a = a_size[i_a-1];
    const int N_b = b_size[i_b-1];
    if (N_a!=N_b && N_a>1 && N_b>1) mexErrMsgTxt("size(a,i_a) incompatible with size(b,i_b)");
    const int N_c = max(N_a,N_b);

    // a matrix
    int M1, M2;
    int a_n_str, a_1_str, a_2_str;
    if (i_a==1) {      // a [N M1 M2]
	M1=a_size[1];  M2=a_size[2];
	a_n_str=1;     a_1_str=N_a;   a_2_str=N_a*M1;
    }
    else if (i_a==2) { // a [M1 N M2]
	M1=a_size[0];  M2=a_size[2];
	a_n_str=M1;    a_1_str=1;     a_2_str=N_a*M1;
    }
    else             { // a [M1 M2 N]
	M1=a_size[0];  M2=a_size[1];
	a_n_str=M1*M2; a_1_str=1;     a_2_str=M1;
    }
    if (N_a==1) a_n_str=0;

    // b matrix
    int M2b, M3;
    int b_n_str, b_2_str, b_3_str;
    if (i_b==1) {      // b [N M2 M3]
	M2b=b_size[1]; M3=b_size[2];
	b_n_str=1;     b_2_str=N_b;   b_3_str=N_b*M2;
    }
    else if (i_b==2) { // b [M2 N M3]
	M2b=b_size[0]; M3=b_size[2];
	b_n_str=M2;    b_2_str=1;     b_3_str=N_b*M2;
    }
    else             { // b [M2 M3 N]
	M2b=b_size[0]; M3=b_size[1];
	b_n_str=M2*M3; b_2_str=1;     b_3_str=M2;
    }
    if (N_b==1) b_n_str=0;
    if (M2!=M2b) mexErrMsgTxt("a and b have incompatible sizes");

    // c matrix
    int c_n_str, c_1_str, c_3_str;
    const int c_dim = 3;
    mwSize c_size[3];
    if (i_c==1) {      // c [N M1 M3]
	c_size[0]=N_c; c_size[1]=M1;  c_size[2]=M3;
	c_n_str=1;     c_1_str=N_c;   c_3_str=N_c*M1;
    }
    else if (i_c==2) { // c [M1 N M3]
	c_size[0]=M1;  c_size[1]=N_c; c_size[2]=M3;
	c_n_str=M1;    c_1_str=1;     c_3_str=N_c*M1;
    }
    else             { // c [M1 M3 N]
	c_size[0]=M1;  c_size[1]=M3;  c_size[2]=N_c;
	c_n_str=M1*M3; c_1_str=1;     c_3_str=M1;
    }

    // OUTPUT ARG: c [* M1 * M3 *], with i_c * equal N
    plhs[0] = (mxArray *) mxCreateNumericArray(c_dim, c_size, mxDOUBLE_CLASS, mxREAL);
    if (plhs[0] == NULL) mexErrMsgTxt("Cannot allocate result matrix");
    Scalar *c_ptr_0 = mxGetPr(plhs[0]);

    Scalar *a_ptr, *b_ptr, *c_ptr;

    // Compute the result
    for (int i_n=0; i_n<N_c; i_n++) {
	for (int i3=0; i3<M3; i3++) {
	    for (int i1=0; i1<M1; i1++) {
		a_ptr = a_ptr_0 + i_n*a_n_str + i1*a_1_str;
		b_ptr = b_ptr_0 + i_n*b_n_str + i3*b_3_str;
		c_ptr = c_ptr_0 + i_n*c_n_str + i1*c_1_str + i3*c_3_str;
		*c_ptr=0;
		for (int i2=0; i2<M2; i2++) {
		    *c_ptr += (*a_ptr)*(*b_ptr);
		    a_ptr += a_2_str;
		    b_ptr += b_2_str;
		}
	    }
	}
    }


    return;
}
