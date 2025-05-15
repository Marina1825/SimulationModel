clear java;
javaaddpath('/home/marina/4_curs/jeromq-0.6.0/target/jeromq-0.6.0.jar')

import org.zeromq.ZMQ.*;
import org.zeromq.*;

port_api = 2111;
context = ZMQ.context(1);
socket_api_proxy = context.socket(ZMQ.REP);
socket_api_proxy.bind(sprintf('tcp://*:%d', port_api));

global pauseFlag;
pauseFlag = false;
col = 0;

clear java;
% Добавляем JAR-библиотеку ZeroMQ в classpath Java
javaaddpath('/home/marina/4_curs/jeromq-0.6.0/target/jeromq-0.6.0.jar')

% Импортируем необходимые классы ZeroMQ
import org.zeromq.ZMQ.*;
import org.zeromq.*;

% Настройка порта и сокета ZeroMQ
port_api = 2111;
context = ZMQ.context(1);
socket_api_proxy = context.socket(ZMQ.REP);
socket_api_proxy.bind(sprintf('tcp://*:%d', port_api));

col = 0; % Счетчик сообщений

while true
    if col == 50
        break; % Выход после 50 сообщений
    end
    
    % Получение сообщения
    msg = socket_api_proxy.recv();
    out_data = msg;
    
    if ~isempty(msg)
        fprintf('Получено сообщение [%d байт]\n', length(msg));
        
        % Обработка первых 16 байт (порт)
        msg_port = msg(1:16);
        msg_port = msg_port';
        msg_port = typecast(int8(msg_port), 'uint8');
        msg_port = typecast(msg_port, 'int16');
        msg_port = msg_port(1:2:end);
        disp(msg_port);
        
        if(length(msg) > 1000)
            % Обработка основного сообщения
            msg = msg(17:end);
            [Srx,SrxCH, data_complex] = process_data(msg);

            % Подготовка данных для отправки
            data = zeros(1, length(Srx));
            data_single = single(data);
            Rpart = real(data_single);
            IMpart = imag(data_single);
            floatArray = zeros(1, 2*length(data_single));
            floatArray(1:2:end) = Rpart;
            floatArray(2:2:end) = IMpart;
            out_data = typecast(single(floatArray), 'uint8');

            col = col + 1; % Увеличение счетчика
        end
        
        % Отправка ответа
        socket_api_proxy.send(msg);
    end
end

function [multipath_signal, costhata_signal, orig_signal] = process_data(data_raw)
    data = data_raw / 1.5;
    fs = 23040000;
    f0 = 1e6;
    fprintf("size data: %d\n", length(data_raw));
    data_slice = data_raw;
    I = double(data_slice(1:2:end));
    Q = double(data_slice(2:2:end));
    complexArray = complex(I, Q);
    data_complex = complexArray(1:128*180);
    fprintf("size complex data: %d\n", length(data_complex));
    cla;
    
    % Обработка данных через каналы
    [Srx, D] = transmission_channel(data_complex);
    SrxCH = transmission_channel1(data_complex, D);

    %# производим преобразование фурье и транспонируем матрицу для удобного вывода на карте
    %data2 = np.fft.fft(data1).T

    orig_signal = fft(data_complex, [], 2);
    multipath_signal = fft(Srx, [], 2).';
    costhata_signal = fft(SrxCH, [], 2).';
    len_frame = 140;
    Nfft = 6;
    cp = 8;
    title_str = 'DIFFT';


    resource_grid(data_complex, Srx, SrxCH, length(16384), len_frame, Nfft, cp, title_str);
    
    % Выбор первых 128 точек для анализа
    %sample_range = 1:128;
    %orig_signal = data_complex(sample_range);
    %multipath_signal = Srx(sample_range);
    %costhata_signal = SrxCH(sample_range);

    
    
    % 1. Временные области
    %figure(1);
    %subplot(1, 3, 1);
    %plot(abs(orig_signal));
    %title('Амплитуда: оригинал');
    %xlabel('Отсчеты');
    %ylabel('Амплитуда');
    
    %subplot(1, 3, 2);
    %plot(abs(multipath_signal));
    %title('Амплитуда: многолучевость');
    %xlabel('Отсчеты');
    
    %subplot(1, 3, 3);
    %plot(abs(costhata_signal));
    %title('Амплитуда: многолучевость+CostHata');
    %xlabel('Отсчеты');
    
    

    % 2. Фазовый шум в полярных координатах
    figure(2);
    subplot(1, 3, 1);
    polarplot(angle(orig_signal), abs(orig_signal), 'o');
    title('Фазовый шум: оригинал (полярные)');
    
    subplot(1, 3, 2);
    polarplot(angle(multipath_signal), abs(multipath_signal), 'o');
    title('Фазовый шум: многолучевость (полярные)');
    
    subplot(1, 3, 3);
    polarplot(angle(costhata_signal), abs(costhata_signal), 'o');
    title('Фазовый шум: многолучевость+CostHata (полярные)');
    
    figure(1);
    subplot(1, 3, 1);
    scatter(real(orig_signal(:)), imag(orig_signal(:)), 'filled');
    grid on;
    xlabel('Реальная часть');
    ylabel('Мнимая часть');
    title('Оригинальный сигнал+DFFT');
    axis ([-150 150 -150 150]);

    subplot(1, 3, 2);
    scatter(real(multipath_signal(:)), imag(multipath_signal(:)), 'filled');
    grid on;
    xlabel('Реальная часть');
    ylabel('Мнимая часть');
    title('Многолучевость+DFFT');
    axis ([-150 150 -150 150]);

    subplot(1, 3, 3);
    scatter(real(costhata_signal(:)), imag(costhata_signal(:)), 'filled');
    grid on;
    xlabel('Реальная часть');
    ylabel('Мнимая часть');
    title('Многолучевость+CostHata+DFFT');
    axis ([-150 150 -150 150]);
    % 3. Сравнение фаз
    %figure(3);
    %subplot(1, 1, 1);
    %plot(angle(orig_signal));
    %hold on;
    %plot(angle(multipath_signal));
    %plot(angle(costhata_signal));
    %title('Сравнение фаз');
    %legend('Оригинал', 'Многолучевость', 'CostHata');
    %xlabel('Отсчеты');
    %ylabel('Фаза (рад)');
    
    % 4. DFFT сравнение
    %figure(4);
    %subplot(1, 1, 1);
    %plot(abs(fft(orig_signal)));
    %hold on;
    %plot(abs(fft(multipath_signal)));
    %%plot(abs(fft(costhata_signal)));
    %title('DFFT сравнение');
    %legend('Оригинал', 'Многолучевость', 'CostHata');
    %xlabel('Частота');
    %ylabel('Амплитуда');
    
    % 5. Сравнение амплитуд
    %figure(5);
    %%subplot(1, 1, 1);
    %plot(abs(orig_signal));
    %hold on;
    %plot(abs(multipath_signal));
    %plot(abs(costhata_signal));
    %title('Сравнение амплитуд');
    %legend('Оригинал', 'Многолучевость', 'CostHata');
    %xlabel('Отсчеты');
    %ylabel('Амплитуда');
    
    drawnow;
