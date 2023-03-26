
%estructura con los parámetros de cuatro tipo de respuesta neuronal
ntype=struct;
% tonic spiking
ntype.ts.a=0.02; 
ntype.ts.b=0.2;  
ntype.ts.c=-65;  
ntype.ts.d=6;
ntype.ts.V=-70;
ntype.ts.I=14;
%phasic spiking
ntype.ps.a=0.02; 
ntype.ps.b=0.25; 
ntype.ps.c=-65;  
ntype.ps.d=6;
ntype.ps.V=-64;
ntype.ps.I=0.5;
%tonic bursting
ntype.tb.a=0.02; 
ntype.tb.b=0.2;  
ntype.tb.c=-50;  
ntype.tb.d=2;
ntype.tb.V=-70;
ntype.tb.I=15;
%phasic bursting
ntype.pb.a=0.02; 
ntype.pb.b=0.25; 
ntype.pb.c=-55;  
ntype.pb.d=0.05;
ntype.pb.V=-64;
ntype.pb.I=0.6;

t_barrido=125;

% obtenemos cantidad de picos por barrido para cada neurona
fn = fieldnames(ntype);
for i=1:length(fn)
    [vm, v_actual] = evaluar_neurona(ntype.(fn{i}),t_barrido,1)
    ntype.(fn{i}).n_pks=number_peaks(vm)
end

function n_pks=number_peaks(vm)
    pks = findpeaks(vm,'MinPeakHeight',21)
    n_pks = length(pks)
end

function [vm, v_actual] = evaluar_neurona(neuron,t_barrido,Nrmlzd_I)
    u=neuron.b * neuron.V;
    VV=[];  uu=[];
    tau = 0.25; 
    tspan = 0:tau:t_barrido;
    
    for t=tspan
        neuron.V = neuron.V + tau*(0.04*neuron.V^2+5*neuron.V+140-u+(Nrmlzd_I*neuron.I));
        u = u + tau*neuron.a*(neuron.b*neuron.V-u);
        if neuron.V > 30
            VV(end+1)=30;
            neuron.V = neuron.c;
            u = u + neuron.d;
        else
            VV(end+1)=neuron.V;
        end
        uu(end+1)=u;
    end
    vm = VV;
    v_actual=neuron.V;
end