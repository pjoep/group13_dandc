clc; clear all; close all;

%% Open Simulink file and set model parameters
sys = 'SimuLinkD1SL';          % <--- your .slx file (without extension)
load_system([sys '.slx']);

% Set simulation settings
set_param(sys,'StopTime','110');   % run for 110 seconds
set_param(sys,'Solver','ode4');    % Runge-Kutta
set_param(sys,'FixedStep','1e-3'); % 1 ms fixed step (or whatever is required)

%% Run simulation and save results
results = sim('SimuLinkD1SL.slx');

if ~isempty(results.ErrorMessage)
    error('Simulation failed: %s', results.ErrorMessage);
end

%% Extract simulation signals
t_sim     = results.tout;                 % time from Simulink
x_sim     = squeeze(results.q(1,1,:));    % simulated x(t)
theta_sim = squeeze(results.q(2,1,:));    % simulated theta(t)

%% Load measured data
load('MeasuredSignals.mat');             % creates struct MeasuredSignals

t_meas     = MeasuredSignals.t;
x_meas     = MeasuredSignals.x;
theta_meas = MeasuredSignals.theta;

%% 1) Position of hoist block x(t)
figure(1)
plot(t_sim, x_sim, 'k', 'LineWidth', 1.2);           % simulation
hold on
plot(t_meas, x_meas, 'r--', 'LineWidth', 1.2);       % measurement
hold off
grid on
xlim([0 110]);                  % time interval
ylim([11.15 12.26]);            % position interval
title('Position of Hoist Block');
xlabel('Time [s]');
ylabel('x(t) [m]');
legend('Simulation','Measurement','Location','best');

%% 2) Absolute angle of the chain θ(t)
figure(2)
plot(t_sim, theta_sim, 'k', 'LineWidth', 1.2);       % simulation
hold on
plot(t_meas, theta_meas, 'r--', 'LineWidth', 1.2);   % measurement
hold off
grid on
xlim([0 110]);                  % time interval
ylim([0.95 2.05]);              % angle interval
title('Absolute Angle of the Chain');
xlabel('Time [s]');
ylabel('\theta(t) [rad]');
legend('Simulation','Measurement','Location','best');


sys2 = 'SimuLinkD2SL';              % linearized Simulink model
load_system([sys2 '.slx']);

% Use same simulation settings
set_param(sys2,'StopTime','110');
set_param(sys2,'Solver','ode4');
set_param(sys2,'FixedStep','1e-3');

%% Run linearized simulation
results_lin = sim([sys2 '.slx']);

if ~isempty(results_lin.ErrorMessage)
    error('Linearized simulation failed: %s', results_lin.ErrorMessage);
end

%% Extract linearized simulation signals
t_sim_lin = results_lin.tout;
x_sim_lin     = squeeze(results_lin.q1(1,1,:));
theta_sim_lin = squeeze(results_lin.q1(2,1,:));

%% Linearized vs non-linearized comparison plots
% 3) Position of hoist block x(t): nonlinear vs linearized
figure(3)
plot(t_sim,  x_sim,  'k',  'LineWidth', 1.2); hold on
plot(t_sim_lin, x_sim_lin, 'b--','LineWidth', 1.2); hold off
grid on
xlim([0 110]);
ylim([11.42 13.08]);   % as requested in D2.d
title('Position of Hoist Block: Nonlinear vs Linearized');
xlabel('Time [s]');
ylabel('x(t) [m]');
legend('Nonlinear model','Linearized model','Location','best');

% 4) Absolute angle of the chain θ(t): nonlinear vs linearized
figure(4)
plot(t_sim,  theta_sim,  'k',  'LineWidth', 1.2); hold on
plot(t_sim_lin, theta_sim_lin, 'b--','LineWidth', 1.2); hold off
grid on
xlim([0 110]);
ylim([0.95 2.05]);     % as requested in D2.d
title('Absolute Angle of the Chain: Nonlinear vs Linearized');
xlabel('Time [s]');
ylabel('\theta(t) [rad]');
legend('Nonlinear model','Linearized model','Location','best');