function [x, t, u, maxTemp, pos] = shuttle(tmax, nt, xmax, nx, method, thermCon, density, specHeat, sensor)
% Function for modelling temperature in a space shuttle tile
%
% Input arguments:
% tmax     - maximum time (s)
% nt       - number of timesteps
% xmax     - total thickness (m)
% nx       - number of spatial steps
% method   - solution method ('Forward', 'Backward' etc)
% thermCon - material thermal conductivity (W/m.K)
% density  - material density (kg/m^3)
% specHeat - material specific heat capacity (J/kg.K)
% sensor   - select temperature sensor data to use
%
% Return arguments:
% x        - distance vector (m)
% t        - time vector (s)
% u        - temperature matrix (K)
% maxTemp  - maximum temperature reached on internal face of tile
% pos      - variable for position in time
%
% For example, to perform a  simulation with 501 time steps
%   [x, t, u, maxTemp, pos] = shuttle(4000, 501, 0.05, 21, 'Crank-Nicolson', 0.0577, 144, 1262, 'Sensor 1');
%

alpha = thermCon/(density * specHeat);

% Run autoplottemp.m
autoplottemp(sensor)
% Load temperature data from file
load temp.mat

% Initialise variables
dt = tmax / (nt-1);
t = (0:nt-1) * dt;
dx = xmax / (nx-1);
x = (0:nx-1) * dx;
u = zeros(nt, nx);
p = alpha*(dt/dx^2);
u([1 2], :) = 293;
i = 2:nx-1;
maxTemp = 0;

% Step through time
for n=2:nt-1

    % Use interpolation to get temperature at time vector t
    % and store it as boundary vectors.
    R = interp1(xScale, yScale, t, "linear", "extrap");

    % Select method and run simulation
    switch method
        case 'Forward'
            u(n+1, nx) = R(n+1); % Outside boundary condition

            u(n+1,1) = (1-2*p) * u(n,1) + 2*p*u(n,2); % Neumann boundary condition
            u(n+1,i) = (1-2*p) * u(n,i) + p * (u(n,i-1) + u(n,i+1)); % Forward differencing

        case 'Dufort-Frankel'
            u(n+1, nx) = R(n+1); % Outside boundary condition

            u(n+1,1) = ((1-2*p) * u(n-1,1) + 4*p*u(n,2)) / (1 + 2*p); % Neumann boundary condition
            u(n+1,i) = ((1-2*p) * u(n-1,i) + 2*p*(u(n,i-1) + u(n,i+1))) / (1 + 2*p); % Dufort-Frankel approximation

        case 'Backward'
            u(n+1, nx) = R(n+1); % Outside boundary condition
            
            % Calculate internal values using backward differencing
            b(1) = 1 + (2 * p);
            c(1) = -2 * p;
            d(1) = u(n,1); % Neumann boundary condition
            a(i) = -p;
            b(i) = 1 + 2*p;
            c(i) = -p;
            d(i) = u(n,2:nx-1); % Neumann boundary condition
            a(nx) = -2 * p;
            b(nx) = 1 + (2 * p);
            d(nx) = R(n+1);

            % Runs tdm.m
            u(n+1,:) = tdm(a,b,c,d);

        case 'Crank-Nicolson'

            % Calculate internal values using Crank-Nicolson 
            b(1)    = 1 + p;
            c(1)    = -p;
            d(1)    = (1 - p) * u(n,1) + p * u(n,2); % Neumann boundary condition
            a(i) = -p/2;
            b(i) = 1 + p;
            c(i) = -p/2;
            d(i) = p/2*u(n,1:nx-2) + (1-p)*u(n,2:nx-1) + p/2*u(n,3:nx); % Neumann boundary condition
            a(nx)   = 0;
            b(nx)   = 1;
            d(nx)   = R(n+1);

            % Runs tdm.m
            u(n+1,:) = tdm(a,b,c,d);

        otherwise
            error (['Undefined method: ' method])
    end

    % Updates value of maxTemp and its position in time
    if u(n,i(1)) > maxTemp
        maxTemp = u(n,i(1));
        pos = n*dt;
    end
end

end

%#ok<*LOAD>
%#ok<*AGROW>

