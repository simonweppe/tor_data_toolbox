%% Figure 03: xCO2 and xH2O

function [figDescrip3] = plot_3(matlabfile_processed,all,timeframe)
% load('SCT_DATA_FRA56.mat'); 
load(matlabfile_processed)
figDescrip3 = "MK2_xCO2 and xH2O"; figDescrip3 = char(figDescrip3); %beschreibt das Figure und nutzt den Char für den Dokumentennamen

fig03_handle = figure(3);
fig03_handle.Position = [0 0 1600 900];

% %folgenden zwei Zeilen nur jetzt, damit diese function auch ohne mater-m-file funktioniert
% timeframe = [datetime('30-Apr-2018 05:00:00') datetime('30-Apr-2018 05:45:00')];
% all = 0;

%% Drei Achsensysteme in das Objekt (Figure) einfügen und Pos festlegen

ax1_handle = axes; % Wird mein YY-Plot

ax1_handle.Position = [0.05 0.06 0.9 0.90]; %Angabe der Position ist "Normalized"

%% Plotten mit Handle: Plots erstellen

[plot1_handle, p1_yy_handle, p2_yy_handle] = plotyy(dt,CO2 , dt,H2O,'scatter');

p1_yy_handle.Marker = '.';
p1_yy_handle.MarkerEdgeColor = 'black';
p2_yy_handle.Marker = '.';
p2_yy_handle.MarkerEdgeColor = 'red';

ylabel(plot1_handle(1), 'xCO2, [µmol/mol]');
ylabel(plot1_handle(2), 'xH2O, [mmol/mol]]','color','red');

ax1_handle.FontWeight = 'bold'; 
ax2_handle.FontWeight = 'bold'; 

ax1_handle.FontSize = 13; 
ax2_handle.FontSize = 13; 

grid(ax1_handle,'on');


% Achsen-Dimensionen festlegen (falls nötig)
% ax1_handle.YLim = [50 53];
% ax2_handle.YLim = [-10 10];
ylim(plot1_handle(1), [0 800]);
ylim(plot1_handle(2), [0 40]);
yticks(plot1_handle(1), [0 100 200 300 400 500 600 700 800]);
yticks(plot1_handle(2), [0 5 10 15 20 25 30 35 40]);

% Achsen-Dimensionen festlegen für X-Achse. Werden vom master-file übergeben
if all ==0 
    %ax1_handle.XLim = timeframe;
                xlim(plot1_handle(1),timeframe);
                xlim(plot1_handle(2),timeframe);
end

 
end