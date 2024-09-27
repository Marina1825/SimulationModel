%viewer = siteviewer;
%viewer = siteviewer(Basemap="openstreetmap",Buildings="map2.osm");

% Координатные границы map2
a1 = 54.971937;
a2 = 54.995294;
b1 = 82.857335;
b2 = 82.899661;
% homo - Пользователи, baza - базовые станции, dista - дистанции
homo =  zeros(1000, 2);
baza = zeros(19, 2);
distance = zeros(1000, 19);

for i = 1:1000
    homo(i, 1) = a1 + (a2 - a1) * rand();
    homo(i, 2) = b1 + (b2 - b1) * rand();
    %a = homo(i, 1);
    %b = homo(i, 2);
    %Tx = txsite("Latitude",a,...
    %   "Longitude",b,...
    %   "AntennaHeight",20);
    %show(Tx)
end

for i = 1:19
    baza(i, 1) = a1 + (a2 - a1) * rand();
    baza(i, 2) = b1 + (b2 - b1) * rand();
    %a = baza(i, 1);
    %b = baza(i, 2);
    %Rx = txsite("Latitude",a,...
    %   "Longitude",b,...
    %   "AntennaHeight",50);
    %show(Rx)
end

for i = 1:19
    for j = 1:1000
        distance(j, i) = sqrt((baza(i, 1) - homo(j, 1))^2 + (baza(i, 2) - homo(j, 2))^2);
    end
end