end

function resource_grid(data, Srx, SrxCH, count_frames, len_frame, Nfft, cp, title_str)
    % Параметры:
    %   data        - данные для ресурсной сетки
    %   count_frame - количество OFDM фреймов для ресурсной сетки
    %   len_frame   - количество OFDM-символов в OFDM фрейме
    %   Nfft        - количество поднесущих
    %   cp          - защитный префикс
    %   title_str   - необязательный заголовок графика (по умолчанию пустая строка)
    
    if nargin < 6
        title_str = "";
    end
    
    % Обрезаем данные до нужного количества фреймов
    data1 = data(1:(Nfft+cp)*len_frame*count_frames);
    data2 = Srx(1:(Nfft+cp)*len_frame*count_frames);
    data3 = SrxCH(1:(Nfft+cp)*len_frame*count_frames);
    
    % Преобразуем в матрицу
    data_freq = reshape(data1, (Nfft+cp), len_frame*count_frames).';
    data_freq2 = reshape(data2, (Nfft+cp), len_frame*count_frames).';
    data_freq3 = reshape(data3, (Nfft+cp), len_frame*count_frames).';
    
    % Обрезаем циклический префикс
    data1 = data_freq(:, cp+1:end);
    data2 = data_freq2(:, cp+1:end);
    data3 = data_freq3(:, cp+1:end);
    
    % Производим преобразование Фурье и транспонируем матрицу
    data21 = fft(data1, [], 2).';
    data22 = fft(data2, [], 2).';
    data23 = fft(data3, [], 2).';
    
    % Центрируем спектр
    data21 = fftshift(data21, 1);
    data22 = fftshift(data22, 1);
    data23 = fftshift(data23, 1);
    
    % Создаем график
    figure(4);
    imagesc(abs(data21));
    colormap('jet');
    title(title_str);
%    label('OFDM symbol');
    ylabel('Subcarriers');
    colorbar;
    axis xy; % Ось Y направлена вверх (низкие частоты внизу)

    figure(3);
    subplot(1, 3, 1);
    scatter(real(data21(:)), imag(data21(:)), 'filled');
    grid on;
    xlabel('Реальная часть');
    ylabel('Мнимая часть');
    title('Оригинальный сигнал+DFFT');
    axis ([-150 150 -150 150]);

    subplot(1, 3, 2);
    scatter(real(data22(:)), imag(data22(:)), 'filled');
    grid on;
    xlabel('Реальная часть');
    ylabel('Мнимая часть');
    title('Многолучевость+DFFT');
    axis ([-150 150 -150 150]);

    subplot(1, 3, 3);
    scatter(real(data23(:)), imag(data23(:)), 'filled');
    grid on;
    xlabel('Реальная часть');
    ylabel('Мнимая часть');
    title('Многолучевость+CostHata+DFFT');
