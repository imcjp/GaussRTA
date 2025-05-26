#include "mex.h"
#include <math.h>

#define EPS   2.220446049250313e-16
#define PI    3.141592653589793238462643383279502884197169399375105820974944592307816406
#define DELTA 1e-5
#define GOLDEN 1.618033988749895
#define ROUND(X) (double)((long long)((X)+0.5))

/* ---------- helper functions ---------- */
static double FPT(double x, double y, int mIter)
{
    int    t = 1;
    double a = 1.0 / (y + 1.0);
    double p = 1.0 - a;
    double r = 0.0;

    if (mIter >= 0) {
        for (; t <= mIter; ++t) {
            r += a;
            a *= p * ((double)t) / (t + x);
        }
    } else {
        while (fabs(a) > EPS) {
            r += a;
            a *= p * ((double)t) / (t + x);
            ++t;
        }
    }
    return r;
}

static double RTA(double x, double y, int mIter)
{
    double a = 1.0, s = 0.0;
    double p = -(1.0 / y);
    double xt = ROUND(x) - x;
    if (fabs(xt) < DELTA) x = ROUND(x);
    xt = 1.0 - x;

    int k = 0;
    if (mIter >= 0) {
        for (; k < mIter; ++k) {
            if (xt != 0.0) s += a / xt;
            xt += 1.0;
            a  *= p;
        }
    } else {
        while (fabs(a) > EPS) {
            if (xt != 0.0) s += a / xt;
            xt += 1.0;
            a  *= p;
        }
    }

    if (ROUND(x) == x)
        return -x * ( log(y) * pow(p, x) + s / y );
    else
        return  x * ( PI * pow(1.0 / y, x) / sin(PI * x) - s / y );
}

static double HybridAlg(double x, double y, int mIter)
{
    if (x == 0.0 || y == 0.0) return 1.0;
    return (y < GOLDEN) ? FPT(x, y, mIter)
                        : RTA (x, y, mIter);
}
/* ---------- MEX gateway (fixed shape logic) ---------- */
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
    /* ---- Argument check ---- */
    if (nrhs < 2)
        mexErrMsgIdAndTxt("fastHypergeomIter:nargin",
                          "Need at least x and y.");

    int mode  = (nrhs >= 3) ? (int)(*mxGetPr(prhs[2])) : 0;
    int mIter = (nrhs >= 4) ? (int)(*mxGetPr(prhs[3])) : -1;

    /* ---- Input dimension ---- */
    mwSize mX = mxGetM(prhs[0]), nX = mxGetN(prhs[0]);
    mwSize mY = mxGetM(prhs[1]), nY = mxGetN(prhs[1]);

    /* ---- Dimension compatibility check: same as code A ---- */
    bool xScalar = (mX * nX == 1);
    bool yScalar = (mY * nY == 1);
    bool sameDim = (mX == mY) && (nX == nY);

    if (!(sameDim || xScalar || yScalar))
        mexErrMsgIdAndTxt("fastHypergeomIter:dimMismatch",
                          "Matrix dimensions must agree.");

    /* ---- Determine output size ---- */
    mwSize rows, cols;
    if (sameDim) {          /* Case 0: same shape matrices */
        rows = mX;  cols = nX;
    } else if (xScalar) {   /* Case 1: x is scalar */
        rows = mY;  cols = nY;
    } else {                /* Case 2: y is scalar */
        rows = mX;  cols = nX;
    }

    plhs[0] = mxCreateDoubleMatrix(rows, cols, mxREAL);

    /* ---- Pointers ---- */
    double *px = mxGetPr(prhs[0]);
    double *py = mxGetPr(prhs[1]);
    double *pz = mxGetPr(plhs[0]);

    mwSize nElem = rows * cols;

    /* ---------------- Element-wise computation ---------------- */
    if (xScalar && !yScalar) {                 /* x is scalar, y is matrix */
        double xVal = *px;
        for (mwSize i=0;i<nElem;++i,++py,++pz)
            *pz = (mode==1)? FPT (xVal,*py,mIter) :
                   (mode==2)? RTA  (xVal,*py,mIter):
                              HybridAlg   (xVal,*py,mIter);
    }
    else if (yScalar && !xScalar) {            /* y is scalar, x is matrix */
        double yVal = *py;
        for (mwSize i=0;i<nElem;++i,++px,++pz)
            *pz = (mode==1)? FPT (*px,yVal,mIter) :
                   (mode==2)? RTA (*px,yVal,mIter):
                              HybridAlg  (*px,yVal,mIter);
    }
    else {                                     /* Same shape matrices */
        for (mwSize i=0;i<nElem;++i,++px,++py,++pz)
            *pz = (mode==1)? FPT (*px,*py,mIter) :
                   (mode==2)? RTA (*px,*py,mIter):
                              HybridAlg  (*px,*py,mIter);
    }
}
