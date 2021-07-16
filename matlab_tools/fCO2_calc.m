function fCO2_calc(matlabfile_processed,check_plots)
% 
% 
% Script to make corrections for the pCO2 data from the SCT system
% File from Sören used for the Volvo Ocean Race, modified for Newrest
% 
% script from Toste with some small edits to make more generic

if nargin ==1;check_plots=1;end % make check plots by default

%% INPUT 
% matlabfile_processed = matlab file processed using dataloader()

load(matlabfile_processed); % matlabfile_processed = matlab file obtained from dataloader.m
seconds1 = second; % just to bug with function name

% make a time vector
time_matlab=datenum(year, month , day , hour , minute , seconds1);
time_minutes=datenum(year, month , day , hour , minute , seconds1)*24*60; T0=min(time_minutes); % units of minutes
time_minutes=time_minutes - T0;

%% pCO2 Korrekturen: unter zuhilfenahme von Ricardos und Pierres Formeln und Erklärungen
% 0.: Temperatur an der Membran abschätzen:
% sbe38 = (SCTwatertemp * 0.97536)-0.18558;
% sbe38 = SCTwaterTempt + 0.5;

xCO2=CO2;
% 1.: Der Wasserdampfdruck ausrechnen: nach Weiss and Price 1980
wvp = exp(24.4543 - (67.4509*(100./(waterTemp+273.15))) -(4.8489.*log((waterTemp+273.15)./100)) - 0.0000544.*salinity);
% correct for the pressure difference between the Licor and the membrane P_Membran=P_Licor - P_diff
% First take the median of the Pdiff
try
    P_diff=median(DPressInt);
catch
    P_diff=-10; % Just for getting a number.
    disp('using P_diff=10 no DPressInt available')
end
% Now make make the correction
CellPress=CellPress-P_diff;   
% 2: MK2-Werte Druckkorregieren:  nach DOE Handbook
MK2pCO2 = xCO2 .* (CellPress-wvp)./1013.249977; % von mBar in atm 
% 3: MK2-Werte mit in-situ Temperatur korregieren: nach Takahashi et al., 1993
pCO2 = MK2pCO2 .* exp(0.0423 * (waterTemp - waterTemp));  % This is now pCO2 
 
%%fCO2 calculation
SCTinK=waterTemp+273.15;
BCO2=-1636.75+12.0408*SCTinK-0.0327957*SCTinK.*SCTinK+0.0000316528.*SCTinK.*SCTinK.*SCTinK;
DCO2=57.7-0.188*SCTinK;
Zaehler=(BCO2+2*(1-xCO2*1e-6).*(1-xCO2*1e-6).*DCO2).*(CellPress./1013.249977);
fCO2=pCO2.*exp(Zaehler./(82.0578*SCTinK));

%% Some check plots
if check_plots
    % from S.Raimund codes
    % Status OLD: 1 = Span; 2= Zero; 5 = Operate; 19= Warmup; 21= Standby
    % Status NEW: 1 = Span; 2= Zero; 3 = Operate; 4= Warmup; 5= Standby
    
    % posfig(1);
    figure
    subplot(2,2,1);
    plot(time_matlab,fCO2,'b.');
    ylabel('fCO_2');
    hold on;
    F=find(STATUS == 2); plot(time_matlab(F),fCO2(F),'r.'); % ZERO
    F=find(STATUS == 1); plot(time_matlab(F),fCO2(F),'g.'); % SPAN/CALIBRATION
    F=find(STATUS == 19); plot(time_matlab(F),fCO2(F),'c.'); % WARMUP
    F=find(STATUS == 4); plot(time_matlab(F),fCO2(F),'k+'); % STANDBY
    F=find(STATUS == 5); plot(time_matlab(F),fCO2(F),'b.'); % OPERATE
    F=find(STATUS == 18); plot(time_matlab(F),fCO2(F),'m+'); % ??
    F=find(STATUS == 21); plot(time_matlab(F),fCO2(F),'y+'); % STANDBY OLD
    
    % legend('water','Zero','span');
    subplot(2,2,2);
    plot(time_matlab,waterTemp,'b.');
    ylabel('Watertemp');
    
    subplot(2,2,3);
    plot(time_matlab,salinity,'b.');
    ylabel('SCTsalinity');
    
    subplot(2,2,4);
    plot(time_matlab,CellPress,'b.');
    ylabel('cellpress');
    
    print -djpeg Checkplot1
