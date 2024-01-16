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
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Importation des données pour le TRAITEMENT CINEMATIQUE
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

        % On selectionne le repertoire
disp('Selectionnez le fichier ');
[Dossier] = uigetdir ('Selectionnez le Dossier où exécuter le Script');
Extension = '*.mat'; %Traite tous les .mat
Chemin = fullfile(Dossier, Extension); % On construit le chemin
ListeFichier = dir(Chemin); % On construit la liste des fichiers

PourMasseBras = 0.05;
g = 9.81;
PourLBras = 0.332;
B= 0.87;
RadiusGir = 0.645;
centergrav = 0.53;
PoidsSujet=[65,70,58,58,85,76,90,90,81,63,50,64,60,51,60,60,52,67,80,59,78,50,55,62];
TailleSujet=[1.75,1.74,1.70,1.64,1.75,1.93,1.88,1.90,1.78,1.78,1.58,1.68,1.68,1.59,1.78,1.75,1.58,1.66,1.72,1.70,1.84,1.55,1.63,1.66];

% On balaye chaque fichier cinématique correspondant chacun à un bloc de mvts
for i =1:length(ListeFichier)
    i
    if i>=5 && i<=13  %i>=4 && i<=11%
        Frequence_acquisition=200;
    else
        Frequence_acquisition=100;
    end
    Fichier_traite = [Dossier '\' ListeFichier(i).name]; %On charge le fichier .mat
    load (Fichier_traite);
    

    for k=1:8 % il y a 8 blocs
        
        % Pour calculer le torque total
        Iner = PourMasseBras * PoidsSujet(i) * (PourLBras*TailleSujet(i)*RadiusGir)^2; % 0.05 c'est la taille du bras en fonction de la taille du sujet
        % 0.44 c'est la longeur du bras par rapport à la taille du sujet, 0.645 c'est le radius of giration
      
        B = 0.87;% Constante de la litt
        GT = PourMasseBras * PoidsSujet(i)* g * Data.Kinematics(k).data.angle_elevationTORQUE * centergrav*PourLBras*TailleSujet(i);
        
        TetaVit = derive(Data.Kinematics(k).data.angle_elevation,1); %Accélération angulaire
        TetaVit = TetaVit./(1/Frequence_acquisition);
        TetaVit = TetaVit*pi./(180); % pour avoir en radians par seconde
        TetaAcc = derive(abs(TetaVit),1); %Vitesse angulaire
        TetaAcc = TetaAcc./(1/Frequence_acquisition);
    
        leng = length(Data.Kinematics(k).data.angle_elevationTORQUE);
        temps = 120;%length(Data.Kinematics(k).data.angle_elevationTORQUE)./Frequence_acquisition;
        temps
        TRAVAIL(i,k) = sum(Iner * abs(TetaAcc) + B * abs(TetaVit) + GT)/(leng);
        GRAVITY_TORQUE(i,k)=sum(GT)/(leng);
        INERTIA_TORQUE(i,k)=sum(Iner * abs(TetaAcc))/(leng);
        FRICTION_TORQUE(i,k)=sum(B * abs(TetaVit))/(leng);

    
        if strcmp(Data.Gaz.sequence(k), '1')
            type_mvt=1;
        else
            type_mvt=2;
        end
        k
        Pos_mvmt = Data.Kinematics(k).C3D.Cinematique.Donnees(:,49:51); % Position du doigt
        
        %On filtre le signal de position
        posfiltre = butter_emgs(Pos_mvmt, Frequence_acquisition, 3, Low_pass_Freq, 'low-pass', 'false', 'centered');
        c1=1;
        c2=1;
        c3=1;
        c4=1;
        for j =1:length(Data.Kinematics(k).data.Debut_Fin(:,1))
            debut = Data.Clics(1,k)+Data.Kinematics(k).data.Debut_Fin(j,1);
            fin = Data.Clics(1,k)+Data.Kinematics(k).data.Debut_Fin(j,2);
            [Pos_mvmt_1] = posfiltre(debut:fin, :);
            debutAmp = Data.Kinematics(k).data.Debut_Fin(j,1);
            finAmp = Data.Kinematics(k).data.Debut_Fin(j,2);
        
        
            [Param, nb_pics] = compute_kinematics_gravity_parameters(Pos_mvmt_1, Frequence_acquisition, Ech_norm, type_mvt);
%             nb_pics
            %MOUVEMENTS Verticaux
            if type_mvt == 2 && nb_pics<2
%                 type_mvt
                if posfiltre(fin,3)-posfiltre(debut,3)<-350 %%% VERS BAS
                    aPOS(i).pos(c1,k-4)=posfiltre(fin,3)-posfiltre(debut,3);
                    Donnees(i).Kinematics(k).Param(c1,1)= Param.rD_PV;
                    Donnees(i).Kinematics(k).Param(c1,2)= Param.rD_PA;
                    Donnees(i).Kinematics(k).Param(c1,3)= Param.rD_PD;
                    Donnees(i).Kinematics(k).Param(c1,4)= Param.PV;
                    Donnees(i).Kinematics(k).Param(c1,5)= Param.PA;
                    Donnees(i).Kinematics(k).Param(c1,6)= Param.PD;
                    Donnees(i).Kinematics(k).Param(c1,7)= Param.MD;
                    Donnees(i).Kinematics(k).Param(c1,8)= abs(Data.Kinematics(k).data.angle_elevation(finAmp, :)-Data.Kinematics(k).data.angle_elevation(debutAmp, :));
                    Donnees(i).Kinematics(k).Param(c1,9)= Param.Vmean;
                    Donnees(i).Kinematics(k).Param(c1,10)= Data.Kinematics(1:2).Torque;
                    c1=c1+1;
                    Donnees(i).Kinematics(k).PPNVersB(1:1000,j)= Param.poscut_norm(:,3);
                    Donnees(i).Kinematics(k).PVNVersB(1:1000,j)= Param.profil_vitesse_norm;
                    Donnees(i).Kinematics(k).PANVersB(1:1000,j)= Param.profil_accel_norm;
                end
                if posfiltre(fin,3)-posfiltre(debut,3)>350 %%% VERS HAUT
                    aPOS(i).pos(c2,k)=posfiltre(fin,3)-posfiltre(debut,3); 
                    Donnees(i).Kinematics(k).Param(c2,11)= Param.rD_PV;
                    Donnees(i).Kinematics(k).Param(c2,12)= Param.rD_PA;
                    Donnees(i).Kinematics(k).Param(c2,13)= Param.rD_PD;
                    Donnees(i).Kinematics(k).Param(c2,14)= Param.PV;
                    Donnees(i).Kinematics(k).Param(c2,15)= Param.PA;
                    Donnees(i).Kinematics(k).Param(c2,16)= Param.PD;
                    Donnees(i).Kinematics(k).Param(c2,17)= Param.MD;
                    Donnees(i).Kinematics(k).Param(c2,18)= abs(Data.Kinematics(k).data.angle_elevation(finAmp, :)-Data.Kinematics(k).data.angle_elevation(debutAmp, :));
                    Donnees(i).Kinematics(k).Param(c2,19)= Param.Vmean;
                    Donnees(i).Kinematics(k).Param(c2,20)= Param.ParamC;
                    c2=c2+1;
                    Donnees(i).Kinematics(k).PPNVersH(1:1000,j)= Param.poscut_norm(:,3);
                    Donnees(i).Kinematics(k).PVNVersH(1:1000,j)= Param.profil_vitesse_norm;
                    Donnees(i).Kinematics(k).PANVersH(1:1000,j)= Param.profil_accel_norm;
                end

                if posfiltre(fin,3)-posfiltre(debut,3)<350 && posfiltre(fin,3)-posfiltre(debut,3)>-350 %%% VERS BAS
                    disp('--------------- MOUVEMENT Trop petit -----------------');
                end
            end
            
            %MOUVEMENTS Horizontaux
            if type_mvt == 1 && nb_pics<2
%                 type_mvt
                if posfiltre(fin,2)-posfiltre(debut,2)<-350
                     aPOS(i).pos2(c3,k)=posfiltre(fin,2)-posfiltre(debut,2);
                    Donnees(i).Kinematics(k).Param(c3,1)= Param.rD_PV;
                    Donnees(i).Kinematics(k).Param(c3,2)= Param.rD_PA;
                    Donnees(i).Kinematics(k).Param(c3,3)= Param.rD_PD;
                    Donnees(i).Kinematics(k).Param(c3,4)= Param.PV;
                    Donnees(i).Kinematics(k).Param(c3,5)= Param.PA;
                    Donnees(i).Kinematics(k).Param(c3,6)= Param.PD;
                    Donnees(i).Kinematics(k).Param(c3,7)= Param.MD;
                    Donnees(i).Kinematics(k).Param(c3,8)= abs(Data.Kinematics(k).data.angle_elevation(finAmp, :)-Data.Kinematics(k).data.angle_elevation(debutAmp, :));
                    Donnees(i).Kinematics(k).Param(c3,9)= Param.Vmean;
                    Donnees(i).Kinematics(k).Param(c3,10)= Param.ParamC;
                    c3=c3+1;
                    Donnees(i).Kinematics(k).PPNVersD(1:1000,j)= Param.poscut_norm(:,2);
                    Donnees(i).Kinematics(k).PVNVersD(1:1000,j)= Param.profil_vitesse_norm;
                    Donnees(i).Kinematics(k).PANVersD(1:1000,j)= Param.profil_accel_norm;
                end
                if posfiltre(fin,2)-posfiltre(debut,2)>350
                    aPOS(i).pos2(c4,k+4)=posfiltre(fin,2)-posfiltre(debut,2);
                    Donnees(i).Kinematics(k).Param(c4,11)= Param.rD_PV;
                    Donnees(i).Kinematics(k).Param(c4,12)= Param.rD_PA;
                    Donnees(i).Kinematics(k).Param(c4,13)= Param.rD_PD;
                    Donnees(i).Kinematics(k).Param(c4,14)= Param.PV;
                    Donnees(i).Kinematics(k).Param(c4,15)= Param.PA;
                    Donnees(i).Kinematics(k).Param(c4,16)= Param.PD;
                    Donnees(i).Kinematics(k).Param(c4,17)= Param.MD;
                    Donnees(i).Kinematics(k).Param(c4,18)= abs(Data.Kinematics(k).data.angle_elevation(finAmp, :)-Data.Kinematics(k).data.angle_elevation(debutAmp, :));
                    Donnees(i).Kinematics(k).Param(c4,19)= Param.Vmean;
                    Donnees(i).Kinematics(k).Param(c4,20)= Param.ParamC;
                    c4=c4+1;
                    Donnees(i).Kinematics(k).PPNVersG(1:1000,j)= Param.poscut_norm(:,2);
                    Donnees(i).Kinematics(k).PVNVersG(1:1000,j)= Param.profil_vitesse_norm;
                    Donnees(i).Kinematics(k).PANVersG(1:1000,j)= Param.profil_accel_norm;
                end

                if posfiltre(fin,2)-posfiltre(debut,2)<350 && posfiltre(fin,2)-posfiltre(debut,2)>-350 %%% VERS BAS
                    disp('--------------- MOUVEMENT Trop petit -----------------');
                end
            end
        end
        if type_mvt == 2 % mvts verticaux
            Donnees(i).Kinematics(k).MEANParamV(1,1)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,1)));Donnees(i).Kinematics(k).MEANParamV(3,1)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,1)));
            Donnees(i).Kinematics(k).MEANParamV(1,2)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,2)));Donnees(i).Kinematics(k).MEANParamV(3,2)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,2)));
            Donnees(i).Kinematics(k).MEANParamV(1,3)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,3)));Donnees(i).Kinematics(k).MEANParamV(3,3)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,3)));
            Donnees(i).Kinematics(k).MEANParamV(1,4)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,4)));Donnees(i).Kinematics(k).MEANParamV(3,4)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,4)));
            Donnees(i).Kinematics(k).MEANParamV(1,5)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,5)));Donnees(i).Kinematics(k).MEANParamV(3,5)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,5)));
            Donnees(i).Kinematics(k).MEANParamV(1,6)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,6)));Donnees(i).Kinematics(k).MEANParamV(3,6)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,6)));
            Donnees(i).Kinematics(k).MEANParamV(1,7)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,7)));Donnees(i).Kinematics(k).MEANParamV(3,7)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,7)));
            Donnees(i).Kinematics(k).MEANParamV(1,8)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,8)));Donnees(i).Kinematics(k).MEANParamV(3,8)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,8)));
            Donnees(i).Kinematics(k).MEANParamV(1,9)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,9)));Donnees(i).Kinematics(k).MEANParamV(3,9)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,9)));
            Donnees(i).Kinematics(k).MEANParamV(1,10)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,10)));Donnees(i).Kinematics(k).MEANParamV(3,10)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,10)));
    
            Donnees(i).Kinematics(k).MEANParamV(2,1)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,11)));Donnees(i).Kinematics(k).MEANParamV(4,1)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,11)));
            Donnees(i).Kinematics(k).MEANParamV(2,2)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,12)));Donnees(i).Kinematics(k).MEANParamV(4,2)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,12)));
            Donnees(i).Kinematics(k).MEANParamV(2,3)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,13)));Donnees(i).Kinematics(k).MEANParamV(4,3)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,13)));
            Donnees(i).Kinematics(k).MEANParamV(2,4)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,14)));Donnees(i).Kinematics(k).MEANParamV(4,4)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,14)));
            Donnees(i).Kinematics(k).MEANParamV(2,5)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,15)));Donnees(i).Kinematics(k).MEANParamV(4,5)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,15)));
            Donnees(i).Kinematics(k).MEANParamV(2,6)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,16)));Donnees(i).Kinematics(k).MEANParamV(4,6)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,16)));
            Donnees(i).Kinematics(k).MEANParamV(2,7)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,17)));Donnees(i).Kinematics(k).MEANParamV(4,7)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,17)));
            Donnees(i).Kinematics(k).MEANParamV(2,8)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,18)));Donnees(i).Kinematics(k).MEANParamV(4,8)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,18)));
            Donnees(i).Kinematics(k).MEANParamV(2,9)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,19)));Donnees(i).Kinematics(k).MEANParamV(4,9)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,19)));
            Donnees(i).Kinematics(k).MEANParamV(2,10)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,20)));Donnees(i).Kinematics(k).MEANParamV(4,10)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,20)));
        end

        if type_mvt == 1 % mvts H
            Donnees(i).Kinematics(k).MEANParamH(1,1)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,1)));Donnees(i).Kinematics(k).MEANParamH(3,1)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,1)));
            Donnees(i).Kinematics(k).MEANParamH(1,2)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,2)));Donnees(i).Kinematics(k).MEANParamH(3,2)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,2)));
            Donnees(i).Kinematics(k).MEANParamH(1,3)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,3)));Donnees(i).Kinematics(k).MEANParamH(3,3)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,3)));
            Donnees(i).Kinematics(k).MEANParamH(1,4)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,4)));Donnees(i).Kinematics(k).MEANParamH(3,4)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,4)));
            Donnees(i).Kinematics(k).MEANParamH(1,5)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,5)));Donnees(i).Kinematics(k).MEANParamH(3,5)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,5)));
            Donnees(i).Kinematics(k).MEANParamH(1,6)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,6)));Donnees(i).Kinematics(k).MEANParamH(3,6)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,6)));
            Donnees(i).Kinematics(k).MEANParamH(1,7)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,7)));Donnees(i).Kinematics(k).MEANParamH(3,7)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,7)));
            Donnees(i).Kinematics(k).MEANParamH(1,8)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,8)));Donnees(i).Kinematics(k).MEANParamH(3,8)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,8)));
            Donnees(i).Kinematics(k).MEANParamH(1,9)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,9)));Donnees(i).Kinematics(k).MEANParamH(3,9)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,9)));
            Donnees(i).Kinematics(k).MEANParamH(1,10)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,10)));Donnees(i).Kinematics(k).MEANParamH(3,10)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,10)));
    
            Donnees(i).Kinematics(k).MEANParamH(2,1)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,11)));Donnees(i).Kinematics(k).MEANParamH(4,1)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,11)));
            Donnees(i).Kinematics(k).MEANParamH(2,2)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,12)));Donnees(i).Kinematics(k).MEANParamH(4,2)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,12)));
            Donnees(i).Kinematics(k).MEANParamH(2,3)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,13)));Donnees(i).Kinematics(k).MEANParamH(4,3)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,13)));
            Donnees(i).Kinematics(k).MEANParamH(2,4)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,14)));Donnees(i).Kinematics(k).MEANParamH(4,4)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,14)));
            Donnees(i).Kinematics(k).MEANParamH(2,5)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,15)));Donnees(i).Kinematics(k).MEANParamH(4,5)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,15)));
            Donnees(i).Kinematics(k).MEANParamH(2,6)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,16)));Donnees(i).Kinematics(k).MEANParamH(4,6)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,16)));
            Donnees(i).Kinematics(k).MEANParamH(2,7)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,17)));Donnees(i).Kinematics(k).MEANParamH(4,7)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,17)));
            Donnees(i).Kinematics(k).MEANParamH(2,8)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,18)));Donnees(i).Kinematics(k).MEANParamH(4,8)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,18)));
            Donnees(i).Kinematics(k).MEANParamH(2,9)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,19)));Donnees(i).Kinematics(k).MEANParamH(4,9)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,19)));
            Donnees(i).Kinematics(k).MEANParamH(2,10)= mean(nonzeros(Donnees(i).Kinematics(k).Param(:,20)));Donnees(i).Kinematics(k).MEANParamH(4,10)= std(nonzeros(Donnees(i).Kinematics(k).Param(:,20)));
        end
        

    end

