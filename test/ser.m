%% Параметры системы
fs = 10000;         % Частота дискретизации (Гц)
T = 1;              % Длительность (с)
t = 0:1/fs:T-1/fs;  % Временная шкала
fc = 50;            % Частота несущей (Гц)
N_bits = 1000;      % Число бит
N_symbols = N_bits/2; % Число символов QPSK
phase_shift = pi/6; % Фазовый сдвиг 30° для второго сигнала

%% 1. Генерация данных и QPSK модуляция
bit_stream = randi([0 1], 1, N_bits);
symbol_indices = reshape(bit_stream, 2, [])';
symbols = bi2de(symbol_indices, 'left-msb')';

% Фазовые точки (Gray coding)
phase_map = [pi/4, 3*pi/4, 5*pi/4, 7*pi/4]; 

% Основной сигнал
rho = ones(1, N_symbols);
theta = phase_map(symbols + 1);
tx_symbols = rho .* exp(1j*theta);

% Сигнал со сдвигом фазы
theta_shifted = mod(theta + phase_shift, 2*pi); % Добавляем сдвиг и нормализуем
tx_symbols_shifted = rho .* exp(1j*theta_shifted);

%% 2. Визуализация созвездий
figure;
subplot(1,2,1);
polarplot(theta, rho, 'o', 'MarkerSize', 8, 'LineWidth', 2);
hold on;
polarplot(theta_shifted, rho, 'x', 'MarkerSize', 8, 'LineWidth', 2);
title('Сравнение созвездий');
legend('Исходный', ['Сдвиг ' num2str(rad2deg(phase_shift)) '°'], 'Location', 'southoutside');
rlim([0 1.5]);

% Гистограмма фаз
subplot(1,2,2);
polarhistogram(theta, 36, 'FaceColor', 'b', 'FaceAlpha', 0.5);
hold on;
polarhistogram(theta_shifted, 36, 'FaceColor', 'r', 'FaceAlpha', 0.5);
title('Распределение фаз');
legend('Исходный', 'Со сдвигом');

%% 3. Формирование сигналов во временной области
upsample_factor = fs/(N_symbols/T);
rrc_filter = rcosdesign(0.35, 10, upsample_factor, 'sqrt');

% Фильтрация основного сигнала
tx_baseband = upsample(tx_symbols, upsample_factor);
tx_filtered = conv(tx_baseband, rrc_filter, 'same');

% Фильтрация сдвинутого сигнала
tx_baseband_shifted = upsample(tx_symbols_shifted, upsample_factor);
tx_filtered_shifted = conv(tx_baseband_shifted, rrc_filter, 'same');

%% 4. Визуализация во временной области
figure;
subplot(2,1,1);
plot(t, real(tx_filtered), 'b', t, real(tx_filtered_shifted), 'r--');
title('Сравнение I-компонент');
xlabel('Время (с)'); ylabel('Амплитуда');
legend('Исходный', 'Со сдвигом');
grid on;

subplot(2,1,2);
phase_diff = angle(tx_filtered .* conj(tx_filtered_shifted));
plot(t, unwrap(phase_diff));
title('Разность фаз между сигналами');
xlabel('Время (с)'); ylabel('Разность фаз (рад)');
grid on;

%% 5. Анализ фазового сдвига (дополнительно)
figure;
polarplot(angle(tx_filtered(1:100:end)), abs(tx_filtered(1:100:end)), 'b.');
hold on;
polarplot(angle(tx_filtered_shifted(1:100:end)), abs(tx_filtered_shifted(1:100:end)), 'r.');
title('Мгновенные значения в полярных координатах');
legend('Исходный', 'Со сдвигом');
rlim([0 max(abs(tx_filtered))]);