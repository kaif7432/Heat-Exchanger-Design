%% =========================================================
%  MATLAB-BASED SHELL-AND-TUBE HEAT EXCHANGER
%  PERFORMANCE + PARAMETER ANALYSIS
%
%  This module uses the results obtained from:
%
%  01_input_data.m
%  02_thermal_design.m
%  03_heat_transfer.m
%  04_hydraulic_design.m
%
%  Main objectives:
%  1. Evaluate exchanger performance
%  2. Calculate effectiveness
%  3. Calculate thermal margin
%  4. Perform parameter studies
%  5. Plot thermal-hydraulic trade-offs
% ==========================================================

run('Hydraulic_design.m') ;

%% =========================================================
% 1. ACTUAL HEAT-TRANSFER PERFORMANCE
% ==========================================================

% Heat-transfer area actually provided

A_actual = ...
    N_tubes * pi * exchanger.D_o * exchanger.L;


% Actual heat-transfer capability

Q_actual = ...
    U_o * A_actual * LMTD_corrected;


%% =========================================================
% 2. REQUIRED HEAT DUTY
% ==========================================================

Q_required = Q_hot;


%% =========================================================
% 3. THERMAL PERFORMANCE MARGIN
% ==========================================================

thermal_margin = ...
    (Q_actual - Q_required) / Q_required * 100;


%% =========================================================
% 4. CAPACITY RATIO
% ==========================================================

C_hot = ...
    hot.m_dot * hot.Cp;

C_cold = ...
    cold.m_dot * cold.Cp;

C_min = min(C_hot,C_cold);
C_max = max(C_hot,C_cold);

capacity_ratio = C_min / C_max;


%% =========================================================
% 5. MAXIMUM POSSIBLE HEAT TRANSFER
% ==========================================================

% Maximum possible heat transfer based on inlet
% temperature difference

Q_max = ...
    C_min * ...
    (hot.T_in - cold.T_in);


%% =========================================================
% 6. EFFECTIVENESS
% ==========================================================

effectiveness = ...
    Q_required / Q_max;


%% =========================================================
% 7. AREA UTILIZATION
% ==========================================================

area_utilization = ...
    Q_required / Q_actual * 100;


%% =========================================================
% 8. OVERALL PERFORMANCE CHECK
% ==========================================================

if Q_actual >= Q_required

    thermal_check = "PASSED";

else

    thermal_check = "FAILED";

end


if DeltaP_total <= ...
        2 * design.max_DeltaP

    hydraulic_check = "PASSED";

else

    hydraulic_check = "FAILED";

end


%% =========================================================
% 9. DISPLAY MAIN PERFORMANCE RESULTS
% ==========================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('       HEAT EXCHANGER PERFORMANCE RESULTS\n');
fprintf('====================================================\n');


fprintf('\nTHERMAL PERFORMANCE\n');

fprintf('Required heat duty       : %.3f kW\n', ...
        Q_required/1000);

fprintf('Actual heat-transfer     : %.3f kW\n', ...
        Q_actual/1000);

fprintf('Thermal margin           : %.2f %%\n', ...
        thermal_margin);

fprintf('Effectiveness            : %.4f\n', ...
        effectiveness);

fprintf('Capacity ratio (Cmin/Cmax): %.4f\n', ...
        capacity_ratio);

fprintf('Area utilization         : %.2f %%\n', ...
        area_utilization);


fprintf('\nDESIGN CHECKS\n');

fprintf('Thermal design check     : %s\n', ...
        thermal_check);

fprintf('Hydraulic design check   : %s\n', ...
        hydraulic_check);


fprintf('\n');

fprintf('Overall heat-transfer coefficient: %.2f W/(m^2.K)\n', ...
        U_o);

fprintf('Corrected LMTD           : %.2f K\n', ...
        LMTD_corrected);

fprintf('Heat-transfer area       : %.3f m^2\n', ...
        A_actual);

fprintf('Total pressure drop      : %.2f kPa\n', ...
        DeltaP_total/1000);

fprintf('Pumping power            : %.3f kW\n', ...
        Power_input/1000);


fprintf('\n====================================================\n');


%% =========================================================
% 10. PARAMETER ANALYSIS - FLOW RATE
% =========================================================

% Flow-rate multiplier

flow_factor = ...
    linspace(0.5,1.5,30);

n_points = length(flow_factor);


% Arrays for storing results

flow_rate = zeros(1,n_points);

h_i_flow = zeros(1,n_points);

h_o_flow = zeros(1,n_points);

U_flow = zeros(1,n_points);

