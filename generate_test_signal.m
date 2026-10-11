% bits_to_text.m
% Step 8: QPSK demodulation + text recovery

clear;
clc;

%% Load shared parameters
run('../shared_params.m');

%% Load transmitted test data
load('../tx_signal.mat', 'noisy_signal', 'original_bit_length');

rx_signal = noisy_signal;

%% Frame parameters
preamble_length = N_fft;
symbol_length = N_fft + N_cp;

%% Remove preamble
data_start = preamble_length + 1;
ofdm_data = rx_signal(data_start:end);

%% Extract OFDM symbols
num_symbols = floor(length(ofdm_data) / symbol_length);

ofdm_data = ofdm_data(1:num_symbols * symbol_length);

symbols = reshape(ofdm_data, symbol_length, []);

%% Remove cyclic prefix
useful_symbols = symbols(N_cp+1:end, :);

%% FFT
freq_symbols = fft(useful_symbols, N_fft, 1);

%% Extract active subcarriers
received_subcarriers = freq_symbols(active_idx, :);

%% Convert to one-dimensional QPSK symbol vector
received_symbols = received_subcarriers(:);

%% QPSK Demodulation
% IMPORTANT:
% Transmitter uses pskmod(..., M, pi/4)
% Therefore receiver must use the same phase offset.

rx_symbol_numbers = pskdemod(received_symbols, M, pi/4);

%% Convert symbol numbers to bits
rx_bit_matrix = de2bi(rx_symbol_numbers, bits_per_sym, 'left-msb');

rx_bits = reshape(rx_bit_matrix.', 1, []);

%% Remove padding
rx_bits = rx_bits(1:original_bit_length);

%% Convert bits to bytes
num_bytes = floor(length(rx_bits) / 8);

rx_bits = rx_bits(1:num_bytes * 8);

bit_matrix = reshape(rx_bits, 8, []).';

%% Convert binary to decimal
byte_values = zeros(1, size(bit_matrix,1));

for k = 1:size(bit_matrix,1)
    value = 0;

    for b = 1:8
        value = value + bit_matrix(k,b) * 2^(8-b);
    end

    byte_values(k) = value;
end

%% Convert ASCII to text
received_text = char(byte_values);

%% Display
disp('=== RECEIVED TEXT ===');
disp(received_text);