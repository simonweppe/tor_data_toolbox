function plot_tor_data
% plot_tor_data
% 
% makes some maps from along-track data collected by Ocean Pack
% 
% https://www.eoas.ubc.ca/~rich/map.html#examples
% 
% 
% 
rmpath('/media/simon/Seagate Backup Plus Drive/programs/matlab_openearthtools/applications/m_map/')
addpath('/media/simon/Seagate Backup Plus Drive/theoceanrace/matlab_tools/m_map')

mkdir('./figures_mmap');
mkdir('./figures_pngs');
mkdir('./figures_mapbox');

% Mooring locations with pCO2 sensors: 
% W1M3A in the Gulf of Genoa (43.79°N, 9.16°E) 
% Dyfamed site (43°22.0202 N 7°54.0423 E)
DYFAMED = [7+54.0423/60 43+22.0202/60]
W1M3A = [9.16 43.79]

% 
% dat=importdata('SCT_DATA_TORE_leg1_2_QC.csv')
dat=importdata('SCT_DATA_TORE_leg1_2_3_QC_CLEANED1.csv')

lon = dat.data(:,7);lon(lon==0)=NaN;
lat = dat.data(:,6);lat(lat==0)=NaN;

%% TEMP
DATA = dat.data(:,8); % SST
figure('units','normalized','outerposition',[0 0 1 1]);
m_proj('miller','lon',[min(lon(:)-5) max(lon(:)+5)],'lat',[min(lat(:)-5) max(lat(:)+5)]);
% m_proj('lambert','long',[min(lon(:)-1) max(lon(:)+1)],'lat',[min(lat(:)-1) max(lat(:)+1)]);
% m_coast('patch',[.7 1 .7],'edgecolor','none'); 
m_coast('patch',[.8 .8 .8]); 
% m_gshhs_f('patch',[.7 .7 .7],'edgecolor','none'); % higher res
hold on
% m_grid('box','fancy','tickdir','out'); 
m_grid('box','fancy','linestyle','-','gridcolor','k')%,'backcolor',[.2 .65 1]); % blue ocean 
m_scatter(lon,lat,50,DATA) % add data along track
% m_colmap(NAME)
cbar=colorbar;
ylabel(cbar,'watertemp[degC]')
title('watertemp[degC]')
caxis([14 25])
export_png_hires(['./figures_mmap/SST.png'],gcf,gca);
m_plot(DYFAMED(1),DYFAMED(2),'o','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',7);m_text(DYFAMED(1),DYFAMED(2),'DYFAMED');
m_plot(W1M3A(1),W1M3A(2),'o','MarkerFaceColor','r','MarkerEdgeColor','k','MarkerSize',7);m_text(W1M3A(1),W1M3A(2),'W1M3A');
%% SALT
DATA = dat.data(:,9); % SSS
figure('units','normalized','outerposition',[0 0 1 1]);
m_proj('miller','lon',[min(lon(:)-5) max(lon(:)+5)],'lat',[min(lat(:)-5) max(lat(:)+5)]);
% m_proj('lambert','long',[min(lon(:)-1) max(lon(:)+1)],'lat',[min(lat(:)-1) max(lat(:)+1)]);
% m_coast('patch',[.7 1 .7],'edgecolor','none'); 
m_coast('patch',[.8 .8 .8]); 
% m_gshhs_f('patch',[.7 .7 .7],'edgecolor','none'); % higher res
hold on
% m_grid('box','fancy','tickdir','out'); 
m_grid('box','fancy','linestyle','-','gridcolor','k')%,'backcolor',[.2 .65 1]); % blue ocean 
m_scatter(lon,lat,50,DATA) % add data along track
% m_colmap(NAME)
cbar=colorbar;
ylabel(cbar,'watersalt[PSU]')
title('watersalt[PSU]')
caxis([33.5 38.5])
export_png_hires(['./figures_mmap/SSS.png'],gcf,gca);close
%% fCO2
DATA = dat.data(:,13); % SST
figure('units','normalized','outerposition',[0 0 1 1]);
m_proj('miller','lon',[min(lon(:)-5) max(lon(:)+5)],'lat',[min(lat(:)-5) max(lat(:)+5)]);
% m_proj('lambert','long',[min(lon(:)-1) max(lon(:)+1)],'lat',[min(lat(:)-1) max(lat(:)+1)]);
% m_coast('patch',[.7 1 .7],'edgecolor','none'); 
m_coast('patch',[.8 .8 .8]); 
% m_gshhs_f('patch',[.7 .7 .7],'edgecolor','none'); % higher res
hold on
% m_grid('box','fancy','tickdir','out'); 
m_grid('box','fancy','linestyle','-','gridcolor','k')%,'backcolor',[.2 .65 1]); % blue ocean 
m_scatter(lon,lat,50,DATA) % add data along track
% m_colmap(NAME)
cbar=colorbar;
ylabel(cbar,'fCO2[muatm]')
title('fCO2[muatm]')
caxis([350 550])
export_png_hires(['./figures_mmap/fCO2.png'],gcf,gca);close

%% pCO2 ANOMALY
% From Soeren : 
% "To have a rough estimate whether the area you are crossing is a sink or a source of CO2,
% you could subtract 415 muatm to your pCO2 value so you get an anomaly. This might help to interpret the measurements. "

DATA = dat.data(:,12)-415; % SST
figure('units','normalized','outerposition',[0 0 1 1]);
m_proj('miller','lon',[min(lon(:)-5) max(lon(:)+5)],'lat',[min(lat(:)-5) max(lat(:)+5)]);
% m_proj('lambert','long',[min(lon(:)-1) max(lon(:)+1)],'lat',[min(lat(:)-1) max(lat(:)+1)]);
% m_coast('patch',[.7 1 .7],'edgecolor','none'); 
m_coast('patch',[.8 .8 .8]); 
% m_gshhs_f('patch',[.7 .7 .7],'edgecolor','none'); % higher res
hold on
% m_grid('box','fancy','tickdir','out'); 
m_grid('box','fancy','linestyle','-','gridcolor','k')%,'backcolor',[.2 .65 1]); % blue ocean 
m_scatter(lon,lat,50,DATA) % add data along track
% m_colmap(NAME)
cbar=colorbar;
ylabel(cbar,'pCO2[muatm] - 415 [muatm]')
title('pCO2[muatm] - 415 [muatm]')
caxis([-150 150])
colormap(colormap_cpt('BlueYellowRed'))%BlueWhiteOrangeRed
export_png_hires(['./figures_mmap/pCO2[muatm]-415[muatm].png'],gcf,gca);close