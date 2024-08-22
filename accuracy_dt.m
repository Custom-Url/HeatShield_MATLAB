% Function to compare the accuracy of the four methods as dt changes
function[] = accuracy_dt

% Initialise variables
% xmax calculated using shooting method to limit maxTemp to 423K
xmax = 0.064;
nx = 21;
tmax = 4000;
i = 0;
thermCon = 0.0577;
density = 144;
specHeat = 1262;
sensor = 'Sensor 1';
x = [];

% Runs all four PDE methods through range of timestep sizes
for nt = 26:40:1001
    x = [x nt];
    i = i + 1;
    dt(i) = tmax/(nt-1);
    disp (['nt = ' num2str(nt) ', dt = ' num2str(dt(i)) ' s'])
    [~, ~, u] = shuttle(tmax, nt, xmax, nx, 'Forward', thermCon, density, specHeat, sensor);
    uf(i) = u(end,1);
    [~, ~, u] = shuttle(tmax, nt, xmax, nx, 'Backward', thermCon, density, specHeat, sensor);
    ub(i) = u(end,1);
    [~, ~, u] = shuttle(tmax, nt, xmax, nx, 'Dufort-Frankel', thermCon, density, specHeat, sensor);
    ud(i) = u(end,1);
    [~, ~, u] = shuttle(tmax, nt, xmax, nx, 'Crank-Nicolson', thermCon, density, specHeat, sensor);
    uc(i) = u(end,1);



end

% Plots the the inner surface temperature at 4000s against the timestep
plot(dt, [uf; ub; ud; uc],'.-')
hold on
plot([0 dt(1)], [0.99*uc(end) 0.99*uc(end)], '--',color=[0 0 0])
plot([0 dt(1)], [1.01*uc(end) 1.01*uc(end)], '--',color=[0 0 0])
hold off
xlabel('Time Step Size (s)')
ylabel('Final Temperature (K)')
ylim([370 430])
grid on
grid minor
legend ('Forward', 'Backward','Dufort-Frankel', 'Crank-Nicolson','1% Error Band')

%#ok<*AGROW> 
