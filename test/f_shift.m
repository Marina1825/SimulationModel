% Исходный массив комплексных чисел
z = [3 + 4i, 3 - 4i, -3 + 4i, -3 - 4i];  

% Углы сдвига для каждой "отправки" (в градусах)
% phase_shifts_deg = [30, 45, 50, 60];  

% Переводим градусы в радианы
phase_shifts_rad = [0.523598775598299, 0.785398163397448, 0.872664625997165, 1.04719755119660];%deg2rad(phase_shifts_deg);  

% Создаем 3D-массив для хранения всех сдвинутых версий:
% z_shifted(i, j) = j-й сдвиг i-го числа из z
z_shifted = zeros(length(z), length(phase_shifts_rad));
for i = 1:length(z)
    z_shifted(i, :) = z(i) * exp(1i * phase_shifts_rad);
end

% Создаем график
figure;
hold on;
grid on;
axis equal;

% Оси
plot([-5, 5], [0, 0], 'k-', 'LineWidth', 0.5); % Ось X
plot([0, 0], [-5, 5], 'k-', 'LineWidth', 0.5); % Ось Y

% Цвета и маркеры
colors = ['r', 'g', 'b', 'm'];  % Цвета для разных сдвигов
markers = ['o', 's', 'd', '^']; % Маркеры для исходных чисел

% Рисуем исходные точки (черные)
for i = 1:length(z)
    plot(real(z(i)), imag(z(i)), ...
        markers(i), 'Color', 'k', 'MarkerSize', 10, ...
        'MarkerFaceColor', 'k', ...
        'DisplayName', sprintf('Исходное z%d', i));
end

% Рисуем сдвинутые точки
for i = 1:length(z)           % Для каждого исходного числа
    for j = 1:length(phase_shifts_rad)  % Для каждого сдвига
        plot(real(z_shifted(i, j)), imag(z_shifted(i, j)), ...
            markers(i), 'Color', colors(j), 'MarkerSize', 8, ...
            'MarkerFaceColor', colors(j), ...
            'DisplayName', sprintf('z%d, сдвиг %d°', i, phase_shifts_rad(j)));
    end
end

% Легенда (показываем только уникальные элементы)
hLeg = legend('Location', 'eastoutside');
set(hLeg, 'FontSize', 8);

% Подписи
xlabel('Re(z)');
ylabel('Im(z)');
title('Фазовые сдвиги для массива комплексных чисел');
xlim([-6, 6]);
ylim([-6, 6]);

hold off;