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
    figure;
    Fichier_traite = [Dossier '\' ListeFichier(i).name]; %On charge le fichier .mat
    load (Fichier_traite);
    for k=1:8

        if strcmp(Data.Gaz.sequence(k), '1')
            type_mvt=1;
        else
            type_mvt=2;
        end
        k


        for j =1:length(Data.Kinematics(k).data.Debut_Fin(:,1))-1
            debut = 10*(Data.Clics(1,k)+Data.Kinematics(k).data.Debut_Fin(j+1,1));
            fin = 10*(Data.Clics(1,k)+Data.Kinematics(k).data.Debut_Fin(j,2));
            phaseStable(j) = debut - fin;
            

            
        end
        plot(phaseStable);hold on;
    end
end


for i=1:5
    figure;plot(aPOS(i).pos)
end

for i=1:5
    figure;plot(aPOS(i).pos2)
end