


%  if length(Donnees(1).Kinematics(1).Param(:,1) )>39
% 
%  end

% VERTI

 a=1;
 for aaaa=1:20
     if aaaa == 4 || aaaa == 13 || aaaa == 14 || aaaa == 16 || aaaa == 19 || aaaa == 20
     else
         for kkkkk=5:8
            len = min(length(nonzeros(Donnees(aaaa).Kinematics(kkkkk).Param(:,1))),length(nonzeros(Donnees(aaaa).Kinematics(kkkkk).Param(:,11))));
            VV = nonzeros(Donnees(aaaa).Kinematics(kkkkk).Param(2:len,1))-nonzeros(Donnees(aaaa).Kinematics(kkkkk).Param(2:len,11));

            minus(:,a) = normalize2(VV, 'spline', 60)

%             plot(minus(a)); hold on;
            a=a+1;
         end
     end
 end

for f=1:60
    MEANA(f,1) = mean(minus(f,:));
    MEANA(f,2) = mean(minus(f,:)) + std(minus(f,:))/sqrt(15);
    MEANA(f,3) = mean(minus(f,:)) - std(minus(f,:))/sqrt(15);
end




% 
%  % HORI
%  figure;
%  for aaaa=1:24
%      if aaaa == 12 || aaaa == 20
%      else
%          for kkkkk=5:8
%             plot(Donnees(aaaa).Kinematics(kkkkk).Param(:,1)); hold on;
%          end
%      end
%  end