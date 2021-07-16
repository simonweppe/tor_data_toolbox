%% Figure 08: CO2 detailed

function [figDescrip8] = plot_8(matlabfile_processed,all,timeframe)
% load('SCT_DATA_FRA56.mat'); 
load(matlabfile_processed)
figDescrip8 = "MK2_CO2 detailed"; figDescrip8 = char(figDescrip8); %beschreibt das Figure und nutzt den Char für den Dokumentennamen

fig08_handle = figure(8);
fig08_handle.Position = [0 0 1600 900];

% % folgenden zwei Zeilen nur dann, wenn diese Function auch ohne mater-m-file funktionieren soll
% timeframe = [datetime('30-Apr-2018 05:00:00') datetime('30-Apr-2018 05:45:00')];
% all = 0;

% Vier Achsensysteme in das Objekt (Figure) einfügen und Pos festlegen

ax1_handle = axes; %fügt das Achsensystem 01 ein
ax2_handle = axes; 
ax3_handle = axes;
ax4_handle = axes;

ax1_handle.Position = [0.07 0.77 0.9 0.20]; %Angabe der Position ist "Normalized"
ax2_handle.Position = [0.07 0.54 0.9 0.20];
ax3_handle.Position = [0.07 0.30 0.9 0.20];
ax4_handle.Position = [0.07 0.06 0.9 0.20];

% Plotten mit Handle: 4 Plots erstellen

plot1_handle = plot(ax1_handle, dt, CO2,            '.','color','black');
plot2_handle = plot(ax2_handle, dt, CO2abs,     '.','color','red');
plot3_handle = plot(ax3_handle, dt, CO2raw, '.','color','blue');
plot4_handle = plot(ax4_handle, dt, CO2ref,  '.','color', [0, 0.5 , 0]);  % dark green

ax1_handle.YLabel.String = ({'xCO2', '[ppm]'});
ax2_handle.YLabel.String = ('CO2 Absorption');
ax3_handle.YLabel.String = ({'Raw detector readings' ,'CO2 MEAS'});
ax4_handle.YLabel.String = ({'Raw detector readings' ,'CO2 REF'});

ax1_handle.FontWeight = 'bold'; 
ax2_handle.FontWeight = 'bold'; 
ax3_handle.FontWeight = 'bold'; 
ax4_handle.FontWeight = 'bold'; 

ax1_handle.FontSize = 13; 
ax2_handle.FontSize = 13; 
ax3_handle.FontSize = 13; 
ax4_handle.FontSize = 13; 

plot1_handle.MarkerSize = 12; 
plot2_handle.MarkerSize = 12; 
plot3_handle.MarkerSize = 12; 
plot4_handle.MarkerSize = 12;

set(ax1_handle,'xticklabel',{});  % verhindert die x-Achsenbeschriftung
set(ax2_handle,'xticklabel',{});  % verhindert die x-Achsenbeschriftung
set(ax3_handle,'xticklabel',{});  % verhindert die x-Achsenbeschriftung

grid(ax1_handle,'on');
grid(ax2_handle,'on');
grid(ax3_handle,'on');
grid(ax4_handle,'on');

% Achsen-Dimensionen festlegen (falls nötig)
% ax1_handle.YLim = [-10 1000];
% ax2_handle.YLim = [-10 10];
% ax3_handle.YLim = [-10 10];
% ax4_handle.YLim = [-1 16];

% Achsen-Dimensionen festlegen für X-Achse. Werden vom master-file übergeben
 if all ==0 
    ax1_handle.XLim = timeframe;
    ax2_handle.XLim = timeframe;
    ax3_handle.XLim = timeframe;
    ax4_handle.XLim = timeframe;
 end

end