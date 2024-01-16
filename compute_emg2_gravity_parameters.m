%% Fonction qui permet à partir des signaux traités (RMS) de computer le phasique

function [EMG_phasique, tonic_meanstd, norm_tonic_R_moy ] = compute_emg2_gravity_parameters(RMS, emg_low_pass_Freq, ...
 emg_frequency, tonic_debut, tonic_fin, Idx)   

EMG_phasique = {};
tonic_meandstd = {};
anticip_pre = Idx.anticip_pre;
anticip_post = Idx.anticip_post;
dureebas = Idx.dureebas;
dureehaut = Idx.dureehaut;
EMD = Idx.EMD;

%On coupe les matrices en 2 pour avoir les essais sur une direction

RMS_R = RMS(:,:);

tonic_debut_R = tonic_debut(:,:);

tonic_fin_R = tonic_fin(:,:);
    


% On moyenne les signaux RMS bruts et normalisés en durée

% Les profils sont normalisés en durée avant d'être moyennés. On prend la
% taille moyenne des essais



% On crée une matrice des RMS moyennées lissées
RMS_R_moy_smooth = butter_emgs(RMS_R, emg_frequency,  5, emg_low_pass_Freq, 'low-pass', 'false', 'centered'); % RMS_R par RMS_moy

% On crée une matrice des tonics moyennés et lissés

% tonic_debut_R_moy_smooth = butter_emgs(tonic_debut_R, emg_frequency,  5, emg_low_pass_Freq, 'low-pass', 'false', 'centered');
% tonic_fin_R_moy_smooth = butter_emgs(tonic_fin_R, emg_frequency,  5, emg_low_pass_Freq, 'low-pass', 'false', 'centered');

% On calcule maintenant la moyenne et l'écart type des siganux
% tonics non-lissés

% tonics_R_meanstd = zeros(4, col_rms);
tonics_R_meanstd(1, :) = mean(tonic_debut_R, 'omitnan');
tonics_R_meanstd(2, :) = mean(tonic_fin_R, 'omitnan');
tonics_R_meanstd(3, :) = std(tonic_debut_R, 'omitnan');
tonics_R_meanstd(4, :) = std(tonic_fin_R, 'omitnan');



% On normalise les tonics pour avoir le même nombre de frames que sur la RMS_cut




norm_tonic_R_moy(anticip_pre-EMD+1:dureebas-anticip_post-EMD, 1) = normalize2(tonics_R_meanstd(1:2, 1), 'PCHIP', dureebas-anticip_post-anticip_pre);

for g = 1:anticip_pre-EMD
    norm_tonic_R_moy(g, 1) = norm_tonic_R_moy(anticip_pre-EMD+1, 1); % Pour le début 
end
% plot(norm_tonic_R_moy)

for g = 1:anticip_post+EMD
    norm_tonic_R_moy(dureebas-g+1, 1) = norm_tonic_R_moy(dureebas-anticip_post-EMD, 1);   % Pour la fin     
end
    

norm_tonic_R_norm = normalize2(norm_tonic_R_moy, 'PCHIP', 1000);
    
% On calcule le phasique sur le non lissé

emg_phasique_R_NORM = RMS_R - norm_tonic_R_norm;

% On normalise les signaux sur 1000 frames

% [~,col_o]=size(emg_phasique_R_avantNorm);
% for i=1:col_o
%     len = length(RMS_R(:,i));
%     emg_phasique_R(:,i) = normalize2(emg_phasique_R_avantNorm(1:profil_sizes_R(1, i),i), 'PCHIP', 1000);
%     RMS_R_moy_Norm(:,i) = normalize2(RMS_R_moy_smooth(1:profil_sizes_R(1, i),i), 'PCHIP', 1000);
% end

% Et sur le lissé

emg_phasique_R_smooth = butter_emgs(emg_phasique_R_NORM, emg_frequency,  5, emg_low_pass_Freq, 'low-pass', 'false', 'centered');


    
    EMG_phasique.nonsmooth.brut.R = emg_phasique_R_NORM;
    
    EMG_phasique.smooth.R = emg_phasique_R_smooth;

    tonic_meanstd.R = norm_tonic_R_norm;
    


