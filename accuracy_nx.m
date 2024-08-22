% Function to compare the accuracy of the four methods as dx changes
function[] = accuracy_nx

% Initialise variables
% xmax calculated using shooting method to limit maxTemp to 423K
xmax = 0.064;
nt = 501;
tmax = 4000;
i = 0;
thermCon = 0.0577;
density = 144;
specHeat = 1262;
sensor = 'Sensor 1';
x = [];

% Runs all four PDE methods through range of spacial step sizes
for nx = 3:2:101
    x = [x nx];
    i = i + 1;
    dx(i) = xmax/(nx-1);
    disp (['nx = ' num2str(nx) ', dx = ' num2str(dx(i)) ' m'])
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
figure(3)
plot(dx, [uf; ub; ud; uc],'.-')
hold on
plot([0 dx(1)], [0.99*uc(end) 0.99*uc(end)], '--',color=[0 0 0])
plot([0 dx(1)], [1.01*uc(end) 1.01*uc(end)], '--',color=[0 0 0])
hold off
ylim([380 420])
%xlim([0 0.01])
grid on
grid minor
xlabel('Spatial Step Size (m)')
ylabel('Final Temperature (K)')
legend ('Forward', 'Backward','Dufort-Frankel', 'Crank-Nicolson','1% Error Band')


%#ok<*AGROW>