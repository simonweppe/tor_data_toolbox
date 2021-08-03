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

    output_file_ambersail = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210620DATA0_AmberSail_ALL/Analysis_TORE_FULL_AmberSail/SCT_DATA_TORE_FULL_CHLOROPHYL.csv'
    df_combined = pd.read_csv(output_file_ambersail,skiprows=0)
    var_range = [[0,10]]
    # for var in ['temperature','pCO2_muatm','fCO2_muatm','xCO2_ppm','salinity_PSU','pH'] :  
    for iv,var in enumerate(['chl_aChl_a[mug/l]']) : # 'xCO2_ppm','pCO2_muatm','pCO2_muatm-415_muatm'
        data = df_combined[var]
        if True:
            # export with plotly
            # https://plotly.com/python/scattermapbox/
            # https://plotly.com/python/maps/
            # https://plotly.github.io/plotly.py-docs/generated/plotly.express.scatter_mapbox.html

            import plotly.express as px
            px.set_mapbox_access_token('pk.eyJ1Ijoic2ltb253cDEiLCJhIjoiY2tpMGYwcHo2NmgzODJ6bDZudHB6bnl3bCJ9.tzJLkzP7-g4fG4_4qFtE1A')
            dot_size = np.zeros(len(data)) ; dot_size[~np.isnan(data)]=10  
            fig = px.scatter_mapbox(df_combined,lat="latitude", lon="longitude", color=var, size=dot_size,color_continuous_scale=px.colors.sequential.Greens, size_max=15, zoom=10,range_color = var_range[iv])
            # px.colors.cyclical.IceFire
            # https://plotly.com/python/builtin-colorscales/#continuous-color-scales-in-dash
            fig.update_mapboxes(center_lon = df_combined['longitude'].mean(), center_lat = df_combined['latitude'].mean(), zoom=3)
            # fig.show()
            # import pdb;pdb.set_trace()
            fig.write_html('./figures_mapbox/%s_mapbox_plotly_ambersail.html' % 'chl_aChl_a')