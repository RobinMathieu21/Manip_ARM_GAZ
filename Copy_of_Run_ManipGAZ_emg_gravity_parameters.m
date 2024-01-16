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
Nb_emgs = 4;
emg_frequency = 1000;
emg_band_pass_Freq = [30 300]; % Passe_bande du filtre EMG
emg_low_pass_Freq = 20; % Fréquence passe_bas lors du second filtre du signal emg. 100 est la fréquence habituelle chez les humains (cf script Jérémie)
type_RMS = 1; % 1 pour sliding et 2 pour skipping
rms_window = 50;
rms_window_step  = (rms_window/1000)*emg_frequency;
% anticip = 0.10; %Temps à soustraire lors du recoupage du rms_cut pour trouver le début de la bouffée
EMD = 0.076; % délai electromécanique moyen de tous les muscles
emg_ech_norm = 1000;
anticip_tonic = 1000; % Durée (en ms) pour avoir le dernier point du tonic avant le mouvement et le premier point du tonic après le mouvement
duration_tonic = 100; % Durée (en ms) de moyennage du tonic
emg_div_kin_freq = emg_frequency/Frequence_acquisition; %used to synchronized emg cutting (for sliding rms) with regard to kinematics
emgrms_div_kin_freq = emg_div_kin_freq/rms_window_step; %used to synchronized emg cutting (for skipping rms) with regard to kinematics

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

    

    for k=5:8
        figure;
        if strcmp(Data.Gaz.sequence(k), '1')
            type_mvt=1;
        else
            type_mvt=2;
        end
        k
        Donnees(i).EMG(k).Brutes(:,1) = Data.Kinematics(k).C3D.EMG.Donnees(:,1);

        [emg_rms, emg_filt, emg_rect_filt] = compute_emg(Donnees(i).EMG(k).Brutes, 1, emg_frequency, ...
            emg_band_pass_Freq, emg_low_pass_Freq, type_RMS, rms_window_step);
        
        Donnees(i).EMG(k).RMS = emg_rms;
        
        plot(emg_rms(:,1));hold on;

        for j =1:length(Data.Kinematics(k).data.Debut_Fin(:,1))

            debutEMG = 10*(Data.Clics(1,k)+Data.Kinematics(k).data.Debut_Fin(j,1));
            finEMG = 10*(Data.Clics(1,k)+Data.Kinematics(k).data.Debut_Fin(j,2));
            y = ylim; % current y-axis limits
            x = xlim; % current y-axis limits

            x2 = [debutEMG-500 debutEMG debutEMG debutEMG-500];
            y2 = [y(1) y(1) y(2) y(2)];
            L(4)= patch(x2,y2,'blue','FaceAlpha',0.05);
            x2 = [finEMG+500 finEMG finEMG finEMG+500];
            y2 = [y(1) y(1) y(2) y(2)];
            L(4)= patch(x2,y2,'red','FaceAlpha',0.05);
        end

        

    end
end

