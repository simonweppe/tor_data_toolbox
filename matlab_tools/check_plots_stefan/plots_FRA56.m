    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Plots for easy evaluation of MK2 or OP data
%
% Stefan Raimund, SubCtech, France
%
% Latest Update: 2018-05-25
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% 
clc;
close all;
clear all;  
load('SCT_DATA_FRA56.mat');

label3 = "entire";             % label 3: e.g. time frame (e.g. week of the year)
label3 = char(label3);    % transform String in Char

combinedStrSubFo = strcat('Plots_',label1, '_', label2, '_', label3);   % Subfolder Name
mkdir (combinedStrSubFo);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Plot figures
% Begrenzung der X-Achse Angabe der Werte für alle Plots (Muss in den einzelnen Figgures gegebenenfalls angewählt werden
% trimeframe wird an die plots weitergegeben. In Abschnitt "Plot figures" muss nun noch entschieden werden: 
%   0 = timeframe; 1 = all data
timeframe = [datetime('04-Jul-2020 20:05:18') datetime('14-Jul-2020 19:26:52')];
% timeframe = [datetime('21-Sep-2018 12:00:00') datetime('22-Sep-2018 14:00:00')];
% timeframe = [datetime('03-Oct-2018 14:30:00') datetime('03-Oct-2018 16:15:00')];

[figDescrip1]= plot_1(1,timeframe);
disp('Plot_1 done')
[figDescrip2]= plot_2(1,timeframe);
disp('Plot_2 done')
[figDescrip3]= plot_3(1,timeframe);
disp('Plot_3 done')
[figDescrip4]= plot_4(1,timeframe);
disp('Plot_4 done')
[figDescrip5]= plot_5(1,timeframe);
disp('Plot_5 done')
[figDescrip6]= plot_6(1,timeframe);
disp('Plot_6 done')
[figDescrip7]= plot_7(1,timeframe);
disp('Plot_7 done')
[figDescrip8]= plot_8(1,timeframe);
disp('Plot_8 done')
[figDescrip9]= plot_9(1,timeframe);
disp('Plot_9 done')
[figDescrip10]= plot_10(1,timeframe,label2, label3);
disp('Plot_10 done')
[figDescrip11]= plot_11(1,timeframe,label2, label3);
disp('Plot_11 done')
[figDescrip12]= plot_12(1,timeframe,label2, label3);
disp('Plot_12 done')
[figDescrip13]= plot_13(1,timeframe,label2, label3);
disp('Plot_13 done')


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Save plots
combinedStr1     = strcat('01_',label1, '_', label2,'_',label3,'_',figDescrip1);
combinedStr2     = strcat('02_',label1, '_', label2,'_',label3,'_',figDescrip2);
combinedStr3     = strcat('03_',label1, '_', label2,'_',label3,'_',figDescrip3);
combinedStr4     = strcat('04_',label1, '_', label2,'_',label3,'_',figDescrip4);
combinedStr5     = strcat('05_',label1, '_', label2,'_',label3,'_',figDescrip5);
combinedStr6     = strcat('06_',label1, '_', label2,'_',label3,'_',figDescrip6);
combinedStr7     = strcat('07_',label1, '_', label2,'_',label3,'_',figDescrip7);
combinedStr8     = strcat('08_',label1, '_', label2,'_',label3,'_',figDescrip8);
combinedStr9     = strcat('09_',label1, '_', label2,'_',label3,'_',figDescrip9);
combinedStr10     = strcat('10_',label2, '_', label1,'_',label3,'_',figDescrip10);
combinedStr11     = strcat('11_',label2, '_', label1,'_',label3,'_',figDescrip11);
combinedStr12     = strcat('12_',label2, '_', label1,'_',label3,'_',figDescrip12);
combinedStr13     = strcat('13_',label2, '_', label1,'_',label3,'_',figDescrip13);

print('-f1',strcat(combinedStrSubFo,'\',combinedStr1),'-dpng');
print('-f2',strcat(combinedStrSubFo,'\',combinedStr2),'-dpng');
print('-f3',strcat(combinedStrSubFo,'\',combinedStr3),'-dpng');
print('-f4',strcat(combinedStrSubFo,'\',combinedStr4),'-dpng');
print('-f5',strcat(combinedStrSubFo,'\',combinedStr5),'-dpng');
print('-f6',strcat(combinedStrSubFo,'\',combinedStr6),'-dpng');
print('-f7',strcat(combinedStrSubFo,'\',combinedStr7),'-dpng');
print('-f8',strcat(combinedStrSubFo,'\',combinedStr8),'-dpng');
print('-f9',strcat(combinedStrSubFo,'\',combinedStr9),'-dpng');
print('-f10',strcat(combinedStrSubFo,'\',combinedStr10),'-dpng'); %für eps: '-deps'
print('-f11',strcat(combinedStrSubFo,'\',combinedStr11),'-dpng');
print('-f12',strcat(combinedStrSubFo,'\',combinedStr12),'-dpng');
print('-f13',strcat(combinedStrSubFo,'\',combinedStr13),'-dpng');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('****************************************************** ');
disp('*');
disp('*');
disp('*                  End data evaluation');
disp('*');
disp('*');
disp('****************************************************** ');

close all;