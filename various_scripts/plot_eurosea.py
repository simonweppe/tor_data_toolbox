import xarray as xr
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import numpy as np
import cmocean
import matplotlib.colors as colors
import tqdm as tqdm

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
plt.show()