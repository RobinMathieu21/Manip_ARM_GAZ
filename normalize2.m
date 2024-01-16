function [signal_,newfreq]=normalize2(signal,type,nbnorm)

global FREQ

NBNORM=nbnorm;

if nargin <= 1

    [rows,cols]=size(signal);

    xx=1:(rows-1)/(NBNORM-1):rows;

    if rows<NBNORM
        for j=1:cols   
            x = 1:rows ;
            signal_(:,j) = spline(x,signal(:,j),xx);
        end
    end

    if rows>=NBNORM
        % on met d'abord un multiple de n. avec spline.
        xx2=1:(rows-1)/(4*NBNORM-1):rows;
        for j=1:cols   
            x = 1:rows ;
            signal_tmp(:,j) = spline(x,signal(:,j),xx2);
        end

        for j=1:cols   

            nsignal_(:,j) = downsample(signal_tmp(:,j),4);

        end

        signal_=nsignal_;
        % plot(signal_); hold on;

    end

    newfreq=(rows-1)/(NBNORM-1)*FREQ;    
    
else
   
    [rows,cols]=size(signal);

    xx=1:(rows-1)/(NBNORM-1):rows;

    if rows<NBNORM
        for j=1:cols   
            x = 1:rows ;
            signal_(:,j) = interp1(x,signal(:,j),xx,type);
        end
    end

    if rows>=NBNORM
        % on met d'abord un multiple de n. avec spline.
        xx2=1:(rows-1)/(4*NBNORM-1):rows;
        for j=1:cols   
            x = 1:rows ;
            signal_tmp(:,j) = interp1(x,signal(:,j),xx2,type);
        end

        for j=1:cols   

            nsignal_(:,j) = downsample(signal_tmp(:,j),4);

        end

        signal_=nsignal_;
        % plot(signal_); hold on;

    end

    newfreq=(rows-1)/(NBNORM-1)*FREQ;    
    
    
end