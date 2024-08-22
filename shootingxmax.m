function [xmax, guess, result, idx, pos] = shootingxmax(intTemp,tmax, nt, nx, method, thermCon, density, specHeat, sensor)
% Function for calculating required tile thickness for a maximum interal
% temperature during heating
%
% Input arguments:
% intTemp  - maximum temperature allowed for internal tile face (K)
% tmax     - maximum time (s)
% nt       - number of timesteps
% nx       - number of spatial steps
% method   - solution method ('Forward', 'Backward' etc)
% thermCon - material thermal conductivity (W/m.K)
% density  - material density (kg/m^3)
% specHeat - material specific heat capacity (J/kg.K)
% sensor   - select temperature sensor data to use
%
% Return arguments:
% xmax     - calculated tile thickness (m)
% guess    - array of guesses from shooting method
% result   - array of results from guesses
% idx      - index for guess and result arrays
% pos      - position in time of maximum temperature (s)

% Initialise variables
i = 0;
xmax = 0;
x1 = 0.05;
x2 = 0.1;
Error1 = 10;
Error2 = 10;
guess = [];
result = [];

% Calculates a tile thickness so maximum internal tile face temperature is not exceeded (accurate to within 1K)
while abs(Error1) && abs(Error2) > 1
    [~,~,~,MT1,~] = shuttle(tmax, nt, x1, nx, method, thermCon, density, specHeat, sensor);
    Error1 = MT1 - intTemp;
    % Runs shuttle for a secondary x guess and calculates Error2
    [~,~,~,MT2,~] = shuttle(tmax, nt, x2, nx, method, thermCon, density, specHeat, sensor);
    Error2 = MT2 - intTemp;
    % Calculates next guess, xMax, using previous xMax and errors
    guess = [guess xmax];
    xmax = x2 - (Error2*(x2 - x1)/(Error2-Error1));


    % Replaces the furthest previous guess with the new xmax
    if abs(Error1) < abs(Error2)
        x2 = xmax;
        result = [result MT1];
    else
        x1 = xmax;
        result = [result MT2];
    end

    % Puts the first two values in each array
    while i <1
        i = i + 1;
        guess = [0.05 0.1];
        result = [MT1 MT2];
    end
end

% Sorts guess into ascending order
[guess,idx] = sort(guess, 'ascend');
result = result(idx);

% Read pos from shuttle.m using calculated xmax
[~,~,~,~,pos] = shuttle(tmax, nt, xmax, nx, method, thermCon, density, specHeat, sensor);


% Output messages for improved usabilty
if pos == tmax
    fprintf('Maximum Temperature Occured at Final Timestep, Increase Simulated Time \n')
else
    fprintf('Tile Thickness for %dK Max Internal Temperature is %d mm.\n',intTemp, round(xmax * 1e03))
end


%#ok<*AGROW>