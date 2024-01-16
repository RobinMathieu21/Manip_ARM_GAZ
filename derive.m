function DiffSignal=derive(signal,dt)
% Compute velocity of several signals given in columns. Rows are time
% acquisitions.
% symmetric version

[nf,nm]=size(signal);

% We smooth the signal to have better derivation
pas=(nf-1)/(5*nf-1);
pas2=pas*dt;
tt=[1:pas:nf]; % More points to smooth
nb=size(tt,2);

for j=1:nm
    smoothsignal=spline(1:nf,signal(:,j),tt);
    
    for i=2:nb-1
            signalderivative(i)=(smoothsignal(i+1)-smoothsignal(i-1))/(2*pas2); 
    end
    signalderivative(nb)=0;
    signalderivative(1)=0;
    
    % Resample to the good frequency dt
    % DiffSignal(:,j)=spline(tt,signalderivative,1:nf); 
    DiffSignal(:,j) = downsample(signalderivative,5);
    
    % interpolation on the bound values
    s=zeros(1);   
    abs = 2:nf-1 ;
    s(1:(nf-2))=DiffSignal(2:(nf-1),j);
    DiffSignal(1,j)=interp1(abs,s,1,'pchip') ; 

    abs = 1:nf-1 ;
    s(1:(nf-1))=DiffSignal(1:(nf-1),j); 
    DiffSignal(nf,j)=interp1(abs,s,nf,'pchip') ; 
end

