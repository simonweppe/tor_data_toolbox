%% Figure 05: MK2 state1

function [figDescrip5] = plot_5(matlabfile_processed,all,timeframe)
% load('SCT_DATA_FRA56.mat'); 
load(matlabfile_processed)
figDescrip5 = "MK2_state1"; figDescrip5 = char(figDescrip5); %beschreibt das Figure und nutzt den Char f�r den Dokumentennamen

fig05_handle = figure(5);
fig05_handle.Position = [0 0 1600 900];

%% Umdefinieren des Systemstatus. Hintergrund: bessere Darstellbarkeit
% Status alt: 1 = Span; 2= Zero; 5 = Operate; 19= Warmup; 21= Standby
% Status neu: 1 = Span; 2= Zero; 3 = Operate; 4= Warmup; 5= Standby

F=find(STATUS==5); %Operate
STATUS(F)= 3;

F=find(STATUS==19); %warmup
STATUS(F)= 4;

F=find(STATUS==21); %standby
STATUS(F)= 5;

%% Zeitausschnitt
% folgenden zwei Zeilen nur dann, wenn diese Funktion auch ohne mater-m-file funktionieren soll. Ansonsten deaktivieren.
% timeframe = [datetime('24-May-2018 00:45:00') datetime('24-May-2018 03:00:00')];
% all = 0;

% Vier Achsensysteme in das Objekt (Figure) einf�gen und Pos festlegen

%% Achsensysteme

% Achsensysteme einf�gen
ax1_handle = axes; 
ax2_handle = axes; 
ax3_handle = axes;
ax4_handle = axes;
ax5_handle = axes;

% Gr��e festlegen. Angabe der Position ist "Normalized". (Anfangspunkt XY. Gr��e XY. Von links unten ausgehend)
ax1_handle.Position = [0.07 0.81 0.9 0.15]; 
ax2_handle.Position = [0.07 0.62 0.9 0.15];
ax3_handle.Position = [0.07 0.43 0.9 0.15];
ax4_handle.Position = [0.07 0.24 0.9 0.15];
ax5_handle.Position = [0.07 0.06 0.9 0.14];

% Run time anpassen (von s in h)
SEC = SEC/3600;

% Plotten mit Handle erstellen
plot1_handle = plot(ax1_handle, dt, CellTemp,  '.','color','black');
plot2_handle = plot(ax2_handle, dt, CellPress,  '.','color','red');
plot3_handle = plot(ax3_handle, dt, DPressInt,  '.','color','blue');
plot4_handle = plot(ax4_handle, dt, FLOWgas,      '.','color', [0, 0.5 , 0]);  % dark green
plot5_handle = plot(ax5_handle, dt, STATUS,  '.','color', [0, 1 , 1]);  % cyan

% Y-Label
ax1_handle.YLabel.String = ({'Cell Temp','[�C]'});
ax2_handle.YLabel.String = ({'Cell Press','[mBar]'});
ax3_handle.YLabel.String = ({'Diff Press','[mBar]'});
ax4_handle.YLabel.String = ({'Gas Flow','[mL/min]'});
% ax5_handle.YLabel.String = ('System State');

% Formatierung der Schrift (Achsensysteme)
ax1_handle.FontWeight = 'bold'; 
ax2_handle.FontWeight = 'bold'; 
ax3_handle.FontWeight = 'bold'; 
ax4_handle.FontWeight = 'bold'; 
ax5_handle.FontWeight = 'bold'; 

ax1_handle.FontSize = 13; 
ax2_handle.FontSize = 13; 
ax3_handle.FontSize = 13; 
ax4_handle.FontSize = 13; 
ax5_handle.FontSize = 13; 

plot1_handle.MarkerSize = 12; 
plot2_handle.MarkerSize = 12; 
plot3_handle.MarkerSize = 12; 
plot4_handle.MarkerSize = 12;
plot5_handle.MarkerSize = 12;

% Label f�r die x-Achsen (hier: verhindert die x-Achsenbeschriftung der oberen Achsensysteme)
set(ax1_handle,'xticklabel',{});  
set(ax2_handle,'xticklabel',{});  
set(ax3_handle,'xticklabel',{});  
set(ax4_handle,'xticklabel',{});  

% Label f�r die y-Achsen
set(ax5_handle,'ytick',[ 1, 2, 3, 4, 5]); %hier: aus den Zahlen wird der Status abgeleitet
set(ax5_handle,'yticklabel',{'Span','Zero','Operate','Warmup','Standby'});

% Anzeigen eines Rasters
grid(ax1_handle,'on');
grid(ax2_handle,'on');
grid(ax3_handle,'on');
grid(ax4_handle,'on');
grid(ax5_handle,'on');

% Textboxen
% Plot 3
% annotation('textbox', [0.15 0.4 0.25 0.05], 'String',... 
%     'Nur ein Gaseingang. Dieses Ventil ist nicht vorhanden.',...
%     'FontSize',14, 'FontName','Arial','LineStyle','--', 'EdgeColor',[1 0 0], 'LineWidth',2, 'BackgroundColor',[1 1 1], 'Color',[0 0 0]);

% Achsen-Dimensionen festlegen f�r Y-Achsen (falls n�tig)
% ax1_handle.YLim = [10 60];
% ax2_handle.YLim = [-0.1 1.1];
% ax3_handle.YLim = [-0.1 1.1];
% ax4_handle.YLim = [-0.1 1.1];
ax5_handle.YLim = [1 5];

% Achsen-Dimensionen festlegen f�r X-Achse. Werden vom master-file �bergeben
 if all ==0 
    ax1_handle.XLim = timeframe;
    ax2_handle.XLim = timeframe;
    ax3_handle.XLim = timeframe;
    ax4_handle.XLim = timeframe;
    ax5_handle.XLim = timeframe;
 end

end
