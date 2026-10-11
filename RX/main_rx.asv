% main_rx.m — Phone recording version
clear; clc; close all;
load('../tx_signal.mat');
Fs = 48000; 

%% Load recording
[rx_raw, Fs_rec] = audioread('../recording.wav');
rx_raw    = rx_raw(:,1).';
rx_signal = resample(rx_raw, Fs, Fs_rec);

%% Bandpass filter — 1125 to 7875 Hz
[b, a]    = butter(4, [1125 7875]/(Fs/2), 'bandpass');
rx_signal = filtfilt(b, a, rx_signal);

%% Preamble detection
correlation      = abs(conv(rx_signal, fliplr(preamble), 'valid'));
figure; plot(correlation); title('Preamble Correlation'); grid on;
disp(['Max correlation = ', num2str(max(correlation))]);

[~, frame_start] = max(correlation);
disp(['Frame start = ', num2str(frame_start)]);

%% Symbol extraction
data_start    = frame_start + N_fft;
symbol_length = N_fft + N_cp;
ofdm_data     = rx_signal(data_start:end);
num_symbols   = floor(length(ofdm_data) / symbol_length);
ofdm_data     = ofdm_data(1:num_symbols * symbol_length);
symbols_mat   = reshape(ofdm_data, symbol_length, []);
disp(['Symbols found = ', num2str(num_symbols)]);

%% Remove CP + FFT + extract subcarriers
useful           = symbols_mat(N_cp+1:end, :);
freq_out         = fft(useful, N_fft, 1);
received_symbols = freq_out(active_idx, :);
received_symbols = received_symbols(:);

%% QPSK demodulation
rx_ints     = pskdemod(received_symbols, M, pi/4);
rx_bits_mat = de2bi(rx_ints, log2(M), 'left-msb');
rx_bits_all = reshape(rx_bits_mat.', 1, []);
rx_bits     = rx_bits_all(1:original_bit_length);

%% Bits to text
received_text = bits_to_text(rx_bits);
disp('=== RECEIVED TEXT ===');
disp(received_text);

%% BER
tx_ref   = text_to_bits('HELLO');
n        = min(length(tx_ref), length(rx_bits));
n_errors = sum(tx_ref(1:n) ~= rx_bits(1:n));
BER      = n_errors / n;
disp(['Bit errors = ', num2str(n_errors)]);
disp(['BER        = ', num2str(BER)]);

%% Constellation
figure;
plot(real(received_symbols), imag(received_symbols), 'bo');
axis equal; grid on;
xlabel('In-Phase'); ylabel('Quadrature');
title('Received QPSK Constellation — Real Channel');
xline(0,'k--'); yline(0,'k--');

%% ── SAVE RX RESULTS FOR PLOTS ───────────────────────
% full_frame comes from tx_signal.mat (noisy_signal_sim is the AWGN version;
% we rebuild the clean frame from padded bits stored there)
bits_per_ofdm_local = N_sub * log2(M);
num_sym     = size(symbols_mat, 2);

% Reconstruct clean TX frame from padded (saved in tx_signal.mat)
tx_frame = reconstruct_tx(padded, M, N_fft, N_cp, active_idx, N_sub, preamble);

save('../rx_results.mat', ...
     'rx_signal', 'correlation', 'frame_start', ...
     'received_symbols', 'rx_bits', 'BER', 'n_errors', ...
     'tx_frame', 'received_text', 'Fs');
disp('rx_results.mat saved.');

%% LOCAL FUNCTIONS
function tx_frame = reconstruct_tx(padded_bits, M, N_fft, N_cp, active_idx, N_sub, preamble)
    bits_per_ofdm = N_sub * log2(M);
    num_symbols   = length(padded_bits) / bits_per_ofdm;
    frame         = [];
    for i = 1:num_symbols
        bit_chunk   = padded_bits((i-1)*bits_per_ofdm+1 : i*bits_per_ofdm);
        bits_matrix = reshape(bit_chunk, 2, []).';
        bit_ints    = bi2de(bits_matrix, 'left-msb');
        symbols     = pskmod(bit_ints, M, pi/4).';
        freq_domain = zeros(1, N_fft);
        freq_domain(active_idx)              = symbols;
        freq_domain(N_fft - active_idx + 2) = conj(symbols);
        time_domain = real(ifft(freq_domain));
        cp          = time_domain(end-N_cp+1:end);
        symbol_cp   = [cp, time_domain];
        frame       = [frame, symbol_cp];
    end
    tx_frame = [preamble, frame];
end

function bits = text_to_bits(text)
    bit_matrix = de2bi(double(text), 8, 'left-msb');
    bits       = reshape(bit_matrix.', 1, []);
end

function text = bits_to_text(bits)
    num_bytes  = floor(length(bits) / 8);
    bits       = bits(1:num_bytes * 8);
    bit_matrix = reshape(bits, 8, []).';
    byte_vals  = bi2de(bit_matrix, 'left-msb');
    text       = char(byte_vals).';
end