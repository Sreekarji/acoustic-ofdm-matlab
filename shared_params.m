% shared_params.m
clear; clc;

Fs           = 48000;
N_fft        = 256;
N_cp         = 64;
active_idx   = 7:43;               % MATLAB 1-indexed (bins 6-42 zero-indexed = 1125-7875 Hz)
N_sub        = length(active_idx); % 37 subcarriers
M            = 4;                  % QPSK
bits_per_sym = log2(M);            % 2 bits per subcarrier
bits_per_ofdm = N_sub * bits_per_sym; % 74 bits per OFDM symbol

% Preamble — real-valued, audio-band, Hermitian-symmetric
rng(42);
pilot_bpsk = 2*randi([0 1], 1, N_sub) - 1;
preamble_freq = zeros(1, N_fft);
preamble_freq(active_idx) = pilot_bpsk;
preamble_freq(N_fft - active_idx + 2) = pilot_bpsk;
preamble = real(ifft(preamble_freq));
preamble = preamble / max(abs(preamble));