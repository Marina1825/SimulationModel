frequency = 2.3e9;
%port_api = 2110;
%pauseFlag = false;
%latitude = [];
%longitude = [];
Rays_tx = [];


addpath('/home/marina/system_level_simulation/MatLab_Marina/map');

filename = '5.osm';
buildings = readgeotable(filename,Layer="buildingparts");
buildings.Shape;

Rays = [];

uniqueMaterials = unique(buildings.Material);

materials = ["","brick","concrete","glass","metal","plaster"]; 
colors = ["#c9c9c9","#870b0b","#424242","#9baceb","#543987","#ff8c90"];
dict = dictionary(materials,colors)

numBuildings = height(buildings);
for n = 1:numBuildings
    material = buildings.Material(n);
    buildings.Color(n) = dict(material);
end


viewer = siteviewer(Basemap="openstreetmap",Buildings=buildings);
viewer.Materials;
dom = xmlread(filename);

latitude = zeros(1, 2);
longitude = zeros(1, 2);

rx = rxsite("Latitude",55.013792,...%78
            "Longitude",82.949042,...%114
            "AntennaHeight",0);

% Define transmitter site at MathWorks (3 Apple Hill Dr, Natick, MA)
tx = txsite("Name", "NAME", ...
    "Latitude",55.013335, ...
    "Longitude",82.950685, ...
    "AntennaHeight",20, ...        % Units: meters
    "TransmitterFrequency",frequency, ... % Units: Hz
    "TransmitterPower",20);        % Units: Watts


pm = propagationModel("raytracing", ...
    'MaxNumReflections', 10);  % Например, 2.6 ГГц (типично для LTE)

rays_tx = raytrace(tx,rx,pm);
rays_tx = rays_tx{1};

show(tx)
show(rx)
plot(rays_tx)
D = zeros(1, length(rays_tx));
phase_shifts_rad = zeros(1, length(rays_tx));

Rays_tx = zeros(2, length(rays_tx));
for i = 1:length(rays_tx)
    Rays_tx(1, i) = rays_tx(1, i).PhaseShift;  % Доступ через ячейку
    phase_shifts_rad(1, i) = rays_tx(1, i).PhaseShift;
    Rays_tx(2, i) = rays_tx(1, i).PropagationDistance;
    D (i) = rays_tx(1, i).PropagationDistance;
end

disp(Rays_tx);

z = [3 + 4i, 3 - 4i, -3 + 4i, -3 - 4i];  

Nv = length(rays_tx);
L = length(z);
B = 9*10^6;
Ts = 1/B;
c = 3 * 10^8;
t = zeros(1, Nv)
fs = 23040000;

[~, idx_min] = min(D);
D = [D(idx_min) , D(1:idx_min-1), D(idx_min+1:end)];

for i = 1:Nv
    t(i)=(D(i)-D(1))/(c*Ts);
    t(i)=round(t(i));
end
    
S = zeros(Nv,L+max(t));%сигнальный вектор
Stx = z;%сигнал из передатчика
for i = 1:Nv
    for k =  1:(L+t(i))
        if k<= t(i)
            S(i, k) = complex(0,0);
        elseif k>t(i)
            S(i, k) = Stx(k-t(i));
        end
    end
end


Smpy = [];%выходной сигнал

for i = 1:Nv
    for k = 1:(L+t(i))
        Smpy(i, k) = S(i, k);
    end
end
Srx_tran_ch = sum(Smpy,1);

fc = 23.04; % Частота в МГц
hte = tx.AntennaHeight; % Высота передающей антенны в метрах
hre = rx.AntennaHeight; % Высота приемной антенны в метрах
d = D; % Расстояние между передатчиком и приемником в километрах 1км+ 2км+ 3км+ 5км+ 100км-
Cm = 0; % Поправочный коэффициент для средних городов и пригородов

% Расчет поправочного коэффициента для высоты приемной антенны
L = [];
    
for i = 1:Nv 
    a_hre = (1.1 * log10(fc) - 0.7) * hre - (1.56 * log10(fc) - 0.8);
    PL = 46.3 + 33.9 * log10(fc) - 13.82 * log10(hte) - a_hre + (44.9 - 6.55 * log10(hte)) * log10(d(i)) + Cm;
    for k = 1:length(Smpy)
        Smpy_L(i, k) = Smpy(i, k) * 10^(-PL / 20);  % Для комплексных чисел (I/Q);
    end
end
%%% вызов шума потерь и фазового сдвига
Srx_PL = sum(Smpy_L,1);

z_shifted = zeros(length(Smpy_L), length(phase_shifts_rad));
for i = 1:length(Nv)
    for j = 1:length(Smpy_L)
    z_shifted(i, j) = Smpy_L(i, j) * exp(1i * phase_shifts_rad(1, j));
end

% Переводим градусы в радианы
%phase_shifts_rad = [0.523598775598299, 0.785398163397448, 0.872664625997165, 1.04719755119660];%deg2rad(phase_shifts_deg);  
% Переводим градусы в радианы
for i = 1:Nv 
    % Создаем график для каждого луча
    % Построение оригинальных значений z
    figure;
    subplot(2,1,1);
    scatter(real(z), imag(z), 'filled');
    title('Оригинальные значения z');
    xlabel('Real часть');
    ylabel('Imaginary часть');
    grid on;
    hold on;
    % Добавление подписей точек
    for i = 1:length(z)
        text(real(z(i)), imag(z(i)), sprintf('z%d', i), 'VerticalAlignment','bottom');
    end
    hold off;

    % Построение фазово-сдвинутых значений
    subplot(2,1,2);
    hold on;
    %colors = ['r', 'g', 'b', 'm']; % Цвета для разных лучей
    for ray = 1:size(z_shifted, 2)
        scatter(real(z_shifted(:, ray)), imag(z_shifted(:, ray)), [], 'filled');%colors(ray), 'filled');
    end
    title('Фазово-сдвинутые значения (4 луча по 18 точек)');
    xlabel('Real часть');
    ylabel('Imaginary часть');
    grid on;
    legend('Луч 1', 'Луч 2', 'Луч 3', 'Луч 4');
    hold off;
end