function [indice_pic_vitesse, pic_vitesse, nb_pics, kine] = compute_kinematics_Gaz(pos, pos_epaule, ...
    Frequence_acquisition, type_mvt, Cutoff, Ech_norm, Seuil)

%% On calcule les paramètres cinématiques des 2 mouvements
    %On derive la position pour avoir la vitesse 3D

if type_mvt ==2


%     vitesse_test = sqrt(derive(pos(:, 1), 1).^2+derive(pos(:, 2), 1).^2+derive(pos(:, 3), 1).^2);
    vitesse_test = derive(pos(:, 3), 1);
    vitesse_3D = sqrt(derive(pos(:, 1), 1).^2+derive(pos(:, 2), 1).^2+derive(pos(:, 3), 1).^2);
    vitesse_3D = vitesse_3D./(1/Frequence_acquisition);
    vitesse = vitesse_test./(1/Frequence_acquisition);
    vitesse = abs(vitesse);
    kine.vitesse = vitesse;
    
    %On trouve les pics de vitesse et leurs indices dans la matrice
    [indice_pic_vitesse, pic_vitesse] = islocalmax(vitesse,'MinProminence',850); % On cherche les maxi locaux
    nb_pics = nnz(indice_pic_vitesse); % nous donne le nombre de pics
    x = 1:length(vitesse);
    plot(x,vitesse,x(indice_pic_vitesse),vitesse(indice_pic_vitesse),'r*') % Pour les afficher

    c=2;
    indices(1,:)=1;
    for j=1:length(indice_pic_vitesse)
        if indice_pic_vitesse(j) ==1
            indices(c,:) = j; c=c+1;      % Pour avoir le moment du pic
        end
    end


         % Calcul amplitude angulaire des mvts VERTICAUX
    kine.VecEM(:,1) = pos(:,1) - pos_epaule(:,1); % Rfin - Rsho
    kine.VecEM(:,2) = pos(:,2) - pos_epaule(:,2);
    kine.VecEM(:,3) = pos(:,3) - pos_epaule(:,3);
    
    kine.VecES(:,1) = pos_epaule(:,1)-pos_epaule(:,1); % Le vecteur de base qui est fixe, de l'épaule vers le sol
    kine.VecES(:,2) = pos_epaule(:,2)-pos_epaule(:,2);
    kine.VecES(:,3) = 0-pos_epaule(:,3);
    
    kine.VecEMcar(:,1) = sqrt(kine.VecEM(:,1).^2 + kine.VecEM(:,2).^2 + kine.VecEM(:,3).^2); % Norme des vecteurs
    kine.VecEScar(:,1) = sqrt(kine.VecES(:,1).^2 + kine.VecES(:,2).^2 + kine.VecES(:,3).^2); 
    
    kine.VecEMnor(:,1) = kine.VecEM(:,1)./kine.VecEMcar(:,1); % Normalisation
    kine.VecEMnor(:,2) = kine.VecEM(:,2)./kine.VecEMcar(:,1);
    kine.VecEMnor(:,3) = kine.VecEM(:,3)./kine.VecEMcar(:,1);
    
    kine.VecESnor(:,1) = kine.VecES(:,1)./kine.VecEScar(:,1);
    kine.VecESnor(:,2) = kine.VecES(:,2)./kine.VecEScar(:,1);
    kine.VecESnor(:,3) = kine.VecES(:,3)./kine.VecEScar(:,1);
    
    % Poduit scalaire 
    kine.prod = kine.VecEMnor(:,1).*kine.VecESnor(:,1) + kine.VecEMnor(:,2).*kine.VecESnor(:,2) + kine.VecEMnor(:,3).*kine.VecESnor(:,3);
    kine.angle_elevation = acosd(kine.prod); % Calcul de l'angle

    %%%%%%%%%%% POUR TORQUE GRAVITAIRE %%%%%%%%%%% 
    kine.angle_elevationTORQUE = cosd(acosd(kine.prod)-90); % Calcul du torque 
    kine.angle_elevationTORQUE_MEAN = mean(kine.angle_elevationTORQUE); % Mean du torque
    %%%%%%%%%%% POUR TORQUE GRAVITAIRE %%%%%%%%%%% 
    
    v=1;
    for j=1:2:nb_pics-2
        [Max1,Imax1] = max(kine.angle_elevation(indices(j):indices(j+1),:));
        Imax1 = Imax1 + indices(j);
        [Min1,Imin1]  = min(kine.angle_elevation(indices(j+1):indices(j+2),:)); % Calcul de l'amplitude
        Imin1 = Imin1 + indices(j+1);
        [Max2,Imax2]= max(kine.angle_elevation(indices(j+2):indices(j+3),:));
        Imax2 = Imax2 + indices(j+2);

        kine.amplitude(v,:) =abs(Min1 - Max1);
        kine.amplitude(v+1,:) =abs(Min1 - Max2); 
        kine.MD1(v,:) = Imin1-Imax1;
        kine.MD1(v+1,:) = Imax2-Imin1;
        v=v+2;
    end 

    v=1; %%% Méthodes 5%
