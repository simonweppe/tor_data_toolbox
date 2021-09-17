
import pandas as pd
from glob import glob
import os
import numpy as np
from datetime import timedelta

class OPData_Process(object):
    """Wraps all post-processing operations on Opendrift netcdf output files.

    Arguments:
    opendrift_output_file: Opendrift output netcdf file
    """
    def __init__(self,op_data_folder = None,
                 **kwargs):
        
        self.op_data_folder = op_data_folder
        
    def load_log_files(self):
        '''load all raw data from log files in op_data_folder into a panda dataframe'''
        # this reads the data in log file into a dataframe and attributes correct column names (58 columns)
        files = glob(os.path.join(self.op_data_folder,'*.log'))#files = glob('*.log')
        files.sort()
        self.data = pd.concat( pd.read_csv(file,skiprows = [0,1,2,3,5,6,7,8,9,10],encoding='ISO-8859-1')  for file in files)
        # convert lon,lat to decimal degrees
        self.data['Longitude'] = self.data['Longitude'].replace('/','nan') #self.data['Longitude'].replace('/','0.0')
        self.data['Latitude'] = self.data['Latitude'].replace('/','nan')
        self.data['Longitude'] = self.data['Longitude'].astype('float64')/100
        self.data['Latitude'] = self.data['Latitude'].astype('float64')/100
        # longitude/latitude are saved as deg.minutes in the <.log> files
        # convert longitude/latitude to decimal degrees
        londeg = np.fix(self.data['Longitude'])
        lonmin = (self.data['Longitude']- np.fix(self.data['Longitude']))*100
        self.data['Longitude'] = londeg + lonmin/60

        latdeg = np.fix(self.data['Latitude'])
        latmin = (self.data['Latitude']- np.fix(self.data['Latitude']))*100
        self.data['Latitude'] = latdeg + latmin/60

        # add panda datetime column
        # this can fails at times
        # self.data['date'] = pd.to_datetime(self.data['DATE'] + ' ' + self.data['TIME'],format = '%Y-%d-%m %H:%M:%S') 
        self.data['date'] = pd.to_datetime(self.data['DATE'] + ' ' + self.data['TIME'],infer_datetime_format=True)
        self.data.set_index('date', inplace=True) # set date as index (used later for resampling)
    
    def derive_fCO2_pCO2(self):
        try :
            # Derivation of pCO2 values from xCO2, water temperature and water salinity 
            # > based on scripts by Toste Tanuah/Soeren Gutenkunst/Stefan Raimund
            # 
            # pCO2 corrections: formulas and explanations with the help of Ricardo and Pierre
            self.data['xCO2'] = self.data['CO2']
            # 0 .: Estimate the temperature at the membrane: - NOT USED FOR NOW
            # sbe38 = (self.data['waterTemp'] * 0.97536)-0.18558;
            # sbe38 = self.data['waterTemp'] + 0.5;  
            sbe38 = self.data['waterTemp'] # based on Soeren's archive - use waterTemp
            # 1.Calculating the water vapor pressure: according to Weiss and Price 1980
            wvp = np.exp(24.4543 - (67.4509*(100/(self.data['waterTemp']+273.15))) -(4.8489*np.log((self.data['waterTemp']+273.15)/100)) - 0.0000544*self.data['salinity']);
            # correct for the pressure difference between the Licor and the membrane P_Membran=P_Licor - P_diff
            try :
                P_diff = np.median(self.data['DPressInt']);
            except:
                P_diff = -10 #  Just for getting a number.
                print('using P_diff=10 no DPressInt available')
            # % Now make make the correction
            CellPress = self.data['CellPress']-P_diff;
            # 2: MK2 Values Pressure Correction: According to DOE Handbook
            MK2pCO2 = self.data['xCO2'] * (CellPress-wvp)/1013.249977; # from mBar to atm
            # 3: Correcting MK2 values with in-situ temperature: according to Takahashi et al., 1993
            self.data['pCO2'] = MK2pCO2 * np.exp(0.0423 * (self.data['waterTemp'] - sbe38));  # This is now pCO2 ** > 
            # ** Note this is equivalent to multiplying MK2pCO2 * exp(0) = MK2pCO2 * 1.0 for now, since sbe38 = waterTemp ?
            # 4. fCO2 calculation - reference ? 
            SCTinK = self.data['waterTemp']+273.15;
            BCO2 = -1636.75+12.0408*SCTinK-0.0327957*SCTinK*SCTinK+0.0000316528*SCTinK*SCTinK*SCTinK
            DCO2 = 57.7-0.188*SCTinK
            Zaehler = (BCO2+2*(1-self.data['xCO2']*1e-6)*(1-self.data['xCO2']*1e-6)*DCO2)*(CellPress/1013.249977)
            self.data['fCO2'] = self.data['pCO2']*np.exp(Zaehler/(82.0578*SCTinK))
        except :
            self.data['fCO2'] = np.ones(self.data['xCO2'].shape[0])*np.nan
            self.data['pCO2'] = np.ones(self.data['xCO2'].shape[0])*np.nan
            print('could not compute pCO2, likely water temp or salinity data missing')

    def clip_data_calibration(self):
        # Remove periods of calibration (zero or span gas) and following 30 minutes
        # use masking rather than nans to keep original data for sanity-checks
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
        self.data_cleaned = self.data.copy(deep=True) # keep a copy of raw data for later checks

        # find calibration times
        calibration_times = np.where((self.data_cleaned['STATUS'] == 1) | (self.data_cleaned['STATUS'] == 2) ) 
        # loop through all "CALIBRATION" periods to mask these periods+ 30 minutes after.
        for ii in calibration_times[0]:
            self.data_cleaned[self.data_cleaned['pCO2'].index[ii] - np.timedelta64(1, 'm') : self.data_cleaned['pCO2'].index[ii]+ np.timedelta64(30, 'm')] = np.nan
        # only keep data when system STATUS is OPERATE (STATUS=5)
        self.data_cleaned = self.data_cleaned.mask(self.data_cleaned['STATUS'] != 5 ) #,try_cast=True


    def remove_time_period(self,tstart = '2021-06-01 00:00:00',tend = '2021-06-01 00:00:00'):
        # remove a given period for which data may be suspicious
        # input date string should be as follow : '2021-06-01 00:00:00'
        self.data_cleaned.loc[tstart:tend] = np.nan

    def time_average_data(self,rule_string = 'T'):
        # makes 1-minute average of data by default 
        # 
        # https://stackoverflow.com/questions/52172098/getting-average-per-minute-in-pandas
        # for rule_string : https://stackoverflow.com/questions/17001389/pandas-resample-documentation
        self.data_reduced = self.data_cleaned.resample(rule = rule_string).mean()

    def remove_data_outliers(self):
        # using moving median ?
        pass
        
    def check_plots(self):
        pass

    def derive_pH(self):
        # first step is compute alkalinity from SST,SSS etc.. > equations can be different for different regions
        # Alkalinity describes the capacity of the sea water to buffer changes in pH (https://bg.copernicus.org/articles/18/1127/2021/)
        # As the concentration of most of the weak bases in seawater is strongly dependent on the salinity, alkalinity can in many regions 
        # be estimated from salinity. However, in regions with a high amount of organic bases in seawater, for example in strong blooms 
        # or at river mouths, deviations from the alkalinity–salinity relationship can occur
        # Lee et al 2006 > global, different regions
        # Nondal 2009 etc...?
        # Schneider et al :Alkalinity of the Mediterranean Sea > MedSea
        alkalinity_medsea_schneider = 73.7*SSS - 285.7 #micro_mol.kg-11 , for surface waters < 25m

        alkalinity_lee = a + b*(SSS-35) + c * (SSS-35)**2 + d*(SST-20) + e*(SST-20)**2
        # 
        # > derive pH > CO2SYS.m python package 
        # PyCO2SYS
        # https://github.com/mvdh7/PyCO2SYS/tree/v1.7.0
        pass

    def plots_cartopy(self,variable2plot,var_range):
        import matplotlib.pyplot as plt
        import cartopy
        import cartopy.crs as ccrs
        import cartopy.feature as cfeature

        if (self.data_reduced['Longitude']==0).any():
            print('removing some data points where longitude=0')
            self.data_reduced['Longitude'][self.data_reduced['Longitude']==0] = np.nan
        if (self.data_reduced['Latitude']==0).any():
            print('removing some data points where latitude=0')
            self.data_reduced['Latitude'][self.data_reduced['Latitude']==0] = np.nan

        # export with cartopy
        for iv,var in enumerate(variable2plot) :
            plt.figure(figsize=(16.0, 10.0))
            plt.ion()
            plt.show()
            ax = plt.axes(projection=ccrs.PlateCarree())
            # ax.stock_img()
            ax.add_feature(cartopy.feature.OCEAN)
            ax.add_feature(cartopy.feature.LAND, edgecolor='black')
            ax.coastlines()
            ax.gridlines(draw_labels= True)
            data_plot = self.data_reduced[var]
            im = ax.scatter(self.data_reduced['Longitude'], self.data_reduced['Latitude'], s=100, c=self.data_reduced[var], alpha=0.5,transform=ccrs.PlateCarree(),vmin=var_range[iv][0],vmax=var_range[iv][1])
            # plt.set_cmap('seismic')
            plt.colorbar(im, label =var )
            frame = 1.0
            ax.set_extent([np.min(self.data_reduced['Longitude'])-frame,
                           np.max(self.data_reduced['Longitude'])+frame,
                           np.min(self.data_reduced['Latitude'])-frame,np.max(self.data_reduced['Latitude'])+frame], crs=None)
            ax.set_title(self.op_data_folder)
            # plt.savefig('./figures_pngs/%s.png' % var,dpi=500)

    def plots_mapbox(self,variable2plot,var_range):
        # https://plotly.com/python/builtin-colorscales/
        # export with plotly
        # https://plotly.com/python/scattermapbox/
        # https://plotly.com/python/maps/
        import plotly.express as px
        px.set_mapbox_access_token('pk.eyJ1Ijoic2ltb253cDEiLCJhIjoiY2tpMGYwcHo2NmgzODJ6bDZudHB6bnl3bCJ9.tzJLkzP7-g4fG4_4qFtE1A')
        for iv,var in enumerate(variable2plot) :
            dot_size = 15*np.ones(len(self.data_reduced[var]))
            dot_size[np.isnan(self.data_reduced[var])] = 0 # bad data is not shown
            fig = px.scatter_mapbox(self.data_reduced, lat="Latitude",      # array or variable name
                                                       lon="Longitude",     # array or variable name
                                                       color=var,           # array or variable name
                                                       size = dot_size ,    # array or variable name
                                                       color_continuous_scale=px.colors.sequential.YlOrRd, 
                                                       size_max=15, 
                                                       zoom=10,
                                                       range_color = var_range[iv],
                                                       mapbox_style = 'satellite')
            fig.update_mapboxes(center_lon = self.data_reduced['Longitude'].mean(), center_lat = self.data_reduced['Latitude'].mean(), zoom=3)
            # fig.update_layout(coloraxis_colorbar=dict(title=var + ' [particles/m3]'))
            fig.show()
            # fig.write_html('./figures_mapbox/%s_mapbox_plotly.html' % var)

    def export_data(self,filename=None,csv=True,excel=False):
        if csv :
            self.data_reduced.to_csv(filename)
        if excel :
            self.data_reduced.to_excel(filename)

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
    op.clip_data_calibration() # remove data during zero and span calibration
    op.remove_time_period(tstart = '2021-5-29 08:00:00',tend = '2021-5-29 12:00:00') # remove some bad data
    op.remove_time_period(tstart = '2021-6-13 12:00:00',tend = '2021-6-13 15:00:00') # remove some bad data
    op.remove_time_period(tstart = '2021-6-02 12:00:00',tend = '2021-6-07 06:00:00') # remove some bad data
    op.remove_time_period(tstart = '2021-6-16 23:00:00',tend = '2021-6-17 02:00:00') # remove some bad data
    op.remove_time_period(tstart = '2021-6-14 13:00:00',tend = '2021-6-14 20:00:00') # remove some bad data
    op.time_average_data(rule_string = 'T') # turn into 1 minute average
    # op.plots_cartopy(variable2plot = ['pCO2','xCO2'],var_range = [[0,500],[0,500]])
    op.plots_mapbox(variable2plot = ['pCO2','xCO2'],var_range = [[0,500],[0,500]])
    # export to file using panda export function 
    # make a reduced dataframe with variables of interest
    op.data_reduced = op.data_reduced[ ['Longitude','Latitude','waterTemp','salinity','pCO2','xCO2','fCO2']]
    # export to file
    op.data_reduced.to_csv('test3.csv',na_rep=np.nan) # fill missing data with nans

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

    import pdb;pdb.set_trace()