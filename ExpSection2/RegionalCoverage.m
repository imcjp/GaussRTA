classdef RegionalCoverage < handle    
    properties
        expType
        expType4Fast
    end    
    methods
        function obj = RegionalCoverage(expType)
            obj.expType=expType;
            if expType>0
                arr=[1,0];
                obj.expType4Fast=arr(expType);
            else
                obj.expType4Fast=0;
            end
        end
        
        function [ z ] = calc(obj,P,eta,rm,q,N,p,lamda0 )
            eps=1e-6;
            z2=quad(@(r0)funcTemp2(obj, P,r0,rm,lamda0 ),0,rm);
            z1=dblquad(@(r0,d1)funcTemp1(obj, P,r0,d1,eta,rm,q,N,p,lamda0 ),eps,rm-eps,eps,2*rm-eps);
            z=z1/z2;
        end
        
        function [ z ] = funcTemp1(obj,P,r0s,d1s,eta,rm,q,N,p,lamda0 )
            for i=1:length(r0s)
                for j=1:length(d1s)
                    r0=r0s(i);
                    d1=d1s(j);
                    if d1>rm+r0
                        z(i+j-1)=0;
                    else
                        if obj.expType==0
                            connPro=connProByOrgAlg(P,r0,d1,eta,rm,q,N,p,lamda0);
                        else
                            connPro=connProByFastAlg(P,r0,d1,eta,rm,q,N,p,lamda0,obj.expType4Fast);
                        end
                        proBase=proOfBaseStation(P,r0,d1,rm,lamda0);
                        z(i+j-1)=proBase*connPro*pdfOf2D(r0,rm)*lamda0.*r0;
                    end
                end
            end
        end
        
        function [ z ] = funcTemp2(obj, P,r0,rm,lamda0 )
	        z=pdfOf2D(r0,rm)*lamda0.*r0/4;
        end
    end    
end

