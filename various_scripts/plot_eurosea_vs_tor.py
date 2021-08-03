import xarray as xr
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import numpy as np
import cmocean
import matplotlib.colors as colors
import tqdm as tqdm
import pandas as pd

infos         = True
draw_graphics = True

ds_MOOSE_GE_2021 = xr.open_dataset('EXP/MOOSE-GE-2021.nc')

time = ds_MOOSE_GE_2021.time
Surface_temperature = ds_MOOSE_GE_2021.temperature
Surface_salinity = ds_MOOSE_GE_2021.salinity
Longitudes = ds_MOOSE_GE_2021.lon
Latitudes = ds_MOOSE_GE_2021.lat

# if infos: display(ds_MOOSE_GE_2021)
ds_MOOSE_GE_2021.close()

plot_temp = True
plot_salt = True

if plot_temp : 
    #######################################################################
    # Temperature plot
    #######################################################################
    fig,ax = plt.subplots(figsize=(15,15))

    ax = plt.axes(projection=ccrs.Mercator())
    ax.set_extent([2, 10, 39.7, 44])
    ax.add_feature(cfeature.COASTLINE)
    ax.add_feature(cfeature.OCEAN, color='lightgrey',alpha=0.3)

    cbar_min, cbar_max = np.min(Surface_temperature), np.max(Surface_temperature)
    cmap = cmocean.cm.thermal
    norm = colors.Normalize(vmin=cbar_min, vmax=cbar_max)

    for i,t in enumerate(tqdm.tqdm(time)):
        THS_T = Surface_temperature[i]
        color = (THS_T-cbar_min)/(cbar_max-cbar_min)
        lon,lat = Longitudes[i], Latitudes[i]
        ax.plot(lon, lat, marker='o', transform=ccrs.PlateCarree(), color=cmap(color))

    cax = fig.add_axes([ax.get_position().x1+0.01,ax.get_position().y0,0.02,ax.get_position().height])
    plt.colorbar(plt.cm.ScalarMappable(norm=norm, cmap=cmap), label='\nTemperature (°C)', cax=cax)
    ax.set_title("Surface temperature (legs 1 & 2)")
    plt.ion()
    plt.show()
    #######################################################################
    # Add 11th Hour data
    #######################################################################
    output_file = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210612DATA0_Leg1_2_3_11thHour/Analysis_TORE_leg1_2_3_11thHour/SCT_DATA_TORE_leg1_2_3_QC_CLEANED1_nonan.csv'
    df_11th = pd.read_csv(output_file,skiprows=0)
    # ax.plot(df['longitude'], df['latitude'], marker='o', transform=ccrs.PlateCarree(), color=cmap(color))
    for i,t in enumerate(tqdm.tqdm(df_11th['year'])):
        THS_T = df_11th['temperature_degC'][i]
        if THS_T == 0.0:
            continue
        color = (THS_T-cbar_min)/(cbar_max-cbar_min)
        lon,lat = df_11th['longitude'][i], df_11th['latitude'][i]
        ax.plot(lon, lat, marker='o', transform=ccrs.PlateCarree(), color=cmap(color),markersize=14)
    # add thin black line for 11thHour track
    ax.plot(df_11th['longitude'][:], df_11th['latitude'][:], color='k', transform=ccrs.PlateCarree(),linewidth = 2)
    #######################################################################
    # Add AmberSail data
    #######################################################################
    output_file = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210620DATA0_AmberSail_ALL/Analysis_TORE_FULL_AmberSail/SCT_DATA_TORE_FULL_QC_CLEANED_nonan.csv'
    df_amber = pd.read_csv(output_file,skiprows=0)
    # ax.plot(df['longitude'], df['latitude'], marker='o', transform=ccrs.PlateCarree(), color=cmap(color))
    for i,t in enumerate(tqdm.tqdm(df_amber['year'])):
        THS_T = df_amber['temperature_degC'][i]
        if THS_T == 0.0:
            continue
        color = (THS_T-cbar_min)/(cbar_max-cbar_min)
        lon,lat = df_amber['longitude'][i], df_amber['latitude'][i]
        ax.plot(lon, lat, marker='o', transform=ccrs.PlateCarree(), color=cmap(color),markersize=14)

    ax.plot(df_amber['longitude'][df_amber['longitude']!=0], df_amber['latitude'][df_amber['longitude']!=0], color='tab:grey', transform=ccrs.PlateCarree(),linewidth = 2)
    plt.savefig('EuroSea_vs_TOR_SST.png',dpi=500)
    import pdb;pdb.set_trace()


