

%estructura con los parámetros de cuatro tipo de respuesta neuronal
ntype=struct;
% tonic spiking 1
ntype.ts.a=0.02; 
ntype.ts.b=0.2;  
ntype.ts.c=-65;  
ntype.ts.d=6;
ntype.ts.V=-70;
ntype.ts.I=14;
%phasic spiking 2
ntype.ps.a=0.02; 
ntype.ps.b=0.25; 
ntype.ps.c=-65;  
ntype.ps.d=6;
ntype.ps.V=-64;
ntype.ps.I=0.5;
%tonic bursting 3
ntype.tb.a=0.02; 
ntype.tb.b=0.2;  
ntype.tb.c=-50;  
ntype.tb.d=2;
ntype.tb.V=-70;
ntype.tb.I=15;
%phasic bursting 4
ntype.pb.a=0.02; 
ntype.pb.b=0.25; 
ntype.pb.c=-55;  
ntype.pb.d=0.05;
ntype.pb.V=-64;
ntype.pb.I=0.6;

t_total=1; %segundos
t_barrido=100;
n_barrido=ceil(t_total/(t_barrido*0.001));
I_Gatillo_nrmlzd=.5;
numero=90;
Vm_general=zeros(numero,n_barrido);
Iouts=zeros(numero,n_barrido);
Iins=zeros(numero,n_barrido);
activaciones=zeros(numero,n_barrido);

% obtenemos cantidad de picos por barrido para cada neurona
fn = fieldnames(ntype);
for i=1:length(fn)
    [vm, v_actual] = evaluar_neurona(ntype.(fn{i}),ntype.(fn{i}).V,t_barrido,1);
    ntype.(fn{i}).n_pks=number_peaks(vm);
end

%asignacion de tipo de respuesta neuronal a las neuronas
nresponse=randperm(90)';
nresponse(1:45,2)=1;
nresponse(1:45,3)=ntype.ts.V;%voltajes de reposo
nresponse(45:90,2)=2;
nresponse(45:90,3)=ntype.ps.V; %voltajes de reposo
nresponse=sortrows( nresponse , 1);
Vm_general(:,1)=nresponse(:,3);

%obtenemos cual será la corriente normalizada proveniente de la neurona 
% gatillo y para cuales neuronas en el primer barrido
pre=91; %es el numero de neurona para la neurona gatillo
Inp_Unit_Neurons=ismember(pares(:,1),pre)*I_Gatillo_nrmlzd;
posts=pares(find(Inp_Unit_Neurons~=0),2);
Iins(posts(:),1)=Nrmlzd_I;

%barrido 1
Nrmlzd_I=I_Gatillo_nrmlzd;
for i=1:length(posts)
    disp(i)
    if nresponse(posts(i),2)==1
        [vm, v_postbarrido,Nrmlzd_Io]=global_neuron_response(ntype.ts,ntype.ts.V,t_barrido,Iins(posts(i),1));
        Vm_general(posts(i),1)=v_actual;
        figure()
        plot(vm)
    end
    if nresponse(posts(i),2)==2
        [vm, v_postbarrido, Nrmlzd_Io]=global_neuron_response(ntype.ps,ntype.ps.V,t_barrido,Iins(posts(i),1));
        Vm_general(posts(i),1)=v_actual;
        figure()
        plot(vm)
    end
    if sum(ismember(inhibidoras,posts(i)))==1
        Iouts(posts(i),1)=-Nrmlzd_Io;
    else
        Iouts(posts(i),1)=Nrmlzd_Io;
    end
    
end

Inp_Unit_Neurons=ismember(pares(:,1),posts(:));
pre=pares(find(Inp_Unit_Neurons~=0),1);
posts=pares(find(Inp_Unit_Neurons~=0),2);
n_inputs = histc(posts,[1:1:numero]); %obtiene el numero de aferencias 
% que recibe cada neurona en este barrido, las filas representan el numero
% de neuronas
nb=2;
%Iins(:,nb)=Iouts(:,nb-1);
aux=find(n_inputs>1);%cuales de las POST reciben mas de una aferencia
for i=1:length(aux)
preaux=pre(find(posts(:,1)==aux(i)))
cont=0;
    for j=1:length(preaux)
        cont=cont+Iouts(preaux(j), nb-1)
    end
Iins(aux(i),nb)=cont/length(preaux);
end
% pre(find(posts==aux))





function Nrmlzd_I=Peaks2Unit(neuron, n_pks)
    Nrmlzd_I=n_pks/neuron.n_pks;
end

% function I_in=Unit2Current(neuron,Nrmlzd_I)
%     I_in=Nrmlzd_I*neuron.I;
% end

function n_pks=number_peaks(vm)
    pks = findpeaks(vm,'MinPeakHeight',21);
    n_pks = length(pks);
end

function [vm, v_postbarrido,Nrmlzd_Io]=global_neuron_response(neuron,v_prebarrido,t_barrido,Nrmlzd_I)
    [vm, v_postbarrido] = evaluar_neurona(neuron,v_prebarrido,t_barrido,Nrmlzd_I);
    n_pks=number_peaks(vm);
    Nrmlzd_Io=Peaks2Unit(neuron, n_pks); 
end 

function [vm, v_postbarrido] = evaluar_neurona(neuron,v_prebarrido,t_barrido,Nrmlzd_I)
    V=v_prebarrido;
    u=neuron.b * V;
    VV=[];  uu=[];
    tau = 0.25; 
    tspan = 0:tau:t_barrido;
    for t=tspan
        V = V + tau*(0.04*V^2+5*V+140-u+(Nrmlzd_I*neuron.I));
        u = u + tau*neuron.a*(neuron.b*V-u);
        if V > 30
            VV(end+1)=30;
            V = neuron.c;
            u = u + neuron.d;
        else
            VV(end+1)=V;
        end
        uu(end+1)=u;
    end
    vm = VV;
    v_postbarrido=V;
end