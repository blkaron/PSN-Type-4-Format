%%---------------Read PSN Type 4 format file-----------------%%
%This is still in development, not many cases have been tested so there are
%probably unknown bugs regarding the variable header. The calc_time_vector
%is a bit slowish and can be better rewriten. For a 12k data points vector it
%is OK.
%
%Info: http://psn.quake.net/psnformat4.html
%Date: 07/11/2017
%Created by: Viktor Stoev

clear all;
close all;

[fileName, pathName] = uigetfile('*.psn','Select a psn file');

[fixed_header, var_header, data_vector] = readPSN(fileName, pathName);

data = data_vector * fixed_header.sensitivity;

[time_vector, time_vector_str] = calc_time_vector(fixed_header);

%Plot the date against the a time_vector consisting of string timestamps
figure(1);
plot(time_vector_str, data, 'DatetimeTickFormat','HH:mm:ss');
title(fileName);
if fixed_header.sensorType == 2
    ylabel('Sensor output [cm/sec]');
else
    ylabel('Sensor output [ADC range]');
end

xlabel('Time [hh:mm:ss]');
xlim([datenum(time_vector_str(1)),datenum(time_vector_str(end))]);
grid on;
box on;