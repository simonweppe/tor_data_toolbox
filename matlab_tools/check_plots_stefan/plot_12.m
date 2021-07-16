%% Figure 12: Map (SSS)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Subfunction to compute the water salinity from values of water conductivity, temperature and pressure.
%
% References:
% Fofonoff, P. and Millard, R.C. (1983). Algorithms for 
%    computation of fundamental properties of seawater,  
%    Unesco Technical Papers in Marine Sci., 44, 58 pp.
% UNESCO. (1981). Background papers and supporting data on
%    the practical salinity, 1978. Unesco Technical Papers 
%    in Marine Sci., 37, 144 pp.
% Wagner, R.J., Boulger, R.W., Jr., Oblinger, C.J., y Smith, 
%    B.A., 2006, Guidelines and standard procedures for continuous
%    water-quality monitorsStation operation, record computation, 
%    and data reporting: U.S. Geological Survey Techniques
%    and Methods 1D3, 51 p.; access 2006-04-10 
%    en http://pubs.water.usgs.gov/tm1d3
% http://www.salinometry.com/welcome/
%
% Gabriel Ruiz Mtz.
% Version 2
% 
%
% modifiziert: August 2018, Thorsten-Andre Stoffers & Stefan Raimund, SubCtech
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


function [figDescrip12] = plot_12(matlabfile_processed,all,timeframe,label2,label3) %Zeitachse wird nicht modifiziert (wie in den anderen xy-Plots)
% load('SCT_DATA_FRA56.mat');
load(matlabfile_processed)
figDescrip12 = "Sea Surface Salinity [PSU]"; 
figDescrip12 = char(figDescrip12); %beschreibt das Figure und nutzt den Char für den Dokumentennamen

fig12_handle = figure(12);

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

%% Calculate the trend (pCO2 / min) and find the time when the values are
% stable, i.e. when DER <1
%     DER=[];
%     for i=1:length(salinity)-1,
%         der=abs(salinity(i)-salinity(i+1));
%         DER=[DER,der];
%     end
% 
% % Assume that all measurements before the pCO2 data are stable are bad
% F=find(DER>0.3); pCO2(F)=NaN; lat(F)=NaN; lon(F)=NaN; salinity(F)=NaN; temperature(F)=NaN; 
% 

C=waterCond;
T = temperature;
%% Computing the conductivity ratio
% $ R = /frac{C(S,T_{68},P)}{C(35,15_{68},0)} $
% where $ C(35,15_{68},0) $ = 42.914 mS/cm = 4.2914 S/m
cnd = C/42.914;
R = cnd;
     
%% Computing rt(t)
if (min(T) >= -2) && (max(T) <= 35)
    c0 =  0.6766097;
	c1 =  2.00564e-2;
	c2 =  1.104259e-4;
	c3 =  -6.9698e-7;
	c4 =  1.0031e-9;
    RT35 = ( ( (c3+c4.*T).*T+c2).*T+c1).*T+c0;
else
	error('Temperature out of range');
end

%% Computing Rp(S,t,p)
d1 = 3.426e-2;
d2 = 4.464e-4;
d3 = 4.215e-1;
d4 = -3.107e-3;
e1 = 2.070e-5;
e2 = -6.370e-10;
e3 = 3.989e-15;
RP = 1+(10.13.*(e1+e2.*10.13+(e3.*10.13.^2)))./(1+(d1.*T)+(d2.*T.^2)+(d3+(d4.*T)).*R);
     
%% Computing Rt(S,t)
RT = R./(RP.*RT35);
	 
%% Computing R
XR =sqrt(RT);
XT = T - 15;
a0 = 0.0080;
a1 = -0.1692;
a2 = 25.3851;
a3 = 14.0941;
a4 = -7.0261;
a5 = 2.7081;
b0 =  0.0005;
b1 = -0.0056;
b2 = -0.0066;
b3 = -0.0375;
b4 =  0.0636;
b5 = -0.0144;
k  =  0.0162;
DSAL = (XT./(1+k.*XT)).*(b0+(b1+(b2+(b3+(b4+(b5.*XR)).*XR).*XR).*XR).*XR);
SAL = (((((a5.*XR)+a4).*XR+a3).*XR+a2).*XR+a1).*XR+a0;
salinity = SAL + DSAL;


%% Make maps
latmin=-20; latmax=54;       %latitude in °N...für südliche Breiten: negative Werte
lonmin=-80; lonmax=10;      %Longutude in °E...für Westliche: negative Werte

posfig(12); hold on;
m_proj('Mercator','long',[lonmin,lonmax],'lat',[latmin,latmax]);
m_gshhs_i('patch',[.5 .5 .5]); % i= indermediate; f= fine
m_grid('box','fancy');
[x,y]=m_ll2xy(lon,lat);

Minrange = floor(min(salinity));
Maxrange = ceil(max(salinity));
%plotbin(x,y,salinity,[Minrange:(Maxrange-Minrange)/10:Maxrange],20);
plotbin(x,y,salinity,[33:0.5:38],20);

% title(figDescrip12); %Kurztitel
combinedStr     = strcat(figDescrip12, {', '}, {'TJV19'}); %für den Titel der Abb musste das Format angepasst werden.
title(combinedStr);
% title({SCTlabel1, figDescrip12}); %Titel mit mehreren Zeilen

% dim = [.175 .0 .075 .08];
% str = 'Preliminary data. S. Raimund. 2019. SubCtech GmbH Kiel / Roscoff';
% annotation('textbox',dim,'String',str,'FitBoxToText','on','fontsize',8);

orient portrait

end

