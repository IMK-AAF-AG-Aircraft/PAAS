function [paas] = import_PAAS(filename, n_laser, BG, show_plot, t_start, t_end)

% filename = location of the csv-file


%% Read data
opts = detectImportOptions(filename);
opts = setvartype(opts,{'Babs'},'double');
paas = readtable(filename,opts);

%% Prepare data
% Time into datetime
paas.TimeStamp = datetime(paas.TimeStamp);

% Sort by TimeStamp
paas = sortrows(paas,'TimeStamp');

% Get Babs for different lasers

if ismember(1,n_laser)
    b_abs_laser1 = paas.Babs(paas.Laser==0);
    laser1_wavelength = paas.Laser_WaveLength(paas.Laser==0); laser1_wavelength = laser1_wavelength(1);
    laser1_wavelength_color = wavelength2color(laser1_wavelength, 'gammaVal', 1, 'maxIntensity', 1, 'colorSpace', 'rgb');
end
if ismember(2,n_laser)
    b_abs_laser2 = paas.Babs(paas.Laser==1);
    laser2_wavelength = paas.Laser_WaveLength(paas.Laser==1); laser2_wavelength = laser2_wavelength(1);
    laser2_wavelength_color = wavelength2color(laser2_wavelength, 'gammaVal', 1, 'maxIntensity', 1, 'colorSpace', 'rgb');
end
if ismember(3,n_laser)
    b_abs_laser3 = paas.Babs(paas.Laser==2);
    laser3_wavelength = paas.Laser_WaveLength(paas.Laser==2); laser3_wavelength = laser3_wavelength(1);
    laser3_wavelength_color = wavelength2color(laser3_wavelength, 'gammaVal', 1, 'maxIntensity', 1, 'colorSpace', 'rgb');
end
if ismember(4,n_laser)
    b_abs_laser4 = paas.Babs(paas.Laser==3);
    laser4_wavelength = paas.Laser_WaveLength(paas.Laser==3); laser4_wavelength = laser4_wavelength(1);
    laser4_wavelength_color = wavelength2color(laser4_wavelength, 'gammaVal', 1, 'maxIntensity', 1, 'colorSpace', 'rgb');
end

%% Plot

if show_plot
% b_abs
figure('Renderer', 'painters', 'Position', [10 10 900 700]),

if ismember(1,n_laser)
    plot(paas.TimeStamp(paas.Laser==0),b_abs_laser1-BG(1),'o-','MarkerSize',1,'linewidth',1.5,'Color',laser1_wavelength_color)
    %plot(paas.TimeStamp(paas.Laser==0),paas.R(paas.Laser==0),'o-','MarkerSize',1,'linewidth',1.5,'Color',laser1_wavelength_color)
    hold all
    %title('overview')
end

if ismember(2,n_laser)
   plot(paas.TimeStamp(paas.Laser==1),b_abs_laser2-BG(2),'o-','MarkerSize',1,'linewidth',1.5,'Color',laser2_wavelength_color)
   %plot(paas.TimeStamp(paas.Laser==1),paas.R(paas.Laser==1),'o-','MarkerSize',1,'linewidth',1.5,'Color',laser2_wavelength_color)
end
if ismember(3,n_laser)
    plot(paas.TimeStamp(paas.Laser==2),b_abs_laser3-BG(3),'o-','MarkerSize',1,'linewidth',1.5,'Color',laser3_wavelength_color)
    %plot(paas.TimeStamp(paas.Laser==2),paas.R(paas.Laser==2),'o-','MarkerSize',1,'linewidth',1.5,'Color',laser3_wavelength_color)
    hold all
end
if ismember(4,n_laser)
    plot(paas.TimeStamp(paas.Laser==3),b_abs_laser4-BG(4),'o-','MarkerSize',1,'linewidth',1.5,'Color',laser4_wavelength_color)
    %plot(paas.TimeStamp(paas.Laser==3),paas.R(paas.Laser==3),'o-','MarkerSize',1,'linewidth',1.5,'Color',laser4_wavelength_color)
    hold all
end

set(gca,'fontsize',14,'linewidth',1.5)
grid on
legend('405 nm','515 nm','660 nm','785 nm','fontsize',6,'Location','northwest')
ylabel('b_{abs} [m^{-1}]','fontsize',10)
%ylabel('R [V]','fontsize',16)
if (exist("t_start","var") & exist("t_end","var"))
    xlim([datetime(t_start),datetime(t_end)])
end

ylim([0.,5.e-5])
%yticks(0:1-e-5:5.e-5)
%ylim([0.,6])
%legend("405 nm","515 nm","660 nm",'location','best')


end

