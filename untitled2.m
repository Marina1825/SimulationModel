% Чтение данных из файла
fid = fopen('output (copy).bin', 'rb');
if fid == -1
    error('Не удалось открыть файл output.bin');
end
data_raw = fread(fid, 'int16');
fclose(fid);

% Преобразование данных
data = data_raw / 1.5;
fs = 23040000;
f0 = 1e6;

fprintf("Размер исходных данных: %d\n", length(data_raw));

% Разделение на I и Q компоненты
I = double(data(1:2:end));
Q = double(data(2:2:end));

% Создание комплексного массива
complexArray = complex(I, Q);
data_complex = complexArray(1:min(128*180, end));

%fprintf("Размер комплексных данных: %d\n", length(data_complex));

% Параметры для моделей распространения
freq = 2.68e9;    % Частота в МГц (1.5-2 ГГц для Cost231-Hata)
hb = 20;        % Высота БС в метрах
hm = 1.5;       % Высота МС в метрах
distances = linspace(0.1, 20, 0.1); % Расстояния в км (0.1-20 км)

% Расчет потерь для разных моделей
cost231_urban = arrayfun(@(d) cost231_hata(freq, hb, hm, d, 'urban'), distances);
cost231_suburban = arrayfun(@(d) cost231_hata(freq, hb, hm, d, 'suburban'), distances);
cost231_rural = arrayfun(@(d) cost231_hata(freq, hb, hm, d, 'rural'), distances);

lee_urban = arrayfun(@(d) lee_model(freq, hb, hm, d, 'urban'), distances);
lee_suburban = arrayfun(@(d) lee_model(freq, hb, hm, d, 'suburban'), distances);

okumura = arrayfun(@(d) okumura_model(freq, hb, hm, d), distances);
walfisch = arrayfun(@(d) walfisch_model(freq, hb, hm, d), distances);




% Чтение данных из файла
filename = 'received_data.txt';
try
    complex_data = read_complex_data(filename);
catch ME
    if strcmp(ME.identifier, 'MATLAB:FileIO:InvalidFid')
        fprintf('Файл %s не найден!\n', filename);
        return;
    else
        fprintf('Ошибка при чтении файла: %s\n', ME.message);
        return;
    end
end

% Примеры расчетов моделей
freq = 900;  % МГц
hb = 50;     % м
hm = 1.5;    % м

w = 20;      % м (для Walfisch-Ikegami)
b = 30;      % м (для Walfisch-Ikegami)
phi = 45;    % градусов (для Walfisch-Ikegami)

d = linspace(0.1, 10, 100);

% Вычисление потерь для всех моделей
PL_cost_urban = arrayfun(@(x) cost_231_hata(freq, hb, hm, x, 'urban'), d);
PL_cost_suburban = arrayfun(@(x) cost_231_hata(freq, hb, hm, x, 'suburban'), d);
PL_cost_open = arrayfun(@(x) cost_231_hata(freq, hb, hm, x, 'open'), d);

PL_lee_urban = arrayfun(@(x) lee_model(freq, hb, hm, x, 'urban'), d);
PL_lee_suburban = arrayfun(@(x) lee_model(freq, hb, hm, x, 'suburban'), d);
PL_lee_open = arrayfun(@(x) lee_model(freq, hb, hm, x, 'open'), d);

PL_okumura_urban = arrayfun(@(x) okumura_model(freq, hb, hm, x, 'urban'), d);
PL_okumura_suburban = arrayfun(@(x) okumura_model(freq, hb, hm, x, 'suburban'), d);
PL_okumura_open = arrayfun(@(x) okumura_model(freq, hb, hm, x, 'open'), d);

PL_walfisch = arrayfun(@(x) walfisch_ikegami_model(freq, hb, hm, x, w, b, phi), d);

% Построение графиков
figure;

% График для модели Cost 231-Hata
subplot(2, 2, 1);
plot(d, PL_cost_urban, 'b', 'LineWidth', 2);
hold on;
plot(d, PL_cost_suburban, 'g', 'LineWidth', 2);
plot(d, PL_cost_open, 'r', 'LineWidth', 2);
hold off;
title('Cost 231-Hata Model');
xlabel('Расстояние (км)');
ylabel('Потери распространения (dB)');
legend('Urban', 'Suburban', 'Open', 'Location', 'northwest');
grid on;

% График для модели Lee
subplot(2, 2, 2);
plot(d, PL_lee_urban, 'b', 'LineWidth', 2);
hold on;
plot(d, PL_lee_suburban, 'g', 'LineWidth', 2);
plot(d, PL_lee_open, 'r', 'LineWidth', 2);
hold off;
title('Lee Model');
xlabel('Расстояние (км)');
ylabel('Потери распространения (dB)');
legend('Urban', 'Suburban', 'Open', 'Location', 'northwest');
grid on;

% График для модели Okumura
subplot(2, 2, 3);
plot(d, PL_okumura_urban, 'b', 'LineWidth', 2);
hold on;
plot(d, PL_okumura_suburban, 'g', 'LineWidth', 2);
plot(d, PL_okumura_open, 'r', 'LineWidth', 2);
hold off;
title('Okumura Model');
xlabel('Расстояние (км)');
ylabel('Потери распространения (dB)');
legend('Urban', 'Suburban', 'Open', 'Location', 'northwest');
grid on;

% График для модели Walfisch-Ikegami
subplot(2, 2, 4);
plot(d, PL_walfisch, 'm', 'LineWidth', 2);
title('Walfisch-Ikegami Model');
xlabel('Расстояние (км)');
ylabel('Потери распространения (dB)');
grid on;

