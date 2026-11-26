# Formulation: definitions as implemented

All defaults come from `config/defaultConfig.m` and are copied into `results/run_info.json` on every run. The implementation uses base MATLAB because Signal Processing, Statistics and Machine Learning, and Wavelet toolboxes are not installed on this machine.

## 1. Preprocessing

For each subject and channel, `+preproc/bandpassEMG.m` designs a 4th-order Butterworth band-pass with cutoff frequencies `cfg.band = [20 90]` Hz at `cfg.fs = 200` Hz.

The design is done numerically: poles of the analogue low-pass prototype are transformed to a band-pass prototype, then mapped to the digital domain with the bilinear transform and pre-warped corner frequencies `Ω = 2 fs tan(π f / fs)`. The passband gain is set from the magnitude of the transfer function at the analogue centre frequency, `gain = 1/abs(H0)`. Filtering is forward then backward with `filter`, giving zero phase and an effective magnitude order of 8. The optional notch (`cfg.applyNotch`, default `false`) is a second-order zero/pole pair at `cfg.notchFreq = 50` Hz with `cfg.notchQ = 10`.

## 2. Segmentation

`+preproc/segmentWindows.m` uses `winSec = 2` s (`winLen = 400` samples) and `overlap = 0.5` (`hop = 200` samples). For `N` samples the number of windows is

```
nWin = floor((N - winLen)/hop) + 1
```

and the time assigned to window `k` is its centre, `t_c(k) = ((k-1)*hop + winLen/2)/fs`. For the 24,085-sample subject this gives 119 windows with centres at 1, 2, …, 119 s. Windows overlap, so window-level values are descriptive only; all inference is across subjects after collapsing channels.

## 3. Features

For window `w`, channel `c`:

| Feature | Definition | Units |
|---|---|---|
| RMS | `sqrt(mean(x.^2))` | ADC counts |
| MAV | `mean(abs(x))` | ADC counts |
| MDF | Frequency `f*` in `[20, 90]` Hz with `∫[20,f*] P(f) df = 0.5 ∫[20,90] P(f) df` | Hz |
| MNF | `∫ f P(f) df / ∫ P(f) df` over `[20, 90]` Hz | Hz |

`P(f)` is a single-sided Welch PSD estimate computed entirely with `fft`: Hamming segments of `welchSeg = 200` samples (1 s) with `welchOverlap = 100` samples (50%), zero-padded to `nfft = 512`. Each segment is mean-removed and scaled by `fs * sum(w.^2)`, with non-DC/non-Nyquist bins doubled. MDF uses `cumtrapz`; MNF uses `trapz`.

The optional wavelet energy ratio `wlr` is **not computed**: Wavelet Toolbox is unavailable. This is recorded in `results/run_info.json`.

## 4. Normalization and smoothing

For each subject, channel and feature, `nb = max(1, round(0.10*nWin))` baseline windows are used. Let `mu` and `sd` be the mean and standard deviation of those baseline values. Then

```
y_n(i) = y(i) / mu
bstd  = sd / mu
y_s(i) = mean(y_n(max(1,i-smoothWin+1):i)),  smoothWin = 5
```

`y_n` is baseline-normalized, `y_s` is causal-trailing smoothed, and `bstd` is the baseline standard deviation on the normalized scale. A zero `mu` or `sd` is replaced by `eps`. Smoothing is causal but introduces a lag of roughly `(smoothWin-1)/2 = 2` windows (2 s at the default hop) in detected onsets.

## 5. Sign convention and sensitivity metrics

Expected signs are `s = +1` for RMS and MAV, and `s = -1` for MDF and MNF. Every metric below is multiplied by `s`, so a positive value always means "changed in the expected fatigue direction".

| ID | Definition on `y_s` |
|---|---|
| M1 | Spearman rank correlation between `y_s` and time, times `s` |
| M2 | `100 * s * b`, where `b` is the OLS slope of `y_s` against time in minutes |
| M3 | `s * (mean(late) - mean(early)) / sqrt((var(early,1) + var(late,1))/2)`, with early and late being the first and last `round(0.20*nWin)` windows |
| M4 | Onset time from one of the criteria below |

