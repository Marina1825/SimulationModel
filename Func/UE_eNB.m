function [distance] = UE_eNB(latitude, longitude)
    global UE;    
    global eNB;
    R = 6371;
    lat1 = 0;
    lon1 = 0;
    lat2 = 0;
    lon2 = 0;

    % homo - Пользователи, baza - базовые станции, dista - дистанции
    homo =  zeros(1, 2);
    baza = zeros(1, 2);
    distance = zeros(1, 1);

    for i = 1:1
        homo(i, 1) = latitude(1,1) + (latitude(1,2) - latitude(1,1)) * rand();
        homo(i, 2) = longitude(1,1) + (longitude(1,2) - longitude(1,1)) * rand();
        a = homo(i, 1);
        lon1 = deg2rad(a);
        b = homo(i, 2);
        lon2 = deg2rad(b);
        UE.Coordinate = [a, b];
        Rx = rxsite("Latitude",a,...
                    "Longitude",b,...
                    "AntennaHeight",20);
        show(Rx)
    end

    for i = 1:1
        baza(i, 1) = latitude(1,1) + (latitude(1,2) - latitude(1,1)) * rand();
        baza(i, 2) = longitude(1,1) + (longitude(1,2) - longitude(1,1)) * rand();
        a = baza(i, 1);
        lat1 = deg2rad(a);
        b = baza(i, 2);
        lat2 = deg2rad(b);
        eNB.Coordinate = [a, b];
        Rx = txsite("Latitude",a,...
                    "Longitude",b,...
                    "AntennaHeight",50);
        show(Rx)
    end

    % Разница широт и долгот
    dlat = lat2 - lat1;
    dlon = lon2 - lon1;

    % Формула гаверсинусов
    a = sin(dlat/2)^2 + cos(lat1) * cos(lat2) * sin(dlon/2)^2;
    c = 2 * atan2(sqrt(a), sqrt(1-a));

    % Расстояние
    distance = R * c;
end