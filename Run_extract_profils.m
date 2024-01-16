 

for i=1:20
    for a=1:4
        a
        Donnees(i).Kinematics(a).PANVersD( :, all(~Donnees(i).Kinematics(a).PANVersD,1) ) = [];
        Donnees(i).Kinematics(a).PANVersG( :, all(~Donnees(i).Kinematics(a).PANVersG,1) ) = [];

        Donnees(i).Kinematics(a).PVNVersD( :, all(~Donnees(i).Kinematics(a).PVNVersD,1) ) = [];
        Donnees(i).Kinematics(a).PVNVersG( :, all(~Donnees(i).Kinematics(a).PVNVersG,1) ) = [];

        Donnees(i).Kinematics(a+4).PANVersB( :, all(~Donnees(i).Kinematics(a+4).PANVersB,1) ) = [];
        Donnees(i).Kinematics(a+4).PANVersH( :, all(~Donnees(i).Kinematics(a+4).PANVersH,1) ) = [];

        Donnees(i).Kinematics(a+4).PVNVersB( :, all(~Donnees(i).Kinematics(a+4).PVNVersB,1) ) = [];
        Donnees(i).Kinematics(a+4).PVNVersH( :, all(~Donnees(i).Kinematics(a+4).PVNVersH,1) ) = [];

    end
end



for i=1:20
    for a=1:4

        [~,vv] = size(Donnees(i).Kinematics(a).PVNVersD);
        for nb=1:vv
            Donnees(i).Kinematics(a).PVNVersDNorm(:,nb) = Donnees(i).Kinematics(a).PVNVersD(:,nb)./max(Donnees(i).Kinematics(a).PVNVersD(:,nb)) ;
        end
        [~,vv] = size(Donnees(i).Kinematics(a).PVNVersG);
        for nb=1:vv
            Donnees(i).Kinematics(a).PVNVersGNorm(:,nb) = Donnees(i).Kinematics(a).PVNVersG(:,nb)./max(Donnees(i).Kinematics(a).PVNVersG(:,nb)) ;
        end

        [~,vv] = size(Donnees(i).Kinematics(a).PANVersG);
        for nb=1:vv
            Donnees(i).Kinematics(a).PANVersGNorm(:,nb) = Donnees(i).Kinematics(a).PANVersG(:,nb)./max(Donnees(i).Kinematics(a).PANVersG(:,nb)) ;
        end
        [~,vv] = size(Donnees(i).Kinematics(a).PANVersD);
        for nb=1:vv
            Donnees(i).Kinematics(a).PANVersDNorm(:,nb) = Donnees(i).Kinematics(a).PANVersD(:,nb)./max(Donnees(i).Kinematics(a).PANVersD(:,nb)) ;
        end

        [~,vv] = size(Donnees(i).Kinematics(a+4).PVNVersH);
        for nb=1:vv
            Donnees(i).Kinematics(a+4).PVNVersHNorm(:,nb) = Donnees(i).Kinematics(a+4).PVNVersH(:,nb)./max(Donnees(i).Kinematics(a+4).PVNVersH(:,nb)) ;
        end
        [~,vv] = size(Donnees(i).Kinematics(a+4).PVNVersB);
        for nb=1:vv
            Donnees(i).Kinematics(a+4).PVNVersBNorm(:,nb) = Donnees(i).Kinematics(a+4).PVNVersB(:,nb)./max(Donnees(i).Kinematics(a+4).PVNVersB(:,nb)) ;
        end

        [~,vv] = size(Donnees(i).Kinematics(a+4).PANVersH);
        for nb=1:vv
            Donnees(i).Kinematics(a+4).PANVersHNorm(:,nb) = Donnees(i).Kinematics(a+4).PANVersH(:,nb)./max(Donnees(i).Kinematics(a+4).PANVersH(:,nb)) ;
        end
        [~,vv] = size(Donnees(i).Kinematics(a+4).PANVersB);
        for nb=1:vv
            Donnees(i).Kinematics(a+4).PANVersBNorm(:,nb) = Donnees(i).Kinematics(a+4).PANVersB(:,nb)./max(Donnees(i).Kinematics(a+4).PANVersB(:,nb)) ;
        end

    end
end

for i=1:20
    counter = 1;
    for a=1:4
        [~,vv]=size(Donnees(i).Kinematics(a).PVNVersDNorm);
        Donnees(i).Kinematics(9).PVNVersDNorm(:,counter:counter+vv-1)  = Donnees(i).Kinematics(a).PVNVersDNorm  ;
        counter = counter+vv;
    end
    counter = 1;
    for a=1:4
        [~,vv]=size(Donnees(i).Kinematics(a).PVNVersGNorm);
        Donnees(i).Kinematics(9).PVNVersGNorm(:,counter:counter+vv-1)  = Donnees(i).Kinematics(a).PVNVersGNorm  ;
        counter = counter+vv;
    end

    counter = 1;
    for a=1:4
        [~,vv]=size(Donnees(i).Kinematics(a).PANVersDNorm);
        Donnees(i).Kinematics(9).PANVersDNorm(:,counter:counter+vv-1)  = Donnees(i).Kinematics(a).PANVersDNorm  ;
        counter = counter+vv;
    end
    counter = 1;
    for a=1:4
        [~,vv]=size(Donnees(i).Kinematics(a).PANVersGNorm);
        Donnees(i).Kinematics(9).PANVersGNorm(:,counter:counter+vv-1)  = Donnees(i).Kinematics(a).PANVersGNorm  ;
        counter = counter+vv;
    end




    counter = 1;
    for a=1:4
        [~,vv]=size(Donnees(i).Kinematics(a+4).PVNVersHNorm);
        Donnees(i).Kinematics(9).PVNVersHNorm(:,counter:counter+vv-1)  = Donnees(i).Kinematics(a+4).PVNVersHNorm  ;
        counter = counter+vv;
    end
    counter = 1;
    for a=1:4
        [~,vv]=size(Donnees(i).Kinematics(a+4).PVNVersBNorm);
        Donnees(i).Kinematics(9).PVNVersBNorm(:,counter:counter+vv-1)  = Donnees(i).Kinematics(a+4).PVNVersBNorm  ;
        counter = counter+vv;
    end

    counter = 1;
    for a=1:4
        [~,vv]=size(Donnees(i).Kinematics(a+4).PANVersHNorm);
        Donnees(i).Kinematics(9).PANVersHNorm(:,counter:counter+vv-1)  = Donnees(i).Kinematics(a+4).PANVersHNorm  ;
        counter = counter+vv;
    end
    counter = 1;
    for a=1:4
        [~,vv]=size(Donnees(i).Kinematics(a+4).PANVersBNorm);
        Donnees(i).Kinematics(9).PANVersBNorm(:,counter:counter+vv-1)  = Donnees(i).Kinematics(a+4).PANVersBNorm  ;
        counter = counter+vv;
    end

