%%
%PAAS Plot
clear all
close all

datafolder = '/Users/emma/Documents/m-codes/PAAS analysis/Data/';
rawdatafilename = 'paas_naua_230417.csv';

t_start = '2021-12-08 19:00:00';
t_end = '2021-12-10 8:30:00';
%BG=[2.38867146094849e-05,1.82243626677138e-05,8.98625012815453e-06,0];
BG=[1.3871e-05,1.3410e-05,1.7576e-05,1.3174e-05];
n_laser=[1,2,3,4];
paas = import_PAAS([datafolder rawdatafilename], n_laser, BG, 0);

% Generate artificial Relay flags
%paas = generate_relay_flag(paas,1,5);

%% Prepare data
% Calculate b_abs
valve_functionality = [-1 0; 0 -1];
[b_abs,b_abs_highres,time,time_highres,laser_wavelength] = calculate_b_abs(paas,valve_functionality,1);


%% Plot

% b_abs
figure,
for i = 1:size(b_abs,1)
    laser_wavelength_color = wavelength2color(laser_wavelength(i), 'gammaVal', 1, 'maxIntensity', 1, 'colorSpace', 'rgb');
    plot(time_highres(i,:),b_abs_highres(i,:),'-','MarkerSize',1,'linewidth',0.5,'Color',laser_wavelength_color)
    hold all
    plot(time,b_abs(i,:),'-','MarkerSize',1,'linewidth',2,'Color',laser_wavelength_color)
end
set(gca,'fontsize',14,'linewidth',1.5)
grid on
ylabel('b_{abs} [m^{-1}]','fontsize',16)
%xlim([datetime(t_start),datetime(t_end)])
%ylim([-1.e-6,1.e-6])

%% Write netCDF
translate_PAAS_to_nc('Test','netCDF','test.nc', ...
    b_abs,b_abs_highres,time,time_highres,rawdatafilename,laser_wavelength)

