import sys
sys.path.append('/home/simon/Documents/GitHub/tor_data_toolbox/python_tools') 
from oceanpack_process.OPData_Process import *

#########################################################################################################
# script to compare processing using this python toolbox and Toste's QC (done in matlab)
#########################################################################################################

op = OPData_Process(op_data_folder = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210612DATA0_Leg1_2_3_11thHour')
op.load_log_files()
op.derive_fCO2_pCO2() 
op.clip_data_calibration() # remove data during zero and span calibrations
op.remove_time_period(tstart = '2021-5-29 08:00:00',tend = '2021-5-29 12:00:00') # remove some bad data
op.remove_time_period(tstart = '2021-6-13 12:00:00',tend = '2021-6-13 15:00:00') # remove some bad data
op.remove_time_period(tstart = '2021-6-02 12:00:00',tend = '2021-6-07 06:00:00') # remove some bad data
op.remove_time_period(tstart = '2021-6-16 23:00:00',tend = '2021-6-17 02:00:00') # remove some bad data
op.remove_time_period(tstart = '2021-6-14 13:00:00',tend = '2021-6-14 20:00:00') # remove some bad data
op.time_average_data(rule_string = 'T') # turn into 1 minute average

# op.plots_cartopy(variable2plot = ['pCO2','xCO2'],var_range = [[0,500],[0,500]])
op.plots_mapbox(variable2plot = ['pCO2','xCO2'],var_range = [[0,500],[0,500]])

# make a reduced dataframe with variables of interest
op.data_reduced = op.data_reduced[ ['Longitude','Latitude','waterTemp','salinity','pCO2','xCO2','fCO2']]
# export to file # export to file using panda export function 
op.data_reduced.to_csv('210612DATA0_Leg1_2_3_11thHour_TEST.csv',na_rep=np.nan) # fill missing data with nans


## Compare with top-copy QC-ed files by Toste
import pdb;pdb.set_trace()
# load final QC-ed data from Toste for comparison
data_toste = pd.read_excel('/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/TORE data_FINAL/11th hour pCO2 final.xlsx',sheet_name = 'cal_data')
data_toste['datetime64'] = pd.to_datetime(dict(year=data_toste.year,month=data_toste.month,day=data_toste.day,hour=data_toste.hour,minute=data_toste.minute))
data_toste.set_index('datetime64', inplace=True) # set date as index (used later for resampling)

import matplotlib.pyplot as plt
plt.ion()
plt.show()
plt.plot(data_toste['pCO2'])
plt.plot(op.data['pCO2'],'k')
plt.plot(op.data_cleaned['pCO2'],'r')
plt.plot(op.data_reduced['pCO2'],'g')

import matplotlib.pyplot as plt
plt.ion()
plt.show()
plt.plot(data_toste['longitude'].values,data_toste['latitude'].values)
plt.plot(op.data['Longitude'].values,op.data['Latitude'],'r')
