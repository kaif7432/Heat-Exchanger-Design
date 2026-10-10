%% =========================================================
% SHELL-AND-TUBE HEAT EXCHANGER DESIGN TOOL
% Main Execution File
% ==========================================================

clc;
clear;
close all;

run('input_data.m');
run('Thermal_Design.m');
run('HTC.m');
run('Hydraulic_design.m');
run('performance_analysis.m');

