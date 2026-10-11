<div align="center">

# **ACOUSTIC OFDM COMMUNICATION SYSTEM USING MATLAB**

## **A Course Based Project Report**
### **B.E. V Semester**

<br>

### Submitted by

| Name | Roll Number |
|---|---|
| **P. Soukya Reddy** | **1602-24-735-116** |
| **Sreekar Balagoni** | **1602-24-735-117** |
| **Sumanyu Rao** | **1602-24-735-118** |

<br>

### Submitted in partial fulfilment of the requirements for the course
### **Course-Based Project**

<br>

## Department of Electronics and Communication Engineering
### Vasavi College of Engineering (Autonomous)
### Accredited by NAAC with ‘A++’ Grade
### Ibrahimbagh, Hyderabad – 500031

<br>

### Academic Year 2025–2026

</div>

<div style="page-break-after: always;"></div>

# Abstract

This course-based project presented the design and implementation of an acoustic orthogonal frequency division multiplexing (OFDM) communication system in MATLAB. The system conveyed short text messages through an audio waveform that could be written to a WAV file for repeatable loopback testing or played through a loudspeaker for capture by a microphone/phone recording workflow. The principal objective was to demonstrate the complete physical-layer path from text input to recovered text while retaining the real-valued waveform required by ordinary audio hardware.

The implemented transmitter converted 8-bit text characters to a serial bit stream, padded the stream to OFDM payload boundaries, modulated bit pairs using π/4-offset quadrature phase-shift keying (QPSK), and mapped the QPSK values onto selected positive-frequency subcarriers. Hermitian symmetry was imposed on the frequency-domain vector so that the 256-point inverse fast Fourier transform (IFFT) produced a real-valued audio-band signal. A 64-sample cyclic prefix (CP) and a deterministic BPSK preamble were added before transmission. At the receiver, the recorded waveform was resampled to 48 kHz, band-pass filtered, synchronized by matched preamble correlation, stripped of its CP, transformed by FFT, and QPSK-demodulated to reconstruct the transmitted characters.

For the supplied result artifact, the message **HELLO** was recovered successfully. The reported result contained **0 bit errors in 40 assessed payload bits**, corresponding to an observed BER of zero for that individual short run, and a peak preamble-correlation magnitude of **33.203**. The project therefore demonstrated correct ideal-link OFDM framing, Hermitian subcarrier mapping, and end-to-end message recovery. The report also identified practical limitations: the present prototype did not include channel equalization, packet-length signaling, a normalized synchronization threshold, forward-error correction, or a fully calibrated real-waveform BER-versus-\(E_b/N_0\) comparison.

**Keywords—** Acoustic communication, OFDM, MATLAB, QPSK, Hermitian symmetry, cyclic prefix, preamble synchronization, BER.

<div style="page-break-after: always;"></div>

# Contents