end

function draw(data_complex)

    subplot(2, 1, 1);
    x_t = 1:length(data_complex);
    plot(x_t, data_complex);
    title('Данные в временной области');
    xlabel('Отсчеты');
    ylabel('Амплитуда');

    drawnow;

end

function [Srx,D] = transmission_channel(ofdm_symb)
    Nv = 10;
    L = length(ofdm_symb);
    B = 9*10^6;
    Ts = 1/B;
    c = 3 * 10^8;
    D = randi([10, 300], 1, Nv);
    t = zeros(1, Nv)
    fs = 23040000;

    [~, idx_min] = min(D);
    D = [D(idx_min) , D(1:idx_min-1), D(idx_min+1:end)];
    
    for i = 1:Nv
        t(i)=(D(i)-D(1))/(c*Ts);
        t(i)=round(t(i));
    end
        
    S = zeros(Nv,L+max(t));%сигнальный вектор
    Stx = ofdm_symb;%сигнал из передатчика
    for i = 1:Nv
        for k =  1:(L+t(i))
            if k<= t(i)
                S(i, k) = complex(0,0);
            elseif k>t(i)
                S(i, k) = Stx(k-t(i));
            end
        end
    end
    %G = zeros(1, Nv);%затухание
    %for i = 1:Nv
    %    G(i)=c/(4*pi*D(i)*fs);
    %end
    
    Smpy = [];%выходной сигнал
    
    for i = 1:Nv
        for k = 1:(L+t(i))
            Smpy(i, k) = S(i, k);%i);
        end
    end
        
    Smpy = sum(Smpy,1);
    Srx = [];%сигнал на приемникке
    n = [];%АБГШ
    M = length(Smpy);%длинна вектора сигнала и шума = длина вектора сигнала
    N0 = -150;%?????
    n = transpose(wgn(M, 1, N0));
    Srx = Smpy+n;
end

function [Srx] = transmission_channel1(ofdm_symb, D)
    Nv = 10;%количество лучей
    L = length(ofdm_symb);%длинная сигнала
    B = 9*10^6;%полоса инф сигнала
    Ts = 1/B;%длительность дискретного отсчета
    c = 3 * 10^8;%скорость света
    %D = randi([10, 300], 1, Nv);%длина луча м потом будем рандомить Nv раз
    t = zeros(1, Nv);%задержка
    fs = 23040000;%несущая
    O = [];
    [~, idx_min] = min(D);
    D = [D(idx_min) , D(1:idx_min-1), D(idx_min+1:end)];
    
    for i = 1:Nv
        t(i)=(D(i)-D(1))/(c*Ts);
        t(i)=round(t(i));
        O(i) = OH(D(i));
    end
        
    S = zeros(Nv,L+max(t));%сигнальный вектор
    Stx = ofdm_symb;%сигнал из передатчика
    for i = 1:Nv
        for k =  1:(L+t(i))
            if k<= t(i)
                S(i, k) = complex(0,0);
            elseif k>t(i)
                S(i, k) = Stx(k-t(i));
            end
        end
    end
    %G = zeros(1, Nv);%затухание
    %for i = 1:Nv
    %    G(i)=c/(4*pi*D(i)*fs);
    %end
    
    Smpy = [];%выходной сигнал
    
    for i = 1:Nv
        for k = 1:(L+t(i))
            Smpy(i, k) = S(i, k)-O(i);%*G(i)-O(i);
        end
    end
        
    Smpy = sum(Smpy,1);
    Srx = [];%сигнал на приемникке
    n = [];%АБГШ
    M = length(Smpy);%длинна вектора сигнала и шума = длина вектора сигнала
    N0 = -150;%?????
    n = transpose(wgn(M, 1, N0));
    Srx = Smpy+n;
end

function [L] = OH(d)
    % Расчет потерь сигнала по модели COST 231 Hata
    fc = 2560; % Частота в МГц
    hte = 50; % Высота передающей антенны в метрах
    hre = 1.5; % Высота приемной антенны в метрах
    %d = 100; % Расстояние между передатчиком и приемником в километрах 1км+ 2км+ 3км+ 5км+ 100км-
    Cm = 0; % Поправочный коэффициент для средних городов и пригородов
    
    % Расчет поправочного коэффициента для высоты приемной антенны
    a_hre = (1.1 * log10(fc) - 0.7) * hre - (1.56 * log10(fc) - 0.8);
    
    % Расчет потерь сигнала
    L = 46.3 + 33.9 * log10(fc) - 13.82 * log10(hte) - a_hre + (44.9 - 6.55 * log10(hte)) * log10(d) + Cm;
end