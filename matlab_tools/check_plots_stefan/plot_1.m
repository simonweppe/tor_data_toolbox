%% Figure 01: Overview OceanPack

function [figDescrip1] = plot_1(matlabfile_processed,all,timeframe)
% load('SCT_DATA_FRA56.mat'); 
load(matlabfile_processed)

figDescrip1 = "Overview OceanPack"; figDescrip1 = char(figDescrip1); %beschreibt das Figure und nutzt den Char für den Dokumentennamen

fig01_handle = figure(1);
fig01_handle.Position = [0 0 1600 900];


%% Zeitausschnitt
% folgenden zwei Zeilen nur dann, wenn diese Funktion auch ohne mater-m-file funktionieren soll. Ansonsten deaktivieren.
% timeframe = [datetime('24-May-2018 00:45:00') datetime('24-May-2018 03:00:00')];
% all = 0;

% Vier Achsensysteme in das Objekt (Figure) einfügen und Pos festlegen

%% Achsensysteme

% Achsensysteme einfügen
ax1_handle = axes; 
ax2_handle = axes; 
ax3_handle = axes;
ax4_handle = axes;
ax5_handle = axes;
ax6_handle = axes; 
ax7_handle = axes; 
ax8_handle = axes;
ax9_handle = axes;
ax10_handle = axes;

% Größe festlegen. Angabe der Position ist "Normalized". (Anfangspunkt XY. Größe XY. Von links unten ausgehend)
ax1_handle.Position = [0.07 0.85 0.9 0.08]; 
ax2_handle.Position = [0.07 0.76 0.9 0.08];
ax3_handle.Position = [0.07 0.67 0.9 0.08];
ax4_handle.Position = [0.07 0.58 0.9 0.08];
ax5_handle.Position = [0.07 0.49 0.9 0.08];
ax6_handle.Position = [0.07 0.40 0.9 0.08]; 
ax7_handle.Position = [0.07 0.31 0.9 0.08];
ax8_handle.Position = [0.07 0.22 0.9 0.08];
ax9_handle.Position = [0.07 0.13 0.9 0.08];
ax10_handle.Position = [0.07 0.04 0.9 0.08];


% Run time anpassen (von s in h)
SEC = SEC/3600;

% Plotten mit Handle erstellen
plot1_handle = plot(ax1_handle, dt, CO2,            '.','color','black');        % [0, 0, 0]
plot2_handle = plot(ax2_handle, dt, H2O,            '.','color','red');          % [1, 0, 0]
plot3_handle = plot(ax3_handle, dt, FLOWgas,           '.','color', [0, 1 , 1]);  % cyan
plot4_handle = plot(ax4_handle, dt, AIN0_mAWaterflow,            '.','color','blue');        
plot5_handle = plot(ax5_handle, dt, TempAirInt,      '.','color','red');          % [1, 0, 0]
plot6_handle = plot(ax6_handle, dt, waterTemp,        '.','color','black');          % [0, 0, 0]
plot7_handle = plot(ax7_handle, dt, waterCond,     '.','color', [0, 0.5 , 0]);  % dark green
plot8_handle = plot(ax8_handle, dt, Speed,     '.','color', [0, 1 , 1]);  % cyan
plot9_handle = plot(ax9_handle, dt, SEC,              '.','color','black');          % [0, 0, 0]
plot10_handle = plot(ax10_handle, dt, STATUS,        '.','color','red');          % [1, 0, 0]


%lablPlot1 = getVarName(Plot1);
% Y-Label
ax1_handle.YLabel.String = ({'xCO2', '[ppm]'});
ax2_handle.YLabel.String = ({'xH2O', '[ppt]'})
ax3_handle.YLabel.String = ({'Gas Flow', '[mL min-1]'});
ax4_handle.YLabel.String = ({'Water Flow', '[L min-1]'});
ax5_handle.YLabel.String = ({'int. Temp', '[°C]'});
ax6_handle.YLabel.String = ({'w temp', '[°C]'});
ax7_handle.YLabel.String = ({'w cond', '[mS cm-1]'});
ax8_handle.YLabel.String = ({'Vessel speed', '[kn]'});
ax9_handle.YLabel.String = ({'Run Time', 'OP'});
ax10_handle.YLabel.String = ({'Status', 'OP'});

% Formatierung der Schrift (Achsensysteme)
ax1_handle.FontWeight  = 'bold'; 
ax2_handle.FontWeight  = 'bold'; 
ax3_handle.FontWeight  = 'bold'; 
ax4_handle.FontWeight  = 'bold'; 
ax5_handle.FontWeight  = 'bold'; 
ax6_handle.FontWeight  = 'bold'; 
ax7_handle.FontWeight  = 'bold'; 
ax8_handle.FontWeight  = 'bold'; 
ax9_handle.FontWeight  = 'bold'; 
ax10_handle.FontWeight = 'bold'; 

% ax1_handle.FontSize = 13; 
% ax2_handle.FontSize = 13; 
% ax3_handle.FontSize = 13; 
% ax4_handle.FontSize = 13; 
% ax5_handle.FontSize = 13; 
% 
% plot1_handle.MarkerSize = 12; 
% plot2_handle.MarkerSize = 12; 
% plot3_handle.MarkerSize = 12; 
% plot4_handle.MarkerSize = 12;
% plot5_handle.MarkerSize = 12;

% Label für die x-Achsen (hier: verhindert die x-Achsenbeschriftung der oberen Achsensysteme)
set(ax1_handle,'xticklabel',{});  
set(ax2_handle,'xticklabel',{});  
set(ax3_handle,'xticklabel',{});  
set(ax4_handle,'xticklabel',{});
set(ax5_handle,'xticklabel',{});  
set(ax6_handle,'xticklabel',{});  
set(ax7_handle,'xticklabel',{});  
set(ax8_handle,'xticklabel',{});  
set(ax9_handle,'xticklabel',{});



% Anzeigen eines Rasters
grid(ax1_handle,'on');
grid(ax2_handle,'on');
grid(ax3_handle,'on');
grid(ax4_handle,'on');
grid(ax5_handle,'on');
grid(ax6_handle,'on');
grid(ax7_handle,'on');
grid(ax8_handle,'on');
grid(ax9_handle,'on');
grid(ax10_handle,'on');

% Textboxen
% Plot 3
% annotation('textbox', [0.15 0.4 0.25 0.05], 'String',... 
%     'Nur ein Gaseingang. Dieses Ventil ist nicht vorhanden.',...
%     'FontSize',14, 'FontName','Arial','LineStyle','--', 'EdgeColor',[1 0 0], 'LineWidth',2, 'BackgroundColor',[1 1 1], 'Color',[0 0 0]);

% Achsen-Dimensionen festlegen für Y-Achsen (falls nötig)
% ax1_handle.YLim = [-10 800];
ax2_handle.YLim = [-1 40];
% ax3_handle.YLim = [-0.1 1.1];
% ax4_handle.YLim = [-0.1 1.1];
% ax5_handle.YLim = [1 5];

% Achsen-Dimensionen festlegen für X-Achse. Werden vom master-file übergeben
 if all ==0 
    ax1_handle.XLim = timeframe;
    ax2_handle.XLim = timeframe;
    ax3_handle.XLim = timeframe;
    ax4_handle.XLim = timeframe;
    ax5_handle.XLim = timeframe;
    ax6_handle.XLim = timeframe;
    ax7_handle.XLim = timeframe;
    ax8_handle.XLim = timeframe;
    ax9_handle.XLim = timeframe;
    ax10_handle.XLim = timeframe;
 end

end
