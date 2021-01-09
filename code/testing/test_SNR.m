format short
tx_power_dBm = 38; % 6.3 Watt
Tx_gain = 10;
Rx_gain = 10;

noise_power = -134 ; % Defined in TS 38.521-4 clause 4.4.3.2
fc = 3 * 10^9;

r = linspace(1, 2000, 1000);
tx_power_dBm_list = linspace(tx_power_dBm+Tx_gain+Rx_gain,tx_power_dBm+Tx_gain+Rx_gain,1000);
noise_power_list = linspace(noise_power,noise_power,1000);

% ---------------------------------------------------------------------------- %
%                                   Shadowing                                  %
% ---------------------------------------------------------------------------- %
log_normal_shoadowing = randn(1,1000)*8.2;
% ---------------------------------------------------------------------------- %
%            Pathloss (Referred to TR 38.901  V16.1.0 Table 7.4.1-1)           %
% ---------------------------------------------------------------------------- %
h_UT = 1.5; %(1.5<=h_UT<=22.5)
h_BS = 10;
h_diff = (h_BS-h_UT);
d_3D = sqrt(r.^2+linspace(h_diff^2,h_diff^2,1000));
UMi_PL_NLOS = 32.4 + 20*log10(fc/10^9)+31.9*log10(d_3D);%fc is normalized by 1GHz

Pr1 = tx_power_dBm_list - UMi_PL_NLOS + log_normal_shoadowing;
Pr2 = tx_power_dBm_list - fspl(r,0.1) + log_normal_shoadowing;
tmp_snr1 = Pr1 - noise_power;
tmp_snr2 = Pr2 - noise_power;
% disp(tmp_snr);
plot(r,tmp_snr1);
hold on
plot(r,tmp_snr2);
xlabel("Distance(m)");
ylabel("Received power(dBm)");
legend("UMi pathloss model","FSPL");
SNR = 10.^(tmp_snr1 ./ 10);

%disp(SNR);
e = 1 - 2.^((14 * 12) * log2((1 - erfc(sqrt(SNR ./ 2)))));

% plot(SNR);
