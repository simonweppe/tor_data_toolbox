function MAIN()

addpath('/home/simon/Documents/GitHub/tor_data_toolbox/matlab_tools/')
rmpath /home/simon/Documents/GitHub/GIMP2/gui_function/

% Inputs:
%   label 1:    Year, Leg, general description
%   label 2:    vessel, owner etc
label1 = 'TORE_leg1_2_3'
label2 = '11thHour'
    
outfile_matlab = dataloader(label1,label2)
outfile_matlab = ['./Analysis_' label1 '_' label2 '/SCT_DATA_' label1 '.mat'];
check_plots = 0
fCO2_calc(outfile_matlab,check_plots);
% check_plots_stefan(outfile_matlab)

%% Further QC/Clipping of data as there are still some outliers even after 
%% removing all calibration period + 30 minutes after
clear all
% start from processed data
data = load('./Analysis_TORE_leg1_2_3_11thHour/SCT_DATA_TORE_leg1_2_3_QC.mat');
time_matlab = datenum(data.year,data.month,data.day,data.hour,data.minute,0);

% period to clip 1
% '02-Jun-2021 13:12:00' >> '07-Jun-2021 04:51:00'
ID_BAD = time_matlab>=datenum(2021,6,2,13,0,0) & time_matlab<=datenum(2021,6,7,5,0,0);
% This could actually be some good data during Mirpuri Trophy Coastal Race 
% '05-Jun-2021 11:00:00' > '05-Jun-2021 15:00:00' 
% but large variations during a single day, and spike at end - check with Toste 
ID_BAD(time_matlab>=datenum(2021,6,5,11,00,0) & time_matlab<=datenum(2021,6,5,15,00,0))=0;
data.fCO2(ID_BAD) = NaN;data.xCO2(ID_BAD) = NaN;data.pCO2(ID_BAD) = NaN;
data.temperature(isnan(data.pCO2)) = NaN;data.salinity(isnan(data.pCO2)) = NaN;

% period to clip 2
% '09-Jun-2021 10:38:00' >> '13-Jun-2021 15:43:00'
ID_BAD = time_matlab>=datenum(2021,6,9,10,40,0) & time_matlab<=datenum(2021,6,13,15,45,0);
data.fCO2(ID_BAD) = NaN;data.xCO2(ID_BAD) = NaN;data.pCO2(ID_BAD) = NaN;
data.pCO2(data.pCO2<=320)=NaN;data.xCO2(data.xCO2<=320)=NaN;  % to remove some outliers
data.temperature(isnan(data.pCO2)) = NaN;data.salinity(isnan(data.pCO2)) = NaN;

% period to clip 3
% '16-Jun-2021 22:40:00' >> '17-Jun-2021 03:12:00'
ID_BAD = time_matlab>=datenum(2021,6,16,22,40,0) & time_matlab<=datenum(2021,6,17,3,12,0);
data.fCO2(ID_BAD) = NaN;data.xCO2(ID_BAD) = NaN;data.pCO2(ID_BAD) = NaN;
data.pCO2(time_matlab>=datenum(2021,6,13,16,40,0) & data.pCO2<=356)=NaN; % specific threshold for that case
data.xCO2(time_matlab>=datenum(2021,6,13,16,40,0) & data.xCO2<=356)=NaN; % specific threshold for that case
data.temperature(isnan(data.pCO2)) = NaN;data.salinity(isnan(data.pCO2)) = NaN;

%% Figure showing initial and "cleaned" data
data_init = load('./Analysis_TORE_leg1_2_3_11thHour/SCT_DATA_TORE_leg1_2_3_QC.mat'); 

figure;
subplot 511
plot(time_matlab,data_init.fCO2,'r');hold on
plot(time_matlab,data.fCO2,'k');ylabel('fCO2');ylim([200 700]);grid on
subplot 512
plot(time_matlab,data_init.pCO2,'r');hold on
plot(time_matlab,data.pCO2,'k');ylabel('pCO2');ylim([200 700]);grid on
subplot 513
plot(time_matlab,data_init.xCO2,'r');hold on
plot(time_matlab,data.xCO2,'k');ylabel('xCO2');ylim([200 700]);grid on
subplot 514
plot(time_matlab,data_init.salinity,'r');hold on
plot(time_matlab,data.salinity,'k');ylabel('salinity');grid on
subplot 515
plot(time_matlab,data_init.temperature,'r');hold on
plot(time_matlab,data.temperature,'k');ylabel('temperature');grid on
datetick('x','dd-mm-yy','keepticks','keeplimits')

figure;
subplot 211
hold on;grid on
plot(time_matlab,data_init.fCO2,'r');plot(time_matlab,data_init.pCO2,'g');plot(time_matlab,data_init.xCO2,'b');
ylim([200 700])
title('before cleaning')
subplot 212
hold on;grid on
plot(time_matlab,data.fCO2,'r');plot(time_matlab,data.pCO2,'g');plot(time_matlab,data.xCO2,'b')
title('after cleaning')
ylim([200 700])
datetick('x','dd-mm-yy','keepticks','keeplimits')

