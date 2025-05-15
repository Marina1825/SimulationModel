clear java;
javaaddpath('/home/marina/4_curs/jeromq-0.6.0/target/jeromq-0.6.0.jar')

import org.zeromq.ZMQ.*;
import org.zeromq.*;

port_api = 2110;
context = ZMQ.context(1);
socket_api_proxy = context.socket(ZMQ.REP);
socket_api_proxy.bind(sprintf('tcp://*:%d', port_api));

global pauseFlag;
pauseFlag = false;
col = 0;

while true

    if col == 50;
        break;
    end
    msg = socket_api_proxy.recv();
    out_data = msg;
    if ~isempty(msg)
        fprintf('received message [%d]\n', length(msg));
        msg_port = msg(1:16);
        msg_port = msg_port';
        msg_port = typecast(int8(msg_port), 'uint8');
        msg_port = typecast(msg_port, 'int16');
        msg_port = msg_port(1:2:end);
        disp(msg_port);
        if(length(msg) > 1000)
            msg = msg(17:end);
            [Srx,SrxCH, data_complex] = process_data(msg);

            data = zeros(1, length(Srx));
             
            data_single = single(data);
            Rpart = real(data_single);
            IMpart = imag(data_single);
            floatArray = zeros(1, 2*length(data_single));
            floatArray(1:2:end) = Rpart;
            floatArray(2:2:end) = IMpart;
            out_data = typecast(single(floatArray), 'uint8');

            col =col +1;
        end
        socket_api_proxy.send(msg);
    end
end

function togglePause()
    global pauseFlag;
    pauseFlag = ~pauseFlag;
end

function [Srx, SrxCH, data_complex] = process_data(data_raw)

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
    %draw(data_complex)
    subplot(1, 3, 1);
    x_t = 1:length(data_complex);
    plot(x_t, data_complex);
    title('Данные в временной области оригинальные');
    xlabel('Отсчеты');
    ylabel('Амплитуда');

    [Srx, D] = transmission_channel(data_complex)
    
    subplot(1, 3, 2);
    x_t = 1:length(Srx);
    plot(x_t, Srx);
    title('Данные в временной области после многолучевости');
    xlabel('Отсчеты');
    ylabel('Амплитуда');
    
    SrxCH = transmission_channel1(data_complex, D)

    subplot(1, 3, 3);
    x_t = 1:length(SrxCH);
    plot(x_t, SrxCH);
    title('Данные в временной области после многолучевости и CostHata');
    xlabel('Отсчеты');
    ylabel('Амплитуда');
    drawnow;
    %draw(Srx)

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

    
    Smpy = [];%выходной сигнал
    
    for i = 1:Nv
        for k = 1:(L+t(i))
            Smpy(i, k) = S(i, k);
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
    
    Smpy = [];%выходной сигнал
    
    for i = 1:Nv
        for k = 1:(L+t(i))
            Smpy(i, k) = S(i, k)-O(i);
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