end

%% Lat and lon are in minutes and seconds, recalculate that
latdeg=fix(Latitude); latmin=(Latitude-latdeg)*100; % latsec=floor((SCTlat-latdeg-(latmin/100))*10000);      
latitude=latdeg+latmin/60; %+ latsec/100; 
% Using the floor command do not work around 0 N/S or E/W.... Use Fix

% SCTlonorg=SCTlon;
londeg=fix(Longitude); lonmin=(Longitude-londeg)*100; % lonsec=floor((fix(SCTlon*100)-(SCTlon*100))*100)/60*100;  
longitude=londeg+lonmin/60;

lon=longitude;lat=latitude;
lon(lon==0)=NaN;lat(lat==0)=NaN;

if check_plots
    % posfig(2);
    figure
    plot(lon,lat,'.');
    fCO2all=fCO2;
    print -djpeg Checkplot2
    
    figure
    scatter(longitude,latitude,10,fCO2);caxis([100 700])
end
%% Remove periods of zero or calibration and following minutes
%% Don't include calibration or span data (STATUS == 2 | STATUS == 1)
%% and the next 30 minutes after these events
% It seems that it takes ~30 minutes after a 0 for the instrument to be back
% to normal.

remove_minutes_before = 0.01;
remove_minutes_after = 30.0;

F= find(STATUS < 5 | STATUS > 5);  % STATUS = OPERATE

for i=1:length(F),
    T=find(time_minutes > time_minutes(F(i))-remove_minutes_before & time_minutes < time_minutes(F(i))+remove_minutes_after); 
    fCO2(T)=NaN; salinity(T)=NaN; CO2(T)=NaN; 
end

if check_plots
    % posfig(2);
    figure;
    plot(time_matlab,fCO2all,'r.'); hold on
    plot(time_matlab,fCO2,'b.');
    legend('All data', 'data logged when STATUS = OPERATE')
    datetick('x','dd-mm-yyyy')
    grid on
    print -djpeg Checkplot3
    
    figure
    subplot 211
    plot(time_matlab,fCO2all);grid on
    title('fCO2')
    subplot 212
    plot(time_matlab(2:end),diff(fCO2all));grid on
    title('fCO2 gradient')
    hold on
    % DIFF=diff(fCO2all);
    % T_DIFF = time_matlab(2:end);
    % ID_BAD = find(DIFF>1);
    % plot(T_DIFF(ID_BAD),DIFF(ID_BAD),'r.')
end
%% Make one minute averages of the data

% >> consider using matlab built-in function?
% https://au.mathworks.com/matlabcentral/answers/450002-how-do-i-compute-3-minute-moving-average-in-timeseries
% % % data = load('./Analysis_TORE_FULL_AmberSail/SCT_DATA_TORE_FULL.mat');
% % % time_matlab = datenum(data.year,data.month,data.day,data.hour,data.minute,data.second);
% % % TT = datetime(time_matlab,'ConvertFrom','datenum'); % convert to datetime
% % % chl_aChl_a = data.chl_aChl_a;
% % % chl_aChl_a_MOVMEAN = movmean(chl_aChl_a, minutes(1),'omitnan', 'SamplePoints', TT)

%multy=1000*SCTfluoro(:,1);
%SCTfluoro1=multy;
PCO2=[]; FCO2=[]; XCO2=[];LAT=[]; LON=[]; SAL=[]; TEM=[]; ZERO=[]; CHLO=[];
YEAR=[]; MONTH=[]; DAY=[]; HOUR=[]; MINUTE=[];
FLOW=[]; FLOWOCEAN=[]; VALVE=[];CELL=[]; CELLPRESS=[];
status=[]; TIME=[];