DeltaP_flow = zeros(1,n_points);

Power_flow = zeros(1,n_points);

Area_flow = zeros(1,n_points);


%% =========================================================
% 11. FLOW-RATE PARAMETER LOOP
% ==========================================================

for i = 1:n_points

    %% Modified cold-fluid flow rate

    m_dot_test = ...
        cold.m_dot * flow_factor(i);

    flow_rate(i) = m_dot_test;


    %% Tube-side velocity

    Vdot_test = ...
        m_dot_test / cold.rho;

    v_test = ...
        Vdot_test / A_tube_flow;


    %% Reynolds number

    Re_test = ...
        cold.rho * v_test * exchanger.D_i / cold.mu;


    %% Tube-side heat-transfer coefficient

    Pr_test = ...
        cold.Cp * cold.mu / cold.k;


    if Re_test < 2300

        Nu_test = 3.66;

    elseif Re_test >= 4000

        Nu_test = ...
            0.023 * Re_test^0.8 * Pr_test^0.4;

    else

        Nu_test = NaN;

    end


    h_i_flow(i) = ...
        Nu_test * cold.k / exchanger.D_i;


    %% Shell-side coefficient
    % Kept constant because hot-side conditions
    % and shell geometry are unchanged

    h_o_flow(i) = h_o;


    %% Overall heat-transfer coefficient

    if isnan(h_i_flow(i))

        U_flow(i) = NaN;

    else

        R_total_test = ...
            1/h_o ...
            + fouling.Rf_o ...
            + (exchanger.D_o / ...
              (2*tube.wall_k)) * ...
              log(exchanger.D_o/exchanger.D_i) ...
            + (exchanger.D_o/exchanger.D_i) * ...
              (fouling.Rf_i + ...
              1/h_i_flow(i));

        U_flow(i) = ...
            1/R_total_test;

    end


    %% Required area

    if isnan(U_flow(i))

        Area_flow(i) = NaN;

    else

        Area_flow(i) = ...
            Q_required / ...
            (U_flow(i) * LMTD_corrected);

    end


    %% Tube-side friction factor

    if Re_test < 2300

        f_test = 64/Re_test;

    elseif Re_test >= 4000

        f_test = ...
            0.3164/Re_test^0.25;

    else

        f_test = NaN;

    end


    %% Tube-side pressure drop

    if isnan(f_test)

        DeltaP_test = NaN;

    else

        DeltaP_test = ...
            f_test * ...
            (L_total_tube / exchanger.D_i) * ...
            (cold.rho*v_test^2/2);

        DeltaP_test = ...
            DeltaP_test + ...
            K_total_tube * ...
            (cold.rho*v_test^2/2);

    end


    DeltaP_flow(i) = ...
        DeltaP_test + DeltaP_shell;


    %% Pumping power

    if isnan(DeltaP_flow(i))

        Power_flow(i) = NaN;

    else

        Power_flow(i) = ...
            (Vdot_test * DeltaP_test ...
            + Vdot_hot * DeltaP_shell) ...
            / design.pump_efficiency;

    end

end


%% =========================================================
% 12. DISPLAY FLOW-RATE PARAMETER TABLE
% ==========================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('       FLOW-RATE PARAMETER ANALYSIS\n');
fprintf('====================================================\n');

fprintf('\n');

fprintf(' Flow (kg/s)   h_i       U        ΔP       Power\n');
fprintf('              W/m2K    W/m2K      kPa       kW\n');
fprintf('----------------------------------------------------\n');

for i = 1:n_points

    fprintf('%8.3f   %8.2f  %8.2f  %8.2f  %8.4f\n', ...
        flow_rate(i), ...
        h_i_flow(i), ...
        U_flow(i), ...
        DeltaP_flow(i)/1000, ...
        Power_flow(i)/1000);

end


%% =========================================================
% 13. PLOT - h_i VS FLOW RATE
% ==========================================================

figure;

plot(flow_rate,h_i_flow,'o-','LineWidth',1.0);

grid on;

xlabel('Cold-fluid mass flow rate (kg/s)');

ylabel('Tube-side heat-transfer coefficient h_i (W/m^2.K)');

title('Effect of Flow Rate on Tube-Side Heat Transfer');


%% =========================================================
% 14. PLOT - PRESSURE DROP VS FLOW RATE
% ==========================================================

figure;

plot(flow_rate,DeltaP_flow/1000,'o-','LineWidth',1.0);

grid on;

xlabel('Cold-fluid mass flow rate (kg/s)');

ylabel('Total pressure drop (kPa)');