%% for verti mvt
    for count =1:4
        Donnees(i).MeanParamV(count,:) =Donnees(i).Kinematics(4+count).MEANParamV(1,:); 
        Donnees(i).MeanParamV(count+4,:) =Donnees(i).Kinematics(4+count).MEANParamV(2,:); 
    end

    for count =1:4
        Donnees(i).MeanParamV(9+count,:) = Donnees(i).MeanParamV(count,:)-Donnees(i).MeanParamV(count+4,:);
    end

    % Pour amp et durée on moyenne la valeur du bloc des mouvements vers le
    % bas avec la valeur du bloc des mouvements vers le haut
    for count =1:4
        Donnees(i).MeanParamV(9+count,8) = mean(Donnees(i).MeanParamV([count count+4],8));
    end

        % For durée
    for count =1:4
        Donnees(i).MeanParamV(9+count,7) = mean(Donnees(i).MeanParamV([count count+4],7));
    end



%% for hori mvt
    for count =1:4
        Donnees(i).MeanParamH(count,:) =Donnees(i).Kinematics(count).MEANParamH(1,:); 
        Donnees(i).MeanParamH(count+4,:) =Donnees(i).Kinematics(count).MEANParamH(2,:); 
    end

    for count =1:4
        Donnees(i).MeanParamH(9+count,:) = Donnees(i).MeanParamH(count,:)-Donnees(i).MeanParamH(count+4,:);
    end

    % Pour amp et durée on moyenne la valeur du bloc des mouvements vers le
    % bas avec la valeur du bloc des mouvements vers le haut
    for count =1:4
        Donnees(i).MeanParamH(9+count,8) = mean(Donnees(i).MeanParamH([count count+4],8));
    end


        % For durée
    for count =1:4
        Donnees(i).MeanParamH(9+count,7) = mean(Donnees(i).MeanParamH([count count+4],7));
    end


        % PLOT  
 for i =1:length(ListeFichier)
    %set(gcf,'position',[200,200,1400,600])
    f = figure('units','normalized','outerposition',[0 0 1 1]);
    t = tiledlayout(2,4,'TileSpacing','Compact');
    title(t,'Comparaison mouvement horizontaux vs verticaux')
    for a=1:4
        a
        Donnees(i).Kinematics(a).PPNVersD( :, all(~Donnees(i).Kinematics(a).PPNVersD,1) ) = [];
        Donnees(i).Kinematics(a).PPNVersG( :, all(~Donnees(i).Kinematics(a).PPNVersG,1) ) = [];
        for f=1:1000
            f1(f,1)= mean(Donnees(i).Kinematics(a).PPNVersD(f,:));
            f2(f,1)= mean(Donnees(i).Kinematics(a).PPNVersG(f,:));
        end
        f1 = (-1).*f1+f1(1);%./max1;
        f2 = f2-f2(1);%./max2;
        max1 = max(f1);
        max2 = max(f2);
        f1 = f1./max1;
        f2 = f2./max2;
        Donnees(i).PPNVersD(:,a) = f1;
        Donnees(i).PPNVersG(:,a) = f2;
        [~,vv] = size(Donnees(i).Kinematics(a).PPNVersD);
        for nb=1:vv
            Donnees(i).Kinematics(a).PPNVersDNorm(:,nb) = (-1).*Donnees(i).Kinematics(a).PPNVersD(:,nb);%./max(Donnees(i).Kinematics(a).PPNVersD(:,nb)) ;
        end
        nexttile;plot(f1)
        hold on
        [~,vv] = size(Donnees(i).Kinematics(a).PPNVersG);
        for nb=1:vv
            Donnees(i).Kinematics(a).PPNVersGNorm(:,nb) =  Donnees(i).Kinematics(a).PPNVersG(:,nb);%./max(Donnees(i).Kinematics(a).PPNVersG(:,nb)) ;
        end
        plot(f2)
        title(append('Bloc ',string(a)))
        
    end
    for f = 1:1000
        Donnees(1).PPNVersDMEAN(f,i) = mean(Donnees(i).PPNVersD(f,:));
        Donnees(1).PPNVersGMEAN(f,i) = mean(Donnees(i).PPNVersG(f,:));
    end
    legend('Vers la droite','Vers la gauche','Position',[0 0.63 0.05 0.3])
    legend('Orientation','vertical')
    legend('boxoff')

    for a=5:8
        Donnees(i).Kinematics(a).PPNVersB( :, all(~Donnees(i).Kinematics(a).PPNVersB,1) ) = [];
        Donnees(i).Kinematics(a).PPNVersH( :, all(~Donnees(i).Kinematics(a).PPNVersH,1) ) = [];
        for f=1:1000
            f1(f,1)= mean(Donnees(i).Kinematics(a).PPNVersH(f,:));
            f2(f,1)= mean(Donnees(i).Kinematics(a).PPNVersB(f,:));
        end
        
        f1 = f1-f1(1);
        f2 = (-1).*f2+f2(1);
        max1 = max(f1);
        max2 = max(f2);
        f1 = f1./max1;
        f2 = f2./max2;
        Donnees(i).PPNVersH(:,a) = f1;
        Donnees(i).PPNVersB(:,a) = f2;
        [~,vv] = size(Donnees(i).Kinematics(a).PPNVersH);
        for nb=1:vv
            Donnees(i).Kinematics(a).PPNVersHNorm(:,nb) = Donnees(i).Kinematics(a).PPNVersH(:,nb);%./max(Donnees(i).Kinematics(a).PPNVersH(:,nb)) ;
        end
        nexttile;plot(f1)
        hold on
        [~,vv] = size(Donnees(i).Kinematics(a).PPNVersB);
        for nb=1:vv
            Donnees(i).Kinematics(a).PPNVersBNorm(:,nb) =  Donnees(i).Kinematics(a).PPNVersB(:,nb);%./max(Donnees(i).Kinematics(a).PPNVersB(:,nb)) ;
        end
        plot(f2)
    end
    legend('Vers le haut','Vers le bas','Position',[0 0.19 0.05 0.3])
    legend('Orientation','vertical')
    legend('boxoff')
    for f = 1:1000
        Donnees(1).PPNVersHMEAN(f,i) = mean(Donnees(i).PPNVersH(f,:));
        Donnees(1).PPNVersBMEAN(f,i) = mean(Donnees(i).PPNVersB(f,:));
    end
