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