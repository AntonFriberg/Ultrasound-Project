function SPL = spl(input_voltage)
%SPL Summary of this function goes here
%   Detailed explanation goes here
    actual_voltage = input_voltage/100; % double 20 dB gains
    smallest_audible = 20*10^(-6);
    V_Pa = 45 * 10^(-3);
    SPL = 20*log10((actual_voltage/V_Pa)/smallest_audible);
end