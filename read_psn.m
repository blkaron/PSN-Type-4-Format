%%---------------Read PSN Type 4 format file-----------------%%
%This is still in development, not many cases have been tested so there are
%probably unknown bugs regarding the variable header. Some check should
%also be added in future versions.
%Info: http://psn.quake.net/psnformat4.html
%Date: 01/11/2017
%Created by: Viktor Stoev

clear all;
close all;

fileName = uigetfile('*.psn','Select a psn file');
fileID = fopen(fileName);

if (fileID >= 3)
    fprintf('Success opening file: %s\n', fileName);
    
    %% Read fixed header data
    fixed_header_struct = memmapfile(fileName,'Format',{'uint8'  , [1 8] , 'headerID';...
                                                          'int32'  , [1 1] , 'varHdrLength';...
                                                          'uint16' , [1 1] , 'year';...
                                                          'uint8'  , [1 1] , 'month';...
                                                          'uint8'  , [1 1] , 'day';...
                                                          'uint8'  , [1 1] , 'hour';...
                                                          'uint8'  , [1 1] , 'minute';...
                                                          'uint8'  , [1 1] , 'seconds';...
                                                          'uint8'  , [1 1] , 'unused';...
                                                          'int32' , [1 1] , 'nanosecond';...
                                                          'double' , [1 1] , 'startTimeOffset';...
                                                          'double' , [1 1] , 'spsRate';...
                                                          'int32'  , [1 1] , 'sampleCount';...
                                                          'int32'  , [1 1] , 'flags';
                                                          'uint8'  , [1 3] , 'timeRefType';...
                                                          'uint8'  , [1 1] , 'timeRefStatus';...
                                                          'uint8'  , [1 1] , 'sampleType';...
                                                          'uint8'  , [1 1] , 'sampleCompression';...
                                                          'double' , [1 1] , 'compIncident';...
                                                          'double' , [1 1] , 'compAzimuth';...
                                                          'uint8'  , [1 1] , 'compOrientation';...
                                                          'uint8'  , [1 1] , 'sensorType';...
                                                          'double' , [1 1] , 'latitude';...
                                                          'double' , [1 1] , 'longitude';...
                                                          'double' , [1 1] , 'elevation';...
                                                          'uint8'  , [1 6] , 'name';...
                                                          'uint8'  , [1 4] , 'compName';...
                                                          'uint8'  , [1 6] , 'network';...
                                                          'double' , [1 1] , 'sensitivity';...
                                                          'double' , [1 1] , 'magCorr';...
                                                          'int16'  , [1 1] , 'atodBits',;...
                                                          'double' , [1 1] , 'minimum';...
                                                          'double' , [1 1] , 'maximum';...
                                                          'double' , [1 1] , 'mean';});
                                                      
    header_data = fixed_header_struct.data;
   
    datetime_struct = struct( 'year', header_data(1).year,...
                              'month',header_data(1).month,...
                              'day',header_data(1).day,...
                              'hour',header_data(1).hour,...
                              'minute',header_data(1).minute,...
                              'seconds',header_data(1).seconds,...
                              'unused',header_data(1).unused,...
                              'nanoseconds',header_data(1).nanosecond);
                             
    %% Read variable header data

    %use fread instead to decide how to handle the variable header data 
    fread(fileID, 154, 'uint8');
    
    %read in first byte of the variable header and check if no errors
    %(!0x55)
    
    variable_header_struct = struct('checkNumber', {},...
                                    'id', {},...
                                    'length', {},...
                                    'data', {});
    
    variable_header_struct(1).checkNumber   = fread(fileID, 1, 'uint8');
    variable_header_struct(1).id            = fread(fileID, 1, 'uint8');
    variable_header_struct(1).length        = fread(fileID, 1, 'int32');
    
    if variable_header_struct.checkNumber ~= 85
        display('Error reading the variable header'); 
        return
    end
    
    tmp_val = variable_header_struct(1).id;
    if tmp_val == 0
        % set data to 0 to indicate that there is nothing there
        variable_header_struct(1).data = 0;
    elseif tmp_val == 1 || tmp_val == 2 || tmp_val == 3
        % TODO - Error checks here
        if tmp_val == 1
            variable_header_struct(1).data = struct('location', fread(fileID, variable_header_struct.length, 'uint8'));
        elseif tmp_val == 2
            variable_header_struct(1).data = struct('sensorType', fread(fileID, variable_header_struct.length, 'uint8'));
        elseif tmp_val == 3
            variable_header_struct(1).data = struct('comment', fread(fileID, variable_header_struct.length, 'uint8'));
        end
    elseif tmp_val == 4 && variable_header_struct.length == 62
        tmp_memmap = memmapfile(fileName,'Offset',160, 'Format',{'uint16' , [1 1] , 'year';...
                                                          'uint8'  , [1 1] , 'month';...
                                                          'uint8'  , [1 1] , 'day';...
                                                          'uint8'  , [1 1] , 'hour';...
                                                          'uint8'  , [1 1] , 'minute';...
                                                          'uint8'  , [1 1] , 'seconds';...
                                                          'uint8'  , [1 1] , 'unused';...
                                                          'int32'  , [1 1] , 'nanosecond';...
                                                          'double' , [1 1] , 'latitude';...
                                                          'double' , [1 1] , 'longitude';...
                                                          'double' , [1 1] , 'depth';...
                                                          'int16'  , [1 1] , 'ms';...
                                                          'int16'  , [1 1] , 'mb';...
                                                          'int16'  , [1 1] , 'mw';...
                                                          'int16'  , [1 1] , 'ml';...
                                                          'int16'  , [1 1] , 'md';...
                                                          'int16'  , [1 1] , 'mOther';...
                                                          'uint8'  , [1 4] , 'otherType';...
                                                          'uint8'  , [1 1] , 'typeCode';...
                                                          'uint8'  , [1 1] , 'qualityChar';...
                                                          'uint16' , [1 1] , 'flags';...
                                                          'uint8'  , [1 6] , 'agency';});
                                                          
        variable_header_struct(1).data = struct('eventInfo',...
                      struct( 'Datetime', struct( 'year', tmp_memmap(1).year,...
                                                  'month',tmp_memmap(1).month,...
                                                  'day',tmp_memmap(1).day,...
                                                  'hour',tmp_memmap(1).hour,...
                                                  'minute',tmp_memmap(1).minute,...
                                                  'seconds',tmp_memmap(1).seconds,...
                                                  'unused',tmp_memmap(1).unused,...
                                                  'nanoseconds',tmp_memmap(1).nanosecond)),...
                              'latitude', tmp_memmap(1).latitude,...
                              'longitude', tmp_memmap(1).longitude,...
                              'depth', tmp_memmap(1).depth,...
                              'ms', tmp_memmap(1).ms,...
                              'mb', tmp_memmap(1).mb,...
                              'mw', tmp_memmap(1).mw,...
                              'ml', tmp_memmap(1).ml,...
                              'md', tmp_memmap(1).md,...
                              'mOther', tmp_memmap(1).mOther,...
                              'otherType', tmp_memmap(1).otherType,...
                              'typeCode', tmp_memmap(1).typeCode,...
                              'qualityChar', tmp_memmap(1).qualityChar,...
                              'flags', tmp_memmap(1).flags,...
                              'agency', tmp_memmap(1).agency);
    
        clear tmp_memmap;
    elseif tmp_val == 5 && variable_header_struct.length == 42
        tmp_memmap = memmapfile(fileName,'Offset',160, 'Format',{'uint16' , [1 1] , 'year';...
                                                          'uint8'  , [1 1] , 'month';...
                                                          'uint8'  , [1 1] , 'day';...
                                                          'uint8'  , [1 1] , 'hour';...
                                                          'uint8'  , [1 1] , 'minute';...
                                                          'uint8'  , [1 1] , 'seconds';...
                                                          'uint8'  , [1 1] , 'unused';...
                                                          'int32'  , [1 1] , 'nanosecond';...
                                                          'uint8'  , [1 8] , 'phaseName';...
                                                          'uint16' , [1 1] , 'flags';...
                                                          'int16'  , [1 1] , 'yLocation';...
                                                          'uint8'  , [1 16], 'fileName';...
                                                          'int16'  , [1 1] , 'tableDepth';});
                                                      
        variable_header_struct(1).data = struct('pickinfo',...
                      struct( 'Datetime', struct( 'year', tmp_memmap(1).year,...
                                                  'month',tmp_memmap(1).month,...
                                                  'day',tmp_memmap(1).day,...
                                                  'hour',tmp_memmap(1).hour,...
                                                  'minute',tmp_memmap(1).minute,...
                                                  'seconds',tmp_memmap(1).seconds,...
                                                  'unused',tmp_memmap(1).unused,...
                                                  'nanoseconds',tmp_memmap(1).nanosecond)),...
                              'latitude', tmp_memmap(1).phaseName,...
                              'flags', tmp_memmap(1).flags,...
                              'yLocation', tmp_memmap(1).yLocation,...
                              'fileName', tmp_memmap(1).fileName,...
                              'tableDepth', tmp_memmap(1).tableDepth);
        clear tmp_memmap;
    elseif tmp_val == 6 && variable_header_struct.length >0
        variable_header_struct(1).data = struct('Sample data', fread(fileID, variable_header_struct.length, 'uint8'));
    elseif tmp_val == 7 && variable_header_struct.length >0
        variable_header_struct(1).data = struct('DataLoggerIdstring', fread(fileID, variable_header_struct.length, '*char'));
    else
        % TODO - add the other structures and options
        variable_header_struct(1).data = struct('Other options', fread(fileID, variable_header_struct.length, 'uint8'));
    end
    fread(fileID, fixed_header_struct.data(1).varHdrLength - (variable_header_struct.length + 6), 'uint8'); %read the rest of the bytes although they are meaningless
    clear tmp_val
    %% Read the data samples
    data_vector = zeros(1, fixed_header_struct.data(1).sampleCount);
    tmp_cnt = fixed_header_struct.data(1).sampleCount;
    for i = 1 : fixed_header_struct.data(1).sampleCount
        if ~(fixed_header_struct.data(1).sampleType)
            tmp_dat = fread(fileID, 1, 'int16');
            if(tmp_dat > intmax('int16'))
                display('Error reading data'); 
                return
            end
        elseif fixed_header_struct.data(1).sampleType == 1
            tmp_dat = fread(fileID, 1, 'int32');
            if(tmp_dat > intmax('int32'))
                display('Error reading data'); 
                return
            end
        elseif fixed_header_struct.data(1).sampleType == 2
            tmp_dat = fread(fileID, 1, 'float');
            if(tmp_dat > intmax('float'))
                display('Error reading data'); 
                return
            end
        elseif fixed_header_struct.data(1).sampleType == 3
            tmp_dat = fread(fileID, 1, 'double');
            if(tmp_dat > intmax('double'))
                display('Error reading data'); 
                return
            end
        end
        data_vector(i) = tmp_dat;
        tmp_cnt = tmp_cnt - 1;
    end
    
    fclose(fileID);
else
    fprintf('Error opening file: %s\n', fileName);
end

figure;
plot(data_vector);
title(fileName);
xlabel('Sample number');
ylabel('Sample Magnitude');