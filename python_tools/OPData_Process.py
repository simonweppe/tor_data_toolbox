
import pandas as pd
from glob import glob
import os
import numpy as np

class OPData_Process(object):
    """Wraps all post-processing operations on Opendrift netcdf output files.

    Arguments:
    opendrift_output_file: Opendrift output netcdf file
    """
    def __init__(self,op_data_folder = None,
                 **kwargs):
        
        self.op_data_folder = op_data_folder
        # # define some details for export
        # path, fname = os.path.split(self.opendrift_output_file)
        # self.opendrift_output_file_path = path
        # self.opendrift_output_file_fname = fname
        # self.processed_path = os.path.join(self.opendrift_output_file_path,'processed_pdfs')

    def load_log_files(self):
        '''load all raw data from log files in op_data_folder into a panda dataframe'''
        # this reads the data in log file into a dataframe and attributes correct column names (58 columns)
        files = glob(os.path.join(self.op_data_folder,'*.log'))#files = glob('*.log')
        files.sort()
        self.data = pd.concat( pd.read_csv(file,skiprows = [0,1,2,3,5,6,7,8,9,10],encoding='ISO-8859-1')  for file in files)
        # convert lon,lat to decimal degrees
        self.data['Longitude'] = self.data['Longitude'].replace('/','0.0')
        self.data['Latitude'] = self.data['Latitude'].replace('/','0.0')
        self.data['Longitude'] = pd.to_numeric(self.data['Longitude'],downcast='float')/ 100.
        self.data['Latitude'] = pd.to_numeric(self.data['Latitude'],downcast='float')/ 100.
        # add panda datetime column
        # this can fails at times
        # self.data['date'] = pd.to_datetime(self.data['DATE'] + ' ' + self.data['TIME'],format = '%Y-%d-%m %H:%M:%S') 
        self.data['date'] = pd.to_datetime(self.data['DATE'] + ' ' + self.data['TIME'],infer_datetime_format=True)
    
    def derive_fCO2_pCO2(self):
        # > derive pCO2 > form Toste/Soeren/Stefan scripts

        # pCO2 corrections: formulas and explanations with the help of Ricardo and Pierre
        self.data['xCO2'] = self.data['CO2']
        # 0 .: Estimate the temperature at the membrane: - NOT USED FOR NOW
        # sbe38 = (self.data['waterTemp'] * 0.97536)-0.18558;
        # sbe38 = self.data['waterTemp'] + 0.5;  
        sbe38 = self.data['waterTemp'] # based on Soeren's archive - use waterTempp  

        # 1.Calculating the water vapor pressure: according to Weiss and Price 1980
        wvp = np.exp(24.4543 - (67.4509*(100/(self.data['waterTemp']+273.15))) -(4.8489*np.log((self.data['waterTemp']+273.15)/100)) - 0.0000544*self.data['salinity']);
        # correct for the pressure difference between the Licor and the membrane P_Membran=P_Licor - P_diff
        try :
            P_diff=np.median(self.data['DPressInt']);
        except:
            P_diff=-10 #  Just for getting a number.
            print('using P_diff=10 no DPressInt available')
        # % Now make make the correction
        CellPress = self.data['CellPress']-P_diff;
        # 2: MK2 Values ​​Pressure Correction: According to DOE Handbook
        MK2pCO2 = self.data['xCO2'] * (CellPress-wvp)/1013.249977; # from mBar to atm
        # % 3: Correcting MK2 values ​​with in-situ temperature: according to Takahashi et al., 1993
        self.data['pCO2'] = MK2pCO2 * np.exp(0.0423 * (self.data['waterTemp'] - sbe38));  # This is now pCO2 ** > 
        # ** Note this is equivalent to multiplying MK2pCO2 * exp(0) = MK2pCO2 * 1.0 for now, since sbe38 = waterTemp ?
        # fCO2 calculation - reference ? 
        SCTinK=self.data['waterTemp']+273.15;
        BCO2=-1636.75+12.0408*SCTinK-0.0327957*SCTinK*SCTinK+0.0000316528*SCTinK*SCTinK*SCTinK
        DCO2=57.7-0.188*SCTinK
        Zaehler=(BCO2+2*(1-self.data['xCO2']*1e-6)*(1-self.data['xCO2']*1e-6)*DCO2)*(CellPress/1013.249977)
        self.data['fCO2']=self.data['pCO2']*np.exp(Zaehler/(82.0578*SCTinK))
        import pdb;pdb.set_trace()

    def clip_data_calibration(self):
        # Remove periods of calibration (zero or span gas) and following 30 minutes
        # 
        # STATUS = 2   - ZERO
        # STATUS = 1   - SPAN /CALIBRATION
        # STATUS = 19  - WARMUP
        # STATUS = 4   - STANDBY
        # STATUS = 5   - OPERATE
        # STATUS = 18  - ??
        # STATUS = 21  - STANDBY OLD
        remove_minutes_before = 1.0
        remove_minutes_after = 30.
        # use masking rather than nans to keep original data for sanity-checks
        # find all non-operate time STATUS != 5, and remove minutes before/after

        pass

    def time_average_data(self):   
        # go from 10 or 20 seconds data points, to 1-3 minutes average 
        # use groupby() 
        # or use  rolling() , then keep every other data point
        # https://stackoverflow.com/questions/57595661/non-overlapping-rolling-windows-in-pandas-dataframes
        pass

    def remove_data_outliers(self):
        # using moving median ?
        pass


    def check_plots(self):
        pass

    def derive_pH(self):
        pass

    def plots_cartopy(self):
        pass

    def plots_mapbox(self):
        # https://plotly.com/python/builtin-colorscales/
        pass

# > derive pH > CO2SYS.m python package 
# PyCO2SYS
# https://github.com/mvdh7/PyCO2SYS/tree/v1.7.0

# > robust time averaging and median filtering
# % https://au.mathworks.com/matlabcentral/answers/450002-how-do-i-compute-3-minute-moving-average-in-timeseries


#################################################################
# MAIN
# 
# Examples
# 
#################################################################
if __name__ == '__main__':

    # op = OPData_Process(op_data_folder = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/2020-07-04_Vendee Arctique')
    op = OPData_Process(op_data_folder = '/media/simon/Seagate Backup Plus Drive/theoceanrace/DATA/TORE/210612DATA0_Leg1_2_3_11thHour')
    op.load_log_files()
    op.derive_fCO2_pCO2()
    import pdb;pdb.set_trace()