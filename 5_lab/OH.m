function process_data(data_raw)
    fs = 23040000;
    fprintf("size data: %d\n", length(data_raw));
    data_slice = data_raw;
    floatArray = typecast(uint8(data_slice), 'single');
    complexArray = complex(floatArray(1:2:end), floatArray(2:2:end));
    data_complex = complexArray(1:128*180);
    fprintf("size complex data: %d\n", length(data_complex));
    cla;
    window = 128;    
    noverlap = 0; 
    nfft = 128;      
    if any(isnan(data_complex))
        data_complex(isnan(data_complex)) = 0;
    end
    subplot(2, 2, 1);
    x_t = 1:length(data_complex);
    plot(x_t, data_complex);
    title('Данные в временной области');
    xlabel('Отсчеты');
    ylabel('Амплитуда');
    subplot(2, 2, 2);
    spectrogram(data_complex, window, noverlap, nfft, fs, 'yaxis');
    title('Спектрограмма переданных данных');
    xlabel('Время (сек)');
    ylabel('Частота (Гц)');
    colorbar;
    grid on;
    
    % Расчет потерь сигнала по модели COST 231 Hata
    fc = 900; % Частота в МГц
    hte = 50; % Высота передающей антенны в метрах
    hre = 1.5; % Высота приемной антенны в метрах
    d = 5; % Расстояние между передатчиком и приемником в километрах
    Cm = 0; % Поправочный коэффициент для средних городов и пригородов
    
    % Расчет поправочного коэффициента для высоты приемной антенны
    a_hre = (1.1 * log10(fc) - 0.7) * hre - (1.56 * log10(fc) - 0.8);
    
    % Расчет потерь сигнала
    L = 46.3 + 33.9 * log10(fc) - 13.82 * log10(hte) - a_hre + (44.9 - 6.55 * log10(hte)) * log10(d) + Cm;
    
    % Вывод результата
    subplot(2, 2, 3);
    text(0.5, 0.5, sprintf('Потери сигнала: %.2f дБ', L), 'HorizontalAlignment', 'center', 'FontSize', 14);
    title('Потери сигнала по модели COST 231 Hata');
    axis off;
    
    drawnow;
end