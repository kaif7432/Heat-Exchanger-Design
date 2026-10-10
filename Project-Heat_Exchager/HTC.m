%% =========================================================
%  MATLAB-BASED SHELL-AND-TUBE HEAT EXCHANGER
%  HEAT-TRANSFER COEFFICIENT
%
%  ITERATIVE TUBE COUNT + KERN SHELL-SIDE METHOD
%
%  Tube side  : Cold fluid
%  Shell side : Hot fluid
%
%  Configuration:
%  1 shell pass - 2 tube passes
% ==========================================================

run('Thermal_Design.m');

%% =========================================================
% 1. INITIAL DESIGN PARAMETERS
% ==========================================================

% Initial guess for number of tubes

N_tubes = 20;

% Convergence tolerance

tube_tolerance = 1;

% Maximum number of iterations

max_iterations = 100;


%% =========================================================
% 2. TUBE-SIDE CALCULATION
% ==========================================================

for iteration = 1:max_iterations

    %% -----------------------------------------------------
    % 2.1 Number of tubes in parallel
    % ------------------------------------------------------

    N_parallel = N_tubes / exchanger.N_passes;


    %% -----------------------------------------------------
    % 2.2 Tube flow area
    % ------------------------------------------------------

    A_tube_flow = ...
        N_parallel * pi * exchanger.D_i^2 / 4;


    %% -----------------------------------------------------
    % 2.3 Cold-fluid volumetric flow rate
    % ------------------------------------------------------

    Vdot_cold = cold.m_dot / cold.rho;


    %% -----------------------------------------------------
    % 2.4 Tube-side velocity
    % ------------------------------------------------------

    v_tube = Vdot_cold / A_tube_flow;


    %% -----------------------------------------------------
    % 2.5 Tube-side Reynolds number
    % ------------------------------------------------------

    Re_tube = ...
        cold.rho * v_tube * exchanger.D_i / cold.mu;


    %% -----------------------------------------------------
    % 2.6 Tube-side Prandtl number
    % ------------------------------------------------------

    Pr_tube = ...
        cold.Cp * cold.mu / cold.k;


    %% -----------------------------------------------------
    % 2.7 Tube-side Nusselt number
    % ------------------------------------------------------

    if Re_tube < 2300

        % Fully developed laminar flow
        Nu_tube = 3.66;

    elseif Re_tube < 4000

        error(['Tube-side flow is transitional. ', ...
               'Modify the tube count or geometry.']);

    else

        % Dittus-Boelter equation
        Nu_tube = ...
            0.023 * Re_tube^0.8 * Pr_tube^0.4;

    end


    %% -----------------------------------------------------
    % 2.8 Tube-side heat-transfer coefficient
    % ------------------------------------------------------

    h_i = ...
        Nu_tube * cold.k / exchanger.D_i;


    %% =====================================================
    % 3. KERN SHELL-SIDE CALCULATION
    % =====================================================


    %% -----------------------------------------------------
    % 3.1 Tube pitch
    % ------------------------------------------------------

    Pt = exchanger.tube_pitch;


    %% -----------------------------------------------------
    % 3.2 Baffle spacing
    % ------------------------------------------------------

    B = exchanger.baffle_spacing;


    %% -----------------------------------------------------
    % 3.3 Shell diameter
    % ------------------------------------------------------

    Ds = exchanger.D_shell;


    %% -----------------------------------------------------
    % 3.4 Cross-flow area
    %
    % Kern approximation:
    %
    % As = Ds * B * (Pt - Do) / Pt
    % ------------------------------------------------------

    As = ...
        Ds * B * ...
        (Pt - exchanger.D_o) / Pt;


    %% -----------------------------------------------------
    % 3.5 Shell-side mass velocity
    % ------------------------------------------------------

    Gs = hot.m_dot / As;


    %% -----------------------------------------------------
    % 3.6 Equivalent diameter
    %
    % For triangular tube arrangement:
    %
    % De = 4 * free area / wetted perimeter
    %
    % Approximate Kern expression:
    % ------------------------------------------------------

    De = ...
        (4 * (0.5 * sqrt(3) * Pt^2 ...
        - 0.25 * pi * exchanger.D_o^2)) ...
        / (pi * exchanger.D_o);


    %% -----------------------------------------------------
    % 3.7 Shell-side Reynolds number
    % ------------------------------------------------------

    Re_shell = ...
        De * Gs / hot.mu;


    %% -----------------------------------------------------
    % 3.8 Shell-side Prandtl number
    % ------------------------------------------------------

    Pr_shell = ...
        hot.Cp * hot.mu / hot.k;


    %% -----------------------------------------------------
    % 3.9 Shell-side Nusselt number
    %
    % Kern correlation:
    %
    % Nu = 0.36 Re^0.55 Pr^(1/3)
    % ------------------------------------------------------

    if Re_shell < 2300

        warning('Shell-side flow is laminar.');

    end

    Nu_shell = ...
        0.36 * Re_shell^0.55 * Pr_shell^(1/3);


    %% -----------------------------------------------------
    % 3.10 Shell-side heat-transfer coefficient
    % ------------------------------------------------------

    h_o = ...
        Nu_shell * hot.k / De;


    %% =====================================================
    % 4. OVERALL HEAT-TRANSFER COEFFICIENT
    % =====================================================

    % Tube-wall thickness

    delta = ...
        (exchanger.D_o - exchanger.D_i) / 2;


    % Overall resistance based on outside tube area

    R_total = ...
        1/h_o ...
        + fouling.Rf_o ...
        + (exchanger.D_o / ...
          (2*tube.wall_k)) * ...
          log(exchanger.D_o/exchanger.D_i) ...
        + (exchanger.D_o/exchanger.D_i) * ...
          (fouling.Rf_i + 1/h_i);


    % Overall heat-transfer coefficient

    U_o = 1/R_total;


    %% =====================================================
    % 5. REQUIRED HEAT-TRANSFER AREA
    % =====================================================

    A_required = ...
        Q_hot / ...
        (U_o * LMTD_corrected);


    %% =====================================================
    % 6. REQUIRED NUMBER OF TUBES
    % =====================================================

    N_required = ceil( ...
        A_required / ...
        (pi * exchanger.D_o * exchanger.L));


    %% =====================================================
    % 7. CHECK CONVERGENCE
    % =====================================================

    if abs(N_required - N_tubes) <= tube_tolerance

        N_tubes = N_required;

        break;

    else

        N_tubes = N_required;

    end

