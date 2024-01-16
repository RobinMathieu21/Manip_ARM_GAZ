    %% Script principal pour manip GAZ
        % A executer pour post-traiter les données obtenues lors des manips wholnormae
        % body. Ce script est à utiliser pour les données STS/BTS et WB reaching.

close all
clear all

    %% Informations sur le traitement des données
        % Données pour le traitement cinématique
Frequence_acquisition = 100;  % Fréquence d'acquisition du signal cinématique
Low_pass_Freq = 5; % Fréquence passe-bas la position
Cut_off = 0.1; %pourcentage du pic de vitesse pour déterminer début et fin du mouvement
Ech_norm_kin = 1000; %Fréquence d'échantillonage du profil de vitesse normalisé en durée 
Seuil = 0.1;
Data.Gaz.sequence = ['1','1','1','1','2','2','2','2'];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Importation des données pour le TRAITEMENT CINEMATIQUE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % On selectionne le repertoire
disp('Selectionnez le fichier ');
[Dossier] = uigetdir ('Selectionnez le Dossier où exécuter le Script');
Extension = '*.mat'; %Traite tous les .mat
Chemin = fullfile(Dossier, Extension); % On construit le chemin
ListeFichier = dir(Chemin); % On construit la liste des fichiers

for AA =1:length(ListeFichier)

    if i>=5 && i<=13  %i>=4 && i<=11%
        Frequence_acquisition=200;
    else
        Frequence_acquisition=100;
    end

%             On selectionne le repertoire
%     disp('Selectionnez le fichier '); %%%%%%%%%
%     [file,Chemin] = uigetfile ('Selectionnez le Dossier où exécuter le Script'); %%%%%%%%%
%     Fichier_traite = [Chemin '\' file]; %On charge le fichier .mat %%%%%%%%%
%     load (Fichier_traite); %%%%%%%%%
    Fichier_traite = [Dossier '\' ListeFichier(AA).name];
    load (Fichier_traite);

    % On balaye chaque fichier cinématique correspondant chacun à un bloc de mvts
    for i =1:8%length(ListeFichier)
        i
% % %         
% % %         Fichier_traite = [Dossier '\' ListeFichier(i).name]; %On charge le fichier .mat
% % %         load (Fichier_traite);
    
        posxyz = Data.Kinematics(i).C3D.Cinematique.Donnees(:, 49:51); % 
% % %         posxyz = C3D.Cinematique.Donnees(:, 49:51); 
        pos_epaule = Data.Kinematics(i).C3D.Cinematique.Donnees(:, 17:19);   % 
% % %         pos_epaule = C3D.Cinematique.Donnees(:, 17:19);   
        
        %On filtre le signal de position
        posfiltre = butter_emgs(posxyz, Frequence_acquisition, 3, Low_pass_Freq, 'low-pass', 'false', 'centered');
        posfiltre_epaule = butter_emgs(pos_epaule, Frequence_acquisition, 3, Low_pass_Freq, 'low-pass', 'false', 'centered');
       
    
        if strcmp(Data.Gaz.sequence(i), '1')
            type_mvt=1;
% % % %             figure;plot(posfiltre(:, 2))
        else
            type_mvt=2;
% % % %             figure;plot(posfiltre(:, 3))
        end
% % % %         enableDefaultInteractivity(gca);
% % % %         [Cut] = ginput(2);
    
        Plage_mvmt_1_start = Data.Clics(1,i); % 
% % %         Plage_mvmt_1_start = round(Cut(1,1));
        Plage_mvmt_1_end = Data.Clics(2,i); % 
% % %         Plage_mvmt_1_end = round(Cut(2,1));
        Data.Clics(1,i) =  Plage_mvmt_1_start;
        Data.Clics(2,i) =  Plage_mvmt_1_end;
    
        [Pos_mvmt_1] = posfiltre(Plage_mvmt_1_start:Plage_mvmt_1_end, :);
        [Pos_epaule_mvmt_1] = posfiltre_epaule(Plage_mvmt_1_start:Plage_mvmt_1_end, :);
    
    
        [indice_pic_vitesse, pic_vitesse, nb_pics, kine] = compute_kinematics_Gaz(Pos_mvmt_1, Pos_epaule_mvmt_1, Frequence_acquisition, type_mvt, Cut_off, Ech_norm_kin, Seuil);
           nb_pics
        Data.Kinematics(i).data = kine;
        Data.Kinematics(i).C3D  =  Data.Kinematics(i).C3D; % C3D
% % %         Data.Kinematics(i).C3D  =  C3D;
       
    
    end
    
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
    
%     figure;
%     for i=1:8
%         i
%      plot(Data.Kinematics(i).data.amplitude);hold on;
%      colororder(newcolors)
%      legend('Hori 1','Hori 2','Hori 3','Hori 4','Vert 1','Vert 2','Vert 3','Vert 4')
%      Data.Kinematics(i).mean_amp=mean(Data.Kinematics(i).data.amplitude);
%      Data.Kinematics(i).mean_md=mean(Data.Kinematics(i).data.MD1)/Frequence_acquisition;
%     end
    
    figure;
    for i=1:8
        i
     plot(Data.Kinematics(i).data.amplitude2);hold on;
     colororder(newcolors)
     legend('Hori 1','Hori 2','Hori 3','Hori 4','Vert 1','Vert 2','Vert 3','Vert 4')
     Data.Kinematics(i).mean2_amp=mean(Data.Kinematics(i).data.amplitude2);
     Data.Kinematics(i).mean2_md=mean(Data.Kinematics(i).data.MD2)/Frequence_acquisition;
    end
    % 
    for i=1:8
        Data.Kinematics(i).Torque = Data.Kinematics(i).data.angle_elevationTORQUE_MEAN;  
    end
    
    for i=1:8
        Data.Kinematics(i).data.amplitude2 = Data.Kinematics(i).data.amplitude2(mod(Data.Kinematics(i).data.amplitude2,2)~=0);
    end
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Export des données
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    name = append(Data.Kinematics(i).C3D.NomSujet(1,:),'_KINE');
    disp('Selectionnez le Dossier où enregistre les données.');
%     [Dossier] = uigetdir ('Selectionnez le Dossier où enregistre les données.');
    Dossier2 =  'G:\Autres ordinateurs\Mon ordinateur portable\Drive google\6A - THESE\MANIP 2\MATLAB\DATA_POST_TREATED7 5pourc corrige';
    save([Dossier2 '/' name ], 'Data');
    disp('Données enregistrées avec succès !');
    
    
    
%     close all

end
