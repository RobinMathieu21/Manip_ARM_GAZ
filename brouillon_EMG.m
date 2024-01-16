
k=6
SUJ = 3;
plot(Donnees(SUJ).EMG(k).RMS(:,1));hold on;

for j =1:length(Donnees(SUJ).kinematics(k).Debut_fin(:,1))
    debutEMG = 10*(Donnees(SUJ).kinematics(k).Clics(1,k)+Donnees(SUJ).kinematics(k).Debut_fin(:,1));
    finEMG = 10*(Donnees(SUJ).kinematics(k).Clics(1,k)+Donnees(SUJ).kinematics(k).Debut_fin(:,2));
    y = ylim; % current y-axis limits
    x = xlim; % current y-axis limits
    plot([debutEMG debutEMG],[y(1) y(2)],'r'); hold on; % debut mvt 1
    plot([finEMG finEMG],[y(1) y(2)],'b'); hold on; % fin mvt 1
end


for sujet=1:13
    plot(Donnees(sujet).MeanParamV(10:end,2)); hold on;
end