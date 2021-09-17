# script to compare processing using the python toolbox and Toste's QC
import sys
sys.path.append('/home/simon/Documents/GitHub/tor_data_toolbox/python_tools') 

from oceanpack_process.OPData_Process import *

op = OPData_Process(op_data_folder = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/2020-07-04_Vendee Arctique')
# op = OPData_Process(op_data_folder = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/MALIZIA_data')
op.load_log_files()
op.derive_fCO2_pCO2() 
op.clip_data_calibration() # remove data during zero and span calibration
op.time_average_data(rule_string = 'T') # turn into 1 minute average

import matplotlib.pyplot as plt
plt.ion()
plt.show()
plt.plot(op.data['xCO2'],'k')
plt.plot(op.data_cleaned['xCO2'],'r')
plt.plot(op.data_reduced['xCO2'],'g')
plt.legend(['raw','cleaned','reduced'])

# op.plots_cartopy(variable2plot = ['xCO2'],var_range = [[300,400]])
op.plots_mapbox(variable2plot = ['xCO2'],var_range = [[300,400]])
import pdb;pdb.set_trace()

# export to file using panda export function 
# make a reduced dataframe with variables of interest
op.data_reduced = op.data_reduced[ ['Longitude','Latitude','waterTemp''xCO2']]
# export to file
op.data_reduced.to_csv('vendee_arctique.csv',na_rep=np.nan) # fill missing data with nans