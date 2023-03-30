clear all
close all
load("ej_conexion.mat")
global I_Gatillo_nrmlzd
global posts
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

t_total=5; %segundos
t_barrido=100;
n_barrido=ceil(t_total/(t_barrido*0.001));
I_Gatillo_nrmlzd=2;

Vm_general=zeros(numero,n_barrido);
Iouts=zeros(numero+1,n_barrido);
Iins=zeros(numero+1,n_barrido);
activaciones=zeros(numero,n_barrido);
pares=sortrows(pares,1);

% obtenemos cantidad de picos por barrido para cada neurona
fn = fieldnames(ntype);
for i=1:length(fn)
    [vm, v_actual] = evaluar_neurona(ntype.(fn{i}),ntype.(fn{i}).V,t_barrido,1);
    ntype.(fn{i}).n_pks=number_peaks(vm);
end

nresponse=randperm(numero)';
nresponse(1:30,2)=1;
nresponse(1:30,3)=ntype.tb.V;%voltajes de reposo
nresponse(31:60,2)=2;
nresponse(31:60,3)=ntype.ts.V; %voltajes de reposo
nresponse(61:90,2)=3;
nresponse(61:90,3)=ntype.pb.V; %voltajes de reposo
nresponse=sortrows( nresponse , 1);
Vm_general(:,1)=nresponse(:,3);
%asignacion de tipo de respuesta neuronal a las neuronas
% nresponse=randperm(numero)';
% nresponse(1:30,2)=1;
% nresponse(1:30,3)=ntype.tb.V;%voltajes de reposo
% nresponse(31:75,2)=2;
% nresponse(31:75,3)=ntype.ts.V; %voltajes de reposo
% nresponse(76:90,2)=3;
% nresponse(76:90,3)=ntype.pb.V; %voltajes de reposo
% nresponse=sortrows( nresponse , 1);
% Vm_general(:,1)=nresponse(:,3);

%obtenemos numero de aferencias que cada neurona recibe (para promediar
%después)
n_inputs = histc(pares(:,2),[1:1:numero]);
n_outputs = histc(pares(:,1),[1:1:numero]);

pre=91; %es el numero de neurona para la neurona gatillo
posts=pares(find(pares(:,1)==pre),2);
for i=1:length(posts)
    Iins(posts(i),1)=I_Gatillo_nrmlzd;%n_inputs(posts(i));
end

% Inp_Unit_Neurons=ismember(pares(:,1),pre)*I_Gatillo_nrmlzd;
% posts=pares(find(Inp_Unit_Neurons~=0),2); %encontramos primeras 5 neuronas 
% Nrmlzd_I=I_Gatillo_nrmlzd;
% %Iins(posts(:),1)=Nrmlzd_I;%asignamos corriente a esas 5 neuronas 

%Iins(:,1)=1;

%barrido 1
tau=0.25;
Vm_tiempototal=[];

for barr=1:n_barrido
%     figure;
    %vm_barridostotal=zeros(numero,1+t_barrido/tau);
    for i=1:numero
        %disp(i)
        if nresponse(i,2)==1 %tipo de respuesta
            [vm, v_postbarrido,Nrmlzd_Io,n_peaks]=global_neuron_response(ntype.tb,Vm_general(i,barr),t_barrido,Iins(i,barr));
            Vm_general(i,barr+1)=v_postbarrido;
            vm_barridostotal(i,:)=vm;
           
        elseif nresponse(i,2)==2
            [vm, v_postbarrido, Nrmlzd_Io, n_peaks]=global_neuron_response(ntype.ts,Vm_general(i,barr),t_barrido,Iins(i,barr));
            Vm_general(i,barr+1)=v_postbarrido;
            vm_barridostotal(i,:)=vm;
            
        elseif nresponse(i,2)==3
            [vm, v_postbarrido, Nrmlzd_Io, n_peaks]=global_neuron_response(ntype.pb,Vm_general(i,barr),t_barrido,Iins(i,barr));
            Vm_general(i,barr+1)=v_postbarrido;
            vm_barridostotal(i,:)=vm;
            
        end
        %plot(vm)
        hold on
        if sum(ismember(inhibidoras,i))==1
            Iouts(i,barr)=-0.2*Nrmlzd_Io;
        else
            Iouts(i,barr)=Nrmlzd_Io;
        end 
        if n_peaks>=1
            activaciones(i,barr)=1;
        end
    end
    Vm_tiempototal=horzcat(Vm_tiempototal,vm_barridostotal);
    new5=excitadoras(randperm(numel(excitadoras),5))
    for l=1:numero
        if sum(ismember(new5,l))==1
            Iins(l,barr+1)=I_Gatillo_nrmlzd;
        else
            Iins(l,barr+1)=promediar_aferencias(pares,l, Iouts, Iins, barr);
        end
    end
end
%figure
plot(sum(Vm_tiempototal,1))

function Iins_n = promediar_aferencias(pares, n_neurona, Iouts, Iins, barr)
    n_neurona;
    global I_Gatillo_nrmlzd
    global posts
    %buscar que neuronas envian info a la neurona
    index=find(pares(:,2)==n_neurona);
    pre=pares(index,1);
    n_pre=length(pre);
    cont=0;
    for p=1:n_pre
        cont=cont+Iouts(pre(p),barr);
    end
    Iins_n=cont/n_pre;
end


function Nrmlzd_I=Peaks2Unit(neuron, n_pks)
    Nrmlzd_I=n_pks/neuron.n_pks;
end

function n_pks=number_peaks(vm)
    pks = findpeaks(vm,'MinPeakHeight',21);
    n_pks = length(pks);
    if vm(1)>21
        n_pks=n_pks+1;
    end
    if vm(end)>21
        n_pks=n_pks+1;
    end
end

function [vm, v_postbarrido,Nrmlzd_Io, n_pks]=global_neuron_response(neuron,v_prebarrido,t_barrido,Nrmlzd_I)
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