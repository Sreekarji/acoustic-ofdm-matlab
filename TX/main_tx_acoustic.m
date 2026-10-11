% main_tx.m — Two-laptop acoustic version
% TX laptop: plays OFDM signal through speaker only

clear; clc;
run('../shared_params.m');

%% ── INPUT ──────────────────────────────────────────
msg    = 'HELLO';
snr_dB = 20;
mode   = 'real';    % 'sim' = AWGN only | 'real' = play through speaker

%% ── PIPELINE ────────────────────────────────────────
bits       = text_to_binary(msg);
padded     = pad_bits(bits, bits_per_ofdm);
full_frame = build_frame(padded, M, N_fft, N_cp, active_idx, N_sub, preamble);

%% ── CHANNEL / PLAYBACK ──────────────────────────────
if strcmp(mode, 'sim')
    noisy_signal = awgn_channel_sim(full_frame, snr_dB);
    disp('Simulation mode — AWGN added.');

elseif strcmp(mode, 'real')
    disp('=== READY TO TRANSMIT ===');
    disp('Make sure RX laptop has started recording, then press any key...');
    pause;   % wait for keypress so RX is ready before TX plays
    disp('Playing now...');
    play_ofdm(full_frame, Fs);
    disp('Playback complete.');
end

%% ── SAVE tx_signal.mat ──────────────────────────────
original_bit_length = length(bits);
noisy_signal        = awgn_channel_sim(full_frame, snr_dB);
save('../tx_signal.mat', ...
     'noisy_signal', 'padded', 'original_bit_length', ...
     'preamble', 'N_fft', 'N_cp', 'active_idx', ...
     'M', 'N_sub', 'bits_per_ofdm', 'snr_dB');
disp('tx_signal.mat saved.');

%% ── REPORT ──────────────────────────────────────────
disp('=== TX Complete ===');
disp(['Message:      ', msg]);
disp(['Bits:         ', num2str(length(bits))]);
disp(['OFDM symbols: ', num2str(length(padded)/bits_per_ofdm)]);
disp(['Frame length: ', num2str(length(full_frame)), ' samples']);
disp(['Duration:     ', num2str(length(full_frame)/Fs * 1000), ' ms']);

%% ════════════════════════════════════════════════════
%% LOCAL FUNCTIONS
%% ════════════════════════════════════════════════════

function play_ofdm(full_frame, Fs)
    audio_out = full_frame / max(abs(full_frame));
    silence   = zeros(1, Fs);
    audio_out = [silence, audio_out, silence];
    player    = audioplayer(audio_out, Fs);
    playblocking(player);
end

function bits = text_to_binary(msg)
    bits = reshape(de2bi(double(msg), 8, 'left-msb').', 1, []);
end

function padded_bits = pad_bits(bits, bits_per_ofdm)
    remainder = mod(length(bits), bits_per_ofdm);
    if remainder ~= 0
        padded_bits = [bits, zeros(1, bits_per_ofdm - remainder)];
    else
        padded_bits = bits;
    end
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

function noisy_signal = awgn_channel_sim(full_frame, snr_dB)
    noisy_signal = awgn(full_frame, snr_dB, 'measured');
end
