    %% Script principal pour manip GAZ
        % A executer pour post-traiter les données obtenues lors des manips whole
        % body. Ce script est à utiliser pour les données STS/BTS et WB reaching.

close all
clear all

    %% Informations sur le traitement des données
        % Données pour le traitement cinématique
Frequence_acquisition = 200;  % Fréquence d'acquisition du signal cinématique
Low_pass_Freq = 5; % Fréquence passe-bas la position
Cut_off = 0.1; %pourcentage du pic de vitesse pour déterminer début et fin du mouvement
Ech_norm_kin = 1000; %Fréquence d'échantillonage du profil de vitesse normalisé en durée 
FCMAXSUJET=[200,197,203,192,203,207,202,208,207,200,202,198,193,193,198,204,203,190,199,205];

        % Données pour le traitement EMG

        % Données pour le traitement GAZ
C1=16.38; %Deux coeff pour le calcul du net metabolic power
C2=4.64;
nb_m_mobile = 30; % Le nombre de valeurs prises pour faire une moyenne glissante
Nb_Baseline = 10; % Le nb de blocs de baseline 
Nb_Blocs = 9; % Le nb de blocs de mvts PLUS LA PAUSE
Nb_t = 38; % Le nombre de temps qui sépare les blocs
BlocPause = 5;
Blocbaseline1 = 5;
Blocbaseline2 = 10;
a = 30; % Pour décaler de 30s et pour prendre 30s de la redescente
b = 60; % Pour décaler la prise de la baseline entre 4 et 5 min
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Premier_bloc = false; % True pour mvt vertical en premier sinon false pour horizontal en premier
Debut = 0; % Le debut en minutes
Pause = 6*60; % La durée de la pause
%%%%%%%%%%%%%%%%%%%%%%%%%%%%
Data.Gaz.timing(1,1)=60*Debut; t1 =Data.Gaz.timing(1,1); Data.Gaz.timing(1,1) = 1;
Data.Gaz.timing(2,1)=t1+60*4;
Data.Gaz.timing(3,1)=t1+60*6; %FIN BASELINE (6min) PRE 1eme BLOC
Data.Gaz.timing(4,1)=t1+60*7.5;
Data.Gaz.timing(5,1)=t1+60*8;
Data.Gaz.timing(6,1)=t1+60*12;
Data.Gaz.timing(7,1)=t1+60*14; %FIN BASELINE (6min) PRE 2eme BLOC
Data.Gaz.timing(8,1)=t1+60*15.5;
Data.Gaz.timing(9,1)=t1+60*16;
Data.Gaz.timing(10,1)=t1+60*20;
Data.Gaz.timing(11,1)=t1+60*22; %FIN BASELINE (6min) PRE 3eme BLOC
Data.Gaz.timing(12,1)=t1+60*23.5;
Data.Gaz.timing(13,1)=t1+60*24;
Data.Gaz.timing(14,1)=t1+60*28;
Data.Gaz.timing(15,1)=t1+60*30; %FIN BASELINE (6min) PRE 4eme BLOC
Data.Gaz.timing(16,1)=t1+60*31.5;
Data.Gaz.timing(17,1)=t1+60*32;
Data.Gaz.timing(18,1)=t1+60*33.5;
Data.Gaz.timing(19,1)=t1+60*34; %FIN BASELINE (2min) POST 4eme BLOC
Data.Gaz.timing(20,1)=t1+Pause/2+60*34;
Data.Gaz.timing(21,1)=t1+Pause+60*34; % FIN PAUSE (6min)
Data.Gaz.timing(22,1)=t1+Pause+60*38; 
Data.Gaz.timing(23,1)=t1+Pause+60*40;  %FIN BASELINE (6min) PRE 5eme BLOC
Data.Gaz.timing(24,1)=t1+Pause+60*41.5;
Data.Gaz.timing(25,1)=t1+Pause+60*42;
Data.Gaz.timing(26,1)=t1+Pause+60*46;
Data.Gaz.timing(27,1)=t1+Pause+60*48; %FIN BASELINE (6min) PRE 6eme BLOC
Data.Gaz.timing(28,1)=t1+Pause+60*49.5;
Data.Gaz.timing(29,1)=t1+Pause+60*50;
Data.Gaz.timing(30,1)=t1+Pause+60*54;
Data.Gaz.timing(31,1)=t1+Pause+60*56; %FIN BASELINE (6min) PRE 7 eme BLOC
Data.Gaz.timing(32,1)=t1+Pause+60*57.5;
Data.Gaz.timing(33,1)=t1+Pause+60*58;
Data.Gaz.timing(34,1)=t1+Pause+60*62;
Data.Gaz.timing(35,1)=t1+Pause+60*64; %FIN BASELINE (6min) PRE 8eme BLOC
Data.Gaz.timing(36,1)=t1+Pause+60*65.5;
Data.Gaz.timing(37,1)=t1+Pause+60*66;
Data.Gaz.timing(38,1)=t1+Pause+60*67.5;
Data.Gaz.timing(39,1)=t1+Pause+60*68; %FIN BASELINE (2min) POST 8eme BLOC


