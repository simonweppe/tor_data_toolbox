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

    output_file_ambersail = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210620DATA0_AmberSail_ALL/Analysis_TORE_FULL_AmberSail/SCT_DATA_TORE_FULL_QC_CLEANED_PH.csv'
    output_file_11thHour  = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210612DATA0_Leg1_2_3_11thHour/Analysis_TORE_leg1_2_3_11thHour/SCT_DATA_TORE_leg1_2_3_QC_CLEANED_PH.csv'
    output_file_akzo = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210528DATA0_AKZONOBEL/Analysis_TORE_FULL_AKZO/SCT_DATA_TORE_FULL_QC_CLEANED_PH.csv'
    try: 
        os.mkdir('figures_pngs')
    except:
        pass
    try: 
        os.mkdir('figures_mapbox')
    except:
        pass

    df_AB = pd.read_csv(output_file_ambersail,skiprows=0)
    df_11 = pd.read_csv(output_file_11thHour,skiprows=0)
    df_AN = pd.read_csv(output_file_akzo,skiprows=0)
    # combined both data frame
    # df_combined = df_AB.append(df_11).append(df_AN)
    df_combined = df_AB.append(df_11)
    # df_combined = df_AN
    
    var_range = [[8,28],[30.0,39.0],[415-250,415+250],[415-250,415+250],[415-250,415+250]] # for colorbar
    # var_range = [[8,28],[5.0,39.0],[415-250,415+250],[415-250,415+250],[415-250,415+250]] # for colorbar

    # var_range = [[14,28],[33.5,38.5],[415-150,415+150],[415-150,415+150],[415-150,415+150]] # for colorbar

    var_range = [[7.75,8.75]]
    var_range = [[7.0,8.75]]
    # var_range = [[7-1.5,7+1.5]]

    # for var in ['temperature','pCO2_muatm','fCO2_muatm','xCO2_ppm','salinity_PSU','pH'] :  
    for iv,var in enumerate(['pH']) : # 'xCO2_ppm','pCO2_muatm','pCO2_muatm-415_muatm'
        data = df_combined[var]
        if True:
            # export with plotly
            # https://plotly.com/python/scattermapbox/
            # https://plotly.com/python/maps/
            # https://plotly.github.io/plotly.py-docs/generated/plotly.express.scatter_mapbox.html

            import plotly.express as px
            px.set_mapbox_access_token('pk.eyJ1Ijoic2ltb253cDEiLCJhIjoiY2tpMGYwcHo2NmgzODJ6bDZudHB6bnl3bCJ9.tzJLkzP7-g4fG4_4qFtE1A')
            dot_size = np.zeros(len(data)) ; dot_size[~np.isnan(data)]=15   
            fig = px.scatter_mapbox(df_combined,lat="latitude", lon="longitude", color=var, size=dot_size,color_continuous_scale=np.flip(px.colors.cyclical.IceFire), size_max=15, zoom=10,range_color = var_range[iv])
            fig.update_mapboxes(center_lon = df_combined['longitude'].mean(), center_lat = df_combined['latitude'].mean(), zoom=3)
            fig.show()
            import pdb;pdb.set_trace()
            fig.write_html('./figures_mapbox/%s_mapbox_plotly_v4.html' % var)