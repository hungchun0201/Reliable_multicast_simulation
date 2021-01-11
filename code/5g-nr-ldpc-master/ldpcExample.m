%% Clean up
clear all;
clc;

%% Init
if ~isdeployed
    addpath('./codes');
end

% Constellation size
M = 4;

% LDPC config
blkSize = 256;
codeRate = '5/6';

% Get LDPC struct
LDPC = ldpcGet(blkSize, codeRate);
%{
puncture_num = 46;
weight = zeros(1, 512);
parfor bit_flip = 1:512
    bit_flip
    codeword = zeros(1, 558);
    codeword(bit_flip+puncture_num) = 1;
    syndrome = mod((codeword*LDPC.H'),2);
    while sum(syndrome) ~= 0
        if sum(codeword) == 512
            break;
        end
        position = [];
        for idx = 1:162
            if syndrome(idx) == 1
                position = [position idx];
            end
        end
        flip_idx = 0;
        max_flip = 0;
        min_extra_flip = 162;
        for idx = 1:512
            if codeword(idx+puncture_num) == 0
                flip = 0;
                extra_flip = 0;
                for jdx = 1:162
                    if LDPC.H(jdx,idx+puncture_num) == 1
                        if ismember(jdx,position)
                            flip = flip + 1;
                        else
                            extra_flip = extra_flip + 1;
                        end
                    end
                end
                if flip > max_flip
                    flip_idx = idx;
                    max_flip = flip;
                    min_extra_flip = extra_flip;
                elseif flip == max_flip && min_extra_flip > extra_flip
                    flip_idx = idx;
                    max_flip = flip;
                    min_extra_flip = extra_flip;
                end
            end
        end
        codeword(flip_idx+puncture_num) = 1;
        syndrome = mod((codeword*LDPC.H'),2);
    end
    sum(codeword)
    weight(bit_flip) = sum(codeword);
end
%}
% Simulation parameters
snr_db = 10:5:60;
snr = 10.^(snr_db./10);
ber = zeros(1,11);
per = zeros(1,11);
numIter = 5e4;
% Convert E_b/N_0 to some SNR
%snr = ebno + 10*log10(log2(M)) + 10*log10(str2num(codeRate));

%% Simulate
for idx = 1:11
    numErr = 0;
    cntErr = 0;
    parfor jdx = 1:numIter

        % Generate random data
        data = randi([0 1], 1, LDPC.numInfBits);

        % Encode
        dataEnc = ldpcEncode(data, LDPC);

        % QAM mapping
        dataMod = qammod(dataEnc(:), M, 'InputType', 'bit', 'UnitAveragePower', true);
        
        dataRx = zeros(size(dataMod, 1), size(dataMod, 2));
        % Rayleigh with diversity
        for sym_idx = 1:size(dataMod, 1)
            h = randn
            dataRx(sym_idx,1) = awgn(dataMod(sym_idx,1), snr(idx)*(h^2));
        end

        % LLR demapping
        dataLlr = qamdemod(dataRx, M, 'OutputType', 'llr', 'UnitAveragePower', true);

        % Decode
        dataHat = ldpcDecode(dataLlr', LDPC);

        % Count number of bit errors
        numErr = numErr + sum(abs(dataHat - data));

        % Count number of error symbols
        if sum(abs(dataHat - data)) ~= 0
            cntErr = cntErr + 1;
        end
    end
       %% BER
    ber(idx) = numErr / (numIter * LDPC.numInfBits)
        %% SER
    per(idx) = cntErr / numIter
end
scatter(snr_db,per)
set(gca,'yscale','log');
ylim([10^-10,1]);
ylabel("PER");
xlabel("SNR");
title("PER over SNR(QPSK)");