Data.Gaz.timing(:,2) = Data.Gaz.timing(:,1)./60;
Data.Gaz(1).timing(:,1)=Data.Gaz(1).timing(:,1).*100;

    %% Importation des données
        %On selectionne le repertoire
disp('Selectionnez le fichier ');
[Dossier] = uigetdir ('Selectionnez le Dossier où exécuter le Script');
Extension = '*.xlsx'; %Traite tous les .mat
Chemin = fullfile(Dossier, Extension); % On construit le chemin
ListeFichier = dir(Chemin); % On construit la liste des fichiers

Data.Noms = ListeFichier;

    %% On procède au balayage fichier par fichier
    %On charge les fichiers
disp('POST TRAITEMENT ')

for SUJET =1:length(ListeFichier)%[1,2,4,5,9,10,11,13,14,16,17,19,20]

%     time1 = Data.Gaz(1).timing(i+1,1)-DEBUTDETEC


    SUJET
    if SUJET ==22
        Data.Gaz(1).timing(3:end) = Data.Gaz(1).timing(3:end)+6000;
    end
    Fichier_traite = [Dossier '\' ListeFichier(SUJET).name]; %On charge le fichier .xlsx

    T = readtable(Fichier_traite);
    Poids_sujet = str2double(table2array(T(6,2))); %On récupère le poids du sujet pour le NMP
    %Data.Gaz.Poids_sujet = T(7,2); %On récupère le poids du sujet pour le NMP
    l=length(table2array(T(3:end,15)));Data.Gaz(SUJET).VO2(:,1) = str2double(table2array(T(3:end,15))); %On récupère la VO2
    l2=length(table2array(T(3:end,16)));Data.Gaz(SUJET).VCO2(:,1) = str2double(table2array(T(3:end,16))); %On récupère la VCO2
    Data.Gaz(SUJET).time(:,1) = round(86400.*str2double(table2array(T(3:end,10))));  %On récupère et convertit le temps
    Data.Gaz(SUJET).NMP2(:,1) = 1000.*(C1.*Data.Gaz(SUJET).VO2(:,1)./(60*1000)+C2.*Data.Gaz(SUJET).VCO2(:,1)./(60*1000))./str2double(table2array(T(6,2))); %On calcule le NMP OLD
    % Data.Gaz.NMP(:,1) = Data.Gaz.VO2(:,1)./Data.Gaz.Poids_sujet; %On calcule le NMP pour juste mL02/min/kg
    PremierBloc = table2array(T(9,9)); %On récupère la PE
    Data.Gaz(1).PremierBloc(SUJET,1) = PremierBloc;
    Data.Gaz(SUJET).FC(:,1) = str2double(table2array(T(3:end,24)));
    Data.Gaz(SUJET).coeff(:,1) = str2double(table2array(T(3:end,17)));

    if isnan(PremierBloc)
        error('------------   QUEL EST LE PREMIER BLOC ?   ------------')
    end

    disp(string(PremierBloc))
    if PremierBloc == 1

        disp('Le premier Bloc était un bloc horizontal')
    else
        disp('Le premier Bloc était un bloc vertical')
    end
    %% sample a linear time vector having the same length as the trial
    lgth = Data.Gaz(SUJET).time(size(Data.Gaz(SUJET).time,1),1);
    timelin = 1:1:100*lgth;
    
    clear t_data
    clear t_data2
    clear t_dataFC
    clear x_data
    clear x_data2
    clear x_data3
    
    %reorganize data
    t_data = Data.Gaz(SUJET).time;
    x_data = Data.Gaz(SUJET).NMP2(:,1);
    x_data2 = Data.Gaz(SUJET).VO2(:,1)./Poids_sujet;
    t_data2 = linspace(t_data(2),t_data(end),100*lgth);
    
    counter =1;
    for f = 1 :length(Data.Gaz(SUJET).FC(:,1))
        if Data.Gaz(SUJET).FC(f,1)==0
            
        else
        t_dataFC(counter,1) = Data.Gaz(SUJET).time(f,1);
        x_data3(counter,1) = Data.Gaz(SUJET).FC(f,1);
        counter =counter+1;
        end
        
    end


    %create a function perfectly fitting the position signal over time
    %for x data
    pp_posx=interp1(t_data,x_data,t_data2,'pchip').';
    pp_posx2=interp1(t_data,x_data2,t_data2,'pchip').';
%     pp_posx3=interp1(t_dataFC,x_data3,t_data2,'pchip').';
%     %sample data over a linear time scale
%     xpos_lintime= transpose(ppval(pp_posx,timelin));
%     xpos_lintime2= transpose(pp_posx2,timelin);

    Data.Gaz(SUJET).NMP(1:100*lgth,2) = pp_posx; % Sampled version
%     Data.Gaz(SUJET).NMP(1:100*lgth,3) = butter_emgs(Data.Gaz(SUJET).NMP(1:100*lgth,2), 10000, 3, 1, 'low-pass', 'false', 'centered');
%     Data.Gaz(SUJET).NMP(1:100*lgth,3) = smoothdata(Data.Gaz(SUJET).NMP(1:100*lgth,2),'movmean',[3000 3000]);
    Data.Gaz(SUJET).NMP(1:100*lgth,3) = smoothdata(Data.Gaz(SUJET).NMP(1:100*lgth,2),'movmean',[500 500]);
    
    Data.Gaz(SUJET).VO2(1:100*lgth,2) = pp_posx2; % Sampled version
%     Data.Gaz(SUJET).VO2(1:100*lgth,3) = butter_emgs(Data.Gaz(SUJET).VO2(1:100*lgth,2), 100, 3, 5, 'low-pass', 'false', 'centered');
    Data.Gaz(SUJET).VO2(1:100*lgth,3) = smoothdata(Data.Gaz(SUJET).VO2(1:100*lgth,2),'movmean',[5000 5000]);

%     Data.Gaz(SUJET).FCnorm(1:100*lgth,2) = pp_posx3; % Sampled version
%     Data.Gaz(SUJET).FCnorm(1:100*lgth,3) = smoothdata(Data.Gaz(SUJET).FCnorm(1:100*lgth,2),'movmean',[500 500]);


debutdetecc=0;
for DEBUTDETEC= [0]%9000, 7500,6000,4500,3000,1500,0,-1500]
    debutdetecc=debutdetecc+1;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Méthode 1 : Aire du bloc après lissage fort
    if PremierBloc ==1 % Horizontal first
        a=0;
        for i=[3 11 23 31]
            a=a+1;
            time1 = Data.Gaz(1).timing(i+1,1)-DEBUTDETEC;
            time2 = Data.Gaz(1).timing(i+2,1);
            time3 = Data.Gaz(1).timing(i-1,1)+6000;
            time4 = Data.Gaz(1).timing(i-1,1)+9000;

            [maxi , PosMax] = max(Data.Gaz(SUJET).NMP(time1:time2,3));
            [maxiVo2 , PosMaxVo2] = max(Data.Gaz(SUJET).VO2(time1:time2,3));
