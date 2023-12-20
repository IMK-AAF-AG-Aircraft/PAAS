function [b_abs,b_abs_highres,time,time_highres,laser_wavelength] = calculate_b_abs(paas,valve_functionality,corr_method)
%calculate_b_abs Calculates absorption coefficients from imported PAAS data
% Background subtraction included
%   input:   paas   imported paas data
%   valve_functionality: status of relay 1 and 2 for BG and sample
%   measurement
%   For KIT PAAS: valve_functionality = [-1 0; 0 -1];

% Number of lasers and first laser
lasers = unique(paas.Laser);
number_of_lasers = length(lasers);

% Dataset should start with a background measurement
i = 1;
while (paas.Relay1(i) ~= valve_functionality(1,1))
    paas(i,:) = [];
end

% Dataset should end with a background measurement
i = size(paas,1);
while (paas.Relay1(i) ~= valve_functionality(1,1) && ...
        paas.Relay2(i) ~= valve_functionality(1,2))
    paas(i,:) = [];
    i = i-1;
end

% Calculate f
f = paas.Calibration_Gain(1) / paas.Lockin_Gain(1);

% Calculate BG
X_bg_temp = [];
Y_bg_temp = [];
R_bg_temp = [];
P_bg_temp = [];
for i = 1:number_of_lasers
    index_bg = find(paas.Relay1 == valve_functionality(1,1) & ...
        paas.Relay2 == valve_functionality(1,2) & paas.Laser==lasers(i));
    idx = find(diff(index_bg)>number_of_lasers);
    % Length of measurement cycle
    n = max(diff(idx));
    % Average BG measurements
    x_bg = paas.X(index_bg); x_bg = reshape(x_bg(1:n*floor(length(index_bg)./n)),n,floor(length(index_bg)./n));
    y_bg = paas.Y(index_bg); y_bg = reshape(y_bg(1:n*floor(length(index_bg)./n)),n,floor(length(index_bg)./n));
    p_bg = paas.Power(index_bg); p_bg = reshape(p_bg(1:n*floor(length(index_bg)./n)),n,floor(length(index_bg)./n));
    r_bg = paas.R(index_bg); r_bg = reshape(r_bg(1:n*floor(length(index_bg)./n)),n,floor(length(index_bg)./n));
    X_bg_temp(i,:) = mean(x_bg,1,'omitnan');
    Y_bg_temp(i,:) = mean(y_bg,1,'omitnan');
    P_bg_temp(i,:) = mean(p_bg,1,'omitnan');
    R_bg_temp(i,:) = mean(r_bg,1,'omitnan');
end

% Extract measurements and reshape
X = [];
Y = [];
P = [];
R = [];
X_highres = [];
Y_highres = [];
P_highres = [];
R_highres = [];
laser_wavelength = [];
for i = 1:number_of_lasers
    index = find(paas.Relay1 == valve_functionality(2,1) & ...
        paas.Relay2 == valve_functionality(2,2) & paas.Laser==lasers(i));
    idx = find(diff(index)>number_of_lasers);
    % Length of measurement cycle
    n = max(diff(idx));
    x = paas.X(index); 
    y = paas.Y(index); 
    p = paas.Power(index); 
    r = paas.R(index); 
    % High resolution values
    X_highres(i,:) = x';
    Y_highres(i,:) = y';
    P_highres(i,:) = p';
    R_highres(i,:) = r';
    % Make average values
    x = reshape(x(1:n*floor(length(index)./n)),n,floor(length(index)./n)); X(i,:) = mean(x,1,'omitnan');
    y = reshape(y(1:n*floor(length(index)./n)),n,floor(length(index)./n)); Y(i,:) = mean(y,1,'omitnan');
    p = reshape(p(1:n*floor(length(index)./n)),n,floor(length(index)./n)); P(i,:) = mean(p,1,'omitnan');
    r = reshape(r(1:n*floor(length(index)./n)),n,floor(length(index)./n)); R(i,:) = mean(r,1,'omitnan');
    laser_wavelength(i) = paas.Laser_WaveLength(index(1));
end
laser_wavelength = laser_wavelength';

