%% =========================================================
%  MATLAB-BASED SHELL-AND-TUBE HEAT EXCHANGER
%  THERMAL DESIGN
%
%  Configuration:
%  1 Shell Pass - 2 Tube Passes
%
%  Method:
%  Energy Balance
%  Counter-current LMTD
%  LMTD Correction Factor
% ==========================================================

 run('input_data.m');

%% 1. HEAT DUTY

% Heat removed from the hot fluid

Q_hot = hot.m_dot * hot.Cp * ...
        (hot.T_in - hot.T_out);


%% 2. COLD FLUID OUTLET TEMPERATURE

% Energy balance:
%
% Q_hot = Q_cold
%
% Therefore:
%
% cold.T_out = cold.T_in + Q_hot/(m_dot*Cp)

cold.T_out = cold.T_in + ...
             Q_hot/(cold.m_dot * cold.Cp);


%% 3. HEAT DUTY FROM COLD SIDE

Q_cold = cold.m_dot * cold.Cp * ...
         (cold.T_out - cold.T_in);


%% 4. ENERGY BALANCE ERROR

energy_balance_error = ...
    abs(Q_hot - Q_cold)/Q_hot * 100;


%% 5. COUNTER-CURRENT TEMPERATURE DIFFERENCES

% These are used to calculate the reference
% counter-current LMTD.

DT1 = hot.T_in - cold.T_out;

DT2 = hot.T_out - cold.T_in;


%% 6. CHECK TEMPERATURE DIFFERENCES

if DT1 <= 0 || DT2 <= 0

    error('Invalid temperature difference. Check input temperatures.');

end


%% 7. COUNTER-CURRENT LMTD

if abs(DT1 - DT2) < 1e-10

    LMTD_counter = DT1;

else

    LMTD_counter = ...
        (DT1 - DT2)/log(DT1/DT2);

end


%% 8. CALCULATE P AND R

% For shell-and-tube heat exchanger
% correction-factor method

P = (cold.T_out - cold.T_in) / ...
    (hot.T_in - cold.T_in);

R = (hot.T_in - hot.T_out) / ...
    (cold.T_out - cold.T_in);


%% 9. LMTD CORRECTION FACTOR F
%
% Configuration:
% 1 shell pass - 2 tube passes
%
% Formula:
%
% F = sqrt(R^2 + 1)/(R - 1) *
%     ln[(1-P)/(1-P*R)] /
%     ln[(2-P*(R+1-sqrt(R^2+1))) /
%        (2-P*(R+1+sqrt(R^2+1)))]
%
% Special handling is required when R = 1.

if abs(R - 1) < 1e-10

    % Limit case when R approaches 1

    F = sqrt(2)*(1-P) / ...
        sqrt(2 - 2*P);

else

    S = sqrt(R^2 + 1);

    numerator = ...
        log((1-P)/(1-P*R));

    denominator = ...
        log((2 - P*(R + 1 - S)) / ...
            (2 - P*(R + 1 + S)));

    F = (S/(R-1)) * ...
        (numerator/denominator);

end


%% 10. CHECK CORRECTION FACTOR

if F <= 0 || F > 1

    error('Invalid LMTD correction factor F. Check P and R.');

end


%% 11. CORRECTED LMTD

LMTD_corrected = F * LMTD_counter;


%% 12. DISPLAY RESULTS

fprintf('\n');
fprintf('============================================\n');
fprintf('       THERMAL DESIGN RESULTS\n');
fprintf('============================================\n');

fprintf('Heat duty                  : %.3f kW\n', ...
        Q_hot/1000);

fprintf('Cold outlet temperature    : %.2f deg C\n', ...
        cold.T_out);

fprintf('\n');

fprintf('DT1                        : %.2f K\n', DT1);
fprintf('DT2                        : %.2f K\n', DT2);

fprintf('Counter-current LMTD       : %.2f K\n', ...
        LMTD_counter);

fprintf('\n');

fprintf('P                          : %.4f\n', P);
fprintf('R                          : %.4f\n', R);

fprintf('LMTD correction factor F   : %.4f\n', F);

fprintf('Corrected LMTD             : %.2f K\n', ...
        LMTD_corrected);

fprintf('\n');

fprintf('Energy balance error       : %.6f %%\n', ...
        energy_balance_error);


%% 13. ENERGY BALANCE CHECK

if energy_balance_error < 1

    fprintf('\nEnergy balance check: PASSED\n');

else

    fprintf('\nEnergy balance check: CHECK INPUT DATA\n');

end


fprintf('============================================\n');