% 
%             Data.Gaz(1).BlocsMean(a,SUJET*2) = maxi; %PicLiss
%             Data.Gaz(1).BlocsMean(a+4,SUJET*2) = mean(Data.Gaz(SUJET).NMP(time1+PosMax-15:time1+PosMax+15,3)); %MeanPicLiss
%             Data.Gaz(1).BlocsMean(a+8,SUJET*2) = trapz(Data.Gaz(SUJET).NMP(time1:time2,3)); %AireLiss
            Data.GazEXPORT(debutdetecc).BlocsMeanH(SUJET,a) = mean(Data.Gaz(SUJET).NMP(time1:time2,2))-mean(Data.Gaz(SUJET).NMP(time3:time4,2)); %AireNotLiss

%             Data.Gaz(1).BlocsMeanVO2(a,SUJET*2) = maxiVo2; %PicLiss
%             Data.Gaz(1).BlocsMeanVO2(a+4,SUJET*2) = mean(Data.Gaz(SUJET).VO2(time1+PosMaxVo2-15:time1+PosMaxVo2+15,3)); %MeanPicLiss
%             Data.Gaz(1).BlocsMeanVO2(a+8,SUJET*2) = trapz(Data.Gaz(SUJET).VO2(time1:time2,3))./60; %AireLiss
%             Data.Gaz(1).BlocsMeanVO2(a+12,SUJET*2) = mean(Data.Gaz(SUJET).VO2(time1:time2,2))./60-mean(Data.Gaz(SUJET).VO2(time3:time4,2))./60; %AireNotLiss

