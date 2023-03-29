clear all
close 
clc

numero = 40; %Número total de neuronas (sin incluir inicial)
num_excitadoras = 25; %Número de neuronas excitadoras
num_inhibidoras = 15; %Número de neuronas inhibidoras
num_aferencias = 2;  %Las que llegan
num_eferencias = 3; %Las que salen
numtipos = 4; %Número de tipos de neuronas
I0 = 10; % Corriente aplicada a la neurona inicial (pA)

[eferencias,neuronas,pares,excitadoras,inhibidoras] = trazar(numero,num_eferencias,num_aferencias,num_excitadoras,num_inhibidoras);


[Color,Color2] = Colorear(excitadoras,inhibidoras,neuronas,eferencias,pares,numero);
G = digraph(neuronas,eferencias);
c = plot(G,'NodeColor',Color,'EdgeColor',Color2);
title('Topología de la Red')


function [eferencias,neuronas,pares,excitadoras,inhibidoras] = trazar(numero,num_eferencias,num_aferencias,num_excitadoras,num_inhibidoras) %La función genera las conexiones de la red 
vector = 1:1:numero;
neuronas = vector;
i = 1;
while i<num_eferencias
    neuronas=horzcat(neuronas,vector);
    i = i+1;
end
eferencias = randi(numero,size(neuronas));
[eferencias,neuronas,pares,excitadoras,inhibidoras] = correccion(neuronas,numero,eferencias,num_aferencias,num_excitadoras,num_inhibidoras);
end

function [eferencias,neuronas,pares,excitadoras,inhibidoras] = correccion(neuronas,numero,eferencias,aferencias,num_excitadoras,num_inhibidoras) %Revisamos que las condiciones de eferencias y aferencias se cumplan
%BUSQUEDA Y CORRECCION DE REPETICIONES EN LAS CONEXIONES
pares =[neuronas',eferencias']; %Creamos una matriz con los pares (origen y destino de la conexion)
[u,I,J] = unique(pares, 'rows', 'first'); %Se encuentran las combinaciones únicas
hasDuplicates = size(u,1) < size(pares,1); %Se determina si existen duplicados o no
ixDupRows = setdiff(1:size(pares,1), I); %Se encuentra los indices de las conexiones repetidas
dupRowValues = pares(ixDupRows,:); %Se especifican las conexiones repetidas
for i=1:size(dupRowValues,1)
    neuronarep = dupRowValues(i,1); %Buscamos el origen de la conexion repetida
    posiciones = find(neuronas == neuronarep); %Encontramos los indices de dicha neurona
    ubirepeticion = find(ismember(pares,dupRowValues(i,:),'rows')); %Obtenemos el indice de la conexion que se repite
    excluir = [neuronarep]; %Primero excluimos a la neurona de origen para evitar que se conecte consigo misma
    for j=1:length(posiciones)
        excluir = [excluir eferencias(posiciones(j))]; %Excluimos las conexiones de la misma neurona para evitar una nueva repetición
    end
    for j=1:size(ubirepeticion,1)-1 %Nos deshacemos de las repeticiones
           x = setdiff(1:numero,excluir,'stable'); %Se obtiene un vector con los posibles valores nuevos
           random = x(randi(numel(x))); %se selecciona uno al azar
           eferencias(ubirepeticion(j)) = random; %Se sustituye el valor repetido
           excluir = [excluir random]; %Excluimos el nuevo valor para que no se produzca otra repeticion
    end
end
% % pares2 = [neuronas',eferencias'];
% % isequal(pares,pares2);
% % [u,I,J] = unique(pares2, 'rows', 'first');
% % hasDuplicates2 = size(u,1) < size(pares2,1)
% % ixDupRows = setdiff(1:size(pares2,1), I);
% % dupRowValues = pares(ixDupRows,:)

%CORRECCION DE LA CONEXION DE LA NEURONA CONSIGO MISMA
    for i=1:length(neuronas)
        if neuronas(i) == eferencias(i) %Buscamos aquellas conexiones donde la neurona conecta a si misma
            excluir = neuronas(i); %Excluimos dicho valor
            ubicaciones = find(neuronas == neuronas(i)); %Encontramos el resto de conexiones de dicha neurona
            for j=1:length(ubicaciones)
                excluir = [excluir eferencias(ubicaciones(j))]; %Excluimos conexiones para evitar nuevas repeticiones
            end
            x = setdiff(1:numero,excluir,'stable'); %Generamos el vector con todos los valores posibles 
            eferencias(i) = x(randi(numel(x))); %Se selecciona un valor aleatorio
        end
    end

