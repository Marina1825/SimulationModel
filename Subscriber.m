classdef Subscriber < handle
    properties
        ID
        ConnectedBaseStation % Ссылка на базовую станцию
        Coordinate
    end
    
    methods
        function obj = Subscriber(id)
            obj.ID = id;
            obj.ConnectedBaseStation = [];
            obj.Coordinate = zeros(1, 2);
        end
        
        function connectToBaseStation(obj, baseStation)
            if isempty(obj.ConnectedBaseStation)
                obj.ConnectedBaseStation = baseStation;
                baseStation.registerSubscriber(obj); % Регистрируем абонента на станции
            else
                fprintf('Абонент %d уже подключен к станции %d!\n', obj.ID, obj.ConnectedBaseStation.ID);
            end
        end
        
        function disconnectFromBaseStation(obj)
            if ~isempty(obj.ConnectedBaseStation)
                obj.ConnectedBaseStation.removeSubscriber(obj);
                obj.ConnectedBaseStation = [];
            end
        end
    end
end