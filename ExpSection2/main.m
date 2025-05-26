clear all;clc;close all
addpath('./core');
%% Setting parameters
rm=5;
q=1;
p=1;
N=1;
%% Experimental input parameters
% expType: 0.Built-in; 1.PFT Only; 2.Our Hybrid with RTA
expType=0;
% Range of parameter P
Ps=[0:0.01:1];
% Parameters of each figure
lamda0s=1:5;
etas=1:5;

%% Execution
rc=RegionalCoverage(expType);

expTypeStr={'Built-in','PFT Only','Our Hybrid with RTA'};
for i=1:length(etas)
    eta=etas(i);
    res=zeros(length(lamda0s),length(Ps));
    for j=1:length(lamda0s)
        lamda0=lamda0s(j);
        for t=1:length(Ps)
            P=Ps(t);
            %% Using the new algorithm proposed in the paper
            fprintf('Starting %s case for ¦Ç is %g, ¦Ë is %g and P is %g.\n',expTypeStr{expType+1},eta,lamda0,P);
            
            tic
            val=rc.calc(P,eta,rm,q,N,p,lamda0);
            tm=toc;
            fprintf('For %s, when ¦Ç is %g, ¦Ë is %g and P is %g, the result is %g. Used time is %gms.\n',expTypeStr{expType+1},eta,lamda0,P,val,tm*1000);
            
        end
    end
end
disp('Experiment completed!');