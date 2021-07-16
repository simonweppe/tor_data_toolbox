%% Figure 10: Map (xCO2)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script von Toste/Sören. Ursprünglich für das VOR Projekt 
% Geomar
%
% modifiziert: 2018-06-06, Stefan Raimund, SubCtech
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [figDescrip10] = plot_10(matlabfile_processed,all,timeframe,label2,label3) %Zeitachse wird nicht modifiziert (wie in den anderen xy-Plots)

% % load('SCT_DATA_FRA56.mat'); 
load(matlabfile_processed)

figDescrip10 = "xCO2 [ppm]"; 
figDescrip10 = char(figDescrip10); %beschreibt das Figure und nutzt den Char für den Dokumentennamen
 
fig10_handle = figure(10);

%% Lat and lon are in minutes and seconds, recalculate that
latdeg=floor(Latitude); latmin=(Latitude-latdeg)*100; % latsec=floor((Latitude-latdeg-(latmin/100))*10000);      
Latitude=latdeg+latmin/60; %+ latsec/100;

% Longitudeorg=Longitude;

londeg=fix(Longitude); lonmin=abs((Longitude-londeg)*100); % lonsec=floor((fix(Longitude*100)-(Longitude*100))*100)/60*100;  
F=find(Longitude <-1);
Longitude(F)=(abs(londeg(F))+lonmin(F)/60)*(-1);
F=find(Longitude >=-1 & Longitude <0);
Longitude(F) = (abs(londeg(F))+lonmin(F)/60)*(-1);
F=find(Longitude >=0 & Longitude <1);
Longitude(F) =abs(londeg(F))+lonmin(F)/60;
F=find(Longitude >=1);
Longitude(F)=abs(londeg(F))+lonmin(F)/60;

Longitude=Longitude;  % to plot the map
F=find(waterTemp>30); waterTemp(F)=NaN; % Several outliers in temp data

pCO2=CO2; lat=Latitude; lon=Longitude; 


% Calculate the trend (pCO2 / min) and find the time when the values are
% stable, i.e. when DER <1
    DER=[];
    for i=1:length(pCO2)-1,
        der=abs(pCO2(i)-pCO2(i+1));
        DER=[DER,der];
    end

% Assume that all measurements before the pCO2 data are stable are bad
F=find(DER>0.3); pCO2(F)=NaN; lat(F)=NaN; lon(F)=NaN; salinity(F)=NaN; temperature(F)=NaN; 

%% Data filter (GPS...)
% F=find(Latitude ==0 & Longitude ==0);
F=find((Latitude ==0 & Longitude ==0) | STATUS ~= 5); %hier fehlt ein Status für das System: wenn das OP neu gestartet ist, dauert das Austausch aus dem Debubbler etwas 

pCO2(F)=NaN; lon(F)=NaN; lat(F)=NaN;


%% Make maps
latmin=-20; latmax=54;       %latitude in °N...für südliche Breiten: negative Werte
lonmin=-80; lonmax=10;      %Longutude in °E...für Westliche: negative Werte

figure; hold on;%posfig(10);
m_proj('Mercator','long',[lonmin,lonmax],'lat',[latmin,latmax]);
m_gshhs_i('patch',[.5 .5 .5]); % i= indermediate; f= fine
m_grid('box','fancy');
[x,y]=m_ll2xy(lon,lat);

Minrange = floor(min(pCO2));
Maxrange = ceil(max(pCO2));
plotbin(x,y,pCO2,[Minrange:(Maxrange-Minrange)/10:Maxrange],20);
% plotbin(x,y,pCO2,[320:10:430],20);

% title(figDescrip10); %Kurztitel
combinedStr     = strcat(figDescrip10, {', '}, {'TJV19'}); %für den Titel der Abb musste das Format angepasst werden.
title(combinedStr);
% title({SCTlabel3, figDescrip10}); %Titel mit mehreren Zeilen

% dim = [.175 .0 .075 .08];
% str = 'Preliminary data. S. Raimund. 2019. SubCtech GmbH Kiel / Roscoff';
% annotation('textbox',dim,'String',str,'FitBoxToText','on','fontsize',8);

orient portrait

end