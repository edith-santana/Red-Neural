clear all
close 
clc

numero = 90;
[r,neuronas] = topologia(numero,3,4);
pares = [neuronas',r'];
pares = sortrows(pares,1);
tamano = 1:1:numero;
excitadoras = sort(tamano(randperm(length(tamano), 50)));
inhibidoras = setdiff(tamano,excitadoras,'stable');

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

Color = [Color; 0 1 0]

Color2 = zeros([length(neuronas) 3]);
for i=1:length(a)
    Color2(a(i),:) = [1 0 0];
end

for i=1:length(b)
    Color2(b(i),:) = [0 0 1];
end

for i=0:4
    Color2(end-i,:) = [0 1 0]
end
%Color(a,:) = [1 0 0];
%Color(b,:) = [0 0 1];
G = digraph(neuronas,r);
c = plot(G,'NodeColor',Color,'EdgeColor',Color2);
%highlight(c,b,'NodeColor','b')


function [r,neuronas] = topologia(numero,aferencias,eferencias) %La función genera la topología de la red 
vector = 1:1:numero; %vector de 1 fila, y numero de columnas igual al del número de neuronas deseadas 
neuronas = vector;
i = 1;
while i<aferencias
    neuronas=horzcat(neuronas,vector);
    i = i+1;
end
r = randi(numero,size(neuronas));
[r,neuronas] = contar(neuronas,numero,r,eferencias);
end

function [r,neuronas] = contar(neuronas,numero,r,eferencias) %Revisamos que las condiciones de aferencias y eferencias se cumplan
    for i=1:length(neuronas) % se va a comparar elemento a elemento de r con los de neurona
        if neuronas(i) == r(i) % si la neurona pre (neuronas) y la post (r) son la misma, se le asigna un valor distinto de neurona postsinaptica
            x = setdiff(1:numero,neuronas(i),'stable'); %si sí se cumple la condición, de obtiene un vector con los numeros de neuronas a los cuales sí se puede conectar la neurona presinaptica 
            r(i) = x(randi(numel(x))); %se le asigna un nuevo numero de neurona postsinaptica a la presinaptica
        end
    end
    cuenta = histc(r,[1:1:numero]);%cuenta el numero de veces que cada
    % número de neurona aparece en el vector de neuronas postsinapticas,
    % y este numero sería el numero de AFERENCIAS que ese
    % numero de neurona recibe 
    k = find(cuenta<eferencias); %busca los indices en donde los elementos de cuenta son menores a los de eferencias deseadas
    for i=1:length(k)
        faltan(i) = eferencias - nnz(cuenta(k(i))); %saca el numero de eferencias faltantes
    end
    for i=1:length(faltan)
         for j=1:faltan(i)
                x = setdiff(1:numero,k(i),'stable');
                neuronas = [neuronas,x(randi(numel(x)))];
                r = [r,k(i)];
         end
    end
        for i=1:5
            x = setdiff(1:numero,neuronas(i),'stable');
            neuronas = [neuronas numero+1];
            r = [r,randi(numero)];
        end
end