function[] = thickness()
% Function to plot temperature graphs for a range of tile thicknesses

% Initialise variables
nt = 501;
nx = 21;
tmax = 4000;
dt = tmax / (nt-1);
thermCon = 0.0577;
density = 144;
specHeat = 1262;
method = 'Crank-Nicolson';
sensor = 'Sensor 1';

% Vary tile thickness
for xmax = 0.01:0.02:0.11
    [~,~,u,~,~] = shuttle(tmax, nt, xmax, nx, method, thermCon, density, specHeat, sensor);
    hold on
    plot(0:dt:tmax, u(:,1))
end
xlabel('Time (s)')
ylabel('Inner Face Temperature (K)')
legend('xmax = 0.01m','xmax = 0.03m','xmax = 0.05m','xmax = 0.07m','xmax = 0.09m','xmax = 0.11m')
grid on
grid minor
hold off

%#ok<*AGROW>