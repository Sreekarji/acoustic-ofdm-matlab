% main_plots.m
% All 4 plots — built from actual RX run results

clear; clc; close all;
run('../shared_params.m');
load('../rx_results.mat');   % rx_signal, tx_frame, correlation,
                             % received_symbols, rx_bits, BER,
                             % n_errors, received_text, frame_start

%% ── PLOT 1: OFDM WAVEFORM ────────────────────────────
tx_plot = tx_frame / max(abs(tx_frame));
rx_plot = rx_signal(frame_start : frame_start + length(tx_plot) - 1);

figure;
subplot(2,1,1);
plot(tx_plot);
title('Transmitted OFDM Frame — HELLO');
xlabel('Sample'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
plot(rx_plot);
title(['Received Signal — Acoustic Channel  |  BER = ', num2str(BER), ...
       '  |  Errors = ', num2str(n_errors)]);
xlabel('Sample'); ylabel('Amplitude');
grid on;
sgtitle('Plot 1 — OFDM Waveform (Real Run)');
saveas(gcf, 'plot1_waveform.png');

%% ── PLOT 2: FREQUENCY SPECTRUM ───────────────────────
figure;
freq_axis = (0:N_fft-1) * (Fs/N_fft);
spectrum  = abs(fft(rx_plot(1:N_fft)));
plot(freq_axis(1:N_fft/2), spectrum(1:N_fft/2));
title('Plot 2 — Frequency Spectrum of Received OFDM Signal (Real Run)');
xlabel('Frequency (Hz)'); ylabel('Magnitude');
xline(1125, 'r--', '1125 Hz');
xline(7875, 'r--', '7875 Hz');
grid on;
saveas(gcf, 'plot2_spectrum.png');

%% ── PLOT 3: BER vs SNR ───────────────────────────────
% Use 500 OFDM symbols of random bits for a statistically valid curve
rng(42);
num_sym_ber = 500;
test_bits   = randi([0 1], 1, bits_per_ofdm * num_sym_ber);
snr_range   = 0:2:20;
ber_sim     = zeros(size(snr_range));

for k = 1:length(snr_range)
    ebn0_dB    = snr_range(k) + 10*log10(N_sub/N_fft) ...
                 + 10*log10(N_fft/(N_fft+N_cp)) ...
                 + 10*log10(log2(M));
    frame_test = build_frame(test_bits, M, N_fft, N_cp, active_idx, N_sub, preamble);
    noisy_test = awgn(frame_test, ebn0_dB, 'measured');
    rx_sym     = run_rx(noisy_test, N_fft, N_cp, active_idx, N_sub, M, preamble);
    rx_ints    = pskdemod(rx_sym, M, pi/4);
    rx_bits_m  = de2bi(rx_ints, log2(M), 'left-msb');
    rx_b       = reshape(rx_bits_m.', 1, []);
    n_cmp      = min(length(test_bits), length(rx_b));
    ber_sim(k) = sum(test_bits(1:n_cmp) ~= rx_b(1:n_cmp)) / n_cmp;
end

snr_lin  = 10.^(snr_range/10);
ber_theo = qfunc(sqrt(2 * snr_lin));

% Real acoustic result — BER=0 plotted just below the floor
real_ber_plot = 1.5e-4;   % just above ylim floor so star is visible

figure;
semilogy(snr_range, ber_sim + 1e-6, 'bo-', 'LineWidth', 1.5); hold on;
semilogy(snr_range, ber_theo,        'r--', 'LineWidth', 1.5);
semilogy(20, real_ber_plot, 'g*', 'MarkerSize', 16, 'LineWidth', 2);
legend('Simulated BER (500 symbols)', 'Theoretical QPSK BER', ...
       ['Real Acoustic Run  BER = ', num2str(BER), '  (at SNR = 20 dB)'], ...
       'Location', 'southwest');
title('Plot 3 — BER vs SNR');
xlabel('SNR (dB)'); ylabel('BER');
grid on; ylim([1e-4 1]);
saveas(gcf, 'plot3_ber_snr.png');

%% ── PLOT 4: QPSK CONSTELLATION ──────────────────────
% Background: 200-symbol random simulation at SNR=20dB (shows all 4 clusters)
rng(42);
rand_bits  = randi([0 1], 1, bits_per_ofdm * 200);
frame_rand = build_frame(rand_bits, M, N_fft, N_cp, active_idx, N_sub, preamble);
noisy_20   = awgn(frame_rand, 20, 'measured');
sim_sym    = run_rx(noisy_20, N_fft, N_cp, active_idx, N_sub, M, preamble);

figure;
% Grey background cluster (simulation — shows all 4 quadrants)
plot(real(sim_sym), imag(sim_sym), 'o', ...
     'Color', [0.4 0.4 0.4], 'MarkerSize', 4); hold on;
% Real HELLO symbols overlaid in blue
plot(real(received_symbols), imag(received_symbols), 'bo', ...
     'MarkerSize', 8, 'LineWidth', 1.5);
axis equal; grid on;
xlim([-2 2]); ylim([-2 2]);
xlabel('In-Phase'); ylabel('Quadrature');
xline(0,'k--'); yline(0,'k--');
legend('Simulated (200 symbols, SNR=20dB)', ...
       ['Real Acoustic — "', received_text, '"'], ...
       'Location', 'southoutside', 'Orientation', 'horizontal');
title(['Plot 4 — QPSK Constellation  |  BER = ', num2str(BER), ...
       '  |  Text = "', received_text, '"']);
saveas(gcf, 'plot4_constellation.png');

disp('All 4 plots generated.');

%% ════════════════════════════════════════════════════
%% LOCAL FUNCTIONS
%% ════════════════════════════════════════════════════

function rx_symbols = run_rx(noisy_signal, N_fft, N_cp, active_idx, N_sub, M, preamble)
    correlation      = abs(conv(noisy_signal, fliplr(preamble), 'valid'));
    [~, frame_start] = max(correlation);
    data_start       = frame_start + N_fft;
    symbol_length    = N_fft + N_cp;
    ofdm_data        = noisy_signal(data_start:end);
    num_symbols      = floor(length(ofdm_data) / symbol_length);
    ofdm_data        = ofdm_data(1:num_symbols * symbol_length);
    symbols_mat      = reshape(ofdm_data, symbol_length, []);
    useful           = symbols_mat(N_cp+1:end, :);
    freq_out         = fft(useful, N_fft, 1);
    rx_symbols       = freq_out(active_idx, :);
    rx_symbols       = rx_symbols(:);
end

function symbols = qpsk_modulate(bits, M)
    bits_matrix = reshape(bits, 2, []).';
    bit_ints    = bi2de(bits_matrix, 'left-msb');
    symbols     = pskmod(bit_ints, M, pi/4).';
end

function freq_domain = subcarrier_map(symbols, N_fft, active_idx)
    freq_domain = zeros(1, N_fft);
    freq_domain(active_idx)              = symbols;
    freq_domain(N_fft - active_idx + 2) = conj(symbols);
end

function time_domain = ofdm_ifft(freq_domain)
    time_domain = real(ifft(freq_domain));
end

function symbol_cp = add_cyclic_prefix(time_domain, N_cp)
    cp        = time_domain(end-N_cp+1:end);
    symbol_cp = [cp, time_domain];
end

function full_frame = build_frame(padded_bits, M, N_fft, N_cp, active_idx, N_sub, preamble)
    bits_per_ofdm = N_sub * log2(M);
    num_symbols   = length(padded_bits) / bits_per_ofdm;
    frame         = [];
    for i = 1:num_symbols
        bit_chunk   = padded_bits((i-1)*bits_per_ofdm+1 : i*bits_per_ofdm);
        symbols     = qpsk_modulate(bit_chunk, M);
        freq_domain = subcarrier_map(symbols, N_fft, active_idx);
        time_domain = ofdm_ifft(freq_domain);
        symbol_cp   = add_cyclic_prefix(time_domain, N_cp);
        frame       = [frame, symbol_cp];
    end
    full_frame = [preamble, frame];
end