function [] = UE_eNB(latitude, longitude)
    global UE;%5    
    global eNB;%2

    % homo - Пользователи, baza - базовые станции, dista - дистанции
    homo =  zeros(UE, 2);
    baza = zeros(eNB, 2);
    distance = zeros(UE, eNB);

    for i = 1:UE
        homo(i, 1) = latitude(1,1) + (latitude(1,2) - latitude(1,1)) * rand();
        homo(i, 2) = longitude(1,1) + (longitude(1,2) - longitude(1,1)) * rand();
        a = homo(i, 1);
        b = homo(i, 2);
        Rx = rxsite("Latitude",a,...
                    "Longitude",b,...
                    "AntennaHeight",20);
        show(Rx)
    end

    for i = 1:eNB
        baza(i, 1) = latitude(1,1) + (latitude(1,2) - latitude(1,1)) * rand();
        baza(i, 2) = longitude(1,1) + (longitude(1,2) - longitude(1,1)) * rand();
        a = baza(i, 1);
        b = baza(i, 2);
        Rx = txsite("Latitude",a,...
                    "Longitude",b,...
                    "AntennaHeight",50);
        show(Rx)
    end

    for i = 1:length(eNB)
        for j = 1:length(UE)
            distance(j, i) = sqrt((baza(i, 1) - homo(j, 1))^2 + (baza(i, 2) - homo(j, 2))^2);
        end
    end
end