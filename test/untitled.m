% Открываем файл для чтения
fileID = fopen('received_message.txt', 'r');
if fileID == -1
    error('Не удалось открыть файл для чтения.');
end

% Читаем данные из файла
decode_message = fread(fileID, '*ubit1'); % Чтение данных как битов (0 и 1)
fclose(fileID); % Закрываем файл после чтения
disp(decode_messageЫ);
% Преобразование бинарных данных в ASCII
Transform_BIN_ASCII = 0;
ASCII_decoder = [];
for i = 1:8:length(decode_message)
    Degree = 0;
    for j = 1:8
        Transform_BIN_ASCII = Transform_BIN_ASCII + decode_message(i+j-1) * 2^(Degree);
        Degree = Degree + 1;
    end
    ASCII_decoder = cat(2, ASCII_decoder, Transform_BIN_ASCII); % Исправлено: добавление в конец массива
    Transform_BIN_ASCII = 0;
    Degree = 0;
end

% Преобразование числовых значений ASCII в символы
SMS_decoder = char(ASCII_decoder);

% Вывод расшифрованного сообщения
disp('Расшифрованное сообщение:');
disp(SMS_decoder);