% Get time
TimeStart = NaT(number_of_lasers,size(X,2));
TimeEnd = NaT(number_of_lasers,size(X,2));
time_highres = NaT(size(X_highres));
for i = 1:number_of_lasers
    index = find(paas.Relay1 == valve_functionality(2,1) &...
        paas.Relay2 == valve_functionality(2,2) & paas.Laser==lasers(i));
    idx = find(diff(index)>number_of_lasers);
    % Length of measurement cycle
    n = max(diff(idx));
    % High resolution time
    time_highres(i,:) = paas.TimeStamp(index);
    % Average time
    time_start = paas.TimeStamp_start(index); time_start = reshape(time_start(1:n*floor(length(index)./n)),n,floor(length(index)./n));
    time_end = paas.TimeStamp_end(index); time_end = reshape(time_end(1:n*floor(length(index)./n)),n,floor(length(index)./n));
    TimeStart(i,:) = time_start(1,:);
    TimeEnd(i,:) = time_end(end,:);
end
TimeStart = datenum(TimeStart); TimeStart = min(TimeStart); TimeStart = datetime(TimeStart,'ConvertFrom','datenum');
TimeEnd = datenum(TimeEnd); TimeEnd = max(TimeEnd); TimeEnd = datetime(TimeEnd,'ConvertFrom','datenum');
time = mean([TimeStart; TimeEnd],1,'omitnan');

% Make average BG
X_bg = [];
Y_bg = [];
R_bg = [];
P_bg = [];
for i = 1:number_of_lasers
    a = X_bg_temp(i,:);
    X_bg(i,:) = arrayfun(@(k) mean(a(k:k+1)),1:length(a)-1); % the averaged bg over 2 samples
    a = Y_bg_temp(i,:);
    Y_bg(i,:) = arrayfun(@(k) mean(a(k:k+1)),1:length(a)-1); % the averaged bg over 2 samples
    a = R_bg_temp(i,:);
    R_bg(i,:) = arrayfun(@(k) mean(a(k:k+1)),1:length(a)-1); % the averaged bg over 2 samples
    a = P_bg_temp(i,:);
    P_bg(i,:) = arrayfun(@(k) mean(a(k:k+1)),1:length(a)-1); % the averaged bg over 2 samples
end


if corr_method == 1
    % Calculate b_abs using R given by the LockIn
    b_abs = ((R - R_bg) .* f) ./ (P .* paas.Calbration_CellConstant(1)); % in 1/m
    
    % High resolution data
    temp = NaN.* R_highres;
    for i = 1:number_of_lasers
        r = R_highres(i,:);
        r = reshape(r(1:n*floor(size(R_highres,2)./n)),n,floor(length(index)./n));
        r = r - R_bg(i,:); % remove average background
        temp(i,:) = r(:)';
    end
    b_abs_highres = (temp .* f) ./ (P_highres .* paas.Calbration_CellConstant(1)); % in 1/m

elseif corr_method == 2
    % Calculate b_abs using R calculated from X and Y
    R_bg = sqrt((X_bg).^2 + (Y_bg).^2); % in V
    Rc = sqrt((X).^2 + (Y).^2); % in V
    b_abs = ((Rc./P - R_bg./P_bg) .* f) ./ (paas.Calbration_CellConstant(1)); % in 1/m
    
    % High resolution data
    Rc_highres = sqrt((X_highres).^2 + (Y_highres).^2); % in V
    for i = 1:number_of_lasers
        r = Rc_highres(i,:)./P_highres(i,:);
        r = reshape(r(1:n*floor(size(R_highres,2)./n)),n,floor(length(index)./n));
        r = r - R_bg(i,:)./P_bg(i,:); % remove average background
        temp(i,:) = r(:)';
    end
    b_abs_highres = (temp .* f) ./ (paas.Calbration_CellConstant(1)); % in 1/m

else
    % Calculate b_abs in a phase correct manner
    Rc = sqrt((X-X_bg).^2 + (Y-Y_bg).^2); % in V
    b_abs = ((Rc./P) .* f) ./ (paas.Calbration_CellConstant(1)); % in 1/m
    
    % High resolution data
    temp1 = NaN.* R_highres;
    temp2 = NaN.* R_highres;
    for i = 1:number_of_lasers
        x = X_highres(i,:);
        x = reshape(x(1:n*floor(size(R_highres,2)./n)),n,floor(length(index)./n));
        x = x - X_bg(i,:); % remove average background
        temp1(i,:) = x(:)';
        y = Y_highres(i,:);
        y = reshape(y(1:n*floor(size(R_highres,2)./n)),n,floor(length(index)./n));
        y = y - Y_bg(i,:); % remove average background
        temp2(i,:) = y(:)';
    end
    Rc_highres = sqrt(temp1.^2 + temp2.^2); % in V
    b_abs_highres = ((Rc_highres./P_highres) .* f) ./ (paas.Calbration_CellConstant(1)); % in 1/m
end