title('Effect of Flow Rate on Pressure Drop');


%% =========================================================
% 15. PLOT - PUMPING POWER VS FLOW RATE
% ==========================================================

figure;

plot(flow_rate,Power_flow/1000,'o-','LineWidth',1.0);

grid on;

xlabel('Cold-fluid mass flow rate (kg/s)');

ylabel('Pumping power (kW)');

title('Effect of Flow Rate on Pumping Power');


%% =========================================================
% 16. PLOT - REQUIRED AREA VS FLOW RATE
% ==========================================================

figure;

plot(flow_rate,Area_flow,'o-','LineWidth',1.0);

grid on;

xlabel('Cold-fluid mass flow rate (kg/s)');

ylabel('Required heat-transfer area (m^2)');

title('Effect of Flow Rate on Required Heat-Transfer Area');


%% =========================================================
% 17. PARAMETER ANALYSIS - TUBE LENGTH
% ==========================================================

L_values = ...
    [2 2.5 3 3.5 4 4.5 5];

n_L = length(L_values);

Area_L = zeros(1,n_L);

N_tubes_L = zeros(1,n_L);

DeltaP_L = zeros(1,n_L);


for i = 1:n_L

    L_test = L_values(i);


    %% Required area remains based on thermal design

    Area_L(i) = A_required;


    %% Number of tubes required

    N_raw = ceil( ...
        A_required / ...
        (pi * exchanger.D_o * L_test));


    N_tubes_L(i) = ...
        ceil(N_raw/exchanger.N_passes) ...
        * exchanger.N_passes;


    %% Tube-side pressure drop

    L_total_test = ...
        L_test * exchanger.N_passes;

    DeltaP_L(i) = ...
        f_tube * ...
        (L_total_test/exchanger.D_i) * ...
        (cold.rho*v_tube^2/2) ...
        + DeltaP_tube_minor ...
        + DeltaP_shell;

end


%% =========================================================
% 18. DISPLAY TUBE-LENGTH ANALYSIS
% ==========================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('       TUBE-LENGTH PARAMETER ANALYSIS\n');
fprintf('====================================================\n');

fprintf('\n');

fprintf(' Length (m)    Tubes      ΔP (kPa)\n');
fprintf('-----------------------------------\n');

for i = 1:n_L

    fprintf('%8.2f     %5d       %8.2f\n', ...
        L_values(i), ...
        N_tubes_L(i), ...
        DeltaP_L(i)/1000);

end


%% =========================================================
% 19. PLOT - TUBE LENGTH VS NUMBER OF TUBES
% ==========================================================

figure;

plot(L_values,N_tubes_L,'o-','LineWidth',1.0);

grid on;

xlabel('Tube length (m)');

ylabel('Required number of tubes');

title('Effect of Tube Length on Required Tube Count');


%% =========================================================
% 20. PLOT - TUBE LENGTH VS PRESSURE DROP
% ==========================================================

figure;

plot(L_values,DeltaP_L/1000,'o-','LineWidth',1.0);

grid on;

xlabel('Tube length (m)');

ylabel('Total pressure drop (kPa)');

title('Effect of Tube Length on Pressure Drop');


%% =========================================================
% 21. FINAL DESIGN SUMMARY
% ==========================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('             FINAL DESIGN SUMMARY\n');
fprintf('====================================================\n');

fprintf('\n');

fprintf('Heat duty                : %.3f kW\n', ...
        Q_required/1000);

fprintf('Number of tubes          : %d\n', ...
        N_tubes);

fprintf('Tube length              : %.2f m\n', ...
        exchanger.L);

fprintf('Tube outside diameter    : %.3f m\n', ...
        exchanger.D_o);

fprintf('Tube inside diameter     : %.3f m\n', ...
        exchanger.D_i);

fprintf('Heat-transfer area       : %.3f m^2\n', ...
        A_actual);

fprintf('Overall U                : %.2f W/(m^2.K)\n', ...
        U_o);

fprintf('Corrected LMTD           : %.2f K\n', ...
        LMTD_corrected);

fprintf('Effectiveness             : %.4f\n', ...
        effectiveness);

fprintf('Total pressure drop      : %.2f kPa\n', ...
        DeltaP_total/1000);

fprintf('Pumping power            : %.3f kW\n', ...
        Power_input/1000);

fprintf('Thermal margin           : %.2f %%\n', ...
        thermal_margin);


fprintf('\n====================================================\n');
fprintf('             ANALYSIS COMPLETE\n');
fprintf('====================================================\n');
