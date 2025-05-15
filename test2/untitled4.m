% Генерация 16-QAM сигнала
M = 16; % 16-QAM
data = qammod(randi([0 M-1], 1000, 1), M, 'UnitAveragePower', true);

% Искусственное ограничение (имитация clipping)
data_clipped = data;
data_clipped(abs(data) > 0.8) = 0.8 * exp(1i * angle(data(abs(data) > 0.8)));

% Построение созвездия
figure;
subplot(1,2,1);
scatter(real(data), imag(data), 'filled');
title('Идеальное 16-QAM');
axis([-1.5 1.5 -1.5 1.5]); grid on;

subplot(1,2,2);
scatter(real(data_clipped), imag(data_clipped), 'filled');
title('16-QAM с Clipping');
axis([-1.5 1.5 -1.5 1.5]); grid on;