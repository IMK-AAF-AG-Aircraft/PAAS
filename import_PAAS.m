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
subplot(4,1,1)
if ismember(1,n_laser)
    plot(paas.TimeStamp(paas.Laser==0),b_abs_laser1-BG(1),'o-','MarkerSize',1,'linewidth',1.5,'Color',laser1_wavelength_color)
    %plot(paas.TimeStamp(paas.Laser==0),paas.R(paas.Laser==0),'o-','MarkerSize',1,'linewidth',1.5,'Color',laser1_wavelength_color)
    hold all
    title('overview')
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
ylim([0.,180.e-6])
%ylim([0.,6])
%legend("405 nm","515 nm","660 nm",'location','best')

% laser power
subplot(4,1,2)
if ismember(1,n_laser)
    plot(paas.TimeStamp(paas.Laser==0),paas.Power(paas.Laser==0),'-','linewidth',1.5,'Color',laser1_wavelength_color)
    hold all
end
if ismember(2,n_laser)
    plot(paas.TimeStamp(paas.Laser==1),paas.Power(paas.Laser==1),'-','linewidth',1.5,'Color',laser2_wavelength_color)
    hold all
end
if ismember(3,n_laser)
    plot(paas.TimeStamp(paas.Laser==2),paas.Power(paas.Laser==2),'-','linewidth',1.5,'Color',laser3_wavelength_color)
    hold all
end
if ismember(4,n_laser)
    plot(paas.TimeStamp(paas.Laser==3),paas.Power(paas.Laser==3),'-','linewidth',1.5,'Color',laser4_wavelength_color)
end
ylim([0.04,0.08])

set(gca,'fontsize',14,'linewidth',1.5)
grid on
ylabel('Laser Power [W]','fontsize',10)
if (exist("t_start","var") & exist("t_end","var"))
    xlim([datetime(t_start),datetime(t_end)])
end


% relative humidity and temperature
subplot(4,1,3)
plot(paas.TimeStamp,paas.Humidity,'b-','linewidth',1.5)
set(gca,'fontsize',14,'linewidth',1.5)
grid on
ylabel('Relative Humidity [%]','FontSize',10)
if (exist("t_start","var") & exist("t_end","var"))
    xlim([datetime(t_start),datetime(t_end)])
end
yyaxis('right')
plot(paas.TimeStamp,paas.Temperature,'r-','linewidth',1.5)
legend('r.h.','Temperature','location','best','fontsize',7,'Location','southwest')
set(gca,'fontsize',14,'linewidth',1.5)
grid on
ylabel('Temperature [C]','fontsize',10)
if (exist("t_start","var") & exist("t_end","var"))
    xlim([datetime(t_start),datetime(t_end)])
end

% Phase angle XY
subplot(4,1,4)
if ismember(1,n_laser)
    plot(paas.TimeStamp(paas.Laser==0),paas.PhaseAngleXY(paas.Laser==0),'-','linewidth',1.5,'Color',laser1_wavelength_color)
    hold all
end
if ismember(2,n_laser)
    plot(paas.TimeStamp(paas.Laser==1),paas.PhaseAngleXY(paas.Laser==1),'-','linewidth',1.5,'Color',laser2_wavelength_color)
    hold all
end
if ismember(3,n_laser)
    plot(paas.TimeStamp(paas.Laser==2),paas.PhaseAngleXY(paas.Laser==2),'-','linewidth',1.5,'Color',laser3_wavelength_color)
    hold all
end
if ismember(4,n_laser)
    plot(paas.TimeStamp(paas.Laser==3),paas.PhaseAngleXY(paas.Laser==3),'o-','linewidth',0.5,'Color',laser4_wavelength_color)
end
set(gca,'fontsize',14,'linewidth',1.5)
grid on
ylabel('Phase Angle','fontsize',10)
ylim([-55,55])
if (exist("t_start","var") & exist("t_end","var"))
    xlim([datetime(t_start),datetime(t_end)])
end

% figure,
% plot(paas.Power(paas.Laser==0),paas.PhaseAngleXY(paas.Laser==0),'o')
% r1 = corrcoef(paas.Power(paas.Laser==0),paas.PhaseAngleXY(paas.Laser==0));
% hold all
% %plot(paas.Power(paas.Laser==1),paas.PhaseAngleXY(paas.Laser==1),'o')
% plot(paas.Power(paas.Laser==2),paas.PhaseAngleXY(paas.Laser==2),'o')
% r3 = corrcoef(paas.Power(paas.Laser==2),paas.PhaseAngleXY(paas.Laser==2));
% plot(paas.Power(paas.Laser==3),paas.PhaseAngleXY(paas.Laser==3),'o')
% r4 = corrcoef(paas.Power(paas.Laser==3),paas.PhaseAngleXY(paas.Laser==3));
% set(gca,'fontsize',14,'linewidth',1.5)
% grid on
% ylabel('Phase Angle','fontsize',16); xlabel('Laser Power')
% legend(['R^{2} = ',num2str(r1(2)^2)],['R^{2} = ',num2str(r3(2)^2)],['R^{2} = ',num2str(r4(2)^2)])
% 
% figure,
% plot(paas.Humidity(paas.Laser==0),paas.PhaseAngleXY(paas.Laser==0),'o'); 
% r1 = corrcoef(paas.Humidity(paas.Laser==0),paas.PhaseAngleXY(paas.Laser==0));
% hold all
% %plot(paas.Humidity(paas.Laser==1),paas.PhaseAngleXY(paas.Laser==1),'o')
% %r2 = corrcoef(paas.Humidity(paas.Laser==1),paas.PhaseAngleXY(paas.Laser==1));
% plot(paas.Humidity(paas.Laser==2),paas.PhaseAngleXY(paas.Laser==2),'o')
% r3 = corrcoef(paas.Humidity(paas.Laser==2),paas.PhaseAngleXY(paas.Laser==2));
% plot(paas.Humidity(paas.Laser==3),paas.PhaseAngleXY(paas.Laser==3),'o')
% r4 = corrcoef(paas.Humidity(paas.Laser==3),paas.PhaseAngleXY(paas.Laser==3));
% set(gca,'fontsize',14,'linewidth',1.5)
% grid on
% ylabel('Phase Angle','fontsize',16); xlabel('Humidity')
% legend(['R^{2} = ',num2str(r1(2)^2)],['R^{2} = ',num2str(r3(2)^2)],['R^{2} = ',num2str(r4(2)^2)])
end
end

