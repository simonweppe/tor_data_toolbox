import sys
from datetime import timedelta
import numpy as np
from scipy.interpolate import interp1d
import logging; logger = logging.getLogger(__name__)
import matplotlib.pyplot as plt
import cartopy
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import pandas as pd
import os
# https://rabernat.github.io/research_computing_2018/maps-with-cartopy.html
# https://scitools.org.uk/cartopy/docs/latest/gallery/index.html


# conda activate opendrift_simon
# pip install plotly

if __name__ == '__main__':

    # output_file = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210604DATA0_11thHourLeg1/Analysis_TORE_leg1_11thHour/SCT_DATA_TORE_leg1_QC.csv'
    # output_file = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210604DATA0_11thHourLeg1/Analysis_TORE_leg1_11thHour/SCT_DATA_TORE_leg1_QC_nonan.csv'
    # output_file = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210604DATA0_11thHourLeg1/Analysis_TORE_leg1_11thHour/SCT_DATA_TORE_leg1_QC_with_pco2_anomaly.csv'
    # output_file = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210612DATA0_Leg1_2_3_11thHour/Analysis_TORE_leg1_2_11thHour/SCT_DATA_TORE_leg1_2_3_QC_CLEANED.csv'
    output_file = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210612DATA0_Leg1_2_3_11thHour/Analysis_TORE_leg1_2_3_11thHour/SCT_DATA_TORE_leg1_2_3_QC_CLEANED1_nonan.csv'

    try: 
        os.mkdir('figures_pngs')
    except:
        pass
    try: 
        os.mkdir('figures_mapbox')
    except:
        pass

    df = pd.read_csv(output_file,skiprows=0)
    var_range = [[14,25],[34.5,36.5],[300,470],[300,470],[300,470]] # for colorbar
    var_range = [[14,28],[33.5,38.5],[415-150,415+150],[415-150,415+150],[415-150,415+150]] # for colorbar

    # for var in ['temperature','pCO2_muatm','fCO2_muatm','xCO2_ppm','salinity_PSU','pH'] :  
    for iv,var in enumerate(['temperature_degC', 'salinity_PSU','xCO2_ppm','pCO2_muatm', 'fCO2_muatm']): #'pCO2_muatm-415_muatm'
        data = df[var]

        if False:
            # export with cartopy
            plt.figure(figsize=(16.0, 10.0))
            plt.ion()
            plt.show()
            ax = plt.axes(projection=ccrs.PlateCarree())
            # ax.stock_img()
            ax.add_feature(cartopy.feature.OCEAN)
            ax.add_feature(cartopy.feature.LAND, edgecolor='black')
            ax.coastlines()
            ax.gridlines(draw_labels= True)
            # ax.plot(df['Longitude'], df['Latitude'],'r.', transform=ccrs.PlateCarree())
            # im = ax.scatter(df['longitude'], df['latitude'], s=10*data.values, c=data.values, alpha=0.5,transform=ccrs.PlateCarree())
            im = ax.scatter(df['longitude'], df['latitude'], s=100, c=data.values, alpha=0.5,transform=ccrs.PlateCarree(),vmin=var_range[iv][0],vmax=var_range[iv][1])
            # plt.set_cmap('seismic')
            plt.colorbar(im, label =var )
            frame = 1.0
            ax.set_extent([np.min(df['longitude'])-frame,np.max(df['longitude'])+frame,np.min(df['latitude'])-frame,np.max(df['latitude'])+frame], crs=None)
            ax.set_title('SCT_DATA_TORE_leg1_2_3_QC.csv')
            plt.savefig('./figures_pngs/%s.png' % var,dpi=500)
            # 
            # to adjust image size vs resolution see below
            # https://stackoverflow.com/questions/10041627/how-to-make-pylab-savefig-save-image-for-maximized-window-instead-of-default

        if True:
            # export with plotly
            # https://plotly.com/python/scattermapbox/
            # https://plotly.com/python/maps/
            import plotly.express as px
            px.set_mapbox_access_token('pk.eyJ1Ijoic2ltb253cDEiLCJhIjoiY2tpMGYwcHo2NmgzODJ6bDZudHB6bnl3bCJ9.tzJLkzP7-g4fG4_4qFtE1A')
            fig = px.scatter_mapbox(df, lat="latitude", lon="longitude", color=var, size=var,color_continuous_scale=px.colors.cyclical.IceFire, size_max=15, zoom=10,range_color = var_range[iv])
            fig.update_mapboxes(center_lon = df['longitude'].mean(), center_lat = df['latitude'].mean(), zoom=4)
            # fig.show()
            fig.write_html('./figures_mapbox/%s_mapbox_plotly.html' % var)

    if True:
        ## pCO2 ANOMALY
        import plotly.express as px
        px.set_mapbox_access_token('pk.eyJ1Ijoic2ltb253cDEiLCJhIjoiY2tpMGYwcHo2NmgzODJ6bDZudHB6bnl3bCJ9.tzJLkzP7-g4fG4_4qFtE1A')
        # dot_size = np.abs(df['pCO2_muatm-415_muatm']);dot_size[np.isnan(dot_size)]=0;dot_size[:]=15
        anomaly = df['pCO2_muatm']-415 #'pCO2_muatm-415_muatm' w
        dot_size = 15*np.ones(len(anomaly))
        dot_size[np.where(anomaly==-415)] = 0
        fig = px.scatter_mapbox(df, lat="latitude", lon="longitude", color= anomaly, size=dot_size,color_continuous_scale=px.colors.cyclical.IceFire, size_max=15, zoom=10,range_color = [-150,150])
        fig.update_mapboxes(center_lon = df['longitude'].mean(), center_lat = df['latitude'].mean(), zoom=4)
        # fig.show()
        fig.write_html('./figures_mapbox/pCO2_muatm_anomaly_mapbox_plotly.html')
        import pdb;pdb.set_trace()
