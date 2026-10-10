%% =========================================================
%  SHELL-AND-TUBE HEAT EXCHANGER
%  INPUT PROCESS DATA
% ==========================================================

clc;
clear;
close all;

%% 1. HOT FLUID / PROCESS STREAM

hot.m_dot = 2.0;          % kg/s
hot.T_in = 150;           % deg C
hot.T_out = 90;           % deg C
hot.Cp = 2100;            % J/(kg.K)
hot.rho = 850;            % kg/m^3
hot.mu = 0.004;           % Pa.s
hot.k = 0.13;             % W/(m.K)

%% 2. COLD FLUID / COOLING WATER

cold.m_dot = 3.0;         % kg/s
cold.T_in = 30;            % deg C
cold.Cp = 4180;            % J/(kg.K)
cold.rho = 995;            % kg/m^3
cold.mu = 0.0008;          % Pa.s
cold.k = 0.62;             % W/(m.K)

%% 3. HEAT EXCHANGER GEOMETRY

exchanger.D_i = 0.020;     % Tube inner diameter, m
exchanger.D_o = 0.025;     % Tube outer diameter, m
exchanger.L = 3.0;         % Tube length, m

exchanger.N_passes = 2;    % Number of tube passes

%% 4. TUBE MATERIAL

tube.wall_k = 16;          % W/(m.K)
tube.roughness = 0.000045; % m

%% 5. FOULING RESISTANCE

fouling.Rf_i = 0.0002;     % m^2.K/W
fouling.Rf_o = 0.0001;     % m^2.K/W

%% 6. DESIGN CONSTRAINTS

design.max_DeltaP = 50000; % Pa
design.pump_efficiency = 0.75;

%% 7. SHELL-SIDE GEOMETRY

exchanger.D_shell = 0.25;       % Shell inside diameter, m
exchanger.baffle_spacing = 0.125; % Baffle spacing, m

% Tube layout
exchanger.tube_pitch = 1.25 * exchanger.D_o;

% Number of tube passes
exchanger.N_passes = 2;

% Tube layout angle
% 30 = triangular arrangement
exchanger.layout_angle = 30;     % degrees

fprintf('Input data loaded successfully.\n');