for i=[1:6:length(time_minutes)-6],
    pco2=nanmean(pCO2(i:i+6)); PCO2=[PCO2 ; pco2];
    fco2=nanmean(fCO2(i:i+6)); FCO2=[FCO2 ; fco2];
    xco2=nanmean(xCO2(i:i+6)); XCO2=[XCO2 ; xco2];
    la=latitude(i); LAT=[LAT ; la];
    lo=longitude(i); LON=[LON ; lo];
    sa=median(salinity(i:i+6)); SAL=[SAL ; sa];
    te=nanmean(waterTemp(i:i+6)); TEM=[TEM ; te];
    ye=nanmean(year(i)); YEAR=[YEAR ; ye];
    mo=nanmean(month(i)); MONTH=[MONTH ; mo];
    da=day(i); DAY=[DAY ;da];
    ho=hour(i); HOUR=[HOUR ; ho];
    mi=minute(i); MINUTE=[MINUTE ; mi];
    cp=nanmean(CellPress(i:i+6)); CELLPRESS=[CELLPRESS ; cp];
    st=STATUS(i); status=[status ;st]; 
    ti=time_minutes(i); TIME=[TIME ; ti];
end

MINUTE=round(MINUTE);
HOUR=round(HOUR);
DAY=round(DAY);
MONTH=round(MONTH);
YEAR=round(YEAR);

% rename
pCO2=PCO2; fCO2=FCO2; xCO2=XCO2; latitude=LAT; longitude=LON; salinity=SAL; temperature=TEM; year=YEAR; month=MONTH; day=DAY; hour=HOUR; minute=MINUTE; 
CellPress=CELLPRESS; time=TIME;

longitude(longitude==0)=NaN;
latitude(latitude==0)=NaN;
% xCO2(xCO2<155)=NaN;
% pCO2(pCO2<155)=NaN;

% still some outliers for salinity. Remove those. 
if 0 % probably not relevant here since ambient salinity is low
    disp('removing salinity below 33.5 PSU')
    T=find(salinity < 30.);
    fCO2(T)=NaN; salinity(T)=NaN; CO2(T)=NaN;
end

%% Do some more check plots for final data 
if check_plots
    % posfig(4);
    figure
    subplot(2,2,1);
    plot(time,fCO2,'b.');
    ylabel('fCO2');
    grid on
    
    subplot(2,2,2);
    plot(time,temperature,'b.');
    ylabel('Watertemp');
    grid on
    
    subplot(2,2,3);
    plot(time,salinity,'b.');
    ylabel('SCTsalinity');
    grid on
    
    subplot(2,2,4);
    plot(time,CellPress,'b.');
    ylabel('cellpress');
    grid on
    
    print -djpeg Checkplot4
end

%% EXPORT CLEAN DATA
[p,f,e]=fileparts(matlabfile_processed);
data=[year month day hour minute latitude longitude temperature salinity CellPress xCO2 pCO2 fCO2 time];
F=find(isnan(fCO2));
data(F,:)=[];
year=data(:,1); month=data(:,2); day=data(:,3); hour=data(:,4); minute=data(:,5); latitude=data(:,6); longitude=data(:,7); 
temperature=data(:,8);salinity=data(:,9); CellPress=data(:,10); xCO2=data(:,11); pCO2=data(:,12); fCO2=data(:,13); time=data(:,14);

save([p filesep f '_QC.mat'],'year','month','day','hour','minute','latitude','longitude','temperature','salinity','CellPress','xCO2','pCO2','fCO2','time');

% Make a txt file
data2=[year month day hour minute latitude longitude temperature salinity CellPress xCO2 pCO2 fCO2];
header = {'year','month','day','hour','minute','latitude','longitude','temperature_degC','salinity_PSU','CellPress','xCO2_ppm','pCO2_muatm','fCO2_muatm'};
% 
% add pC02 anomaly
% From Soeren : "To have a rough estimate whether the area you are crossing is a sink or a source of CO2,
% you could subtract 415 muatm to your pCO2 value so you get an anomaly. This might help to interpret the measurements. "
data2=[data2 data2(:,12)-415];
header = [header 'pCO2_muatm-415_muatm']; 
writefile([p filesep f '_QC.csv'],header,data2); 

% fid = fopen([f '_QC.csv'], 'w' );
% fprintf(fid,'%d,%d,%d,%d,%d,%4.2f,%4.2f,%4.3f,%4.3f,%4.1f, %4.1f, %4.1f, %4.1f\n',data2');
% fclose(fid); 

if check_plots
    %% Make a plot for the archive
    % posfig(5),
    figure
    plot(time,fCO2,'b.'); hold on
    plot(time,fCO2,'b');
    ylabel('fCO_2');
    xlabel('Time');
    title(f,'interpreter','none');
    print([f],'-djpeg')
end

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






