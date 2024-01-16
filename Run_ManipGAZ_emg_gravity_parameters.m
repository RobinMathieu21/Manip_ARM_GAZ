
%% Script principal pour manip GAZ
        % A executer pour post-traiter les données obtenues lors des manips whole
        % body. Ce script est à utiliser pour les données STS/BTS et WB reaching.
          
close all
clear all

    %% Informations sur le traitement des données
        % Données pour le traitement cinématique
Frequence_acquisition = 100;  % Fréquence d'acquisition du signal cinématique
Low_pass_Freq = 5; % Fréquence passe-bas la position
Ech_norm = 1000;
Data.Gaz.sequence = ['1','1','1','1','2','2','2','2'];
Nb_emgs = 2;
emg_frequency = 1000;
emg_band_pass_Freq = [30 300]; % Passe_bande du filtre EMG
emg_low_pass_Freq = 20; % Fréquence passe_bas lors du second filtre du signal emg. 100 est la fréquence habituelle chez les humains (cf script Jérémie)
type_RMS = 1; % 1 pour sliding et 2 pour skipping
rms_window = 50;
rms_window_step  = (rms_window/1000)*emg_frequency;
EMD = 0.076; % délai electromécanique moyen de tous les muscles
emg_ech_norm = 1000;
anticip_tonic_pre = 300; % Durée (en ms) pour avoir le dernier point du tonic avant le mouvement et le premier point du tonic après le mouvement
anticip_tonic_post = 50;
duration_tonic_th = 50; % Durée (en ms) de moyennage du tonic
emg_div_kin_freq = emg_frequency/Frequence_acquisition; %used to synchronized emg cutting (for sliding rms) with regard to kinematics
emgrms_div_kin_freq = emg_div_kin_freq/rms_window_step; %used to synchronized emg cutting (for skipping rms) with regard to kinematics
limite_en_temps = 0.020;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Importation des données pour le TRAITEMENT CINEMATIQUE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % On selectionne le repertoire
disp('Selectionnez le fichier ');
[Dossier] = uigetdir ('Selectionnez le Dossier où exécuter le Script');
Extension = '*.mat'; %Traite tous les .mat
Chemin = fullfile(Dossier, Extension); % On construit le chemin
ListeFichier = dir(Chemin); % On construit la liste des fichiers


