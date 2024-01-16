for SUJET=1:20   

lgth = Data.Gaz(SUJET).time(size(Data.Gaz(SUJET).time,1),1);
    timelin = 1:1:100*lgth;
    

    %reorganize data
    t_data = Data.Gaz(SUJET).time;
    x_data = Data.Gaz(SUJET).coeff(:,1);
    t_data2 = linspace(t_data(1),t_data(end),100*lgth);
    



    %create a function perfectly fitting the position signal over time
    %for x data
    pp_posx=interp1(t_data,x_data,t_data2,'pchip').';

    Data.Gaz(SUJET).coeff(1:100*lgth,2) = pp_posx; % Sampled version
    Data.Gaz(SUJET).coeff(1:100*lgth,3) = smoothdata(Data.Gaz(SUJET).coeff(1:100*lgth,2),'movmean',[1000 1000]);

end

for SUJET=1:20   
%     figure;plot(Data.Gaz(SUJET).coeff(:,end))

    Data.Gaz(1).RERmoyen(SUJET,1) = mean(Data.Gaz(SUJET).coeff([1:190000 250000:end],end));


end

for SUJET=1:20   

    counter = 0;
    for i=1:length(Data.Gaz(SUJET).coeff(:,3))
        if Data.Gaz(SUJET).coeff(i,end)>1
            if  (190000>i) || (250000<i)
                counter = counter +1;
            end
        else
        end
    end

    Data.Gaz(1).RERmoyen(SUJET,2) = 100*counter/length(Data.Gaz(SUJET).coeff(:,3));


end