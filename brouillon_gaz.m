

for SUJET=1:14
    for bloc=1:4
        Data.Gaz(1).BlocsMeanTEST(,SUJET*2) = mean(Data.Gaz(SUJET).NMP(time1:time2,2))-mean(Data.Gaz(SUJET).NMP(time3:time4,2));
    end
end


    if PremierBloc ==1 % Horizontal first
        a=0;
        for i=[3 11 23 31]
            a=a+1;
            time1 = Data.Gaz(1).timing(i,1);time2 = Data.Gaz(1).timing(i+2,1);time3 = Data.Gaz(1).timing(i-1,1);time4 = Data.Gaz(1).timing(i-1,1)+60;

            Data.Gaz(1).BlocsMean(a+12,SUJET*2) = mean(Data.Gaz(SUJET).NMP(time1:time2,2))-mean(Data.Gaz(SUJET).NMP(time3:time4,2)); %AireNotLiss
        end
        a=0;
        for i=[7 15 27 35]
            a=a+1;
            time1 = Data.Gaz(1).timing(i,1);time2 = Data.Gaz(1).timing(i+2,1);time3 = Data.Gaz(1).timing(i-1,1);time4 = Data.Gaz(1).timing(i-1,1)+60;

            Data.Gaz(1).BlocsMean(a+12,SUJET*2-1) = mean(Data.Gaz(SUJET).NMP(time1:time2,2))-mean(Data.Gaz(SUJET).NMP(time3:time4,2));
            
        end
    else % If it is vertical first
        a=0;
        for i=[7 15 27 35]
            a=a+1;
            time1 = Data.Gaz(1).timing(i,1);time2 = Data.Gaz(1).timing(i+2,1);time3 = Data.Gaz(1).timing(i-1,1);time4 = Data.Gaz(1).timing(i-1,1)+60;
            Data.Gaz(1).BlocsMean(a+12,SUJET*2) = trapz(Data.Gaz(SUJET).NMP(time1:time2,2))-trapz(Data.Gaz(SUJET).NMP(time3:time4,2)); %AireNotLiss

        end
        a=0;
        for i=[3 11 23 31]
            a=a+1;
            time1 = Data.Gaz(1).timing(i,1);time2 = Data.Gaz(1).timing(i+2,1);time3 = Data.Gaz(1).timing(i-1,1);time4 = Data.Gaz(1).timing(i-1,1)+60;

            Data.Gaz(1).BlocsMean(a+12,SUJET*2-1) = trapz(Data.Gaz(SUJET).NMP(time1:time2,2))-trapz(Data.Gaz(SUJET).NMP(time3:time4,2));
        end
    end
