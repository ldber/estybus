% This script estimates Ybus assuming the voltage angles are not available.
% This would be the case if all the measurements were taken with smart
% meters.

clc; clear all; close all;

load Pinj.mat;
load Qinj.mat;
load Vrms.mat;
load Ytrue.mat;

% Guess Angles
[Nsample, Nbus] = size(Vrms);
Vang_guess =  zeros(Nsample, Nbus);

% Main Loop
numiter = 10000;
S = (Pinj + 1j*Qinj).';

for i = 1:numiter
    V = (Vrms.*cosd(Vang_guess) + 1j*Vrms.*sind(Vang_guess)).';
    Yinfer = conj(S./V)*pinv(V);


    % Run power flows to update angle guess
    for k = 1:Nsample
        [Vpf, converged, ~] = newtonpf(Yinfer, @(x) Sfun(S(:,k), x), V(:,k), 1, [], 2:Nbus);
        if ~converged
            error('Power Flow Did Not Converge!');
        end
        Vang_guess(k, :) = (angle(Vpf)*180/pi)';
    end

end

% Check results
checky;


% This local function is used for MATPOWER power flow
function [Sbus, dSbus_dVm] = Sfun(Sbus, Vm)
    dSbus_dVm = zeros(size(Sbus,1),size(Vm,1));
end