%     figure;
    for j=2:nb_pics
        a = indices(j); b = indices(j);
        while (vitesse(a, 1) > Seuil*vitesse(indices(j)))
            a = a-1;
        end
        while (vitesse(b, 1)> Seuil*vitesse(indices(j)))
            b = b+1;
        end
        
        kine.Debut_Fin(v,1) = a;
        kine.Debut_Fin(v,2) = b;
        kine.amplitude2(v,:) =abs(kine.angle_elevation(a,:)-kine.angle_elevation(b,:)); 
        kine.MD2(v,:) = b-a; 
%         hold on; plot(vitesse_3D(a:b)) 
        v=v+1;
    end

end







if type_mvt ==1

    %     vitesse_test = sqrt(derive(pos(:, 1), 1).^2+derive(pos(:, 2), 1).^2+derive(pos(:, 3), 1).^2);
    vitesse_test = derive(pos(:, 2), 1);
    vitesse = vitesse_test./(1/Frequence_acquisition);
    vitesse_3D = sqrt(derive(pos(:, 1), 1).^2+derive(pos(:, 2), 1).^2+derive(pos(:, 3), 1).^2);
    vitesse_3D = vitesse_3D./(1/Frequence_acquisition);
    vitesse = abs(vitesse);
    kine.vitesse = vitesse;
    
    %On trouve les pics de vitesse et leurs indices dans la matrice
    [indice_pic_vitesse, pic_vitesse] = islocalmax(vitesse,'MinProminence',850); % On cherche les maxi locaux
    nb_pics = nnz(indice_pic_vitesse); % nous donne le nombre de pics
    x = 1:length(vitesse);
    plot(x,vitesse,x(indice_pic_vitesse),vitesse(indice_pic_vitesse),'r*') % Pour les afficher

    c=2;
    indices(1,:)=1;
    for j=1:length(indice_pic_vitesse)
        if indice_pic_vitesse(j) ==1
            indices(c,:) = j; c=c+1;      % Pour avoir le moment du pic
        end
    end


    % Calcul amplitude angulaire des mvts HORIZONTAUX
    kine.VecEM(:,1) = pos(:,1) - pos_epaule(:,1); % Rfin - Rsho
    kine.VecEM(:,2) = pos(:,2) - pos_epaule(:,2);
    kine.VecEM(:,3) = pos(:,3) - pos_epaule(:,3);
    