% On balaye chaque fichier cinématique correspondant chacun à un bloc de mvts
for i =1:length(ListeFichier)
    i
    Fichier_traite = [Dossier '\' ListeFichier(i).name]; %On charge le fichier .mat
    load (Fichier_traite);

    if i>=5 && i<=13  %i>=4 && i<=11%
        Frequence_acquisition=200;
    else
        Frequence_acquisition=100;
    end
    emg_div_kin_freq = emg_frequency/Frequence_acquisition; 

    for k=1:8

        if strcmp(Data.Gaz.sequence(k), '1')
            type_mvt=1;
        else
            type_mvt=2;
        end
        k
        Pos_mvmt = Data.Kinematics(k).C3D.Cinematique.Donnees(:,49:51); % Position du doigt
        posfiltre = butter_emgs(Pos_mvmt, Frequence_acquisition, 3, Low_pass_Freq, 'low-pass', 'false', 'centered');
        Donnees(i).EMG(k).Brutes(:,1) = Data.Kinematics(k).C3D.EMG.Donnees(:,1);
        Donnees(i).EMG(k).Brutes(:,2) = Data.Kinematics(k).C3D.EMG.Donnees(:,2);
        Donnees(i).kinematics(k).Debut_fin(:,:) = Data.Kinematics(1).data.Debut_Fin(:,:);
        Donnees(i).kinematics(k).Clics=Data.Clics; 
%         Donnees(i).EMG(k).Brutes(:,3) = Data.Kinematics(k).C3D.EMG.Donnees(:,3);
%         Donnees(i).EMG(k).Brutes(:,4) = Data.Kinematics(k).C3D.EMG.Donnees(:,4);

        [emg_rms, emg_filt, emg_rect_filt] = compute_emg(Donnees(i).EMG(k).Brutes, Nb_emgs, emg_frequency, ...
            emg_band_pass_Freq, emg_low_pass_Freq, type_RMS, rms_window_step);
        
        Donnees(i).EMG(k).RMS = emg_rms;


        for j =1:length(Data.Kinematics(k).data.Debut_Fin(:,1))
            debut = (Data.Clics(1,k)+Data.Kinematics(k).data.Debut_Fin(j,1));
            fin = (Data.Clics(1,k)+Data.Kinematics(k).data.Debut_Fin(j,2));

            debutEMG = emg_div_kin_freq*(Data.Clics(1,k)+Data.Kinematics(k).data.Debut_Fin(j,1))-anticip_tonic_pre;
            finEMG = emg_div_kin_freq*(Data.Clics(1,k)+Data.Kinematics(k).data.Debut_Fin(j,2))+anticip_tonic_post;
            
            if type_mvt==1 % Bloc horizon
                if posfiltre(fin,2)-posfiltre(debut,2)<-350 %%%
                    len= length(emg_rms(debutEMG:finEMG,1));
                    Donnees(i).EMG(k).RMSCUT.DA_droit(1:len,j)=emg_rms(debutEMG:finEMG,1);
%                     Donnees(i).EMG(k).TONIC_debut.DA_droit(1:duration_tonic,j)=emg_rms(debutEMG:debutEMG+duration_tonic-1,1);
%                     Donnees(i).EMG(k).TONIC_fin.DA_droit(1:duration_tonic,j)=emg_rms(finEMG-duration_tonic+1:finEMG,1);
                end
    
                if posfiltre(fin,2)-posfiltre(debut,2)>350 %%% 
                    len= length(emg_rms(debutEMG:finEMG,1));
                    Donnees(i).EMG(k).RMSCUT.DA_gauche(1:len,j)=emg_rms(debutEMG:finEMG,1);
%                     Donnees(i).EMG(k).TONIC_debut.DA_gauche(1:duration_tonic,j)=emg_rms(debutEMG:debutEMG+duration_tonic-1,1);
%                     Donnees(i).EMG(k).TONIC_fin.DA_gauche(1:duration_tonic,j)=emg_rms(finEMG-duration_tonic+1:finEMG,1);
                end
    
                if posfiltre(fin,2)-posfiltre(debut,2)<350 && posfiltre(fin,2)-posfiltre(debut,2)>-350 %%% VERS BAS
                    disp('--------------- MOUVEMENT Trop petit -----------------');
                end
            else % Bloc vertical
                if posfiltre(fin,3)-posfiltre(debut,3)<-350 %%% VERS BAS
                    len= length(emg_rms(debutEMG:finEMG,1));
                    Donnees(i).EMG(k).RMSCUT.DA_bas(1:len,j)=emg_rms(debutEMG:finEMG,1);
%                     Donnees(i).EMG(k).TONIC_debut.DA_bas(1:duration_tonic,j)=emg_rms(debutEMG:debutEMG+duration_tonic-1,1);
%                     Donnees(i).EMG(k).TONIC_fin.DA_bas(1:duration_tonic,j)=emg_rms(finEMG-duration_tonic+1:finEMG,1);
%                                         Donnees(i).EMG(k).TONIC_debut.DA_bas(1:duration_tonic,j)=emg_rms(debutEMG-anticip_tonic+1:debutEMG-anticip_tonic+duration_tonic,1);
%                     Donnees(i).EMG(k).TONIC_fin.DA_bas(1:duration_tonic,j)=emg_rms(finEMG+anticip_tonic-duration_tonic:finEMG+anticip_tonic-1,1);
                end
    
                if posfiltre(fin,3)-posfiltre(debut,3)>350 %%% VERS HAUT
                    len= length(emg_rms(debutEMG:finEMG,1));
                    Donnees(i).EMG(k).RMSCUT.DA_haut(1:len,j)=emg_rms(debutEMG:finEMG,1);
%                     Donnees(i).EMG(k).TONIC_debut.DA_haut(1:duration_tonic,j)=emg_rms(debutEMG:debutEMG+duration_tonic-1,1);
%                     Donnees(i).EMG(k).TONIC_fin.DA_haut(1:duration_tonic,j)=emg_rms(finEMG-duration_tonic+1:finEMG,1);
                end
    
                if posfiltre(fin,3)-posfiltre(debut,3)<350 && posfiltre(fin,3)-posfiltre(debut,3)>-350 %%% VERS BAS
                    disp('--------------- MOUVEMENT Trop petit -----------------');
                end
            end
            
        end

        

    end
end

%% On vire les colonnes avec des zéros
for i =1:length(ListeFichier)
    for k=1:4
        Donnees(i).EMG(k).RMSCUT.DA_gauche( :, all(~Donnees(i).EMG(k).RMSCUT.DA_gauche,1) ) = [];
        Donnees(i).EMG(k).RMSCUT.DA_droit( :, all(~Donnees(i).EMG(k).RMSCUT.DA_droit,1) ) = [];
        Donnees(i).EMG(k+4).RMSCUT.DA_haut( :, all(~Donnees(i).EMG(k+4).RMSCUT.DA_haut,1) ) = [];
        Donnees(i).EMG(k+4).RMSCUT.DA_bas( :, all(~Donnees(i).EMG(k+4).RMSCUT.DA_bas,1) ) = [];
    end
end



%% Normalisation des profils RMS
 % On commence par trouver la taille de chaque profil en omettant les zeros
for i =1:length(ListeFichier)
    for k=5:8

        [lig_rms, col_rms] = size(Donnees(i).EMG(k).RMSCUT.DA_bas);
        profil_sizes_R = zeros(1, col_rms);
        for f = 1:col_rms
            for b = 1:lig_rms
                if Donnees(i).EMG(k).RMSCUT.DA_bas(b, f) ~= 0
                profil_sizes_R(1, f) = profil_sizes_R(1, f)+1;
                end
            end
        end
        for colo=1:col_rms
            Donnees(i).EMG(k).RMSCUTNorm.DA_bas(:,colo) = normalize2(Donnees(i).EMG(k).RMSCUT.DA_bas(1:profil_sizes_R(1, colo),colo), 'PCHIP', 1000);
            Donnees(i).EMG(k).Duree.DA_bas(:,colo) = profil_sizes_R(1, colo);
        end


        [lig_rms, col_rms] = size(Donnees(i).EMG(k).RMSCUT.DA_haut);
        profil_sizes_R = zeros(1, col_rms);
        for f = 1:col_rms
            for b = 1:lig_rms
                if Donnees(i).EMG(k).RMSCUT.DA_haut(b, f) ~= 0
                profil_sizes_R(1, f) = profil_sizes_R(1, f)+1;
                end
            end
        end
        for colo=1:col_rms
            Donnees(i).EMG(k).RMSCUTNorm.DA_haut(:,colo) = normalize2(Donnees(i).EMG(k).RMSCUT.DA_haut(1:profil_sizes_R(1, colo),colo), 'PCHIP', 1000);
            Donnees(i).EMG(k).Duree.DA_haut(:,colo) = profil_sizes_R(1, colo);
        end
    end
end

for i =1:length(ListeFichier)
    for k=1:4

        % On commence par trouver la taille de chaque profil en omettant les zeros
        [lig_rms, col_rms] = size(Donnees(i).EMG(k).RMSCUT.DA_droit);
        profil_sizes_R = zeros(1, col_rms);
        for f = 1:col_rms
            for b = 1:lig_rms
                if Donnees(i).EMG(k).RMSCUT.DA_droit(b, f) ~= 0
                profil_sizes_R(1, f) = profil_sizes_R(1, f)+1;
                end
            end
        end
        for colo=1:col_rms
            Donnees(i).EMG(k).RMSCUTNorm.DA_droit(:,colo) = normalize2(Donnees(i).EMG(k).RMSCUT.DA_droit(1:profil_sizes_R(1, colo),colo), 'PCHIP', 1000);
            Donnees(i).EMG(k).Duree.DA_droit(:,colo) = profil_sizes_R(1, colo);
        end

        
        [lig_rms, col_rms] = size(Donnees(i).EMG(k).RMSCUT.DA_gauche);
        profil_sizes_R = zeros(1, col_rms);
        for f = 1:col_rms
            for b = 1:lig_rms
                if Donnees(i).EMG(k).RMSCUT.DA_gauche(b, f) ~= 0
                profil_sizes_R(1, f) = profil_sizes_R(1, f)+1;
                end
            end
        end
        for colo=1:col_rms
            Donnees(i).EMG(k).RMSCUTNorm.DA_gauche(:,colo) = normalize2(Donnees(i).EMG(k).RMSCUT.DA_gauche(1:profil_sizes_R(1, colo),colo), 'PCHIP', 1000);
            Donnees(i).EMG(k).Duree.DA_gauche(:,colo) = profil_sizes_R(1, colo);
            
        end
    end
end



% On calcule la moyenne +/- erreur std
for i =1:length(ListeFichier)
    for k=1:4
        for f=1:1000
            [~,col]=size(Donnees(i).EMG(k+4).RMSCUT.DA_bas);
            Donnees(i).EMG(k+4).RMSCUTNorm.DA_basMEAN(f,1) = mean(Donnees(i).EMG(k+4).RMSCUTNorm.DA_bas(f,:));
            Donnees(i).EMG(k+4).RMSCUTNorm.DA_basMEAN(f,2) = mean(Donnees(i).EMG(k+4).RMSCUTNorm.DA_bas(f,:))+std(Donnees(i).EMG(k+4).RMSCUTNorm.DA_bas(f,:))/sqrt(col);
            Donnees(i).EMG(k+4).RMSCUTNorm.DA_basMEAN(f,3) = mean(Donnees(i).EMG(k+4).RMSCUTNorm.DA_bas(f,:))-std(Donnees(i).EMG(k+4).RMSCUTNorm.DA_bas(f,:))/sqrt(col);
        
        end
    duration_tonic = round(duration_tonic_th*emg_frequency/mean(Donnees(i).EMG(k+4).Duree.DA_bas(1,:)));
    
    Donnees(i).EMG(k).TONIC_debut.DA_bas(1:duration_tonic,1)=Donnees(i).EMG(k+4).RMSCUTNorm.DA_basMEAN(1:1+duration_tonic-1,1);
    Donnees(i).EMG(k).TONIC_fin.DA_bas(1:duration_tonic,1)=Donnees(i).EMG(k+4).RMSCUTNorm.DA_basMEAN(emg_frequency-duration_tonic+1:emg_frequency,1);
    end
end

for i =1:length(ListeFichier)
    for k=1:4
        for f=1:1000
            [~,col]=size(Donnees(i).EMG(k+4).RMSCUTNorm.DA_haut);
            Donnees(i).EMG(k+4).RMSCUTNorm.DA_hautMEAN(f,1) = mean(Donnees(i).EMG(k+4).RMSCUTNorm.DA_haut(f,:));
            Donnees(i).EMG(k+4).RMSCUTNorm.DA_hautMEAN(f,2) = mean(Donnees(i).EMG(k+4).RMSCUTNorm.DA_haut(f,:))+std(Donnees(i).EMG(k+4).RMSCUTNorm.DA_haut(f,:))/sqrt(col);
            Donnees(i).EMG(k+4).RMSCUTNorm.DA_hautMEAN(f,3) = mean(Donnees(i).EMG(k+4).RMSCUTNorm.DA_haut(f,:))-std(Donnees(i).EMG(k+4).RMSCUTNorm.DA_haut(f,:))/sqrt(col);
        
        end
    
    
    duration_tonic = round(duration_tonic_th*emg_frequency/mean(Donnees(i).EMG(k+4).Duree.DA_haut(1,:)));
    Donnees(i).EMG(k).TONIC_debut.DA_haut(1:duration_tonic,1)=Donnees(i).EMG(k+4).RMSCUTNorm.DA_hautMEAN(1:1+duration_tonic-1,1);
    Donnees(i).EMG(k).TONIC_fin.DA_haut(1:duration_tonic,1)=Donnees(i).EMG(k+4).RMSCUTNorm.DA_hautMEAN(emg_frequency-duration_tonic+1:emg_frequency,1);
    end
end


%% Calcul tonic / phasic
for i =1:length(ListeFichier)
    for k=1:4
        Idx = {};
        Idx.EMD = EMD*emg_frequency;
        Idx.dureebas = round(mean(Donnees(i).EMG(k+4).Duree.DA_bas));
        Idx.dureehaut = round(mean(Donnees(i).EMG(k+4).Duree.DA_haut));
        Idx.anticip_pre = anticip_tonic_pre;
        Idx.anticip_post = anticip_tonic_post;

        [EMG_traite.DA_bas, Tonic.DA, Profil_tonic_R.DA, ] = compute_emg2_gravity_parameters( Donnees(i).EMG(k+4).RMSCUTNorm.DA_basMEAN(:,1), ...
          emg_low_pass_Freq, emg_frequency, Donnees(i).EMG(k).TONIC_debut.DA_bas(:,1), Donnees(i).EMG(k).TONIC_fin.DA_bas(:,1), Idx);

        Donnees(i).EMG(k+4).Phasic.DA_bas=EMG_traite.DA_bas.nonsmooth.brut.R;  
        Donnees(i).EMG(k+4).Tonic.DA_bas=Tonic.DA.R; 

        [EMG_traite.DA_haut, Tonic.DA, Profil_tonic_R.DA, ] = compute_emg2_gravity_parameters( Donnees(i).EMG(k+4).RMSCUTNorm.DA_hautMEAN(:,1), ...
          emg_low_pass_Freq, emg_frequency, Donnees(i).EMG(k).TONIC_debut.DA_haut(:,1), Donnees(i).EMG(k).TONIC_fin.DA_haut(:,1), Idx);

        Donnees(i).EMG(k+4).Phasic.DA_haut=EMG_traite.DA_haut.nonsmooth.brut.R;  
        Donnees(i).EMG(k+4).Tonic.DA_haut=Tonic.DA.R; 

    end
end


%% PLOT
for i =1:length(ListeFichier)
    f = figure('units','normalized','outerposition',[0 0 1 1]);
    t = tiledlayout(1,2,'TileSpacing','Compact');
    nexttile
    for k=5:8
        r=[0.1:0.1:1000]; y = zeros(length(r),1);plot(r,y,'r');hold on;
        plot(Donnees(i).EMG(k).Phasic.DA_bas);hold on;
    end
    nexttile
    for k=5:8  
        r=[0.1:0.1:1000]; y = zeros(length(r),1);plot(r,y,'r');hold on;
        plot(Donnees(i).EMG(k).Phasic.DA_haut);hold on;
    end
end


%% QUANTIFS  
for i =1:length(ListeFichier)
    for k=5:8 % On balaye
        
        phasicLever = Donnees(i).EMG(k).Phasic.DA_haut;
        SD_Lever=std(Donnees(i).EMG(k-4).TONIC_debut.DA_haut, 'omitnan'); 
        timeLever = round(mean(Donnees(i).EMG(k).Duree.DA_haut))-anticip_tonic_post-anticip_tonic_pre;
        tonicLever = Donnees(i).EMG(k).Tonic.DA_haut;  

        phasicBaisser = Donnees(i).EMG(k).Phasic.DA_bas;
        SD_Baisser=std(Donnees(i).EMG(k-4).TONIC_debut.DA_bas, 'omitnan'); 
        timeBaisser = round(mean(Donnees(i).EMG(k).Duree.DA_bas))-anticip_tonic_post-anticip_tonic_pre;
        tonicBaisser = Donnees(i).EMG(k).Tonic.DA_bas;  

        
        %% Calculs quantif desac pour le mvt lever


        % Calcul temps phase desac LEVER
        indic = 0; % Variable pour vérifier la longueur des phases de désactivation
        Limite_atteinte = false; % variable bouléene pour enregistrer le fait que les phases de désactivation sont assez longues (ou pas)
        compteur = 0; % Si la désactivation est assez longue, elle est comptée dans cette variable
        Limite_basse_detection = round(emg_frequency * limite_en_temps); %Limite d'image à atteindre pour considérer la phase négative 40ms, arrondi à l'image près
        for f = 400 : 1000 % Une boucle pour tester toutes les valeurs du phasic
            if phasicLever(f, 1) < 0-3*abs(SD_Lever(1, 1)) % Si la valeur est inf à zero indic est incrementé
               indic = indic + 1 ;
            else   % Sinon
                if Limite_atteinte % Soit la limite avait déjà été atteinte (la phase doit donc être comptée)
                    compteur = compteur + indic; % On la compte 
                    indic = 0;    % on remet la variable indic à 0 pour vérifier les suivantes
                    Limite_atteinte = false; % On remet la variable bouléene à Faux 
                else
                    indic = 0; % Si la limite n'avait pas été atteinte on remet simplement l'indicateur à 0
                end
            end
            if indic >Limite_basse_detection*emg_frequency/timeLever(1,1) % Si la variable indicateur augmente et dépasse la limite de détection (40 ms), la limite est atteinte
                Limite_atteinte = true;
            end
        end
        
         if Limite_atteinte % Si la limite est atteinte mais qu'on dépasse les 600
                Limite_atteinte = false;
                compteur = compteur + indic;
        end

        % Calcul de l'amplitude max de négativité
        if compteur>0
            frequence =1;
            [Pmin, indice] = min(phasicLever(:, 1));
            if Pmin > 0
                Pmin =0;
            end
            amplitude = Pmin * 100 / tonicLever(indice,1);
        else 
            frequence = 0;
            amplitude = 0;
        end

            % Calcul temps phase desac BAISSER
        indic = 0; % Variable pour vérifier la longueur des phases de désactivation
        Limite_atteinte = false; % variable bouléene pour enregistrer le fait que les phases de désactivation sont assez longues (ou pas)
        compteur2 = 0; % Si la désactivation est assez longue, elle est comptée dans cette variable
        Limite_basse_detection = round(emg_frequency * limite_en_temps); %Limite d'image à atteindre pour considérer la phase négative 40ms, arrondi à l'image près
        for f = 1 : 600% Une boucle pour tester toutes les valeurs du phasic
            if phasicBaisser(f, 1) < 0-3*abs(SD_Baisser(1, 1)) % Si la valeur est inf à zero indic est incrementé
               indic = indic + 1 ;
               indic
            else   % Sinon
                if Limite_atteinte % Soit la limite avait déjà été atteinte (la phase doit donc être comptée)
                    compteur2 = compteur2 + indic; % On la compte 
                    indic = 0;    % on remet la variable indic à 0 pour vérifier les suivantes
                    Limite_atteinte = false; % On remet la variable bouléene à Faux 
                else
                    indic = 0; % Si la limite n'avait pas été atteinte on remet simplement l'indicateur à 0
                end
            end

            if indic >Limite_basse_detection*emg_frequency/timeBaisser(1,1) % Si la variable indicateur augmente et dépasse la limite de détection (40 ms), la limite est atteinte
                Limite_atteinte = true;
            end
        end
        
        if Limite_atteinte % Si la limite est atteinte mais qu'on dépasse les 600
                Limite_atteinte = false;
                compteur2 = compteur2 + indic;
        end
        % Calcul de l'amplitude max de négativité
        if compteur2>0
            frequence2 =1;
            [Pmin, indice] = min(phasicBaisser(:, 1));
            if Pmin > 0
                Pmin =0;
            end
            amplitude2 = Pmin * 100 / tonicBaisser(indice,1);
        else 
            frequence2 = 0;
            amplitude2 = 0;
        end

    %% Enregistrement des données

%             Donnees_EMG(YY).QuantifDesac(1, j) = compteur*timeSL(1,acqui)/1000;  % Pour l'avoir en temps
        Donnees(i).EMG(1).QuantifDesac(1, k-4) = compteur/10;  % Pour l'avoir %
%             Donnees_EMG(YY).QuantifDesac(2, j) = compteur2*timeSR(1,acqui)/1000; % Pour l'avoir en temps  
        Donnees(i).EMG(1).QuantifDesac(2, k-4) = compteur2/10; % Pour l'avoir %
        Donnees(i).EMG(1).QuantifDesac(3, k-4) = amplitude; % Amplitudes des mvts se lever
        Donnees(i).EMG(1).QuantifDesac(4, k-4) = amplitude2; % Amplitudes des mvts se rassoir
        Donnees(i).EMG(1).QuantifDesac(5, k-4) = frequence;  % Fréquence des désac mvt se lever
        Donnees(i).EMG(1).QuantifDesac(6, k-4) = frequence2; % Fréquence des désac mvt se rassoir


        
    end

end
for i =1:length(ListeFichier)
    for k=5:8 % On balaye
        Donnees(i).EMG(1).MeanPhasic(:,1)=Donnees(i).EMG(5).Phasic.DA_bas;
        Donnees(i).EMG(1).MeanPhasic(:,2)=Donnees(i).EMG(6).Phasic.DA_bas;
        Donnees(i).EMG(1).MeanPhasic(:,3)=Donnees(i).EMG(7).Phasic.DA_bas;
        Donnees(i).EMG(1).MeanPhasic(:,4)=Donnees(i).EMG(8).Phasic.DA_bas;
        Donnees(i).EMG(1).MeanPhasic(:,6)=Donnees(i).EMG(5).Phasic.DA_haut;
        Donnees(i).EMG(1).MeanPhasic(:,7)=Donnees(i).EMG(6).Phasic.DA_haut;
        Donnees(i).EMG(1).MeanPhasic(:,8)=Donnees(i).EMG(7).Phasic.DA_haut;
        Donnees(i).EMG(1).MeanPhasic(:,9)=Donnees(i).EMG(8).Phasic.DA_haut;
    end
end


    
for i =1:length(ListeFichier)
    for k=5:8 % On balaye
        Donnees(1).Quantifs(1,i) = mean(Donnees(i).EMG(1).QuantifDesac(1,1:4));
        Donnees(1).Quantifs(2,i) = mean(Donnees(i).EMG(1).QuantifDesac(2,1:4));
        Donnees(1).Quantifs(3,i) = mean(Donnees(i).EMG(1).QuantifDesac(3,1:4));
        Donnees(1).Quantifs(4,i) = mean(Donnees(i).EMG(1).QuantifDesac(4,1:4));
        Donnees(1).Quantifs(5,i) = mean(Donnees(i).EMG(1).QuantifDesac(5,1:4));
        Donnees(1).Quantifs(6,i) = mean(Donnees(i).EMG(1).QuantifDesac(6,1:4));
        Donnees(1).Temps(1,i) = round(mean(Donnees(i).EMG(k).Duree.DA_haut))-anticip_tonic_post-anticip_tonic_pre;
        Donnees(1).Temps(2,i) = round(mean(Donnees(i).EMG(k).Duree.DA_bas))-anticip_tonic_post-anticip_tonic_pre;
        Donnees(1).QuantifsTEMPSBAISSER(1,i) = Donnees(i).EMG(1).QuantifDesac(2,1);
        Donnees(1).QuantifsTEMPSBAISSER(2,i) = Donnees(i).EMG(1).QuantifDesac(2,2);
        Donnees(1).QuantifsTEMPSBAISSER(3,i) = Donnees(i).EMG(1).QuantifDesac(2,3);
        Donnees(1).QuantifsTEMPSBAISSER(4,i) = Donnees(i).EMG(1).QuantifDesac(2,4);
        Donnees(1).QuantifsTEMPSLever(1,i) = Donnees(i).EMG(1).QuantifDesac(1,1);
        Donnees(1).QuantifsTEMPSLever(2,i) = Donnees(i).EMG(1).QuantifDesac(1,2);
        Donnees(1).QuantifsTEMPSLever(3,i) = Donnees(i).EMG(1).QuantifDesac(1,3);
        Donnees(1).QuantifsTEMPSLever(4,i) = Donnees(i).EMG(1).QuantifDesac(1,4);
        for f=1:1000
            maxi = max(max(abs(Donnees(i).EMG(1).MeanPhasic(:,1:4))));
            maxih = max(max(abs(Donnees(i).EMG(1).MeanPhasic(:,6:9))));
            Donnees(1).MeanPhasicDaBas(f,i) = mean(Donnees(i).EMG(1).MeanPhasic(f,1:4))./maxi;
            Donnees(1).MeanPhasicDaHaut(f,i) = mean(Donnees(i).EMG(1).MeanPhasic(f,6:9))./maxih;
        end
    end
end

for f=1:1000
    maxi = max(Donnees(1).MeanPhasicDaBas(:,:))
    MEANDAPHASIC(f,1) = mean(Donnees(1).MeanPhasicDaBas(f,:));
    MEANDAPHASIC(f,2) = mean(Donnees(1).MeanPhasicDaBas(f,:)) + std(Donnees(1).MeanPhasicDaBas(f,:))/sqrt(20);
    MEANDAPHASIC(f,3) = mean(Donnees(1).MeanPhasicDaBas(f,:)) - std(Donnees(1).MeanPhasicDaBas(f,:))/sqrt(20);
end

for f=1:1000
    MEANDAPHASICH(f,1) = mean(Donnees(1).MeanPhasicDaHaut(f,:));
    MEANDAPHASICH(f,2) = mean(Donnees(1).MeanPhasicDaHaut(f,:)) + std(Donnees(1).MeanPhasicDaHaut(f,:))/sqrt(20);
    MEANDAPHASICH(f,3) = mean(Donnees(1).MeanPhasicDaHaut(f,:)) - std(Donnees(1).MeanPhasicDaHaut(f,:))/sqrt(20);
end

%% EXPORT
name = 'New_DATA';
disp('Selectionnez le Dossier où enregistre les données.');
[Dossier] = uigetdir ('Selectionnez le Dossier où enregistre les données.');
save([Dossier '/' name ], 'Donnees');
disp('Données enregistrées avec succès !');
