classdef BaseStation < handle
    properties
        ID
        ConnectedSubscribers % Список подключенных абонентов (объекты Subscriber)
        Coordinate %lla coordinates
        
    end
    
    methods
        function obj = BaseStation(id)
            obj.ID = id;
            obj.ConnectedSubscribers = Subscriber.empty(); % Инициализация пустым массивом
            obj.Coordinate = zeros(1, 2);
        end
        
        %function registerSubscriber(obj, subscriber)
        %    % Проверяем, есть ли абонент уже в списке
        %    if ~any([obj.ConnectedSubscribers.ID] == subscriber.ID)
        %        obj.ConnectedSubscribers(end + 1) = subscriber;
        %        fprintf('Абонент с ID %d подключен к базовой станции %d.\n', subscriber.ID, obj.ID);
        %    else
        %        fprintf('Абонент с ID %d уже подключен!\n', subscriber.ID);
        %    end
        %end
        
        function removeSubscriber(obj, subscriber)
            idx = find([obj.ConnectedSubscribers.ID] == subscriber.ID);
            if ~isempty(idx)
                obj.ConnectedSubscribers(idx) = [];
                fprintf('Абонент с ID %d отключен.\n', subscriber.ID);
            end
        end
        
        function logSubscribers(obj)
            fprintf('Базовая станция %d имеет абонентов:\n', obj.ID);
            for sub = obj.ConnectedSubscribers
                fprintf(' - Абонент %d\n', sub.ID);
            end
        end
    end
end