%             Data.GazEXPORT(debutdetecc).FCMeanH(SUJET,a) = (mean(Data.Gaz(SUJET).FCnorm(time1:time2,2))-mean(Data.Gaz(SUJET).FCnorm(time3:time4,2))) / (FCMAXSUJET(SUJET)-mean(Data.Gaz(SUJET).FCnorm(time3:time4,2))); %AireNotLiss

        end
        a=0;
        for i=[7 15 27 35]
            a=a+1;
            time1 = Data.Gaz(1).timing(i+1,1)-DEBUTDETEC;
            time2 = Data.Gaz(1).timing(i+2,1);
            time3 = Data.Gaz(1).timing(i-1,1)+6000;
            time4 = Data.Gaz(1).timing(i-1,1)+9000;

            [maxi , PosMax] = max(Data.Gaz(SUJET).NMP(time1:time2,3));
            [maxiVo2 , PosMaxVo2] = max(Data.Gaz(SUJET).VO2(time1:time2,3));

            Data.GazEXPORT(debutdetecc).BlocsMeanV(SUJET,a) = mean(Data.Gaz(SUJET).NMP(time1:time2,2))-mean(Data.Gaz(SUJET).NMP(time3:time4,2));
%             Data.GazEXPORT(debutdetecc).FCMeanV(SUJET,a) = (mean(Data.Gaz(SUJET).FCnorm(time1:time2,2))-mean(Data.Gaz(SUJET).FCnorm(time3:time4,2))) / (FCMAXSUJET(SUJET)-mean(Data.Gaz(SUJET).FCnorm(time3:time4,2))); %AireNotLiss

        end
    else % If it is vertical first
        a=0;
        for i=[7 15 27 35]
            a=a+1;
            time1 = Data.Gaz(1).timing(i+1,1)-DEBUTDETEC;
            time2 = Data.Gaz(1).timing(i+2,1);
            time3 = Data.Gaz(1).timing(i-1,1)+6000;
            time4 = Data.Gaz(1).timing(i-1,1)+9000;

            [maxi , PosMax] = max(Data.Gaz(SUJET).NMP(time1:time2,3));
            [maxiVo2 , PosMaxVo2] = max(Data.Gaz(1).VO2(time1:time2,3));
            
            Data.GazEXPORT(debutdetecc).BlocsMeanH(SUJET,a) = mean(Data.Gaz(SUJET).NMP(time1:time2,2))-mean(Data.Gaz(SUJET).NMP(time3:time4,2)); %AireNotLiss
