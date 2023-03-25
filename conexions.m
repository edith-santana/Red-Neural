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
vector = 1:1:numero;
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
    for i=1:length(neuronas)
        if neuronas(i) == r(i)
            x = setdiff(1:numero,neuronas(i),'stable');
            r(i) = x(randi(numel(x)));
        end
    end
    cuenta = histc(r,[1:1:numero]);
    k = find(cuenta<eferencias);
    for i=1:length(k)
     faltan(i) = eferencias - nnz(cuenta(k(i)));
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