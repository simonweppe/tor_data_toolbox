function outfile_matlab = dataloader(label1,label2)
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % This script provides a flexible way of loading variables from the 
    % .log files output by the SubCtech Oceanpack datalogging system (SCT).
    % One restriction is given, all files in the directory have to have the 
    % same headers names and header order.
    %
    % example function call:
    %   dataloader('2018','Malizia')
    %
    % Inputs:
    %   label 1:    Year, Leg, general description
    %   label 2:    vessel, owner etc
    %
    % Outputs:
    %   The function generates a .mat-File in a folder defined by the labels
    %       e.g. Analysis_2018_Malizia
    %
    % v1.0, 2018-NOV-09, Thorsten-Andre Stoffers, Kiel, Germany.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Prosses Inputvalues
%     label1 = "11thHour";       % label 1: Vessel, owner etc
%     label2 = "TestTORE";   % label 2: Year, Leg, general description
    label1 = char(label1);    % transform String in Char
    label2 = char(label2);    % transform String in Char

    %% Create Folder for Analysis
    combinedStrFo = strcat('Analysis_',label1, '_', label2);   % Folder Name
    mkdir(combinedStrFo); 

    %% Read Files
    clc; fclose all; % Clear Workspace
    files = dir('*.log'); % Load all files with the .log termination
    fprintf('Files found: %s\n',int2str(length(files))); % Output the amount of found files
    headerfound = 0; % Only find 1 header, no change should happen
    %% Data needs to be read seperately from the different files and than be concatinated
    for i = 1:length(files)
        linesparsed = 1;
        datalinesfound = 0;
        filedone = 0;
        tic % to measure the used time per file
        filei=files(i).name; % hands the filename to the loop
        fprintf('\nNow loading: %s\n',filei)
        fid = fopen(filei); % opens the file
        while filedone == 0	
            cl = fgetl(fid); % read a line
            tmp1 = int2str(linesparsed);
            tmp2 = int2str(datalinesfound);
            if cl == -1
                fprintf('*** End of datafile reached after %s lines. Found %s lines of data.\n', tmp1, tmp2);
                filedone = 1;
            elseif strcmp(cl(1:5),'@NAME')&& headerfound==0 % Determine data width
                fprintf('*** Header information found in line %s.\n', tmp1);
                headernames = textscan(cl,'%s','delimiter',',');
                headernames = string(headernames{1}');
                headerfound = 1;
            elseif strcmp(cl(1:5),'@NAME')&& headerfound==1 % Determine data width
                fprintf('*** Another header was encountered in the datafile around line %s.\n', tmp1)
            elseif strcmp(cl(1:5),'@DATA') % read data from that line
                datalinesfound = datalinesfound + 1;
                data = textscan(cl,'%s','delimiter',',');
                data = string(data{1}');
                B(datalinesfound,:) = data;
            end
            linesparsed = linesparsed + 1;		
        end
        % Determine if the big matrix exist or not to avoid an error with only
        % the else variant
        x = exist('A','var');
        if x == 0
            A = B(1:datalinesfound,:);
        else
            A= [A ; B(1:datalinesfound,:)];
        end
        clear B
        fclose(fid);
        fclose('all');	
        toc
    end
    if ~isempty(files)
        tic
        clear tmp1 tmp2 cl data headerfound linesparsed datalinesfound x B filedone fid i filei files ans;
        fprintf('\nConvert string data to numbers for further procession.\n');
        %% Make sure all headernames are able to be a variable in MatLab
        headernames = erase(headernames,["/","."," ","-"]);
        %% Cut the @Data/@Header from the Data and headers
        Data        = A(:,2:length(headernames));
        clear A
        headernames = headernames(2:length(headernames));
        %% Generate single vectors from the data based on the headername and a SCT infront
        fprintf('*** Generate single vectors based on SCT plus headername.\n');
        for j = 1:length(headernames)
            
            eval([ headernames{j} ' = Data(:,' int2str(j) ');']); 
            %the following if structure makes sure that all data is saved as a
            %number with exceptions for TIME, DATE, and  *Cal Values....
            if strcmp(headernames{j} , 'DATE')     || strcmp(headernames{j} , 'TIME')    ||....
               strcmp(headernames{j} , 'H2OzCal')  || strcmp(headernames{j} , 'CO2zCal') ||....
               strcmp(headernames{j} , 'Span1Cal') || strcmp(headernames{j} , 'Span2Cal') 

            else
                eval([headernames{j} ' = double(' headernames{j} ');']);

            end
        end
        clear Data
        %% Split the DATE and TIME into single values for easy access, before it delete the string-versions
        fprintf('*** Generate Time and Date devides vectors.\n');
        for i = 1:length(DATE) %#ok<*USENS>
            year(i,1)    = double(string(DATE{i}(1:4))); %#ok<*IDISVAR>
            month(i,1)   = double(string(DATE{i}(6:7)));
            day(i,1)     = double(string(DATE{i}(9:10)));
            hour(i,1)    = double(string(TIME{i}(1:2)));
            minute(i,1)  = double(string(TIME{i}(4:5)));
            second(i,1)  = double(string(TIME{i}(7:8)));
        end
        clear DATE TIME

        %% Make date-time vectors
        fprintf('*** Generate date-time vectors.\n')
        datetimes = datenum([year month day hour minute second]);
        dt       = datetime([year month day hour minute second]);

        %% Convert to correct format for Latitude and Longitude - if available
        x = exist('Latitude','var');
        if x == 0 
        else
            Latitude = Latitude/100;
            Longitude = Longitude/100;
        end



        %% Save only needed data "SCT" 
        clear i j headernames x combinedStrFo
        fprintf('*** Save the data to the .mat file.\n');
         %Where to save the mat-File
        save(strcat(strcat('Analysis_',label1, '_', label2),'/SCT_DATA_',label1,'.mat'));% only variables with 'SCT*' will be saved
        outfile_matlab=['./' strcat(strcat('Analysis_',label1, '_', label2),'/SCT_DATA_',label1,'.mat')];
%         outfile_matlab = 'Analysis_',label1, '_', label2),'/SCT_DATA_',label1,'.mat');
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        %%
        toc

        fprintf('\n******************************************************\n');
        fprintf('*\n*\n*\t\t\t\t\tEnd data load\n*\n*\n');
        fprintf('******************************************************\n');
    else
        fprintf('\nNo files found. Check folder if .log files are inside.\n');
    end
end
