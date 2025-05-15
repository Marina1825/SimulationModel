function [data_complex] = process_data(data_raw, filename)
    % Обработка данных и сохранение в файл
    % data_raw - входные данные
    % filename - имя файла для сохранения (необязательный параметр)
    
    % Обработка данных
    data = data_raw / 1.5;
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
    
    % Запись в файл, если указано имя файла
    if nargin > 1 && ~isempty(filename)
        try
            % Открытие файла для записи (создаст новый или перезапишет существующий)
            fileID = fopen(filename, 'w');
            if fileID == -1
                error('Не удалось создать файл %s', filename);
            end
            
            % Запись данных в файл (в бинарном формате)
            fwrite(fileID, data_complex, 'single');
            
            % Закрытие файла
            fclose(fileID);
            fprintf('Данные успешно записаны в файл: %s\n', filename);
        catch ME
            warning('Ошибка при записи в файл: %s', filename);
            % Закрытие файла в случае ошибки (если он был открыт)
            if exist('fileID', 'var') && fileID ~= -1
                fclose(fileID);
            end
        end
    end
end