Spearman correlation and midranks are implemented in base MATLAB, with ties receiving average ranks.

## 6. Onset criteria

All three criteria return `NaN` when no onset is found; `NaN` is kept distinct from "late".

- **O1 (primary).** First window of the first run of `kConsec = 3` consecutive windows satisfying `s * (y_s - 1) / bstd >= zThresh`, with `zThresh = 3`. Since `y_s` is baseline-normalized, the baseline mean is 1.
- **O2.** Same run rule with `s * (y_s - 1) >= pctThresh`, with `pctThresh = 0.10`.
- **O3.** Single change point minimizing the sum of two linear-segment residual sums of squares. Candidate splits are restricted to indices between `max(5, round(0.10*nWin))` and `nWin - max(5, round(0.10*nWin))`. The reported onset is the last pre-change window-centre time.

**Deviation from the specification.** Section 4.5 of the supplied README specified `findchangepts` on the *unnormalized* feature. `findchangepts` is not installed, so a base-MATLAB two-segment least-squares search is used. The caller passes the *smoothed normalized* series `y_s` to this search, not the raw feature. O3 is therefore a descriptive change-point summary and is not directly comparable with published `findchangepts` results.

## 7. Aggregation and inference

For each feature, metrics are first reduced to one median per subject across the 8 channels. Across the 15 subjects the code reports medians and IQRs of M1–M3, the `dirCount` of subjects with positive subject-level M3, onset detection rates, and median onset times among detections only.

Paired feature comparisons use a Wilcoxon signed-rank statistic with the normal approximation (no tie correction), followed by Holm correction across the 6 M3 pairs. A Friedman omnibus statistic is computed on the 4 × 15 subject-level M3 matrix using average ranks and the chi-square approximation from `gammainc`. With `n = 15`, all p-values are exploratory; effect sizes and consistency counts are emphasized.

`E4_onset_pairwise.csv` contains the single planned onset comparison, MDF versus RMS under O1. Its Holm family contains one test, so `p_holm` equals `p_raw`; both columns are written so the correction is explicit.

## 8. Robustness and channel consistency

`experiments/run_E5.m` reruns the full feature/normalization/metric chain while changing one setting at a time: window 1, 2 or 4 s; overlap 0, 0.5 or 0.75; band `[10 90]`, `[20 90]` or `[30 90]`; baseline fraction 0.05, 0.10 or 0.20. `sameAsDefault` compares the complete four-feature order, not just the winner.

`experiments/run_E6.m` reports, for each channel and feature, the fraction of the 15 subjects with `M3 > 0`.

## 9. Bonus fatigue time constant

For each subject, the channel-median `mdf_n` series is fitted to

```
MDF(t) = a + (1 - a) * exp(-t / tau)
```

with `fminsearch`. Parameters are searched as `(a, log(tau))` with `a` restricted to `[0.5, 1.5]` and `tau` to `[1, 1000]` s; outside those bounds the objective returns `Inf`. A fit is marked `usableFit` only if `tau` is finite and `R^2 >= 0.3`. Unusable fits stay in `E7_timeConstant.csv` and are flagged rather than silently dropped. This curve is a descriptive summary of the observed MDF trend, not an independently validated physiological time constant.

## 10. Synthetic validation

`+synth/makeSyntheticFatigue.m` generates 24,000 samples (120 s at 200 Hz). Two independent band-limited noise processes are normalized to unit RMS: a high-band component at 60–85 Hz and a low-band component at 25–50 Hz. They are mixed by a logistic transition centred at `t0` with a 2 s width, and the mixed signal is multiplied by `1 + 0.6*p`. For `t0 = Inf`, `p = 0` and the signal is stationary.

E0 runs 50 seeded signals with `t0 = 40` s and 100 stationary signals. O1 must fall within 12 s of 40 s for a run to pass; the stationary runs estimate a false-positive rate. A separate noise-amplitude sweep was **not** run; the mixed band-limited noise and the stationary null are the noise checks actually implemented.
