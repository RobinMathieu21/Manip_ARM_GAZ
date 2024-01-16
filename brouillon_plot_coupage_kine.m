


figure;
plot(Data.Kinematics(8).data.vitesse  ); hold on;
% plot(Data.Kinematics(8).data.vitesse)
y = ylim; % current y-axis limits
x = xlim; % current y-axis limits

l = length(Data.Kinematics(8).data.Debut_Fin);
deb = Data.Kinematics(8).data.Debut_Fin;
g = 0;%Data.Clics(1,8);
for a=1:l
    plot([g + deb(a,1) g + deb(a,1)],[y(1) y(2)],'r'); hold on; % debut mvt 1
    plot([g + deb(a,2) g + deb(a,2)],[y(1) y(2)],'b'); hold on; % fin mvt 1
end