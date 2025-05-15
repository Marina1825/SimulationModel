osmFile = '1.osm';
    % Чтение файла .osm
dom = xmlread(osmFile);

    % Извлечение данных из тега <bounds>
bounds = dom.getElementsByTagName('bounds').item(0);
minlat = str2double(bounds.getAttribute('minlat'));
minlon = str2double(bounds.getAttribute('minlon'));
maxlat = str2double(bounds.getAttribute('maxlat'));
maxlon = str2double(bounds.getAttribute('maxlon'));

    % Вывод bounds
fprintf('Bounds:\n');
fprintf('minlat = %.7f, minlon = %.7f\n', minlat, minlon);
fprintf('maxlat = %.7f, maxlon = %.7f\n', maxlat, maxlon);


homo =  zeros(2, 1);