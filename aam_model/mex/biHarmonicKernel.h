#ifndef biHarmonicKernel_h
#define biHarmonicKernel_h

#include <cmath>
#include <limits>

// U_2(r) = r^2 ln(r^2)
template<class T>
inline T biHarmonicKernel2d(const T x, const T y)
{
  const T r2 = x * x + y * y;
  if (r2>std::numeric_limits<T>::min()) return r2 * log(r2);
  return 0;
}

// U_3(r) = r
template<class T>
inline T biHarmonicKernel3d(const T x, const T y, const T z)
{
  return sqrt(x*x + y*y + z*z);
}

// dU_2(|x|)/dx = 2(1+ln(|x|^2))x
template<class T>
void biHarmonicKernelDerivative2d(const T x, const T y, T *ux, T *uy)
{
    const T r2 = x * x + y * y;
    if (r2>std::numeric_limits<T>::min()) {
	const T alpha = 2*(1.0+log(r2));
	*ux = alpha * x; *uy = alpha * y;
    }
    else {
	*ux = 0.0; *uy = 0.0;
    }
}

// dU_3(|x|)/dx = x/|x|
template<class T>
void biHarmonicKernelDerivative3d(const T x, const T y, const T z, T *ux, T *uy, T *uz) 
{
    const T r2 = x * x + y * y;
    if (r2>std::numeric_limits<T>::min()) {
	const T alpha = 1/sqrt(r2);
	*ux = alpha * x; *uy = alpha * y; *uz = alpha * z;
    }
    else {
	*ux = *uy = *uz = 1/sqrt(3.0);
    }
}

#endif // biHarmonicKernel_h
