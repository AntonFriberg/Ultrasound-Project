%Ta faktiska insamlade amplituder och lägg ovanpå rough amplitudes. 

%% Initialize experiment parameters
file = 'data.xlsx';                         % Excel file with data contents
xl_parameters = xlsread(file, 'A1:A12');
Fs = xl_parameters(1)                       % samples per second
dt = 1/Fs;                                  % second per sample
collected_time = xl_parameters(7)           % duration of collected data
t = (0:dt:collected_time-dt)';
N = size(t,1);

%% Initialize rough peak-to-peak values
xl_rough_amp = xlsread(file, 'D4:EI4');

%% Extract rough peak-to-peak values
distance_vector = fliplr(1:17);                     % flipped as below
r = 1;                                              % row
for i = 1:8:135;
    % peak-to-peak readings every second column
    pos_1000  = i;
    pos_5000  = i+2;
    pos_10000 = i+4;
    pos_15000 = i+6;
    
    amp_1000(r)  = xl_rough_amp(pos_1000);         % 1  kHz readings
    amp_5000(r)  = xl_rough_amp(pos_5000);         % 5  kHz readings
    amp_10000(r) = xl_rough_amp(pos_10000);        % 10 kHz readings
    amp_15000(r) = xl_rough_amp(pos_15000);        % 15 kHz readings
    
    r = r + 1;
end

%% Plot the rough peak-to-peak values 
figure('Visible', 'off'); hold on;
set(gcf, 'PaperUnits', 'centimeters');      % set size units to cm
set(gcf, 'PaperPosition', [0 0 24 14]);     % set size
    
hold on; grid minor;
title('Rough Amplitudes');
p1 = plot(distance_vector,arrayfun(@spl,amp_1000));
p5 = plot(distance_vector,arrayfun(@spl,amp_5000));
p10 = plot(distance_vector,arrayfun(@spl,amp_10000));
p15 = plot(distance_vector,arrayfun(@spl,amp_15000));
ylim([55 85]);
xlabel('Distance (m)'); ylabel('Sound Pressure Level (dB)');
legend([p1,p5,p10,p15], {'1000 Hz','5000 Hz','10000 Hz','15000 Hz'});
filename = 'output/rough_amp';
saveas(gcf, filename, 'png');


%% Initialize microphone readings
xl_data = xlsread(file, 'D8:EI22007');

%% Extract raw amplitude data from microphone readings
time_vector = xl_data(:,1);

c = 1;                                              % column
for i = 2:8:136;
    % amplitude readings every second column
    pos_1000  = i;
    pos_5000  = i+2;
    pos_10000 = i+4;
    pos_15000 = i+6;
    
    mic_1000(:, c)  = xl_data(:, pos_1000);         % 1  kHz readings
    mic_5000(:, c)  = xl_data(:, pos_5000);         % 5  kHz readings
    mic_10000(:, c) = xl_data(:, pos_10000);        % 10 kHz readings
    mic_15000(:, c) = xl_data(:, pos_15000);        % 15 kHz readings
    c = c+1;
end

%% Plot the time amplitude data to image files
for i = 1:17;
    figure('Visible', 'off'); hold on;
    set(gcf, 'PaperUnits', 'centimeters');      % set size units to cm
    set(gcf, 'PaperPosition', [0 0 24 14]);     % set size
    
    subplot(2,2,1);
    plot(time_vector, mic_1000(:,i)); title('1000 Hz');
    xlabel('Time (s)'); ylabel('Amplitude (V)');
    axis([0 inf -0.7 0.7]);
    
    subplot(2,2,2);
    plot(time_vector, mic_5000(:,i)); title('5000 Hz');
    xlabel('Time (s)'); ylabel('Amplitude (V)');
    axis([0 inf -0.7 0.7]);
    
    subplot(2,2,3);
    plot(time_vector, mic_10000(:,i)); title('10000 Hz');
    xlabel('Time (s)'); ylabel('Amplitude (V)');
    axis([0 inf -0.7 0.7]);
    
    subplot(2,2,4);
    plot(time_vector, mic_15000(:,i)); title('15000 Hz');
    xlabel('Time (s)'); ylabel('Amplitude (V)');
    axis([0 inf -0.7 0.7]);
    
    suptitle(sprintf('Time Amplitude from %d Meters', 18-i));
    filename = sprintf('output/timedomain_%d', 18-i);
    saveas(gcf, filename, 'png');