%             Data.GazEXPORT(debutdetecc).FCMeanH(SUJET,a) = (mean(Data.Gaz(SUJET).FCnorm(time1:time2,2))-mean(Data.Gaz(SUJET).FCnorm(time3:time4,2))) / (FCMAXSUJET(SUJET)-mean(Data.Gaz(SUJET).FCnorm(time3:time4,2))); %AireNotLiss

        end
        a=0;
        for i=[3 11 23 31]
            a=a+1;
            time1 = Data.Gaz(1).timing(i+1,1)-DEBUTDETEC;
            time2 = Data.Gaz(1).timing(i+2,1);
            time3 = Data.Gaz(1).timing(i-1,1)+6000;
            time4 = Data.Gaz(1).timing(i-1,1)+9000;

            [maxi , PosMax] = max(Data.Gaz(SUJET).NMP(time1:time2,3));
            [maxiVo2 , PosMaxVo2] = max(Data.Gaz(SUJET).VO2(time1:time2,3));
            
            Data.GazEXPORT(debutdetecc).BlocsMeanV(SUJET,a) = mean(Data.Gaz(SUJET).NMP(time1:time2,2))-mean(Data.Gaz(SUJET).NMP(time3:time4,2));
%             Data.GazEXPORT(debutdetecc).FCMeanV(SUJET,a) = (mean(Data.Gaz(SUJET).FCnorm(time1:time2,2))-mean(Data.Gaz(SUJET).FCnorm(time3:time4,2))) / (FCMAXSUJET(SUJET)-mean(Data.Gaz(SUJET).FCnorm(time3:time4,2))); %AireNotLiss


        end
    end
end

% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % for Sujett =1:20
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     if Data.Gaz(1).PremierBloc(Sujett) ==1
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %         Data.Gaz(1).NMPNormHori(:,Sujett) = Data.Gaz(Sujett).NMP(1:443500,3)./max(Data.Gaz(Sujett).NMP([1:195000,250000:443500],3));
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     else
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %         Data.Gaz(1).NMPNormVerti(:,Sujett) = Data.Gaz(Sujett).NMP(1:443500,3)./max(Data.Gaz(Sujett).NMP([1:195000,250000:443500],3));
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % end
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % for f=1:443500
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     Data.Gaz(1).NMPNormMeanHori(f,1) = mean(nonzeros(Data.Gaz(1).NMPNormHori(f,:))); 
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % %     Data.Gaz(1).NMPNormMeanVerti(f,1) = mean(nonzeros(Data.Gaz(1).NMPNormVerti(f,:)));
% % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % % end

    color_BL = [0.8500 0.3250 0.0980];
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Plot pour vérifier
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     answer = input('saisir le numéro du sujet : ','s');
%     name = append('GAZ_Sujet_n_',string(SUJET));