%     kine.VecEC(:,1) = 125-pos_epaule(:,1);% Le vecteur de base qui est fixe
%     kine.VecEC(:,2) = 296;
%     kine.VecEC(:,3) = 939-pos_epaule(:,3);

    kine.VecEC(:,1) = pos_epaule(:,1)-pos_epaule(:,1);% Le vecteur de base qui est fixe
    kine.VecEC(:,2) = -500;
    kine.VecEC(:,3) = pos_epaule(:,3)-pos_epaule(:,3);

    %%%%%%%%%%% POUR TORQUE GRAVITAIRE %%%%%%%%%%% 
    kine.VecES(:,1) = pos_epaule(:,1)-pos_epaule(:,1); % Le vecteur de base qui est fixe POUR TORQUE GRAVITAIRE
    kine.VecES(:,2) = pos_epaule(:,2)-pos_epaule(:,2);
    kine.VecES(:,3) = 0-pos_epaule(:,3); 
    kine.VecEScar(:,1) = sqrt(kine.VecES(:,1).^2 + kine.VecES(:,2).^2 + kine.VecES(:,3).^2); % Norme des vecteurs
    kine.VecESnor(:,1) = kine.VecES(:,1)./kine.VecEScar(:,1);
    kine.VecESnor(:,2) = kine.VecES(:,2)./kine.VecEScar(:,1);
    kine.VecESnor(:,3) = kine.VecES(:,3)./kine.VecEScar(:,1);
    %%%%%%%%%%% POUR TORQUE GRAVITAIRE %%%%%%%%%%% 
    

    kine.VecEMcar(:,1) = sqrt(kine.VecEM(:,1).^2 + kine.VecEM(:,2).^2 + kine.VecEM(:,3).^2);% Norme des vecteurs
    kine.VecECcar(:,1) = sqrt(kine.VecEC(:,1).^2 + kine.VecEC(:,2).^2 + kine.VecEC(:,3).^2); 
    
    kine.VecEMnor(:,1) = kine.VecEM(:,1)./kine.VecEMcar(:,1);% Normalisation
    kine.VecEMnor(:,2) = kine.VecEM(:,2)./kine.VecEMcar(:,1);
    kine.VecEMnor(:,3) = kine.VecEM(:,3)./kine.VecEMcar(:,1);
    
    kine.VecECnor(:,1) = kine.VecEC(:,1)./kine.VecECcar(:,1);
    kine.VecECnor(:,2) = kine.VecEC(:,2)./kine.VecECcar(:,1);
    kine.VecECnor(:,3) = kine.VecEC(:,3)./kine.VecECcar(:,1);
    
    % Poduit scalaire 
    kine.prod = kine.VecEMnor(:,1).*kine.VecECnor(:,1) + kine.VecEMnor(:,2).*kine.VecECnor(:,2) + kine.VecEMnor(:,3).*kine.VecECnor(:,3);
    kine.angle_elevation = acosd(kine.prod);% Calcul de l'angle

    %%%%%%%%%%% POUR TORQUE GRAVITAIRE %%%%%%%%%%% 
    kine.prod = kine.VecEMnor(:,1).*kine.VecESnor(:,1) + kine.VecEMnor(:,2).*kine.VecESnor(:,2) + kine.VecEMnor(:,3).*kine.VecESnor(:,3);
    kine.angle_elevationTORQUE = cosd(acosd(kine.prod)-90); % Calcul du TORQUE
    kine.angle_elevationTORQUE_MEAN = mean(kine.angle_elevationTORQUE); % Mean du torque sur le bloc 
    %%%%%%%%%%% POUR TORQUE GRAVITAIRE %%%%%%%%%%% 
    
    v=1;
    for j=1:2:nb_pics-2
        [Min1,Imin1] = min(kine.angle_elevation(indices(j):indices(j+1),:));
        Imin1 = Imin1 + indices(j);
        [Max1,Imax1] = max(kine.angle_elevation(indices(j+1):indices(j+2),:)); % Calcul de l'amplitude
        Imax1 = Imax1 + indices(j+1);
        [Min2,Imin2] = min(kine.angle_elevation(indices(j+2):indices(j+3),:));
        Imin2 = Imin2 + indices(j+2);
        kine.amplitude(v,:) =abs(Min1 - Max1);
        kine.amplitude(v+1,:) =abs(Min2 - Max1); 
        kine.MD1(v,:) = Imax1-Imin1;
        kine.MD1(v+1,:) = Imin2-Imax1;
        v=v+2;
    end

    v=1; %%% Méthodes 5%
%     try
%         figure;
    for j=2:nb_pics
        a = indices(j); b = indices(j);
        while (vitesse(a, 1) > Seuil*vitesse(indices(j)))
            a = a-1;
        end
        while (vitesse(b, 1)> Seuil*vitesse(indices(j)))
            b = b+1;
        end
        kine.Debut_Fin(v,1) = a;
        kine.Debut_Fin(v,2) = b;
        kine.amplitude2(v,:) =abs(kine.angle_elevation(a,:)-kine.angle_elevation(b,:)); 
        kine.MD2(v,:) = b-a; v=v+1;
%         hold on; plot(vitesse_3D(a:b)) 
    end
%     catch
%         disp("Problème méthode 5%")
%     end

end
 
                
                