end


%% Convert time amplitude data into frequency data
for i = 1:17
    freq_1000(:,i)  = abs(fftshift(fft(mic_1000(:,i))))/N;
    freq_5000(:,i)  = abs(fftshift(fft(mic_5000(:,i))))/N;
    freq_10000(:,i) = abs(fftshift(fft(mic_10000(:,i))))/N;
    freq_15000(:,i) = abs(fftshift(fft(mic_15000(:,i))))/N;
end

%% Plot the logarithmic frequency amplitude data to image files
for i = 1:17;
    figure('Visible', 'off'); hold on;
    set(gcf, 'PaperUnits', 'centimeters');      % set size units to cm
    set(gcf, 'PaperPosition', [0 0 24 14]);     % set size
    
    subplot(2,2,1);
    semilogy(frequency_vector, freq_1000(:,i)); title('1000 Hz');
    xlabel('Frequency (Hz)'); ylabel('Amplitude (V p-to-p)');
    axis([0 20000 0 inf]);
    
    subplot(2,2,2);
    semilogy(frequency_vector, freq_5000(:,i)); title('5000 Hz');
    xlabel('Frequency (Hz)'); ylabel('Amplitude (V p-to-p)');
    axis([0 20000 0 inf]);
    
    subplot(2,2,3);
    semilogy(frequency_vector, freq_10000(:,i)); title('10000 Hz');
    xlabel('Frequency (Hz)'); ylabel('Amplitude (V p-to-p)');
    axis([0 20000 0 inf]);
    
    subplot(2,2,4);
    semilogy(frequency_vector, freq_15000(:,i)); title('15000 Hz');
    xlabel('Frequency (Hz)'); ylabel('Amplitude (V p-to-p)');
    axis([0 20000 0 inf]);
    
    suptitle(sprintf('Frequency Amplitude from %d meters', 18-i));
    filename = sprintf('output/freqdomain_%d', 18-i);
    saveas(gcf, filename, 'png');
end

%% Peak analysis of microphone readings
clc;
for i = 1:17;
    % 1000 Hz
    u_peak = findpeaks(mic_1000(3200:11000,i), 'MinPeakHeight', 0.01, ...
                                               'MinPeakDistance', 200);
    l_peak = findpeaks(-mic_1000(3200:11000,i),'MinPeakHeight', 0.01, ...
                                               'MinPeakDistance', 200);
    limit = min(length(u_peak), length(l_peak));
    diff = u_peak(1:limit)+abs(l_peak(1:limit));
    mean_ptp_1000(i) = mean(diff);
    
    % 5000 Hz
    u_peak = findpeaks(mic_5000(3200:11000,i), 'MinPeakHeight', 0.04, ...
                                               'MinPeakDistance', 200);
    l_peak = findpeaks(-mic_5000(3200:11000,i),'MinPeakHeight', 0.04, ...
                                               'MinPeakDistance', 200);
    limit = min(length(u_peak), length(l_peak));
    diff = u_peak(1:limit)+abs(l_peak(1:limit));
    mean_ptp_5000(i) = mean(diff);
    
    % 10000 Hz
    u_peak = findpeaks(mic_10000(3200:11000,i), 'MinPeakHeight', 0.05, ...
                                                'MinPeakDistance', 200);
    l_peak = findpeaks(-mic_10000(3200:11000,i),'MinPeakHeight', 0.05, ...
                                                'MinPeakDistance', 200);
    limit = min(length(u_peak), length(l_peak));
    diff = u_peak(1:limit)+abs(l_peak(1:limit));
    mean_ptp_10000(i) = mean(diff);
    
    % 15000 Hz
    u_peak = findpeaks(mic_15000(3200:11000,i), 'MinPeakHeight', 0.02, ...
                                                'MinPeakDistance', 200);
    l_peak = findpeaks(-mic_15000(3200:11000,i),'MinPeakHeight', 0.02, ...
                                                'MinPeakDistance', 200);
    limit = min(length(u_peak), length(l_peak));
    diff = u_peak(1:limit)+abs(l_peak(1:limit));
    mean_ptp_15000(i) = mean(diff);
