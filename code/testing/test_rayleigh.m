format long
digits(1000)
SNR_dB = 40:0.5:41;
SNR = 10.^(SNR_dB./10);

x_axis = log10(SNR).*10;

e_awgn = qfunc(sqrt(SNR));
e_rayleigh = 0.5.*(1.-sqrt(SNR./(2.+SNR)));

SER_awgn = 2.*e_awgn-e_awgn.^2;
SER_rayleigh = 2.*e_rayleigh-e_rayleigh.^2;

PER_awgn = 168.*SER_awgn-84*167.*SER_awgn.^2;
PER_rayleigh = 168.*SER_rayleigh-84*167.*SER_rayleigh.^2;
%{
s = zeros(1,3);
for m = 0:6
    if m == 0
        s = 2^104 - 2^104./(factorial(m).*SNR.^m).*(sqrt(SNR./(SNR+2))).^(2*m+1)
    else
        s = s - 2^104*2*m*factorial(2*m-1)./((factorial(m))^2.*(2.*SNR).^m).*(sqrt(SNR./(SNR+2))).^(2*m+1)
    end
end
PER_rayleigh_LDPC = vpa(1/2*s)
%}
clf
subplot(2,3,1);
scatter(x_axis,e_awgn,4,'b');
hold on
scatter(x_axis,e_rayleigh,4,'r');
hold off
set(gca,'yscale','log');
ylim([10^-300,1]);
legend("AWGN","Rayleigh","Location","Best");
ylabel("BER");
xlabel("SNR");
title("BER over SNR(QPSK)");

subplot(2,3,2);
scatter(x_axis,SER_awgn,4,'b');
hold on
scatter(x_axis,SER_rayleigh,4,'r');
hold off
set(gca,'yscale','log');
ylim([10^-300,1]);
legend("AWGN","Rayleigh","Location","Best");
ylabel("SER");
xlabel("SNR");
title("SER over SNR(QPSK)");

subplot(2,3,3);
scatter(x_axis,PER_awgn,4,'b');
hold on
scatter(x_axis,PER_rayleigh,4,'r');
%scatter(x_axis,PER_rayleigh_LDPC,4,'r');
hold off
set(gca,'yscale','log');
ylim([10^-300,1]);
legend("AWGN","Rayleigh","Location","Best");
ylabel("PER");
xlabel("SNR");
title("PER over SNR(QPSK)");

subplot(2,3,4);
scatter(x_axis,e_awgn,4,'b');
hold on
scatter(x_axis,e_rayleigh,4,'r');
hold off
set(gca,'yscale','log');
ylim([10^-10,1]);
legend("AWGN","Rayleigh","Location","Best");
ylabel("BER");
xlabel("SNR");
title("BER over SNR(QPSK)");

subplot(2,3,5);
scatter(x_axis,SER_awgn,4,'b');
hold on
scatter(x_axis,SER_rayleigh,4,'r');
hold off
set(gca,'yscale','log');
ylim([10^-10,1]);
legend("AWGN","Rayleigh","Location","Best");
ylabel("SER");
xlabel("SNR");
title("SER over SNR(QPSK)");

subplot(2,3,6);
scatter(x_axis,PER_awgn,4,'b');
hold on
scatter(x_axis,PER_rayleigh,4,'r');
%scatter(x_axis,PER_rayleigh_LDPC,4,'r');
hold off
set(gca,'yscale','log');
ylim([10^-10,1]);
legend("AWGN","Rayleigh","Location","Best");
ylabel("PER");
xlabel("SNR");
title("PER over SNR(QPSK)");