[Abstract](#abstract)<br>
[List of Figures](#list-of-figures)<br>
1. [Introduction](#1-introduction)<br>
&nbsp;&nbsp;&nbsp;1.1 [Background](#11-background)<br>
&nbsp;&nbsp;&nbsp;1.2 [Aim](#12-aim)<br>
2. [Literature Survey](#2-literature-survey)<br>
3. [Theoretical Analysis](#3-theoretical-analysis)<br>
4. [Tool Used: MATLAB](#4-tool-used-matlab)<br>
5. [System Diagram](#5-system-diagram)<br>
6. [Results and Discussion](#6-results-and-discussion)<br>
&nbsp;&nbsp;&nbsp;6.1 [Numerical result summary](#61-numerical-result-summary)<br>
&nbsp;&nbsp;&nbsp;6.2 [Figure 1: Transmitted and received OFDM waveform](#62-figure-1-transmitted-and-received-ofdm-waveform)<br>
&nbsp;&nbsp;&nbsp;6.3 [Figure 2: Frequency spectrum of the received preamble](#63-figure-2-frequency-spectrum-of-the-received-preamble)<br>
&nbsp;&nbsp;&nbsp;6.4 [Figure 3: BER versus SNR](#64-figure-3-ber-versus-snr)<br>
&nbsp;&nbsp;&nbsp;6.5 [Figure 4: Received QPSK constellation](#65-figure-4-received-qpsk-constellation)<br>
&nbsp;&nbsp;&nbsp;6.6 [Discussion of receiver performance](#66-discussion-of-receiver-performance)<br>
[Conclusion](#conclusion)<br>
[Future Work](#future-work)<br>
[References](#references)

# List of Figures

- **Figure 1.** Transmitted OFDM frame and aligned received waveform for the supplied `HELLO` run.
- **Figure 2.** Spectrum of the first 256 received samples aligned to frame start (the received preamble), with nominal active-band boundaries.
- **Figure 3.** Simulated BER, ideal QPSK reference, and the supplied result marker.
- **Figure 4.** Receiver-extracted QPSK values for `HELLO`, including trailing-silence samples, overlaid on a simulated 20 dB reference constellation.

<div style="page-break-after: always;"></div>

# 1. Introduction

## 1.1 Background

Acoustic data communication uses sound as the information-bearing medium. Unlike radio-frequency links, an acoustic link can be demonstrated with equipment already available on many computers and mobile devices: loudspeakers, microphones, and audio files. This property makes acoustic communication useful for short-range device pairing, low-cost laboratory demonstrations, proof-of-concept machine-to-machine links, and education in digital communication concepts. Depending on the hardware response and application, signals may occupy the audible or near-ultrasonic frequency bands. The present implementation operated in the audible audio-band region from 1.125 kHz to 7.875 kHz.

An acoustic channel is generally more frequency selective and less stable than an ideal additive white Gaussian noise (AWGN) channel. Speaker and microphone responses vary across frequency, rooms introduce reflections, and practical devices may use independent sampling clocks. A modulation system intended for such a channel must use the available spectrum efficiently and should tolerate delay spread. Orthogonal frequency division multiplexing was selected because it divides a wideband channel into many narrowband, mutually orthogonal subchannels. The resulting long symbol duration and cyclic prefix reduce sensitivity to multipath-induced inter-symbol interference (ISI).

OFDM has been extensively adopted in modern wireless standards because its FFT implementation is efficient and because one-tap frequency-domain equalization can be applied when channel estimates are available. These same concepts make OFDM a suitable educational framework for acoustic communication. In this project, the design was constrained by the need to play and record a real-valued waveform. Hermitian symmetry was consequently applied to the OFDM spectrum so that the IFFT output was real and compatible with normal mono audio WAV files.

The developed MATLAB system represented a compact baseband prototype. It included the main elements of a digital communication chain: source serialization, QPSK modulation, multicarrier mapping, guard interval insertion, packet synchronization, FFT-based recovery, demodulation, text reconstruction, and basic BER measurement. The implementation was intended to establish a clear foundation for further work on robust acoustic modems.

## 1.2 Aim

The aim of the project was to design, simulate, and demonstrate an acoustic OFDM communication link using MATLAB. The specific objectives were:

1. To model a short-range audio communication path using direct WAV loopback and a speaker/microphone recording workflow.
2. To implement real-valued Hermitian-symmetric OFDM suitable for audio playback and recording.
3. To implement π/4-offset QPSK modulation and demodulation for OFDM payload transmission.
4. To insert a cyclic prefix and assess its relationship to tolerable multipath delay spread.
5. To design a deterministic preamble and perform frame synchronization using cross-correlation.
6. To evaluate BER against SNR using an AWGN simulation and compare it with an ideal QPSK reference.
7. To demonstrate end-to-end transmission and recovery of a text message.

# 2. Literature Survey

OFDM theory is well established in digital communication literature. Proakis and Salehi described multicarrier transmission as a method for converting a frequency-selective channel into parallel narrowband subchannels [1]. Their treatment of Fourier-based signaling, cyclic prefixes, and error probability provided the communication-theory basis for the present work. In particular, OFDM permits efficient generation by IFFT and recovery by FFT, avoiding the need to synthesize and demodulate every subcarrier separately.

Haykin discussed the importance of orthogonality, matched filtering, synchronization, and channel impairments in practical communication systems [2]. These concepts were directly applicable to the implemented preamble detector. A known training waveform produces a correlation peak at the correct frame position, but practical performance depends on threshold design, timing offset, channel distortion, and noise. The present work used the basic correlation method as a first implementation, while leaving robust synchronization extensions for future work.

Sklar presented digital modulation methods and error-rate analysis for PSK systems [3]. QPSK was selected because it carries two bits per complex subcarrier symbol while retaining a simple constant-envelope constellation before OFDM summation. The commonly used ideal Gray-coded coherent-QPSK BER expression, \(Q(\sqrt{2E_b/N_0})\), served as the theoretical reference in the BER discussion. The MATLAB implementation used π/4 phase offset so that the nominal constellation points lay at diagonal angles rather than directly on the in-phase and quadrature axes.

Acoustic communication literature identifies propagation delay, multipath, transducer frequency response, ambient noise, and time-varying sampling offsets as important limitations. Although underwater acoustic channels are physically different from room acoustics, their frequency-selective and delayed nature illustrates why multicarrier transmission, guard intervals, pilots, and adaptive equalization are valuable [4]. The present project simplified these effects to make the core OFDM architecture visible and reproducible in a course setting.

MATLAB documentation and its Communications Toolbox and Signal Processing Toolbox functions were used as implementation references [5]–[8]. The repository documentation provided the system workflow, parameter set, supplied plots, and experimental interpretation [9]. It also documented an important research limitation: a direct WAV file created by the default transmitter is a repeatable loopback path, whereas a genuine over-air acoustic experiment requires the separate speaker-playback workflow and an externally recorded waveform.

# 3. Theoretical Analysis

## 3.1 OFDM fundamentals

An OFDM signal conveys data on a set of orthogonal subcarriers. For an \(N\)-point OFDM symbol with frequency-domain values \(X[k]\), the discrete-time baseband signal was generated as

\[
x[n] = \frac{1}{N}\sum_{k=0}^{N-1}X[k]e^{j2\pi kn/N}, \qquad 0\leq n\leq N-1.
\]

This operation was performed by the IFFT. At the receiver, the FFT produced

\[
Y[k] = \sum_{n=0}^{N-1}y[n]e^{-j2\pi kn/N}.
\]

When the FFT window was correctly aligned and the CP was longer than the effective channel impulse response, each subcarrier could be represented approximately as

\[
Y[k] = H[k]X[k] + W[k],
\]

where \(H[k]\) is the channel response and \(W[k]\) is frequency-domain noise. The implementation extracted the active positive-frequency values after the FFT and passed them directly to the QPSK demodulator. In the present prototype, \(H[k]\) was not estimated or equalized; therefore, the direct decision was most reliable only when channel amplitude and phase distortion were small.

Subcarrier orthogonality followed from the integer-spaced complex exponentials over an FFT interval:

\[
\sum_{n=0}^{N-1} e^{j2\pi(k-\ell)n/N} =
\begin{cases}
N, & k=\ell,\\
0, & k\ne\ell.
\end{cases}
\]

For \(F_s=48\,000\) Hz and \(N=256\), the subcarrier spacing was

\[
\Delta f=\frac{F_s}{N}=\frac{48\,000}{256}=187.5\text{ Hz}.
\]

## 3.2 Hermitian symmetry for real audio waveforms

An arbitrary complex OFDM spectrum produces a complex time-domain IFFT output. Audio hardware, however, expects a real-valued waveform. A real sequence is obtained by imposing Hermitian symmetry:

\[
X[N-k]=X^*[k].
\]

The implementation used MATLAB’s one-based indexing. If a data symbol was assigned to an element in `active_idx`, its conjugate was assigned by

```matlab
freq_domain(active_idx)              = symbols;
freq_domain(N_fft - active_idx + 2) = conj(symbols);
```

Thus, the exact mirror-index formula used was

\[
\texttt{mirror\_idx}=N_{\rm fft}-\texttt{active\_idx}+2.
\]

With `active_idx = 7:43`, the zero-indexed positive bins were \(k=6,\ldots,42\). Their frequencies were \(6\Delta f=1125\) Hz to \(42\Delta f=7875\) Hz. DC and the Nyquist bin were left zero, avoiding self-conjugate special cases. The same symmetry was applied to the BPSK preamble spectrum. Consequently, `real(ifft(freq_domain))` was mathematically justified; any residual imaginary part would only be numerical round-off.

## 3.3 Cyclic prefix and delay-spread tolerance

A cyclic prefix was formed by copying the final \(N_{\rm CP}\) samples of an IFFT output and placing them before that output:

\[
x_{\rm CP}[n] = x[(n\bmod N)], \qquad -N_{\rm CP}\le n\le N-1.
\]

In the project, \(N_{\rm CP}=64\) samples and \(F_s=48\) kHz. Therefore, the guard duration was

\[
T_{\rm CP}=\frac{64}{48\,000}=1.333\text{ ms}.
\]

The useful FFT duration was \(256/48\,000=5.333\) ms, and an entire CP-extended data symbol lasted \(320/48\,000=6.667\) ms. When the channel delay spread and residual timing offset remained within 64 samples, the CP transformed linear convolution into a circular convolution over the retained FFT window. This preserved subcarrier orthogonality and reduced ISI. The CP did not compensate for a frequency-selective gain or phase response; equalization would still be required in a non-flat acoustic channel.

## 3.4 QPSK with \(\pi/4\) offset

Each active positive-frequency subcarrier carried one QPSK value. The MATLAB implementation used

```matlab
pskmod(bit_ints, 4, pi/4)
```

which generated the ideal symbol phases

\[
s_m=e^{j(\pi/4+m\pi/2)}, \qquad m\in\{0,1,2,3\}.
\]

The bit pairs were converted to integers using `bi2de(...,'left-msb')`. With MATLAB’s default binary symbol ordering, the implemented association was:

**Table 1. Implemented π/4-offset QPSK bit-to-symbol association.**

| Bit pair | Symbol index \(m\) | Nominal phase |
|---|---:|---:|
| 00 | 0 | \(45^\circ\) |
| 01 | 1 | \(135^\circ\) |
| 10 | 2 | \(225^\circ\) |
| 11 | 3 | \(315^\circ\) |

The receiver used the matching operation `pskdemod(received_symbols, M, pi/4)` and reversed the integer-to-bit conversion using `de2bi(...,'left-msb')`. Thus, the TX/RX bit ordering and phase offset were consistent.

For coherent Gray-coded QPSK in AWGN, the standard theoretical bit-error probability is

\[
P_b=Q\left(\sqrt{\frac{2E_b}{N_0}}\right),
\]

where

\[
Q(x)=\frac{1}{\sqrt{2\pi}}\int_x^\infty e^{-t^2/2}\,dt.
\]

This expression was used as the ideal reference in the plot script. The current MATLAB calls used their default binary, rather than explicitly Gray, symbol ordering. Therefore, the ideal Gray-coded expression was a useful benchmark but was not an exact mapping-specific BER prediction. An explicit Gray mapping at both TX and RX would be required for exact correspondence to the conventional Gray-QPSK expression.

## 3.5 Preamble design and matched-filter synchronization

The frame began with a known 256-sample preamble. A deterministic random BPSK sequence was generated after setting `rng(42)`, placed on the active bins, conjugate mirrored, IFFT-transformed, and normalized. The receiver located the preamble using the magnitude of a valid cross-correlation:

\[
C[m]=\left|\sum_{n=0}^{N_p-1}r[m+n]p^*[n]\right|,
\]

where \(r[n]\) was the received waveform, \(p[n]\) was the known preamble, and \(N_p=256\). Since the stored preamble was real, the implementation used

```matlab
correlation = abs(conv(rx_signal, fliplr(preamble), 'valid'));
[~, frame_start] = max(correlation);
```

The peak index estimated the first sample of the preamble. The first data sample was then selected using `frame_start + N_fft`, which followed the 256-sample preamble. This was a valid basic matched-filter method. However, the detector did not normalize the correlation or evaluate a detection threshold, so its peak magnitude depended on recording gain, filtering, and noise.

## 3.6 System parameters

**Table 2. OFDM system parameters used in the MATLAB implementation.**

| Parameter | Symbol / implementation value | Value | Significance |
|---|---|---:|---|
| Sampling rate | \(F_s\) | 48,000 Hz | Audio sampling and receiver resampling rate |
| FFT size | \(N_{\rm FFT}\) | 256 | Number of OFDM frequency bins |
| Cyclic prefix | \(N_{\rm CP}\) | 64 samples | 1.333 ms guard interval |
| Active positive bins | `active_idx` | 7:43 | MATLAB bins corresponding to \(k=6\ldots42\) |
| Active subcarriers | \(N_{\rm sub}\) | 37 | Independent QPSK data subcarriers |
| Subcarrier spacing | \(\Delta f\) | 187.5 Hz | \(F_s/N_{\rm FFT}\) |
| Active frequency range | — | 1125–7875 Hz | Audio-band positive-frequency allocation |
| Modulation order | \(M\) | 4 | QPSK |
| Bits per QPSK symbol | \(\log_2M\) | 2 | Bits carried by one active subcarrier |
| Payload per OFDM symbol | \(N_{\rm sub}\log_2M\) | 74 bits | Payload before application framing |
| Useful symbol duration | \(N_{\rm FFT}/F_s\) | 5.333 ms | IFFT interval |
| Total symbol duration | \((N_{\rm FFT}+N_{\rm CP})/F_s\) | 6.667 ms | CP-extended OFDM interval |
| Nominal payload rate | \(74/6.667\text{ ms}\) | 11.1 kbit/s | Excludes preamble and padding overhead |
| Preamble | BPSK, Hermitian, fixed seed | 256 samples | Frame acquisition waveform |

# 4. Tool Used: MATLAB

MATLAB was used as the design, simulation, visualization, and audio-processing environment. Scripts in the repository defined the common parameters, built the transmitted frame, processed the received waveform, generated result files, and produced the four figures. MATLAB was appropriate because it provided vectorized matrix operations, FFT functions, digital modulation tools, audio file I/O, filtering functions, and plotting support in one environment.

The Communications Toolbox functions `pskmod` and `pskdemod` were used for π/4-offset QPSK modulation and demodulation. `de2bi` and `bi2de` converted between left-MSB-first bit pairs and symbol indices. The functions `ifft` and `fft` implemented the OFDM modulator and demodulator. `awgn` generated controlled additive noise for the simulation portions of the transmitter and BER plot. The plot script used `qfunc` to compute the ideal QPSK reference curve.

Audio processing was carried out with `audiowrite` and `audioread`. In the direct-WAV workflow, `TX/main_tx.m` normalized the OFDM frame, surrounded it with one second of silence on both sides, and wrote `recording.wav`. This repeatable path did not require a physical speaker or microphone. In the acoustic workflow, `TX/main_tx_acoustic.m` normalized the waveform and played it using `audioplayer`; a separate device or recorder was expected to capture the sound as `recording.wav` before decoding.

At the receiver, `resample` converted an input recording to 48 kHz. A fourth-order Butterworth band-pass filter was designed using `butter(4,[1125 7875]/(Fs/2),'bandpass')` and applied with `filtfilt`. Zero-phase filtering avoided an additional filter phase shift in the offline recording workflow. `conv` implemented the matched-correlation operation used for preamble detection. MATLAB graphics functions, including `plot`, `subplot`, `semilogy`, `legend`, `xline`, `yline`, and `saveas`, were used to create and save the waveform, spectrum, BER, and constellation figures.

# 5. System Diagram

No separate architecture image was stored in the repository. The following block diagram represents the implemented system and corresponds to the transmitter, receiver, and shared-parameter scripts.

```text
┌────────────┐  ┌──────────────┐  ┌─────────────┐  ┌─────────────────┐
│ Text Input │→ │ Bit Serializer│→ │ π/4 QPSK    │→ │ Hermitian OFDM  │
│  (ASCII)   │  │ + Zero Padding│  │ Mapper      │  │ Subcarrier Map  │
└────────────┘  └──────────────┘  └─────────────┘  └─────────────────┘
                                                                  │
                                                                  ▼
┌─────────────────────┐  ┌─────────────┐  ┌────────────────────────────┐
│ Audio Channel       │← │ Preamble    │← │ IFFT → Cyclic Prefix       │
│ WAV / Speaker–Mic   │  │ Prepend     │  │ Insertion                  │
└─────────────────────┘  └─────────────┘  └────────────────────────────┘
          │
          ▼
┌──────────────────────┐  ┌───────────────────────┐  ┌──────────────┐
│ Resample + Band-Pass │→ │ Matched-Filter Sync   │→ │ CP Removal   │
│ Filter               │  │ (Preamble Correlation)│  └──────────────┘
└──────────────────────┘  └───────────────────────┘          │
                                                               ▼
┌─────────────────────┐  ┌───────────────────────┐  ┌──────────────┐
│ Text Output         │← │ Bit Truncation / Bytes│← │ QPSK Demod.  │
└─────────────────────┘  └───────────────────────┘  └──────────────┘
                                                               ▲
                                                               │
                                                    ┌──────────┴─────────┐
                                                    │ FFT + Active-bin   │
                                                    │ Extraction         │
                                                    └────────────────────┘
```

The transmitter began by serializing each text character into eight bits. The payload was padded to a multiple of 74 bits, because each OFDM data symbol contained 37 QPSK subcarriers carrying two bits each. After Hermitian mapping, IFFT conversion, and CP insertion, the known preamble was prepended. The resulting frame was either written directly to a WAV file or played through the speaker path.

The receiver read the recording, converted it to the design sampling rate, and retained the intended acoustic band using a band-pass filter. The correlation peak identified frame timing. The CP was discarded, the useful interval was FFT-transformed, and bins 7 through 43 were passed to the matching QPSK demodulator. Finally, padding was removed according to the transmitted metadata and the recovered bits were converted to text.

# 6. Results and Discussion

## 6.1 Numerical result summary

The supplied files contained a result for the message `HELLO`. Five 8-bit characters formed a 40-bit payload, which was padded to the 74-bit capacity of one OFDM data symbol. The frame itself consisted of a 256-sample preamble followed by one 320-sample CP-extended data symbol, for 576 samples before the added silence. The supplied WAV contained 96,576 samples at 48 kHz (2.012 s), consistent with one second of leading silence, the 576-sample frame, and one second of trailing silence.

**Table 3. Numerical results from the supplied `HELLO` receive-side artifact.**

| Metric | Reported value |
|---|---|
| Message transmitted | `HELLO` |
| Message recovered | `HELLO` |
| Payload bits transmitted | 40 bits |
| OFDM payload capacity used | 1 symbol, padded from 40 to 74 bits |
| Bit errors | 0 |
| Observed BER for supplied run | 0 / 40 = 0 |
| Peak preamble correlation | 33.203 |
| Detected frame start | Sample 48,001 (one-indexed) |
| Nominal plot/run SNR label | 20 dB; not an SNR measured from the WAV recording |
| Active acoustic band | 1125–7875 Hz |

The result confirmed successful message recovery for the supplied short recording. The correlation magnitude was unnormalized, so it should be interpreted as a frame-detection indicator for that recording rather than as an absolute channel-quality metric. Similarly, zero errors in only 40 bits demonstrated correct operation for that frame but did not establish a statistically precise long-run BER. The bundled result was produced by the repository’s offline WAV workflow; it should not by itself be interpreted as a controlled over-air acoustic BER measurement.

## 6.2 Figure 1: Transmitted and received OFDM waveform

<p align="center">
  <img src="PLOTs/plot1_waveform.png" alt="Plot of transmitted and received OFDM waveforms" width="820">
</p>

**Figure 1. Transmitted OFDM frame and aligned received waveform for the supplied `HELLO` run.**

The upper subplot shows the normalized transmitted frame, including the high-amplitude preamble portion and the CP-extended OFDM data interval. The lower subplot shows the corresponding aligned portion of the received signal after front-end processing. The visual correspondence between the two traces confirmed that preamble-based alignment found the intended frame and retained the short OFDM payload structure. The figure also reported zero bit errors for the supplied run.

## 6.3 Figure 2: Frequency spectrum of the received preamble

<p align="center">
  <img src="PLOTs/plot2_spectrum.png" alt="Frequency spectrum of received OFDM signal" width="820">
</p>

**Figure 2. Spectrum of the first 256 received samples aligned to frame start (the received preamble), with nominal active-band boundaries.**

The plot script took the FFT of `rx_plot(1:N_fft)`. Because `rx_plot` began at `frame_start`, these 256 samples were the received preamble rather than an OFDM payload symbol. The spectrum concentrated energy between the indicated 1125 Hz and 7875 Hz boundaries, corresponding to zero-indexed FFT bins 6 through 42 at the 187.5 Hz subcarrier spacing. The figure therefore confirmed that the preamble allocation and receiver band-pass filter were consistent with the intended audio-band design. Energy near the band edges was affected by the finite observation length and filter response.

## 6.4 Figure 3: BER versus SNR

<p align="center">
  <img src="PLOTs/plot3_ber_snr.png" alt="Simulated BER and theoretical QPSK BER versus SNR" width="820">
</p>

**Figure 3. Simulated BER, ideal QPSK reference, and the supplied recorded-run marker.**

The script generated 500 random OFDM symbols at each SNR point from 0 dB to 20 dB. The simulated BER decreased monotonically as the requested SNR increased, confirming the expected qualitative behavior of QPSK in AWGN. The red curve represented the ideal QPSK reference. The green marker was deliberately placed at 20 dB and \(1.5	imes10^{-4}\), just above the logarithmic display floor, because a BER of zero could not be plotted directly on a log scale. Its horizontal coordinate was the script’s nominal label and was not an SNR estimated from the bundled WAV recording.

The simulation did not coincide exactly with the ideal reference curve. The implemented correction passed to `awgn(...,'measured')` was

\[
10\log_{10}\left(\frac{N_{\rm sub}}{N_{\rm FFT}}\right)+
10\log_{10}\left(\frac{N_{\rm FFT}}{N_{\rm FFT}+N_{\rm CP}}\right)+
10\log_{10}(\log_2M),
\]

which equalled approximately \(-6.36\) dB for the configured values. This expression did not fully account for the fact that the transmitted waveform was real and Hermitian symmetric, so both positive and negative frequency bins contributed to its measured time-domain power. In addition, the ideal reference assumed Gray-coded QPSK whereas the implementation used MATLAB’s default binary ordering unless a mapping option was explicitly supplied. These factors explained the visible gap between simulation and theory. A calibrated noise-variance procedure and an explicitly selected symbol mapping should be used in future measurements.

## 6.5 Figure 4: Received QPSK constellation

<p align="center">
  <img src="PLOTs/plot4_constellation.png" alt="Received QPSK constellation with simulated reference" width="620">
</p>

**Figure 4. Receiver-extracted QPSK values for `HELLO`, including trailing-silence samples, overlaid on a simulated 20 dB reference constellation.**

The gray points form the four expected QPSK clusters for the simulated reference signal. `main_rx.m` continued segmenting until the end of the 2.012 s WAV file, so it extracted 151 OFDM-length intervals (5,587 displayed positive-frequency values): the first interval contained the payload and the remaining intervals were trailing silence. Consequently, the blue point at the origin and its high multiplicity were produced by demodulating trailing zeros; only the first 37 blue values belonged to the padded `HELLO` OFDM symbol. The first 40 recovered bits were retained for text reconstruction, which was sufficient for the hard QPSK demodulator to recover the short test message without detected errors.

## 6.6 Discussion of receiver performance

The transmitter and receiver used matching π/4 phase offsets, matching left-MSB-first bit conventions, and identical active-bin definitions. These consistencies were essential to the successful `HELLO` recovery. The Hermitian mapper generated a real audio signal, while the FFT at the receiver recovered the original positive-frequency QPSK values in the absence of severe channel distortion.

The CP duration of 1.333 ms provided a meaningful guard interval for short reflected paths in a compact indoor setting. However, this protection was conditional: a channel with longer effective delay spread, or a synchronization error beyond the CP, would introduce ISI and inter-carrier interference. Since the receiver did not estimate a channel response from the preamble, it could not correct per-subcarrier amplitude attenuation or phase rotation. The constellation plot consequently motivated one-tap equalization and pilot-assisted phase tracking.

The supplied result should be interpreted carefully. A direct WAV loopback is repeatable and useful for testing software correctness, but it is not equivalent to uncontrolled speaker-to-microphone propagation. The separate acoustic-transmitter script supported physical playback, but the receiver required a matching `tx_signal.mat` file to obtain the original bit length. Thus, the current link was not self-describing over the air. A practical packet format would carry a robust preamble, payload-length field, sequence number, CRC, and coded payload.

# Conclusion

The project successfully implemented an acoustic OFDM communication prototype in MATLAB. The work used 256-point real-valued Hermitian OFDM, 37 active positive-frequency QPSK subcarriers, a 64-sample cyclic prefix, and a deterministic BPSK preamble. The transmitter converted an ASCII text message into a CP-extended audio waveform, while the receiver synchronized to the preamble, recovered the active subcarriers by FFT, demodulated QPSK, and reconstructed text.

For the supplied direct-WAV result, `HELLO` was recovered with zero observed bit errors in a 40-bit message and a peak preamble correlation of 33.203. This result confirmed correct implementation of the core framing and ideal-link signal flow. The BER-versus-SNR curve showed the expected decreasing trend, but its mismatch with the ideal reference indicated that the real Hermitian waveform, CP/SNR convention, and symbol-mapping assumptions required more careful calibration.

The work therefore achieved its educational objective of demonstrating an end-to-end acoustic OFDM link. It should be regarded as a foundation rather than a fully robust acoustic modem. The absence of equalization, normalized packet detection, self-contained length signaling, error detection/correction, and extensive acoustic trials limited its practical reliability in noisy or frequency-selective environments.

# Future Work

- Add preamble-based channel estimation and one-tap per-subcarrier equalization.
- Add pilot subcarriers or repeated training symbols for common-phase-error, carrier-frequency-offset, and sample-rate-offset tracking.
- Replace the unnormalized maximum-correlation rule with normalized correlation, a detection threshold, and a peak-to-sidelobe validation criterion.
- Add a physical-layer header containing packet length, sequence number, modulation/coding information, and a CRC.
- Add forward-error correction, such as convolutional coding, Reed–Solomon coding, or LDPC coding, with interleaving.
- Specify and implement an explicit Gray QPSK mapping at both transmitter and receiver when comparison with the standard Gray-QPSK BER expression is required.
- Calibrate AWGN generation using the actual real-waveform energy and a clearly stated \(E_b/N_0\) convention.
- Test longer messages, multiple payload lengths, and packet-error rate in addition to BER.
- Conduct repeated real acoustic measurements using different speaker/microphone pairs, distances, room conditions, and noise levels.
- Extend the prototype toward embedded implementation using an audio codec, microcontroller/DSP platform, and custom PCB hardware.

# References

[1] J. G. Proakis and M. Salehi, *Digital Communications*, 5th ed. New York, NY, USA: McGraw-Hill, 2008.

[2] S. Haykin, *Communication Systems*, 5th ed. Hoboken, NJ, USA: Wiley, 2009.

[3] B. Sklar, *Digital Communications: Fundamentals and Applications*, 2nd ed. Upper Saddle River, NJ, USA: Prentice Hall, 2001.

[4] M. Stojanovic and J. Preisig, “Underwater acoustic communication channels: Propagation models and statistical characterization,” *IEEE Communications Magazine*, vol. 47, no. 1, pp. 84–89, Jan. 2009.

[5] The MathWorks, Inc., “PSK Modulation,” *MATLAB Communications Toolbox Documentation*.

[6] The MathWorks, Inc., “AWGN Channel,” *MATLAB Communications Toolbox Documentation*.

[7] The MathWorks, Inc., “Signal Processing Toolbox Documentation: Butterworth Filters, Resampling, FFT, and Audio I/O,” *MATLAB Documentation*.

[8] The MathWorks, Inc., “MATLAB Graphics Documentation,” *MATLAB Documentation*.

[9] Sreekarji, “acoustic-ofdm-matlab: Acoustic OFDM Communication System,” GitHub repository. [Online]. Available: https://github.com/Sreekarji/acoustic-ofdm-matlab
