    %% Script principal pour manip GAZ
        % A executer pour post-traiter les données obtenues lors des manips whole
        % body. Ce script est à utiliser pour les données STS/BTS et WB reaching.

close all
clear all


    %% Importation des données
        %On selectionne le repertoire
disp('Selectionnez le fichier ');
[Dossier] = uigetdir ('Selectionnez le Dossier où exécuter le Script');
Extension = '*.mat'; %Traite tous les .mat
Chemin = fullfile(Dossier, Extension); % On construit le chemin
ListeFichier = dir(Chemin); % On construit la liste des fichiers
newcolors = [
128/255 0/255 0/255
230/255 25/255 75/255
245/255 130/255 48/255
255/255 225/255 25/255
210/255 245/255 60/255
60/255 180/255 75/255
70/255 240/255 240/255
0/255 130/255 200/255
145/255 30/255 180/255
240/255 50/255 230/255
128/255 128/255 128/255
170/255 110/255 40/255
0 0 0];


    %% On procède au balayage fichier par fichier
    %On charge les fichiers
disp('POST TRAITEMENT ')

for SUJET =1:length(ListeFichier)
    SUJET

    Fichier_traite = [Dossier '\' ListeFichier(SUJET).name]; %On charge le fichier .mat
    load (Fichier_traite);
%     figure;plot(Data.Kinematics(1).data.angle_elevation)
    DATA_ALL.Kinematics.amp(1:8,SUJET) = [Data.Kinematics.mean2_amp];
    DATA_ALL.Kinematics.ampMean(SUJET,1) = mean([Data.Kinematics(1:4).mean2_amp]);
    DATA_ALL.Kinematics.ampMean(SUJET,2) = mean([Data.Kinematics(5:8).mean2_amp]);

    DATA_ALL.Kinematics.mean2_md(SUJET,1) = mean([Data.Kinematics(1:4).mean2_md]);
    DATA_ALL.Kinematics.mean2_md(SUJET,2) = mean([Data.Kinematics(5:8).mean2_md]);

    DATA_ALL.Kinematics.Torque(SUJET,1) = mean([Data.Kinematics(1:4).Torque]);
    DATA_ALL.Kinematics.Torque(SUJET,2) = mean([Data.Kinematics(5:8).Torque]);
%     figure;
%     for i=1:8
%         i
%      plot(Data.Kinematics(i).data.amplitude);hold on;
%      title(append('Sujet ',string(SUJET), ' AMP méthode 1 '));
%      colororder(newcolors)
%      legend('Hori 1','Hori 2','Hori 3','Hori 4','Vert 1','Vert 2','Vert 3','Vert 4')
%     end
% 
%     figure;
%     for i=1:8
%         i
%      plot(Data.Kinematics(i).data.amplitude2);hold on;
%      title(append('Sujet ',string(SUJET), ' AMP méthode 2 '));
%      colororder(newcolors)
%      legend('Hori 1','Hori 2','Hori 3','Hori 4','Vert 1','Vert 2','Vert 3','Vert 4')
%     end
%     
end


