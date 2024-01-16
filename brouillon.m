for i =1:length(ListeFichier)
    for k=1:4
        Idx = {};
        Idx.EMD = EMD*emg_frequency;
        Idx.anticip = anticip*emg_frequency;

        [EMG_traite.DA_bas, Tonic.DA, Profil_tonic_R.DA, ] = compute_emg2_gravity_parameters(Donnees(i).EMG(k+4).RMSCUT.DA_bas, ...
          emg_low_pass_Freq, emg_frequency, Donnees(i).EMG(k+4).TONIC_debut.DA_bas, Donnees(i).EMG(k+4).TONIC_fin.DA_bas, Idx);
        Donnees(i).EMG(k+4).Phasic.DA_bas=EMG_traite.DA_bas.nonsmooth.brut.R;  

        [EMG_traite.DA_bas, Tonic.DA, Profil_tonic_R.DA, ] = compute_emg2_gravity_parameters(Donnees(i).EMG(k+4).RMSCUT.DA_haut, ...
          emg_low_pass_Freq, emg_frequency, Donnees(i).EMG(k+4).TONIC_debut.DA_haut, Donnees(i).EMG(k+4).TONIC_fin.DA_haut, Idx);
        Donnees(i).EMG(k+4).Phasic.DA_haut=EMG_traite.DA_haut.nonsmooth.brut.R;  

    end
end