if plot_salt : 
    #######################################################################
    # Salinity plot
    #######################################################################
    fig,ax = plt.subplots(figsize=(15,15))

    ax = plt.axes(projection=ccrs.Mercator())
    ax.set_extent([2, 10, 39.7, 44])
    ax.add_feature(cfeature.COASTLINE)
    ax.add_feature(cfeature.OCEAN, color='lightgrey',alpha=0.3)

    cbar_min, cbar_max = np.nanmin(Surface_salinity), np.nanmax(Surface_salinity)
    cmap = cmocean.cm.haline
    norm = colors.Normalize(vmin=cbar_min, vmax=cbar_max)

    for i,t in enumerate(tqdm.tqdm(time)):
        THS_S = Surface_salinity[i]
        color = (THS_S-cbar_min)/(cbar_max-cbar_min)
        lon,lat = Longitudes[i], Latitudes[i]
        ax.plot(lon, lat, marker='o', transform=ccrs.PlateCarree(), color=cmap(color))

    cax = fig.add_axes([ax.get_position().x1+0.01,ax.get_position().y0,0.02,ax.get_position().height])
    plt.colorbar(plt.cm.ScalarMappable(norm=norm, cmap=cmap), label='\nSalinity (psu)', cax=cax)
    ax.set_title("Surface salinity (legs 1 & 2)")
    plt.ion()
    plt.show()

    #######################################################################
    # Add 11th Hour data
    #######################################################################
    output_file = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210612DATA0_Leg1_2_3_11thHour/Analysis_TORE_leg1_2_3_11thHour/SCT_DATA_TORE_leg1_2_3_QC_CLEANED1_nonan.csv'
    df_11th = pd.read_csv(output_file,skiprows=0)
    # ax.plot(df['longitude'], df['latitude'], marker='o', transform=ccrs.PlateCarree(), color=cmap(color))
    for i,t in enumerate(tqdm.tqdm(df_11th['year'])):
        THS_S = df_11th['salinity_PSU'][i]
        if THS_S == 0.0:
            continue
        color = (THS_S-cbar_min)/(cbar_max-cbar_min)
        lon,lat = df_11th['longitude'][i], df_11th['latitude'][i]
        ax.plot(lon, lat, marker='o', transform=ccrs.PlateCarree(), color=cmap(color),markersize=14)
    ax.plot(df_11th['longitude'][:], df_11th['latitude'][:], color='k', transform=ccrs.PlateCarree(),linewidth = 2)
    #######################################################################
    # Add AmberSail data
    #######################################################################
    output_file = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210620DATA0_AmberSail_ALL/Analysis_TORE_FULL_AmberSail/SCT_DATA_TORE_FULL_QC_CLEANED_nonan.csv'
    df_amber = pd.read_csv(output_file,skiprows=0)
    # ax.plot(df['longitude'], df['latitude'], marker='o', transform=ccrs.PlateCarree(), color=cmap(color))
    for i,t in enumerate(tqdm.tqdm(df_amber['year'])):
        THS_S = df_amber['salinity_PSU'][i]
        if THS_S == 0.0:
            continue
        color = (THS_S-cbar_min)/(cbar_max-cbar_min)
        lon,lat = df_amber['longitude'][i], df_amber['latitude'][i]
        ax.plot(lon, lat, marker='o', transform=ccrs.PlateCarree(), color=cmap(color),markersize=14)
    ax.plot(df_amber['longitude'][df_amber['longitude']!=0], df_amber['latitude'][df_amber['longitude']!=0], color='tab:grey', transform=ccrs.PlateCarree(),linewidth = 2)
    plt.savefig('EuroSea_vs_TOR_SSS.png',dpi=500)
    import pdb;pdb.set_trace()
