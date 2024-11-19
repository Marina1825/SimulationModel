buildings = readgeotable("map2.osm", Layer="buildingparts");
buildings.Shape

uniqueMaterials = unique(buildings.Material);

materials = ["","brick","concrete","copper","glass","metal","plaster","stone"]; 
colors = ["#D3D3D3","#AA4A44","#D3D3D3","#B87333","#35707E","#151513","#FFFFFF","#301934"];
dict = dictionary(materials, colors);

% Добавляем пустую строку для дефолтного цвета
defaultColor = "#D3D3D3";

numBuildings = height(buildings);
for n = 1:numBuildings
    material = buildings.Material(n);
    if isKey(dict, material)
        buildings.Color(n) = dict(material);
    else
        buildings.Color(n) = defaultColor;
    end
end

viewer = siteviewer(Buildings=buildings);