% Общий график для сравнения всех моделей (urban)
figure;
plot(d, PL_cost_urban, 'b', 'LineWidth', 2);
hold on;
plot(d, PL_lee_urban, 'g', 'LineWidth', 2);
plot(d, PL_okumura_urban, 'r', 'LineWidth', 2);
plot(d, PL_walfisch, 'm', 'LineWidth', 2);
hold off;
title('Сравнение моделей (Urban)');
xlabel('Расстояние (км)');
ylabel('Потери распространения (dB)');
legend('Cost 231-Hata', 'Lee', 'Okumura', 'Walfisch-Ikegami', 'Location', 'northwest');
grid on;


function data_complex = read_complex_data(filename)
    % Чтение данных из файла и преобразование в комплексные числа
    fileID = fopen(filename, 'r');
    first_line = fgetl(fileID);
    fclose(fileID);
    
    % Разбиваем строку по запятым и преобразуем в числа
    data_raw = str2double(strsplit(first_line, ','));
    data_raw = data_raw(~isnan(data_raw));  % Удаляем NaN значения
    
    % Преобразование данных согласно алгоритму
    data = data_raw / 1.5;
    fs = 23040000;
    f0 = 1e6;
    
    fprintf('size data: %d\n', length(data_raw));
    
    data_slice = data_raw;
    I = data_slice(1:2:end);  % Нечетные элементы (индексы 1, 3, 5...)
    Q = data_slice(2:2:end);  % Четные элементы (индексы 2, 4, 6...)
    
    complexArray = I + 1j * Q;
    data_complex = complexArray(1:128*180);
    
    fprintf('size complex data: %d\n', length(data_complex));
end

function L = cost_231_hata(freq, hb, hm, d, area_type)
    % Модель Cost 231-Hata
    % freq: частота в МГц (1500-2000 МГц)
    % hb: высота антенны БС (30-200 м)
    % hm: высота антенны МС (1-10 м)
    % d: расстояние (км)
    % area_type: 'urban', 'suburban', 'open'
    
    if nargin < 5
        area_type = 'urban';
    end
    
    a_hm = (1.1 * log10(freq) - 0.7) * hm - (1.56 * log10(freq) - 0.8);
    L = 46.3 + 33.9 * log10(freq) - 13.82 * log10(hb) - a_hm + (44.9 - 6.55 * log10(hb)) * log10(d);
    
    if strcmp(area_type, 'suburban')
        L = L - 2 * (log10(freq/28))^2 + 5.4;
    elseif strcmp(area_type, 'open')
        L = L - 4.78 * (log10(freq))^2 + 18.33 * log10(freq) - 40.94;
    end
end

function L = lee_model(freq, hb, hm, d, area_type)
    % Модель Lee
    % freq: частота в МГц
    % hb: высота антенны БС (м)
    % hm: высота антенны МС (м)
    % d: расстояние (км)
    % area_type: 'urban', 'suburban', 'open'
    
    if nargin < 5
        area_type = 'urban';
    end
    
    % Базовые значения для urban area
    L0 = 89.5;  % потери на 1 милю (1.609 км) для 900 МГц
    gamma = 3.84;  % коэффициент затухания
    
    % Коррекция для частоты
    L0 = L0 + 20 * log10(freq / 900);
    
    % Коррекция для высот антенн
    L0 = L0 - 10 * log10(hb / 30);
    L0 = L0 - 20 * log10(hm / 2);
    
    % Коррекция для типа местности
    if strcmp(area_type, 'suburban')
        L0 = L0 - 8;
    elseif strcmp(area_type, 'open')
        L0 = L0 - 28;
    end
    
    % Расчет полных потерь
    L = L0 + 10 * gamma * log10(d / 1.609);
end

function L = okumura_model(freq, hb, hm, d, area_type)
    % Модель Okumura
    % freq: частота в МГц (150-1920 МГц)
    % hb: высота антенны БС (30-200 м)
    % hm: высота антенны МС (1-10 м)
    % d: расстояние (км)
    % area_type: 'urban', 'suburban', 'open'
    
    if nargin < 5
        area_type = 'urban';
    end
    
    % Основные потери в свободном пространстве
    Lfs = 32.45 + 20 * log10(freq) + 20 * log10(d);
    
    % Поправка Okumura
    Amu = 0;
    if freq >= 150 && freq <= 1920
        % Для urban area
        Amu = 69.55 + 26.16 * log10(freq) - 13.82 * log10(hb) - (3.2 * (log10(11.75 * hm))^2 - 4.97);
        
        if strcmp(area_type, 'suburban')
            Amu = Amu - 2 * (log10(freq/28))^2 + 5.4;
        elseif strcmp(area_type, 'open')
            Amu = Amu - 4.78 * (log10(freq))^2 + 18.33 * log10(freq) - 40.94;
        end
    end
    
    L = Lfs + Amu - 13.82 * log10(hb) - (3.2 * (log10(11.75 * hm))^2 - 4.97);
end

function L = walfisch_ikegami_model(freq, hb, hm, d, w, b, phi)
    % Модель Walfisch-Ikegami
    % freq: частота в МГц (800-2000 МГц)
    % hb: высота антенны БС (4-50 м)
    % hm: высота антенны МС (1-3 м)
    % d: расстояние (км)
    % w: ширина улицы (м)
    % b: расстояние между зданиями (м)
    % phi: угол улицы относительно направления на БС (градусы)
    
    L0 = 42.6 + 26 * log10(d) + 20 * log10(freq);
    
    Lrts = -16.9 - 10 * log10(w) + 10 * log10(freq) + 20 * log10(hb - hm) + 2.5 + 0.075 * (phi - 35);
    
    Lori = -10 + 0.354 * phi;
    
    Lbsh = 0;
    if hb > hb
        Lbsh = -18 * log10(1 + (hb - hm));
    end
    
    L = L0 + Lrts + Lori + Lbsh;
end