%     name = append('Kine_Sujet_n_',string(i));
%     path = 'G:\Autres ordinateurs\Mon ordinateur portable\Drive google\6A - THESE\MANIP 2\MATLAB\Graphs kine6 5 pourc\';
%     path = 'C:\Users\robin\Desktop\Drive google\6A - THESE\MANIP 2\MATLAB\Graphs kine6 5 pourc\';
%     path = append(path,'Velocity_profils_',name);
%     saveas(gcf,path,'png');

end

%% RDPA RDPV
for sujets=1:length(ListeFichier)
    Matrice_results_RDPV_RDPA(sujets,1:4) = Donnees(sujets).MeanParamV(10:end,1)'
    Matrice_results_RDPV_RDPA(sujets,5:8) = Donnees(sujets).MeanParamV(10:end,2)'
end

for sujets=1:length(ListeFichier)
    Matrice_results_H_RDPV_RDPA(sujets,1:4) = Donnees(sujets).MeanParamH(10:end,1)'
    Matrice_results_H_RDPV_RDPA(sujets,5:8) = Donnees(sujets).MeanParamH(10:end,2)'
end



%% AMPLITUDE
for sujets=1:length(ListeFichier)
    Matrice_results_H_amp(sujets,1:4) = Donnees(sujets).MeanParamH(10:end,8)';
