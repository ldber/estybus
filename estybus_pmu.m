% This script estimates Ybus assuming the voltage angles are available.
% This would be the case if all the measurements were taken with PMUs.

clc; clear all; close all;

load Pinj.mat;
load Qinj.mat;
load Vrms.mat;
load Vang.mat;


S = (Pinj + 1j*Qinj).';
V = (Vrms.*cosd(Vang) + 1j*Vrms.*sind(Vang)).';

Yinfer = conj(S./V)*pinv(V);

% Check results
checky;

