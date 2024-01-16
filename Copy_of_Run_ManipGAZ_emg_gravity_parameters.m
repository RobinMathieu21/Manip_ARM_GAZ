    %% Script principal pour manip GAZ
        % A executer pour post-traiter les donn�es obtenues lors des manips whole
        % body. Ce script est � utiliser pour les donn�es STS/BTS et WB reaching.

close all
clear all

    %% Informations sur le traitement des donn�es
        % Donn�es pour le traitement cin�matique
Frequence_acquisition = 100;  % Fr�quence d'acquisition du signal cin�matique
Low_pass_Freq = 5; % Fr�quence passe-bas la position
Ech_norm = 1000;
Data.Gaz.sequence = ['1','1','1','1','2','2','2','2'];
Nb_emgs = 4;
emg_frequency = 1000;
emg_band_pass_Freq = [30 300]; % Passe_bande du filtre EMG
emg_low_pass_Freq = 20; % Fr�quence passe_bas lors du second filtre du signal emg. 100 est la fr�quence habituelle chez les humains (cf script J�r�mie)
type_RMS = 1; % 1 pour sliding et 2 pour skipping
rms_window = 50;
rms_window_step  = (rms_window/1000)*emg_frequency;
% anticip = 0.10; %Temps � soustraire lors du recoupage du rms_cut pour trouver le d�but de la bouff�e
EMD = 0.076; % d�lai electrom�canique moyen de tous les muscles
emg_ech_norm = 1000;
anticip_tonic = 1000; % Dur�e (en ms) pour avoir le dernier point du tonic avant le mouvement et le premier point du tonic apr�s le mouvement
duration_tonic = 100; % Dur�e (en ms) de moyennage du tonic
emg_div_kin_freq = emg_frequency/Frequence_acquisition; %used to synchronized emg cutting (for sliding rms) with regard to kinematics
emgrms_div_kin_freq = emg_div_kin_freq/rms_window_step; %used to synchronized emg cutting (for skipping rms) with regard to kinematics

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Importation des donn�es pour le TRAITEMENT CINEMATIQUE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % On selectionne le repertoire
disp('Selectionnez le fichier ');
[Dossier] = uigetdir ('Selectionnez le Dossier o� ex�cuter le Script');
Extension = '*.mat'; %Traite tous les .mat
Chemin = fullfile(Dossier, Extension); % On construit le chemin
ListeFichier = dir(Chemin); % On construit la liste des fichiers


% On balaye chaque fichier cin�matique correspondant chacun � un bloc de mvts
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

