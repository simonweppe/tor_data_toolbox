%% Figure 11: Map (SST)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Script von Toste/Sören. Ursprünglich für das VOR Projekt 
% Geomar
%
% modifiziert: 2018-06-06, Stefan Raimund, SubCtech
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [figDescrip11] = plot_11(matlabfile_processed,all,timeframe,label2,label3) %Zeitachse wird nicht modifiziert (wie in den anderen xy-Plots)
% load('SCT_DATA_FRA56.mat');
load(matlabfile_processed)
figDescrip11 = "Sea Surface Temperatur [°C]"; 
figDescrip11 = char(figDescrip11); %beschreibt das Figure und nutzt den Char für den Dokumentennamen

fig11_handle = figure(11);

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

pCO2=CO2; lat=Latitude; lon=Longitude;  temperature=waterTemp;

%% Data filter (GPS...)
F=find((lat ==0 & lon ==0) | STATUS ~= 5); %hier fehlt ein Status für das System: wenn das OP neu gestartet ist, dauert das Austausch aus dem Debubbler etwas 
temperature(F)=NaN; lon(F)=NaN; lat(F)=NaN;


%% Make maps
latmin=-20; latmax=54;       %latitude in °N...für südliche Breiten: negative Werte
lonmin=-80; lonmax=10;      %Longutude in °E...für Westliche: negative Werte

posfig(11); hold on;
m_proj('Mercator','long',[lonmin,lonmax],'lat',[latmin,latmax]);
m_gshhs_i('patch',[.5 .5 .5]); % i= indermediate; f= fine
m_grid('box','fancy');
[x,y]=m_ll2xy(lon,lat);

Minrange = floor(min(temperature));
Maxrange = ceil(max(temperature));
plotbin(x,y,temperature,[Minrange:(Maxrange-Minrange)/10:Maxrange],20);
%plotbin(x,y,temperature,[16:0.1:17],20);

% title(figDescrip11); %Kurztitel
combinedStr     = strcat(figDescrip11, {', '}, {'TJV19'}); %für den Titel der Abb musste das Format angepasst werden.
title(combinedStr);
% title({SCTlabel1, figDescrip11}); %Titel mit mehreren Zeilen

% dim = [.175 .0 .075 .08];
% str = 'Preliminary data. S. Raimund. 2019. SubCtech GmbH Kiel / Roscoff';
% annotation('textbox',dim,'String',str,'FitBoxToText','on','fontsize',8);

orient portrait

end

