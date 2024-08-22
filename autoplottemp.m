function[] = autoplottemp(sensor)
% Function to automatically record temperature data from graphs
%
% Input arguments:
% sensor       - Temperature graph selection
%
% Image from http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.26.1075&rep=rep1&type=pdf


% Select sensor to run simulation with
switch sensor
    case 'Sensor 1'
        name = 'temp597';
        img=imread([name '.jpg']);

    case 'Sensor 2'
        name = 'temp468';
        img=imread([name '.jpg']);

    case 'Sensor 3'
        name = 'temp850';
        img=imread([name '.jpg']);

    case 'Sensor 4'
        name = 'temp730';
        img=imread([name '.jpg']);

    otherwise
        error(['Undefined Sensor: ' sensor])
end

% Read image to find pixels containing red and green
R = img(:,:,1);
G = img(:,:,2);

% Find black pixels
[y,x]=find(and(R<=0,G<=0));
% Find red pixels 
[tempData,timeData]=find(and(R>=250,G<=180));


% Locate the graph axis from the image
count=1;
yaxis=[];
for k=1:length(x)-1

    if x(k)==x(k+1)
        count=count +1;
    end

    if x(k)~=x(k+1)
        count = 1;
    end

    if count>300
        yaxis=[count,x(k)];
        offset = mode(y);
    end
end

% Converting pixel data to time data in seconds
pixPerSec = (timeData(end)-yaxis(2))/2000;
xScale = (timeData - yaxis(2)) ./ pixPerSec;

% Converting pixel data to temperature data in kelvin
pixPerFar = (yaxis(end,1)/2000);
yScale = (((tempData - offset) ./ -pixPerFar) + 459.67) .*5/9;

% Average repeated values
[xScale,~,idx_2] = unique(xScale);
yScale = accumarray(idx_2,yScale,[],@mean);
yScale(end)=yScale(end-1);

% save data to .mat file with same name as image file
save('temp.mat','xScale','yScale')
