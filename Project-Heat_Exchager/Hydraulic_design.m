%% =========================================================
%  MATLAB-BASED SHELL-AND-TUBE HEAT EXCHANGER
%  HYDRAULIC DESIGN
%
%  Tube side  : Cold fluid
%  Shell side : Hot fluid
%
%  Method:
%  Darcy-Weisbach equation
%  Blasius friction factor
%  Kern shell-side pressure-drop method
% ==========================================================

  run ('HTC.m') ;

%% =========================================================
% 3. TUBE-SIDE FRICTION FACTOR
% =========================================================

% Darcy friction factor

if Re_tube < 2300

    % Laminar flow
    f_tube = 64 / Re_tube;

elseif Re_tube >= 4000

    % Turbulent flow - Blasius correlation
    f_tube = 0.3164 / Re_tube^0.25;

else

    error(['Tube-side flow is transitional. ', ...
           'Hydraulic design requires Re < 2300 ', ...
           'or Re > 4000.']);

end


%% =========================================================
% 4. TUBE-SIDE STRAIGHT-PIPE PRESSURE DROP
% ==========================================================

% Total flow length through all tube passes

L_total_tube = ...
    exchanger.L * exchanger.N_passes;

% Darcy-Weisbach pressure drop

DeltaP_tube_friction = ...
    f_tube * ...
    (L_total_tube / exchanger.D_i) * ...
    (cold.rho * v_tube^2 / 2);


%% =========================================================
% 5. TUBE-SIDE MINOR LOSSES
% ==========================================================

% Approximate loss coefficient
% for entrance, exit and return bends

K_entrance = 1.0;
K_exit = 1.0;
K_return = 1.5;

% Number of return bends
N_return = exchanger.N_passes - 1;

K_total_tube = ...
    K_entrance + ...
    K_exit + ...
    N_return * K_return;

% Minor pressure drop

DeltaP_tube_minor = ...
    K_total_tube * ...
    (cold.rho * v_tube^2 / 2);


%% =========================================================
% 6. TOTAL TUBE-SIDE PRESSURE DROP
% ==========================================================

DeltaP_tube = ...
    DeltaP_tube_friction + ...
    DeltaP_tube_minor;



%% =========================================================
% 11. SHELL-SIDE FRICTION FACTOR
% ==========================================================

% Preliminary Kern turbulent-flow correlation

if Re_shell < 2300

    f_shell = 24 / Re_shell;

elseif Re_shell >= 2300

    f_shell = ...
        0.14 * Re_shell^(-0.16);

end


%% =========================================================
% 12. NUMBER OF BAFFLE SPACES
% ==========================================================

% Approximate number of cross-flow sections

N_baffles = ...
    floor(exchanger.L / B) - 1;

% Ensure at least one baffle space
N_baffles = max(N_baffles,1);


%% =========================================================
% 13. SHELL-SIDE PRESSURE DROP
% ==========================================================

% Kern pressure-drop approximation

DeltaP_shell = ...
    f_shell * ...
    (Gs^2 / (2 * hot.rho)) * ...
    (Ds / De) * ...
    (N_baffles + 1);


%% =========================================================
% 14. TOTAL HEAT-EXCHANGER PRESSURE DROP
% ==========================================================

DeltaP_total = ...
    DeltaP_tube + DeltaP_shell;


%% =========================================================
% 15. PUMPING POWER
% ==========================================================

% Pumping power required for both streams

Power_tube = ...
    Vdot_cold * DeltaP_tube;

Vdot_hot = hot.m_dot / hot.rho;

Power_shell = ...
    Vdot_hot * DeltaP_shell;

% Hydraulic power

Power_hydraulic = ...
    Power_tube + Power_shell;


% Electrical/mechanical input power

Power_input = ...
    Power_hydraulic / ...
    design.pump_efficiency;


%% =========================================================
% 16. PRESSURE-DROP CHECK
% ==========================================================

if DeltaP_tube <= design.max_DeltaP

    tube_pressure_check = "PASSED";

else

    tube_pressure_check = "FAILED";

end


if DeltaP_shell <= design.max_DeltaP

    shell_pressure_check = "PASSED";

else

    shell_pressure_check = "FAILED";

end


if DeltaP_total <= 2 * design.max_DeltaP

    overall_pressure_check = "PASSED";

else

    overall_pressure_check = "FAILED";

end


%% =========================================================
% 17. DISPLAY RESULTS
% ==========================================================

fprintf('\n');
fprintf('====================================================\n');
fprintf('          HYDRAULIC DESIGN RESULTS\n');
fprintf('====================================================\n');


%% TUBE SIDE

fprintf('\nTUBE SIDE - COLD FLUID\n');

fprintf('Number of tubes           : %f\n', ...
        N_tubes);

fprintf('Number of tube passes     : %d\n', ...
        exchanger.N_passes);

fprintf('Tubes per pass            : %.2f\n', ...
        N_parallel);

fprintf('Flow velocity             : %.3f m/s\n', ...
        v_tube);

fprintf('Reynolds number           : %.2f\n', ...
        Re_tube);

fprintf('Total Tube length           : %.2f\n', ...
        L_total_tube);

fprintf('Darcy friction factor     : %.5f\n', ...
        f_tube);

fprintf('Frictional pressure drop  : %.2f Pa\n', ...
        DeltaP_tube_friction);

fprintf('Minor pressure drop       : %.2f Pa\n', ...
        DeltaP_tube_minor);

fprintf('Total tube-side ΔP        : %.2f Pa\n', ...
        DeltaP_tube);


%% SHELL SIDE

fprintf('\nSHELL SIDE - HOT FLUID\n');

fprintf('Cross-flow area           : %.6f m^2\n', ...
        As);

fprintf('Mass velocity             : %.3f kg/(m^2.s)\n', ...
        Gs);

fprintf('Equivalent diameter       : %.5f m\n', ...
        De);

fprintf('Reynolds number           : %.2f\n', ...
        Re_shell);

fprintf('Friction factor           : %.5f\n', ...
        f_shell);

fprintf('Number of baffles         : %d\n', ...
        N_baffles);

fprintf('Shell-side ΔP             : %.2f Pa\n', ...
        DeltaP_shell);


%% TOTAL

fprintf('\nOVERALL HYDRAULIC PERFORMANCE\n');

fprintf('Total exchanger ΔP        : %.2f Pa\n', ...
        DeltaP_total);

fprintf('Total exchanger ΔP        : %.2f kPa\n', ...
        DeltaP_total/1000);

fprintf('\n');

fprintf('Tube-side hydraulic power : %.3f W\n', ...
        Power_tube);

fprintf('Shell-side hydraulic power: %.3f W\n', ...
        Power_shell);

fprintf('Total hydraulic power     : %.3f W\n', ...
        Power_hydraulic);

fprintf('Required input power      : %.3f W\n', ...
        Power_input);

fprintf('Required input power      : %.3f kW\n', ...
        Power_input/1000);


%% PRESSURE-DROP CHECK

fprintf('\nPRESSURE-DROP CHECK\n');

fprintf('Tube-side limit check     : %s\n', ...
        tube_pressure_check);

fprintf('Shell-side limit check    : %s\n', ...
        shell_pressure_check);

fprintf('Overall pressure check    : %s\n', ...
        overall_pressure_check);


fprintf('\n====================================================\n');