% 
%     Titre = append('Net Metabolic Power');
%     f = figure('units','normalized','outerposition',[0 0 1 1]);
% 
%     L(1) = plot(Data.Gaz(SUJET).FCnorm(:,2),'LineWidth',2);hold on; 
%     
%     y = [0 fix(max(Data.Gaz(SUJET).FCnorm([1:2000 2640:end],2))+1)]; % current y-axis limits
%     ylim(y)
%     x = xlim; % current y-axis limits
% 
%     % Pour les BASELINES
%     for i=2:4:34   
%         if i == 18
%         else
%             L(6) = plot([Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i,1)],[y(1) y(2)],'color',color_BL); hold on;
%             plot([Data.Gaz(1).timing(i,1)+60 Data.Gaz(1).timing(i,1)+60],[y(1) y(2)],'color',color_BL); hold on;
%         end
%     end
% 
%     x2 = [Data.Gaz(1).timing(19,1) Data.Gaz(1).timing(21,1) Data.Gaz(1).timing(21,1) Data.Gaz(1).timing(19,1)];
%     y2 = [y(1) y(1) y(2) y(2)];
%     L(2) = patch(x2,y2,'black','FaceAlpha',0.1); hold on;
% 
%     if Data.Gaz(1).PremierBloc(SUJET,1) ==1 % Horizontal first
%         for i=[3 11 23 31]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(3)= patch(x2,y2,'green','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
%         end
%         for i=[7 15 27 35]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(4)= patch(x2,y2,'blue','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
%         end
%         legend([L(1) L(2) L(3) L(4)],'Net Metabolic Power','Rest', 'Hori', 'Verti' );
%     %     legend([L(1) L(2) L(3) L(4) L(5) L(6)],'Net Metabolic Power','Rest', 'Hori', 'Verti', '+30s bloc', '4min 5min baseline');
%     else % It it is vertical first
%         for i=[7 15 27 35]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(3)= patch(x2,y2,'green','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
%         end
%         for i=[3 11 23 31]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(4)= patch(x2,y2,'blue','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
% 
%         end
%         legend([L(1) L(2) L(3) L(4)],'Net Metabolic Power','Rest', 'Hori', 'Verti');
%     %     legend([L(1) L(2) L(3) L(4) L(5) L(6)],'Net Metabolic Power','Rest', 'Hori', 'Verti', '+30s bloc', '4min 5min baseline');
%     end
% 
%     xlabel('time (s)')
%     ylabel('FCnorm (kJ/S/kg)')
%     path = 'C:\Users\robin\Desktop\Drive google\6A - THESE\MANIP 2\MATLAB\Graphs 05_05_2023\';
%     path = append(path,'FCnorm_Lisse_',name);
%     saveas(gcf,path,'png');


    % w = waitforbuttonpress;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%
%     Titre = append('Conso Vo2');
%     f = figure('units','normalized','outerposition',[0 0 1 1]);
% 
% 
%     L(1) = plot(Data.Gaz(SUJET).VO2(:,3),'LineWidth',2);hold on; 
%     
%     y = [0 fix(max(Data.Gaz(SUJET).VO2([1:2000 2640:end],3))+1)]; % current y-axis limits
%     ylim(y)
%     x = xlim; % current y-axis limits
%     % Pour les BASELINES
%     for i=2:4:34   
%         if i == 18
%         else
%             L(6) = plot([Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i,1)],[y(1) y(2)],'color',color_BL); hold on;
%             plot([Data.Gaz(1).timing(i,1)+60 Data.Gaz(1).timing(i,1)+60],[y(1) y(2)],'color',color_BL); hold on;
%         end
%     end
% 
%     x2 = [Data.Gaz(1).timing(19,1) Data.Gaz(1).timing(21,1) Data.Gaz(1).timing(21,1) Data.Gaz(1).timing(19,1)];
%     y2 = [y(1) y(1) y(2) y(2)];
%     L(2) = patch(x2,y2,'black','FaceAlpha',0.1); hold on;
% 
%     if PremierBloc ==1 % Horizontal first
%         for i=[3 11 23 31]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(3)= patch(x2,y2,'green','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
%         end
%         for i=[7 15 27 35]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(4)= patch(x2,y2,'blue','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
%         end
%         legend([L(1) L(2) L(3) L(4)],'Net Metabolic Power','Rest', 'Hori', 'Verti' );
%     %     legend([L(1) L(2) L(3) L(4) L(5) L(6)],'Net Metabolic Power','Rest', 'Hori', 'Verti', '+30s bloc', '4min 5min baseline');
%     else % It it is vertical first
%         for i=[7 15 27 35]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(3)= patch(x2,y2,'green','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
%         end
%         for i=[3 11 23 31]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(4)= patch(x2,y2,'blue','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
% 
%         end
%         legend([L(1) L(2) L(3) L(4)],'Net Metabolic Power','Rest', 'Hori', 'Verti');
%     %     legend([L(1) L(2) L(3) L(4) L(5) L(6)],'Net Metabolic Power','Rest', 'Hori', 'Verti', '+30s bloc', '4min 5min baseline');
%     end
% 
%     xlabel('time (s)')
%     ylabel('Conso O2 (mL/min/kg)')
% 
%     path = 'C:\Users\robin\Desktop\Drive google\6A - THESE\MANIP 2\MATLAB\graphs 06_01_2023\';
%     path = append(path,'Vo2_Lisse_',name);
%     saveas(gcf,path,'png');
% 
% 
% 
% 
%     %%
% 
%     %%
% 
%     %%
% 
%     %%
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ùù
%     Titre = append('Net metabolic Power brut');
%     f = figure('units','normalized','outerposition',[0 0 1 1]);
% 
%     L(1) = plot(Data.Gaz(SUJET).NMP(:,2),'LineWidth',2);hold on; 
% 
%     y = [0 fix(max(Data.Gaz(SUJET).NMP([1:2000 2640:end],2))+1)]; % current y-axis limits
%     ylim(y)
%     x = xlim; % current y-axis limits
% 
%     % Pour les BASELINES
%     for i=2:4:34   
%         if i == 18
%         else
%             L(6) = plot([Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i,1)],[y(1) y(2)],'color',color_BL); hold on;
%             plot([Data.Gaz(1).timing(i,1)+60 Data.Gaz(1).timing(i,1)+60],[y(1) y(2)],'color',color_BL); hold on;
%         end
%     end
% 
%     x2 = [Data.Gaz(1).timing(19,1) Data.Gaz(1).timing(21,1) Data.Gaz(1).timing(21,1) Data.Gaz(1).timing(19,1)];
%     y2 = [y(1) y(1) y(2) y(2)];
%     L(2) = patch(x2,y2,'black','FaceAlpha',0.1); hold on;
% 
%     if PremierBloc==1 % Horizontal first
%         for i=[3 11 23 31]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(3)= patch(x2,y2,'green','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
%         end
%         for i=[7 15 27 35]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(4)= patch(x2,y2,'blue','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
%         end
%         legend([L(1) L(2) L(3) L(4)],'Net Metabolic Power','Rest', 'Hori', 'Verti' );
%     %     legend([L(1) L(2) L(3) L(4) L(5) L(6)],'Net Metabolic Power','Rest', 'Hori', 'Verti', '+30s bloc', '4min 5min baseline');
%     else % It it is vertical first
%         for i=[7 15 27 35]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(3)= patch(x2,y2,'green','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
%         end
%         for i=[3 11 23 31]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(4)= patch(x2,y2,'blue','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
% 
%         end
%         legend([L(1) L(2) L(3) L(4)],'Net Metabolic Power','Rest', 'Hori', 'Verti');
%     %     legend([L(1) L(2) L(3) L(4) L(5) L(6)],'Net Metabolic Power','Rest', 'Hori', 'Verti', '+30s bloc', '4min 5min baseline');
%     end
% 
%     xlabel('time (s)')
%     ylabel('NMP (kJ/s/kg)')
% 
%     path = 'C:\Users\robin\Desktop\Drive google\6A - THESE\MANIP 2\MATLAB\graphs 06_01_2023\';
%     path = append(path,'NMP_Brut_',name);
%     saveas(gcf,path,'png');
% 
%     % w = waitforbuttonpress;
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% 
%     %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%     %%
%     Titre = append('Conso Vo2 brute');
%     f = figure('units','normalized','outerposition',[0 0 1 1]);
% 
%     nexttile
%     L(1) = plot(Data.Gaz(SUJET).VO2(:,2),'LineWidth',2);hold on; 
% 
%     y = [0 fix(max(Data.Gaz(SUJET).VO2([1:2000 2640:end],2))+1)]; % current y-axis limits
%     ylim(y)
%     x = xlim; % current y-axis limits
% 
%     % Pour les BASELINES
%     for i=2:4:34   
%         if i == 18
%         else
%             L(6) = plot([Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i,1)],[y(1) y(2)],'color',color_BL); hold on;
%             plot([Data.Gaz(1).timing(i,1)+60 Data.Gaz(1).timing(i,1)+60],[y(1) y(2)],'color',color_BL); hold on;
%         end
%     end
% 
%     x2 = [Data.Gaz(1).timing(19,1) Data.Gaz(1).timing(21,1) Data.Gaz(1).timing(21,1) Data.Gaz(1).timing(19,1)];
%     y2 = [y(1) y(1) y(2) y(2)];
%     L(2) = patch(x2,y2,'black','FaceAlpha',0.1); hold on;
% 
%     if PremierBloc ==1 % Horizontal first
%         for i=[3 11 23 31]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(3)= patch(x2,y2,'green','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
%         end
%         for i=[7 15 27 35]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(4)= patch(x2,y2,'blue','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
%         end
%         legend([L(1) L(2) L(3) L(4)],'Net Metabolic Power','Rest', 'Hori', 'Verti' );
%     %     legend([L(1) L(2) L(3) L(4) L(5) L(6)],'Net Metabolic Power','Rest', 'Hori', 'Verti', '+30s bloc', '4min 5min baseline');
%     else % It it is vertical first
%         for i=[7 15 27 35]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(3)= patch(x2,y2,'green','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
%         end
%         for i=[3 11 23 31]
%             x2 = [Data.Gaz(1).timing(i,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i+2,1) Data.Gaz(1).timing(i,1)];
%             y2 = [y(1) y(1) y(2) y(2)];
%             L(4)= patch(x2,y2,'blue','FaceAlpha',0.1);
%     %         L(5) = plot([Data.Gaz(1).timing(i+2,1)+30 Data.Gaz(1).timing(i+2,1)+30],[y(1) y(2)],"m--"); hold on;
%     %         plot([Data.Gaz(1).timing(i+2,1)-30 Data.Gaz(1).timing(i+2,1)-30],[y(1) y(2)],"m--"); hold on;
% 
%         end
%         legend([L(1) L(2) L(3) L(4)],'Net Metabolic Power','Rest', 'Hori', 'Verti');
%     %     legend([L(1) L(2) L(3) L(4) L(5) L(6)],'Net Metabolic Power','Rest', 'Hori', 'Verti', '+30s bloc', '4min 5min baseline');
%     end
% 
%     xlabel('time (s)')
%     ylabel('Conso O2 (mL/min/kg)')
% 
%     path = 'C:\Users\robin\Desktop\Drive google\6A - THESE\MANIP 2\MATLAB\graphs 06_01_2023\';
%     path = append(path,'VO2_Brut_',name);
%     saveas(gcf,path,'png');
% 



end


    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Export des données
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% disp('Selectionnez le Dossier où enregistre les données.');
[Dossier] = uigetdir ('Selectionnez le Dossier où enregistre les données.');
% Dossier = 'C:\Users\robin\Desktop\Drive google\6A - THESE\MANIP 2\MATLAB\DATA_POST_TREATED2';
save([Dossier '/' 'Data' ], 'Data');
disp('Données enregistrées avec succès !');