% More checks on cleaned data
% figure
% scatter(data_init.longitude,data_init.latitude,10,data_init.fCO2)
% 
% figure
% scatter(data.longitude,data.latitude,10,data.salinity)

%%  Export a comma-delimited file
data2=[data.year data.month data.day data.hour data.minute data.latitude data.longitude data.temperature data.salinity data.CellPress data.xCO2 data.pCO2 data.fCO2];
header = {'year','month','day','hour','minute','latitude','longitude','temperature_degC','salinity_PSU','CellPress','xCO2_ppm','pCO2_muatm','fCO2_muatm'};
% add anomaly metric
data2=[data2 data2(:,12)-415];
header = [header 'pCO2_muatm-415_muatm'];
writefile(['./Analysis_TORE_leg1_2_3_11thHour/SCT_DATA_TORE_leg1_2_3_QC_CLEANED.csv'],header,data2);

%% Add PH to data (From Soeren archives)
data.alkalinity = 2305 + 58.66.*(data.salinity-35)+2.32.*(data.salinity-35).^2 - 1.41.*(data.temperature-20) + 0.040.*(data.temperature-20).^2;
% From Lee et al. see paper in '/media/simon/Seagate Backup Plus Drive/theoceanrace/matlab_tools/top_copy/pH'

% % from their example
%     par1type =    1; % The first parameter supplied is of type "1", which is "alkalinity"
%     par1     = 2400; % value of the first parameter
%     par2type =    2; % The first parameter supplied is of type "1", which is "DIC"
%     par2     = [2100:5:2300]; % value of the second parameter, which is a long vector of different DIC's!
%     sal      =   35; % Salinity of the sample
%     tempin   =   10; % Temperature at input conditions
%     presin   =    0; % Pressure    at input conditions
%     tempout  =    0; % Temperature at output conditions - doesn't matter in this example
%     presout  =    0; % Pressure    at output conditions - doesn't matter in this example
%     sil      =   50; % Concentration of silicate  in the sample (in umol/kg)
%     po4      =    2; % Concentration of phosphate in the sample (in umol/kg)
%     pHscale  =    1; % pH scale at which the input pH is reported ("1" means "Total Scale")  - doesn't matter in this example
%     k1k2c    =    4; % Choice of H2CO3 and HCO3- dissociation constants K1 and K2 ("4" means "Mehrbach refit")
%     kso4c    =    1; % Choice of HSO4- dissociation constants KSO4 ("1" means "Dickson")
%     % Do the calculation. See CO2SYS's help for syntax and output format
%     A=CO2SYS(par1,par2,par1type,par2type,sal,tempin,tempout,presin,presout,sil,po4,pHscale,k1k2c,kso4c);

[DATA,HEADERS,NICEHEADERS]=CO2SYS(data.pCO2,data.alkalinity,4,1,data.salinity,data.temperature,data.temperature,3,3,0,0,1,10,1);
% https://cdiac.ess-dive.lbl.gov/ftp/co2sys/CO2SYS_calc_MATLAB_v1.1/
% pressure in dbar is equivalent to the depth of the water intake ~2-3 m below surface
% or simply use 0 since measurement made onboard ?
% small difference in predicted pH anyway

data.pH = DATA(:,37);
% figure
% scatter(data.longitude,data.latitude,10,data.pH)

% Make a txt file
data2=[data.year data.month data.day data.hour data.minute data.latitude data.longitude data.temperature data.salinity data.CellPress data.xCO2 data.pCO2 data.fCO2];
header = {'year','month','day','hour','minute','latitude','longitude','temperature_degC','salinity_PSU','CellPress','xCO2_ppm','pCO2_muatm','fCO2_muatm'};
% add pH
data2=[data2 data.pH];
header = [header 'pH']; 
writefile(['./Analysis_TORE_leg1_2_3_11thHour/SCT_DATA_TORE_leg1_2_3_QC_CLEANED_PH.csv'],header,data2,',');

function writefile(fname,header,data)
%  writefile(fname,header,data)
% fname='filename' in quotes
% header=cell with each column header string
% data data to write, must have same nb of columns as header

fid=fopen(fname,'w');
if ~isempty(header)
    if length(header)==1;
        fprintf(fid,'%s\n',header{1})
        fclose(fid);
    else
        for kk=1:length(header)-1
            fprintf(fid,'%s,',header{kk});
        end
        fprintf(fid,'%s\n',header{kk+1});
        fclose(fid);
    end
end
dlmwrite(fname,[data],'delimiter',',','precision','%.10f','-append');
% dlmwrite(fname,[data],'delimiter',' ','-append','precision','%e');




