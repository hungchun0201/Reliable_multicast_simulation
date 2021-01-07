%% get_error_prob_list
function e = get_error_prob_list(n)
    % Assume the BS is type 1-C and Local Area Base Station
    % Assume that QPSK is used.
    tx_power_db = 24; % 0.25 Watt
    noise_power = -174+10*log10(180*10^3)+6+10; % -174+10log(180k)+6(NF)+10(??) (dBm)
    fc = 3*10^9;
    lambda = physconst('LightSpeed')/fc;
    SNR = [];
    for i=1:n
        r = 8000*sqrt(unifrnd(0,1));
        Pr = tx_power_db - fspl(r,lambda);
        tmp_snr = Pr - noise_power;
        % disp(tmp_snr);
        SNR = [SNR 10^(tmp_snr/10)];
    end
    %disp(SNR);
    e = 1-2.^((14*12)*log2((1-erfc(sqrt(SNR./2)))));
end