end


%% =========================================================
% 8. CHECK ITERATION CONVERGENCE
% ==========================================================

if iteration == max_iterations

    warning('Maximum iterations reached before convergence.');

else

    fprintf('\nTube-count iteration converged.\n');

end


%% =========================================================
% 9. FINAL ACTUAL HEAT-TRANSFER AREA
% ==========================================================

A_actual = ...
    N_tubes * pi * exchanger.D_o * exchanger.L;


%% =========================================================
% 10. FINAL TUBE-SIDE VELOCITY
% ==========================================================

N_parallel = N_tubes / exchanger.N_passes;

A_tube_flow = ...
    N_parallel * pi * exchanger.D_i^2 / 4;

Vdot_cold = cold.m_dot / cold.rho;

v_tube = Vdot_cold / A_tube_flow;


%% =========================================================
% 11. FINAL TUBE-SIDE REYNOLDS NUMBER
% ==========================================================

Re_tube = ...
    cold.rho * v_tube * exchanger.D_i / cold.mu;


%% =========================================================
% 12. FINAL SHELL-SIDE CALCULATIONS
% ==========================================================

As = ...
    Ds * B * ...
    (Pt - exchanger.D_o) / Pt;

Gs = hot.m_dot / As;

Re_shell = ...
    De * Gs / hot.mu;


%% =========================================================
% 13. HEAT-TRANSFER AREA MARGIN
% ==========================================================

area_margin = ...
    (A_actual - A_required) / A_required * 100;


%% =========================================================
% 14. DISPLAY RESULTS
% ==========================================================

fprintf('\n');
fprintf('================================================\n');
fprintf('       HEAT-TRANSFER DESIGN RESULTS\n');
fprintf('================================================\n');

fprintf('\nITERATION\n');

fprintf('Number of iterations       : %d\n', ...
        iteration);

fprintf('Final number of tubes      : %f\n', ...
        N_tubes);


fprintf('\nTUBE SIDE - COLD FLUID\n');

fprintf('Tube velocity              : %.3f m/s\n', ...
        v_tube);

fprintf('Reynolds number            : %.2f\n', ...
        Re_tube);

fprintf('Prandtl number             : %.2f\n', ...
        Pr_tube);

fprintf('Nusselt number             : %.2f\n', ...
        Nu_tube);

fprintf('Tube-side h_i              : %.2f W/(m^2.K)\n', ...
        h_i);


fprintf('\nSHELL SIDE - HOT FLUID\n');

fprintf('Shell cross-flow area      : %.5f m^2\n', ...
        As);

fprintf('Mass velocity              : %.2f kg/(m^2.s)\n', ...
        Gs);

fprintf('Equivalent diameter        : %.5f m\n', ...
        De);

fprintf('Reynolds number            : %.2f\n', ...
        Re_shell);

fprintf('Prandtl number             : %.2f\n', ...
        Pr_shell);

fprintf('Nusselt number             : %.2f\n', ...
        Nu_shell);

fprintf('Shell-side h_o             : %.2f W/(m^2.K)\n', ...
        h_o);


fprintf('\nOVERALL HEAT TRANSFER\n');

fprintf('Overall U based on OD      : %.2f W/(m^2.K)\n', ...
        U_o);

fprintf('Required area              : %.3f m^2\n', ...
        A_required);

fprintf('Actual area                : %.3f m^2\n', ...
        A_actual);

fprintf('Area margin                : %.2f %%\n', ...
        area_margin);


fprintf('\n================================================\n');
