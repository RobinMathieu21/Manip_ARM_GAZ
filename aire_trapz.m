function [aire] = aire_trapz(depart, arrive, Y)
%AIRE_TRAPZ compute area under the curve between 'depart' and 'arrive'

aire = abs(trapz(Y(depart:arrive)));

end
