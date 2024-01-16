function [Param, nb_pics] = compute_kinematics_BrasDom_nondom(pos, Frequence_acquisition, Ech_norm, type_mvt)

%% On calcule les param�tres cin�matiques classiques de l'analyse par rapport � la gravit�
        
        %On derive la position pour avoir la vitesse 3D
        if type_mvt == 1
            vitesse_test = derive(pos(:, 2), 1);
%             vitesse_test = sqrt(derive(pos(:, 1), 1).^2+derive(pos(:, 2), 1).^2+derive(pos(:, 3), 1).^2);
        else
            vitesse_test = derive(pos(:, 3), 1);
%             vitesse_test = sqrt(derive(pos(:, 1), 1).^2+derive(pos(:, 2), 1).^2+derive(pos(:, 3), 1).^2);
        end
        vitesse = vitesse_test./(1/Frequence_acquisition);
        vitesse = abs(vitesse);
         
        %On derive maintenant la vitesse pour avoir l'acc�l�ration 3D
        accel_test = derive(vitesse, 1);
        accel = accel_test./(1/Frequence_acquisition);



        AV = islocalmax(vitesse);
        nb_pics=0;
        for CC=1:length(AV)
            if AV(CC)>0
                nb_pics=nb_pics+1;
            end
        end

        AV = islocalmax(accel);
        nb_pics2=0;
        for CC=1:length(AV)
            if AV(CC)>0
                nb_pics2=nb_pics2+1;
            end
        end

        AV = islocalmin(accel);
        nb_pics3=0;
        for CC=1:length(AV)
            if AV(CC)>0
                nb_pics3=nb_pics3+1;
            end
        end

        if nb_pics3>1 || nb_pics2>1 || nb_pics>1 
            nb_pics=3;
        end

        
        %On d�finit la taille de la matrice vitesse
        lignes = size(vitesse(:, 1));
        lignes = lignes(1);
    
        
        %On cr�e une matrice correspondant au profil de vitesse
        
        Param.profil_vitesse = vitesse(:, 1);
        [Param.PV, indice_PV] = max(Param.profil_vitesse);
        
        %On cr�e une matrice correspondant au profil d'acc�l�ration
        Param.profil_accel = accel(:, 1);
        [Param.PA, ind_PA] = max(Param.profil_accel);
        [Param.PD, ind_PD] = min(Param.profil_accel);
        [lig_PA, col_PA] = size(Param.profil_accel);
        clear col_PA
        
        %On cr�e une matrice correspondant � la position du doigt pendant le
        %mouvement (le profil de vitesse)
        profil_position = pos(:, :);
        lig_pos = size(profil_position(:, 1));
        lig_pos = lig_pos(1);

        
        %On normalise le profil de position en dur�e
        [Param.poscut_norm, newfreq_pos] = normalize2(profil_position, 'spline', Ech_norm);
       
        clear newfreq_pos
        
        %On normalise le profil de vitesse en dur�e 
        [Param.profil_vitesse_norm, newfreq_vit] = normalize2(Param.profil_vitesse, 'spline', Ech_norm);
        clear newfreq_vit
        %On normalise le profil d'acc�l�ration en dur�e
        [Param.profil_accel_norm, newfrq_acc] = normalize2(Param.profil_accel, 'spline', Ech_norm);
        clear newfrq_acc
        
        % On calcule les param�tres
        
        %On calcule la dur�e du mouvement
        lig_pv = size(Param.profil_vitesse(: ,1));
        lig_pv = lig_pv(1);
        Param.MD = (lig_pv/ Frequence_acquisition);
        
        %On calcule Vmoy
        Param.Vmean = mean(Param.profil_vitesse);
        
        %On calcule param�tre C = Vmax/Vmean     
        Param.ParamC = Param.PV/Param.Vmean;
        
        %On calcule rD-PV 
        Param.rD_PV = (indice_PV/lig_pv);
        
        %On calcule rD-PA
        Param.rD_PA = (ind_PA/lig_PA);
        
        %On calcule rD_PD
        Param.rD_PD = (ind_PD/lig_PA);
        
        %On calcule l'amplitude
        Param.Amp = sqrt((profil_position(lig_pos, 1)-profil_position(1, 1)).^2+(profil_position(lig_pos, 2)-profil_position(1, 2)).^2+(profil_position(lig_pos, 3)-profil_position(1, 3)).^2);
     
