# Shell-and-Tube Heat Exchanger Design and Performance Analysis

## Overview

This project develops a MATLAB/GNU Octave-based calculation tool for the preliminary thermal and hydraulic design of a shell-and-tube heat exchanger.

The model evaluates heat duty, heat-transfer area, heat-transfer coefficients, pressure drop, and pumping power. It also investigates how operating conditions and design parameters affect exchanger performance.

The primary objective is to understand the trade-off between thermal performance and hydraulic requirements.

## Objectives

* Calculate heat duty using mass and energy balances.
* Determine the cold-fluid outlet temperature.
* Calculate counter-current log mean temperature difference (LMTD) and its correction factor.
* Estimate tube-side and shell-side heat-transfer coefficients.
* Estimate the overall heat-transfer coefficient, including wall and fouling resistances.
* Estimate the required heat-transfer area and tube count.
* Calculate preliminary tube-side and shell-side pressure drops.
* Estimate pumping power.
* Perform parameter studies to investigate thermal-hydraulic trade-offs.

## Model Workflow

Input Process Data
↓
Thermal Design
↓
Heat-Transfer Coefficients
↓
Hydraulic Design
↓
Performance and Parameter Analysis

## Software

* MATLAB or GNU Octave
* Git and GitHub for version control and project hosting

## Project Structure

```text
Shell_Tube_Heat_Exchanger/
├── main.m
├── 01_input_data.m
├── 02_thermal_design.m
├── 03_HTC.m
├── 04_hydraulic_design.m
├── 05_performance_analysis.m
├── validation/
│   └── validate_design.m
├── results/
├── documentation/
└── README.md
```

## Methodology

### 1. Thermal Design

The heat duty is calculated using the hot-stream energy balance:

$$
Q_h = \dot{m}_h C_{p,h}
(T_{h,in}-T_{h,out})
$$

The cold-stream outlet temperature is obtained from the corresponding energy balance.

The log mean temperature difference is calculated using counter-current terminal temperature differences. An appropriate correction factor is then applied for the selected shell-and-tube configuration.

### 2. Heat-Transfer Coefficients

The model estimates tube-side and shell-side heat-transfer coefficients using selected empirical correlations.

The overall heat-transfer coefficient accounts for the tube-wall resistance and fouling resistances.

### 3. Hydraulic Design

The model estimates pressure losses in both fluid circuits using preliminary friction-factor and pressure-drop correlations.

Pumping power is estimated from volumetric flow rate, pressure drop, and pump efficiency.

### 4. Performance Analysis

Parameter studies investigate the effects of selected operating and geometrical variables on heat-transfer performance, pressure drop, and pumping power.

## Verification and Validation

The model is being checked using:

* Independent energy-balance calculations.
* Heat-transfer equation checks.
* Positive and physically valid temperature differences.
* Tube-count and area consistency checks.
* Pressure-drop and pumping-power checks.
* Comparison against suitable published worked examples or reference data.

Detailed validation results and numerical comparisons will be documented after the complete model has been tested.

## Limitations

This is a preliminary engineering model, not a fully validated industrial heat-exchanger rating package.

Predictions depend on the selected empirical correlations, fluid-property assumptions, and geometrical simplifications. Detailed industrial design may require additional treatment of shell-side leakage and bypass streams, baffle geometry, tube vibration, mechanical design, and applicable design codes.

## How to Run

1. Download or clone the repository.
2. Open MATLAB or GNU Octave.
3. Set the Current Directory to the project folder.
4. Review the process inputs in `01_input_data.m`.
5. Run `main.m`.
6. Review the Command Window output and generated plots.

Run the validation script separately to execute the independent calculation checks.

## Future Improvements

* More rigorous shell-side heat-transfer and pressure-drop calculations.
* Fully coupled thermal-hydraulic parameter studies.
* Automated design optimization.
* Improved fluid-property calculations.
* Automatic report generation.
* Comparison against additional reference cases.

## Author

Abdul Kaif

Chemical Engineering Undergraduate
Jadavpur University