end

% Flip so that index represents distance
mean_ptp_1000 = fliplr(mean_ptp_1000);
mean_ptp_5000 = fliplr(mean_ptp_5000);
mean_ptp_10000 = fliplr(mean_ptp_10000);
mean_ptp_15000 = fliplr(mean_ptp_15000);

% remove invalid values
mean_ptp_1000([11,9,7,3]) = NaN;
mean_ptp_5000([12,10,9,8]) = NaN;
mean_ptp_10000([10,9,4]) = NaN;
mean_ptp_15000([10,9,5]) = NaN;
clf;
hold on;
plot(mean_ptp_15000,'o');
plot(distance_vector,amp_15000);
hold off;

%% Plot the results
figure; hold on;
set(gcf, 'PaperUnits', 'centimeters');      % set size units to cm
set(gcf, 'PaperPosition', [0 0 24 14]);     % set size
    
subplot(2,2,1); hold on; grid minor;
plot(mean_ptp_1000,'o');
plot(distance_vector,amp_1000);
title('1000 Hz');
xlabel('Distance (m)'); ylabel('Amplitude (V_{pp})');

subplot(2,2,2); hold on; grid minor;
dot5000 = plot(mean_ptp_5000,'o');
line5000 = plot(distance_vector,amp_5000);
title('5000 Hz');
xlabel('Distance (m)'); ylabel('Amplitude (V_{pp})');

subplot(2,2,3); hold on; grid minor;
plot(mean_ptp_10000,'o');
plot(distance_vector,amp_10000);
title('10000 Hz');
xlabel('Distance (m)'); ylabel('Amplitude (V_{pp})');

subplot(2,2,4); hold on; grid minor;
plot(mean_ptp_15000,'o');
plot(distance_vector,amp_15000);
title('15000 Hz');
xlabel('Distance (m)'); ylabel('Amplitude (V_{pp})');
    
suptitle(sprintf('Resulting Amplitudes', 18-i));
hL = legend([dot5000, line5000], {'Mean V_{pp}', 'Rough V_{pp}'});

filename = 'output/res_amp';
saveas(gcf, filename, 'png');

%% Convert Voltage to sound level
figure; hold on;
set(gcf, 'PaperUnits', 'centimeters');      % set size units to cm
set(gcf, 'PaperPosition', [0 0 26 18]);     % set size
   
subplot(2,2,1); hold on; grid minor;
plot(arrayfun(@spl,mean_ptp_1000),'o');
plot(distance_vector,arrayfun(@spl,amp_1000));
ylim([55 85]);
title('1000 Hz');
xlabel('Distance (m)'); ylabel('Sound Pressure Level (dB)');

subplot(2,2,2); hold on; grid minor;
dot5000 = plot(arrayfun(@spl,mean_ptp_5000),'o');
line5000 = plot(distance_vector,arrayfun(@spl,amp_5000));
ylim([55 85]);
title('5000 Hz');
xlabel('Distance (m)'); ylabel('Sound Pressure Level (dB)');

subplot(2,2,3); hold on; grid minor;
plot(arrayfun(@spl,mean_ptp_10000),'o');
plot(distance_vector,arrayfun(@spl,amp_10000));
ylim([55 85]);
title('10000 Hz');
xlabel('Distance (m)'); ylabel('Sound Pressure Level (dB)');

subplot(2,2,4); hold on; grid minor;
plot(arrayfun(@spl,mean_ptp_15000),'o');
plot(distance_vector,arrayfun(@spl,amp_15000));
ylim([55 85]);
title('15000 Hz');
xlabel('Distance (m)'); ylabel('Sound Pressure Level (dB)');
    
suptitle('Resulting Amplitudes');
legend([dot5000, line5000], {'Mean Pressure Level', 'Rough Pressure Level'});

filename = 'output/res_amp';
saveas(gcf, filename, 'png');