end

for sujets=1:length(ListeFichier)
    Matrice_results_V_amp(sujets,1:4) = Donnees(sujets).MeanParamV(10:end,8)';
end

%% DUREE
for sujets=1:length(ListeFichier)
    Matrice_results_H_duree(sujets,1:4) = Donnees(sujets).MeanParamH(10:end,7)';
end

for sujets=1:length(ListeFichier)
    Matrice_results_V_duree(sujets,1:4) = Donnees(sujets).MeanParamV(10:end,7)';
end












% 
% 
%     % PLOT  
% % for i =1:length(ListeFichier)
%     %set(gcf,'position',[200,200,1400,600])
%     f = figure('units','normalized','outerposition',[0 0 1 1]);
%     t = tiledlayout(2,4,'TileSpacing','Compact');
%     title(t,'Comparaison mouvement horizontaux vs verticaux')
%     for a=1:4
%         a
%         Donnees(i).Kinematics(a).PPNVersD( :, all(~Donnees(i).Kinematics(a).PPNVersD,1) ) = [];
%         Donnees(i).Kinematics(a).PPNVersG( :, all(~Donnees(i).Kinematics(a).PPNVersG,1) ) = [];
% %         for f=1:1000
% %             f1(f,1)= mean(Donnees(i).Kinematics(a).PPNVersD(f,:));
% %             f2(f,1)= mean(Donnees(i).Kinematics(a).PPNVersG(f,:));
% %         end
% %         max1 = max(f1);
% %         max2 = max(f2);
% %         f1 = f1./max1;
% %         f2 = f2./max2;
%         [~,vv] = size(Donnees(i).Kinematics(a).PPNVersD);
%         for nb=1:vv
%             Donnees(i).Kinematics(a).PPNVersDNorm(:,nb) = (-1).*Donnees(i).Kinematics(a).PPNVersD(:,nb);%./max(Donnees(i).Kinematics(a).PPNVersD(:,nb)) ;
%         end
%         nexttile;plot(Donnees(i).Kinematics(a).PPNVersDNorm)
%         hold on
%         [~,vv] = size(Donnees(i).Kinematics(a).PPNVersG);
%         for nb=1:vv
%             Donnees(i).Kinematics(a).PPNVersGNorm(:,nb) =  Donnees(i).Kinematics(a).PPNVersG(:,nb);%./max(Donnees(i).Kinematics(a).PPNVersG(:,nb)) ;
%         end
%         plot(Donnees(i).Kinematics(a).PPNVersGNorm)
%         title(append('Bloc ',string(a)))
%         
%     end
%     legend('Vers la droite','Vers la gauche','Position',[0 0.63 0.05 0.3])
%     legend('Orientation','vertical')
%     legend('boxoff')
% 
%     for a=5:8
%         Donnees(i).Kinematics(a).PPNVersB( :, all(~Donnees(i).Kinematics(a).PPNVersB,1) ) = [];
%         Donnees(i).Kinematics(a).PPNVersH( :, all(~Donnees(i).Kinematics(a).PPNVersH,1) ) = [];
% %         for f=1:1000
% %             f1(f,1)= mean(Donnees(i).Kinematics(a).PPNVersH(f,:));
% %             f2(f,1)= mean(Donnees(i).Kinematics(a).PPNVersB(f,:));
% %         end
% %         max1 = max(f1);
% %         max2 = max(f2);
% %         f1 = f1./max1;
% %         f2 = f2./max2;
%         [~,vv] = size(Donnees(i).Kinematics(a).PPNVersH);
%         for nb=1:vv
%             Donnees(i).Kinematics(a).PPNVersHNorm(:,nb) = Donnees(i).Kinematics(a).PPNVersH(:,nb);%./max(Donnees(i).Kinematics(a).PPNVersH(:,nb)) ;
%         end
%         nexttile;plot(Donnees(i).Kinematics(a).PPNVersHNorm)
%         hold on
%         [~,vv] = size(Donnees(i).Kinematics(a).PPNVersB);
%         for nb=1:vv
%             Donnees(i).Kinematics(a).PPNVersBNorm(:,nb) =  Donnees(i).Kinematics(a).PPNVersB(:,nb);%./max(Donnees(i).Kinematics(a).PPNVersB(:,nb)) ;
%         end
%         plot(Donnees(i).Kinematics(a).PPNVersBNorm)
%     end
%     legend('Vers le haut','Vers le bas','Position',[0 0.19 0.05 0.3])
%     legend('Orientation','vertical')
%     legend('boxoff')
% %     name = append('Kine_Sujet_n_',string(i));
% %     path = 'G:\Autres ordinateurs\Mon ordinateur portable\Drive google\6A - THESE\MANIP 2\MATLAB\Graphs kine6 5 pourc\';
% %     path = 'C:\Users\robin\Desktop\Drive google\6A - THESE\MANIP 2\MATLAB\Graphs kine6 5 pourc\';
% %     path = append(path,'Velocity_profils_',name);
% %     saveas(gcf,path,'png');







for f =1:1000
    PPMEAN(f,1) = mean(Donnees(1).PPNVersDMEAN(f,1:20));
    PPMEAN(f,2) = std(Donnees(1).PPNVersDMEAN(f,1:20));
    
    PPMEAN(f,4) = mean(Donnees(1).PPNVersGMEAN(f,1:20));
    PPMEAN(f,5) = std(Donnees(1).PPNVersGMEAN(f,1:20));
    
    PPMEAN(f,7) = mean(Donnees(1).PPNVersHMEAN(f,1:20));
    PPMEAN(f,8) = std(Donnees(1).PPNVersHMEAN(f,1:20));
    
    PPMEAN(f,10) = mean(Donnees(1).PPNVersBMEAN(f,1:20));
    PPMEAN(f,11) = std(Donnees(1).PPNVersBMEAN(f,1:20));
    
end  
    
    
    
    
    
    