% % % pares2 = [neuronas',eferencias'];
% % % isequal(pares,pares2);
% % % [u,I,J] = unique(pares2, 'rows', 'first');
% % % hasDuplicates2 = size(u,1) < size(pares2,1)
% % % ixDupRows = setdiff(1:size(pares2,1), I);
% % % dupRowValues = pares2(ixDupRows,:)   

%CREACION DE LAS eferencias FALTANTES
    cuenta = histc(eferencias,[1:1:numero]); %Realizamos la cuenta de las aferencias de cada neurona
    k = find(cuenta<aferencias); %Se busca aquellas neuronas que no cumplen con la condición de aferencias
    for i=1:length(k)
     faltan(i) = aferencias - nnz(cuenta(k(i))); %Valor faltante de aferencias
    end
    for i=1:length(faltan)
        excluir = k(i); %Excluimos la propia neurona para evitar auto conexiones
        ubicaciones = find(eferencias == k(i)); %Encontramos el resto de conexiones de dicha neurona
        for j=1:length(ubicaciones)
             excluir = [excluir neuronas(ubicaciones(j))];%Excluimos conexiones para evitar nuevas repeticiones
        end
     for j=1:faltan(i)
            x = setdiff(1:numero,excluir,'stable'); %Conjunto de valores posibles
            random = x(randi(numel(x))); %Selección de valor aleatorio
            neuronas = [neuronas random]; %Se añade el valor
            excluir = [excluir random]; %Se excluye el valor añadido para la siguiente iteración
            eferencias = [eferencias,k(i)]; %Se añade una conexión más para satisfacer la condición de aferencias
     end
    end

% pares2 = [neuronas',eferencias'];
% isequal(pares,pares2);
% [u,I,J] = unique(pares2, 'rows', 'first');
% hasDuplicates2 = size(u,1) < size(pares2,1)
% ixDupRows = setdiff(1:size(pares2,1), I);
% dupRowValues = pares2(ixDupRows,:);

[excitadoras,inhibidoras,pares] = sortear(numero,num_excitadoras,num_inhibidoras,neuronas,eferencias);

%GENERACION DE LA NEURONA GATILLO Y SUS eferencias
excluir = [];
        for i=1:5 %La neurona gatillo tiene 5 eferencias
            x = setdiff(excitadoras,excluir,'stable'); %Excluimos los valores ya utilizados para evitar repeticiones
            random = x(randi(numel(x))); %Seleccionamos un valor aleatorio
            neuronas = [neuronas numero+1]; %Añadimos el origen de la conexion
            eferencias = [eferencias,random]; %Destino de la conexion
            excluir = [excluir random]; %Se excluye valor para evitar repeticion
        end
pares = [neuronas',eferencias']
pares=sortrows(pares,1);

% % pares2 = [neuronas',eferencias'];
% % isequal(pares,pares2);
% % [u,I,J] = unique(pares2, 'rows', 'first');
% % hasDuplicates2 = size(u,1) < size(pares2,1)
% % ixDupRows = setdiff(1:size(pares2,1), I);
% % dupRowValues = pares2(ixDupRows,:);
end

function [Color,Color2] = Colorear(excitadoras,inhibidoras,neuronas,eferencias,pares,numero)

a = [];
b = [];
for i=1:length(excitadoras)
    a = [a,find(pares(:,1)' == excitadoras(i))];
end
for i=1:length(inhibidoras)
    b = [b,find(pares(:,1)' == inhibidoras(i))];
end

Color = zeros([numero 3]);
for i=1:length(excitadoras)
    Color(excitadoras(i),:) = [1 0 0];
end

for i=1:length(inhibidoras)
    Color(inhibidoras(i),:) = [0 0 1];
end

Color = [Color; 0 1 0];

Color2 = zeros([length(neuronas) 3]);
for i=1:length(a)
    Color2(a(i),:) = [1 0 0];
end

for i=1:length(b)
    Color2(b(i),:) = [0 0 1];
end

for i=0:4
    Color2(end-i,:) = [0 1 0];
end
%Color(a,:) = [1 0 0];
%Color(b,:) = [0 0 1];

%highlight(c,b,'NodeColor','b')
%iguales = unique(pares,'rows')

end

function [excitadoras,inhibidoras,pares] = sortear(numero,num_excitadoras,num_inhibidoras,neuronas,eferencias)
pares = [neuronas',eferencias'];
pares = sortrows(pares,1);
tamano = 1:1:numero;
excitadoras = sort(tamano(randperm(length(tamano), num_excitadoras)));
inhibidoras = setdiff(tamano,excitadoras,'stable');
%tiponeurona = randi(numtipos,[1 numero]);
end