end


for i=1:20
    for f =1:1000
        Donnees(1).MEANKinematics.PVNVersDNorm(f,i) = mean(Donnees(i).Kinematics(9).PVNVersDNorm(f,:));  
        Donnees(1).MEANKinematics.PVNVersGNorm(f,i) = mean(Donnees(i).Kinematics(9).PVNVersGNorm(f,:));
        Donnees(1).MEANKinematics.PANVersDNorm(f,i) = mean(Donnees(i).Kinematics(9).PANVersDNorm(f,:));  
        Donnees(1).MEANKinematics.PANVersGNorm(f,i) = mean(Donnees(i).Kinematics(9).PANVersGNorm(f,:));

        Donnees(1).MEANKinematics.PVNVersHNorm(f,i) = mean(Donnees(i).Kinematics(9).PVNVersHNorm(f,:));  
        Donnees(1).MEANKinematics.PVNVersBNorm(f,i) = mean(Donnees(i).Kinematics(9).PVNVersBNorm(f,:));
        Donnees(1).MEANKinematics.PANVersHNorm(f,i) = mean(Donnees(i).Kinematics(9).PANVersHNorm(f,:));  
        Donnees(1).MEANKinematics.PANVersBNorm(f,i) = mean(Donnees(i).Kinematics(9).PANVersBNorm(f,:));
    end
end

for i=1:20
    for f =1:1000
        Donnees(1).MEANKinematics.PVNVersDNorm(f,22) = mean(Donnees(1).MEANKinematics.PVNVersDNorm(f,1:20)); 
        Donnees(1).MEANKinematics.PVNVersGNorm(f,22) = mean(Donnees(1).MEANKinematics.PVNVersGNorm(f,1:20));  
        Donnees(1).MEANKinematics.PANVersDNorm(f,22) = mean( Donnees(1).MEANKinematics.PANVersDNorm(f,1:20));  
        Donnees(1).MEANKinematics.PANVersGNorm(f,22) = mean(Donnees(1).MEANKinematics.PANVersGNorm(f,1:20));  

        Donnees(1).MEANKinematics.PVNVersHNorm(f,22) = mean(Donnees(1).MEANKinematics.PVNVersHNorm(f,1:20));  
        Donnees(1).MEANKinematics.PVNVersBNorm(f,22) = mean(Donnees(1).MEANKinematics.PVNVersBNorm(f,1:20));
        Donnees(1).MEANKinematics.PANVersHNorm(f,22) = mean(Donnees(1).MEANKinematics.PANVersHNorm(f,1:20));  
        Donnees(1).MEANKinematics.PANVersBNorm(f,22) = mean(Donnees(1).MEANKinematics.PANVersBNorm(f,1:20));  
    end
end

for i=1:20
    for f =1:1000
        Donnees(1).MEANKinematics.PVNVersDNorm(f,23) = std(Donnees(1).MEANKinematics.PVNVersDNorm(f,1:20))/sqrt(20); 
        Donnees(1).MEANKinematics.PVNVersGNorm(f,23) = std(Donnees(1).MEANKinematics.PVNVersGNorm(f,1:20))/sqrt(20);  
        Donnees(1).MEANKinematics.PANVersDNorm(f,23) = std( Donnees(1).MEANKinematics.PANVersDNorm(f,1:20))/sqrt(20);  
        Donnees(1).MEANKinematics.PANVersGNorm(f,23) = std(Donnees(1).MEANKinematics.PANVersGNorm(f,1:20))/sqrt(20);  

        Donnees(1).MEANKinematics.PVNVersHNorm(f,23) = std(Donnees(1).MEANKinematics.PVNVersHNorm(f,1:20))/sqrt(20);  
        Donnees(1).MEANKinematics.PVNVersBNorm(f,23) = std(Donnees(1).MEANKinematics.PVNVersBNorm(f,1:20))/sqrt(20);
        Donnees(1).MEANKinematics.PANVersHNorm(f,23) = std(Donnees(1).MEANKinematics.PANVersHNorm(f,1:20))/sqrt(20);  
        Donnees(1).MEANKinematics.PANVersBNorm(f,23) = std(Donnees(1).MEANKinematics.PANVersBNorm(f,1:20))/sqrt(20);  
    end
end

