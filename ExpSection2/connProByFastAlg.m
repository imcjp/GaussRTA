function [ z ] = connProByFastAlg(P,r0,d1,eta,rm,q,N,p,lamda0,expType )
theta1=min(acos((r0^2+d1^2-rm^2)/(2*r0*d1)),pi);
omiga=myOmiga(rm,r0,d1,eta,theta1,q,expType);
z=exp(-q*N/(p*d1^(-eta)))*exp(-P*lamda0/(rm^2*pi)*omiga);
end

function [ z ] = myOmiga(rm,r0,d1,eta,theta1,q,expType)
z=quad(@(theta)dmyOmiga(rm,r0,d1,eta,theta,q,expType),0,theta1);
end

function [ z ] = dmyOmiga(rm,r0,d1,eta,theta,q,expType)
z=myphi(r0*cos(theta)+sqrt(rm^2-r0^2*(sin(theta)).^2),rm,r0,d1,eta,theta,q,expType)-myphi(d1,rm,r0,d1,eta,theta,q,expType);
end

function [ z ] = myphi( x,rm,r0,d1,eta,theta,q,expType)
fhg=@(x,y)HybridWithRTA(x,y,expType);
t1=x.^eta/(q*d1^eta);
z=(x.^2/6).*(6*(2-2*r0^2/rm^2)*fhg(2/eta,t1)-(2*x/rm^2).*(3*x.*fhg(4/eta,t1)-8*r0*cos(theta).*fhg(3/eta,t1)));
end
