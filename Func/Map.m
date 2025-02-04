function [latitude, longitude] = Map()

    addpath('/home/marina/4_curs/SimulationModel/Func/map');

    osmFile = '1.osm';

    viewer = siteviewer(Basemap="openstreetmap",Buildings=osmFile);
    dom = xmlread(osmFile);

    latitude = zeros(1, 2);
    longitude = zeros(1, 2);

    % Извлечение данных из тега <bounds>
    bounds = dom.getElementsByTagName('bounds').item(0);
    latitude(1,1) = str2double(bounds.getAttribute('minlat'));%широта
    latitude(1,2) = str2double(bounds.getAttribute('maxlat'));
    longitude(1,1) = str2double(bounds.getAttribute('minlon'));%долгот
    longitude(1,2) = str2double(bounds.getAttribute('maxlon'));

    % Вывод bounds
    fprintf('Bounds:\n');
    fprintf('minlat = %.7f, minlon = %.7f\n', latitude(1,1), longitude(1,1));
    fprintf('maxlat = %.7f, maxlon = %.7f\n', latitude(1,2), longitude(1,2));
    
end