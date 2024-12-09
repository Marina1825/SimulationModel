function [data_complex] = process_data(data_raw)
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
    drawnow;
end