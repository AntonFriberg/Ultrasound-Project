Ta faktiska insamlade amplituder och lägg ovanpå rough amplitudes. 

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
    
subplot(2,2,1);
plot(distance_vector,amp_1000); title('1000 Hz');
xlabel('Distance (m)'); ylabel('Amplitude (V p-to-p)');

subplot(2,2,2);
plot(distance_vector,amp_5000); title('5000 Hz');
xlabel('Distance (m)'); ylabel('Amplitude (V p-to-p)');

subplot(2,2,3);
plot(distance_vector,amp_10000); title('10000 Hz');
xlabel('Distance (m)'); ylabel('Amplitude (V p-to-p)');

subplot(2,2,4);
plot(distance_vector,amp_15000); title('15000 Hz');
xlabel('Distance (m)'); ylabel('Amplitude (V p-to-p)');
    
suptitle(sprintf('Rough Amplitudes', 18-i));
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

dF = Fs/N;                                  % listening frequency hertz
frequency_vector = -Fs/2:dF:Fs/2-dF;        % hertz
figure;
semilogy(frequency_vector(N/2:end), freq_5000(N/2:end,1))

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

%% Plot amplitude
nbr_sample = length(amplitude1000);
xrange = linspace(0, collected_time, nbr_sample);
plot(xrange, amplitude1000)

%% Plot frequency spectrum
figure;
plot(f(N/2:end), abs(freq_amplitude(N/2:end)/N));
xlabel('Frequency (Hz)');
title('Magnitude Response');
