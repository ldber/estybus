% Author: Lakshan Bernard

% This script generates synthetic smart meter data for a radial feeder.

clc; clear all; close all;
rng(1,"twister");

% Load 18-bus radial distribution system in MATPOWER
MPC = case18;
[PQ, PV, REF, NONE, BUS_I, BUS_TYPE, PD, QD, GS, BS, BUS_AREA, VM, VA, BASE_KV, ZONE, VMAX, VMIN, LAM_P, LAM_Q, MU_VMAX, MU_VMIN] = idx_bus;
[F_BUS, T_BUS, BR_R, BR_X, BR_B, RATE_A, RATE_B, RATE_C, TAP, SHIFT, BR_STATUS, PF, QF, PT, QT, MU_SF, MU_ST, ANGMIN, ANGMAX, MU_ANGMIN, MU_ANGMAX] = idx_brch;
[GEN_BUS, PG, QG, QMAX, QMIN, VG, MBASE, GEN_STATUS, PMAX, PMIN, MU_PMAX, MU_PMIN, MU_QMAX, MU_QMIN, PC1, PC2, QC1MIN, QC1MAX, QC2MIN, QC2MAX, RAMP_AGC, RAMP_10, RAMP_30, RAMP_Q, APF] = idx_gen;
MPC.branch(:,BR_B) = 0;
MPC.gen(1, GEN_BUS) = 1;
MPC.bus = MPC.bus(MPC.bus(:,BUS_I) < 50, :);
MPC.bus(1,BUS_TYPE) = 3;
MPC.branch = MPC.branch((MPC.branch(:,F_BUS) < 50) & (MPC.branch(:,T_BUS) < 50), :);

% Synthetic load scenarios
Nsample = 100;
Nbus = size(MPC.bus, 1);
Ngen = size(MPC.gen, 1);

t = linspace(0, 23, Nsample);

duck = [ 0,   1,   2,   3,   4,   5,   6,   7,   8,   9,  10,  11,  12,  13,  14,  15,  16,  17,  18,  19,  20,  21,  22,  23;
      1.29,1.22,1.19,1.17,1.18,1.19,1.21,1.22,1.20,1.09,0.95,0.87,0.82,0.80,0.80,0.82,0.87,1.00,1.29,1.54,1.60,1.54,1.45,1.36];

Pdem = repmat(MPC.bus(:,PD)', Nsample,1).*repmat(spline(duck(1,:), duck(2,:), t)', 1, Nbus);
Pdem = (0.8 + 0.4*rand(Nsample, Nbus)).*Pdem;

pf = (0.8 + 0.1*rand(Nsample, Nbus));
Qdem = (Pdem./pf).*sqrt(1-pf.^2);

% Run power flow for each load scenario
Vrms = zeros(Nsample, Nbus);
Vang = zeros(Nsample, Nbus);
Pgen = zeros(Nsample, Nbus);
Qgen = zeros(Nsample, Nbus);

for i = 1:Nsample
    MPC.bus(:, PD) = Pdem(i,:)';
    MPC.bus(:, QD) = Qdem(i,:)';
    MPC = runpf(MPC);
    
    if ~MPC.success
        error('Power flow did not converge');
    end

    Vrms(i,:) = MPC.bus(:,VM)';
    Vang(i,:) = MPC.bus(:,VA)';

    for k = 1:Ngen
        mask = MPC.bus(:,BUS_I) == MPC.gen(k,GEN_BUS);
        Pgen(i,mask) = MPC.gen(k,PG);
        Qgen(i,mask) = MPC.gen(k,QG);
    end
end

% Saving important data
Pinj = (Pgen - Pdem)/MPC.baseMVA;
Qinj = (Qgen - Qdem)/MPC.baseMVA;
Ytrue = full(makeYbus(ext2int(MPC)));

save('Pinj.mat', 'Pinj');
save('Qinj.mat', 'Qinj');
save('Vrms.mat', 'Vrms');
save('Vang.mat', 'Vang');
save('Ytrue.mat', 'Ytrue');

% Plotting
subplot(2,2,1);
for i = 1:Nbus
    plot(t, Pinj(:,i)); hold on;
end
ylabel('Active power (MW)')

subplot(2,2,2);
for i = 1:Nbus
    plot(t, Qinj(:,i)); hold on;
end
ylabel('Reactive power (Mvar)')

subplot(2,2,3);
for i = 1:Nbus
    plot(t, Vrms(:,i)); hold on;
end
ylabel('RMS voltage (pu)')

subplot(2,2,4);
for i = 1:Nbus
    plot(t, Vang(:,i)); hold on;
end
ylabel('Voltage angle (deg)')