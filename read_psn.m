%%---------------Read PSN Type 4 format file-----------------%%
%This is still in development, not many cases have been tested so there are
%probably unknown bugs regarding the variable header. Some check should
%also be added in future versions.
%Info: http://psn.quake.net/psnformat4.html
%Date: 01/11/2017
%Created by: Viktor Stoev

clear all;
close all;

[fileName, pathName] = uigetfile('*.psn','Select a psn file');

[fixed_header, var_header, data_vector] = readPSN(fileName, pathName);
figure;
plot(data_vector);
title(fileName);
xlabel('Sample number');
ylabel('Sample Magnitude');