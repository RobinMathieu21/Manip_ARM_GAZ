function [output] = butter_emgs(data, frequ,  filter_order, cutoff, type, redress, centered)

%%% data : matrix of data without time
%%% frequ : frequency sample of the signal data
%%% filter_order : order of the filter
%%% cutoff : 1 by n matrix where n is 1 for low-pass and 2 for band-pass
%%% type : low-pass or band-pass
%%% redre : logical value, true or false for redressing or not the signal data

[nf,nc]=size(data);

for i=1:nc
    
    %% Common
    halfrate = frequ/2;
    if nargin < 4
        error 'review the filter paramters'
        return
    elseif nargin < 5
        type = 'low-pass';
        redress = 'false'
    elseif nargin < 6
        redress = 'false'
    end

    %% band-pass filter
    if strcmp(type, 'band-pass')==1
        if length(cutoff)==1
            passe = [1 cutoff];
        elseif length(cutoff)==2
            passe = cutoff;
        else
            error 'review the cutoff paramters'
            return
        end

        [b2 a2] = butter(filter_order, passe/halfrate);
        dataf(:,i) = filtfilt(b2, a2, data(:,i));
        if ( strcmp(redress, 'true') == 1 && strcmp(centered, 'true') )
            output(:,i) =  abs(dataf(:,i)-mean(dataf(:,i)));
        elseif ( strcmp(redress, 'true') == 1 && strcmp(centered, 'false') )
             output(:,i) =  abs(dataf(:,i));
        elseif ( strcmp(redress, 'false') == 1 && strcmp(centered, 'true') )
            output(:,i) = dataf(:,i)-mean(dataf(:,i));
        else
            output(:,i) = dataf(:,i);
        end

    %% Low-pass filter
    elseif strcmp(type, 'low-pass')==1
        if length(cutoff)==1
            passe = cutoff;
        else
            error 'review the cutoff paramters'
            return
        end
%         [b2 a2] = butter(filter_order, passe/halfrate);
%         dataf(:,i) = filtfilt(b2, a2, data(:,i));
        dataf=data;
        if ( strcmp(redress, 'true') == 1 && strcmp(centered, 'true') )
            output(:,i) =  abs(dataf(:,i)-mean(dataf(:,i)));
        elseif ( strcmp(redress, 'true') == 1 && strcmp(centered, 'false') )
             output(:,i) =  abs(dataf(:,i));
        elseif ( strcmp(redress, 'false') == 1 && strcmp(centered, 'true') )
            output(:,i) = dataf(:,i)-mean(dataf(:,i));
        else
            output(:,i) = dataf(:,i);
        end
        [b2 a2] = butter(filter_order, passe/halfrate);
        output(:,i) = filtfilt(b2, a2, output(:,i));
    else
        error 'review the filter paramters'
        return
    end
    
end