#include "mex.h"
#include <math.h>
#define EPS 2.220446049250313e-16
#define PI 3.141592653589793238462643383279502884197169399375105820974944592307816406
#define DELTA 1e-5
#define GOLDEN_SECTION_NUMBER 1.618033988749895
#define ROUND(X) (double)((long long)(X+0.5))
double FPT(double x,double y){
    int t=1;
    double a,p,r;
    r=0;
    a=1/(y+1);
    p=1-a;
    while(a>EPS){
        r+=a;
        a*=p*(t/(t+x));
        t++;
    }
    return r;
}
double RTA(double x,double y){
    double s,a,p,r,xt;
    a=1;
    s=0;
    p=-(1/y);
    xt=ROUND(x)-x;
    if (xt<DELTA&&xt>-DELTA) {
        x=ROUND(x);
    }
    xt=1-x;
    while(a>EPS||a<-EPS){
        if(xt!=0) {
            s+=a/xt;
        }
        xt+=1;
        a*=p;
    }
    if (ROUND(x)==x){
        r=-x*(log(y)*pow(p,x)+s/y);
    }else{
        r=x*(PI*pow(1/y,x)/sin(PI*x)-s/y);
    }
    return r;
}
double HybridAlg(double x,double y){
    if(x==0||y==0){
        return 1;
    }else if(y<GOLDEN_SECTION_NUMBER){
        return FPT(x,y);
    }else{
        return RTA(x,y);
    }
}
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int n,i;
    double *px,*py,*pz,tmp;
    int tp=0;
    if(nrhs < 2) {
        mexErrMsgIdAndTxt("MATLAB:mexcpp:nargin","need two matrice");
    }
    if(nrhs==3){
        tp = * mxGetPr(prhs[2]);
    }
    if((mxGetN(prhs[0]) == mxGetN(prhs[1]))&&(mxGetM(prhs[0]) == mxGetM(prhs[1]))) {
        n=mxGetN(prhs[0])*mxGetM(prhs[0]);
        plhs[0]=mxCreateDoubleMatrix(mxGetM(prhs[0]),mxGetN(prhs[0]),mxREAL);
        px = mxGetPr(prhs[0]);
        py = mxGetPr(prhs[1]);
        pz = mxGetPr(plhs[0]);
        for(i=0;i<n;++i,++px,++py,++pz){
            if(tp==0){
                *pz=HybridAlg(*px,*py);
            }else if(tp==1){
                *pz=FPT(*px,*py);
            }else if(tp==2){
                *pz=RTA(*px,*py);
            }
        }
    }else if((mxGetN(prhs[0]) == 1)||(mxGetM(prhs[0]) == 1)) {
        n=mxGetN(prhs[1])*mxGetM(prhs[1]);
        plhs[0]=mxCreateDoubleMatrix(mxGetM(prhs[1]),mxGetN(prhs[1]),mxREAL);
        px = mxGetPr(prhs[0]);
        tmp=*px;
        py = mxGetPr(prhs[1]);
        pz = mxGetPr(plhs[0]);
        for(i=0;i<n;++i,++py,++pz){
            if(tp==0){
                *pz=HybridAlg(tmp,*py);
            }else if(tp==1){
                *pz=FPT(tmp,*py);
            }else if(tp==2){
                *pz=RTA(tmp,*py);
            }
        }
    }else if((mxGetN(prhs[1]) ==1)||(mxGetM(prhs[1]) ==1)) {
        n=mxGetN(prhs[0])*mxGetM(prhs[0]);
        plhs[0]=mxCreateDoubleMatrix(mxGetM(prhs[0]),mxGetN(prhs[0]),mxREAL);
        px = mxGetPr(prhs[0]);
        py = mxGetPr(prhs[1]);
        tmp=*py;
        pz = mxGetPr(plhs[0]);
        for(i=0;i<n;++i,++px,++pz){
            if(tp==0){
                *pz=HybridAlg(*px,tmp);
            }else if(tp==1){
                *pz=FPT(*px,tmp);
            }else if(tp==2){
                *pz=RTA(*px,tmp);
            }
        }
    }else{
        mexErrMsgIdAndTxt("MyToolbox:arrayProduct:innerDimensions","Matrix dimensions must agree.");
    }
}