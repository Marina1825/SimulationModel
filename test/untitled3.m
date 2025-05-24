% Создание просмотрщика сайтов с базовой картой и зданиями
viewer = siteviewer(Basemap="openstreetmap", Buildings="map2.osm");

% Координатные границы map2
a1 = 54.971937;
a2 = 54.995294;
b1 = 82.857335;
b2 = 82.899661;

% homo - Пользователи, dista - дистанции
homo = zeros(5, 2);
distance = zeros(1000, 19);

% Создание начальных позиций пользователей
Rx = cell(1, 5); % Инициализация массива ячеек для хранения объектов rxsite
for i = 1:5
    homo(i, 1) = a1 + (a2 - a1) * rand();
    homo(i, 2) = b1 + (b2 - b1) * rand();
    a = homo(i, 1);
    b = homo(i, 2);
    Rx{i} = rxsite("Latitude", a, "Longitude", b, "AntennaHeight", 20);
    show(Rx{i});
end

% Анимация передвижения пользователей
numSteps = 10; % Количество шагов анимации
for step = 1:numSteps
    for i = 1:5
        % Генерация новых координат для пользователя
        newLat = homo(i, 1) + (a2 - a1) * (rand() - 0.5) / 50;
        newLon = homo(i, 2) + (b2 - b1) * (rand() - 0.5) / 50;
        
        % Обновление координат пользователя
        homo(i, 1) = newLat;
        homo(i, 2) = newLon;
        
        % Обновление позиции пользователя на карте
        Rx{i}.Latitude = newLat;
        Rx{i}.Longitude = newLon;
        show(Rx{i}); % Обновление позиции пользователя на карте
    end
    
    % Задержка для плавности анимации
    pause(0.1);
end