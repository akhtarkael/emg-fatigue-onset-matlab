# Detecting Muscle Fatigue Onset from Surface EMG: A Comparative Study of Spectral and Time-Domain Features in MATLAB

**MATLAB Success Story | Category: Biomedical Signal Processing | `[TODO: program / challenge name]`**

> Give the tool a multi-channel surface EMG recording of a sustained muscle effort. It cleans the signal, extracts spectral and time-domain fatigue indicators in sliding windows, and reports which indicator reveals the onset of fatigue earliest and most consistently, with every claim backed by a number and a figure produced by the code in this repository.

<!-- Replace with a real image once available -->
![Hero: raw vs filtered EMG, and the median-frequency shift from early to late in the recording](docs/media/hero.png)

- Demo video / write-up: `[TODO: link]`
- Team: `[TODO: team name]` (Jennifer, Kael)
- Institution: Universitas Brawijaya, Malang, Indonesia
- MATLAB release: `[TODO: e.g. R2026b]`
- Required products: MATLAB, Signal Processing Toolbox, Statistics and Machine Learning Toolbox
- Optional products: Wavelet Toolbox (wavelet feature)

> **Note for coding agents:** read Section 10 (Implementation Plan and Agent Rules) completely before writing any code. Sections 4, 7 and 9 are the specification. Section 8 is filled only from files produced by the code.

---

## Contents

1. [Problem Statement](#1-problem-statement)
2. [Contribution and Positioning](#2-contribution-and-positioning)
3. [Research Questions and Hypotheses](#3-research-questions-and-hypotheses)
4. [Solution Approach](#4-solution-approach)
5. [How MATLAB Was Used](#5-how-matlab-was-used)
6. [How Generative AI Was Used](#6-how-generative-ai-was-used)
7. [Experiments](#7-experiments)
8. [Key Results](#8-key-results)
9. [Repository Structure and Data Contracts](#9-repository-structure-and-data-contracts)
10. [Implementation Plan and Agent Rules](#10-implementation-plan-and-agent-rules)
11. [Getting Started](#11-getting-started)
12. [Limitations and Future Work](#12-limitations-and-future-work)
13. [Team](#13-team)
14. [References](#14-references)

---

## 1. Problem Statement

Muscle fatigue is a decline in a muscle's ability to produce force. It matters in sport, rehabilitation, and workplace ergonomics, where detecting it early can prevent injury. Surface electromyography (sEMG) is a non-invasive way to observe it, because the electrical activity of the muscle changes as it tires. Classic findings are that the signal's frequency content shifts toward lower frequencies and its amplitude tends to rise. Many indicators have been proposed, and a practitioner must choose one. Two problems follow:

1. **Which indicator to trust.** Spectral indicators (median and mean frequency) and time-domain indicators (RMS, mean absolute value) are all used, but they differ in how consistently and how early they respond. The choice is often made by habit rather than by comparison on the same data.
2. **A workflow that is hard to repeat.** Raw sEMG is noisy, quantized, and recorded with varying hardware settings. Without a clean, scripted pipeline, results are difficult to reproduce or compare.

**Goal:** build a reproducible MATLAB pipeline that

- loads a public multi-channel sEMG fatigue dataset and checks its quality,
- filters the signals and extracts spectral and time-domain features in sliding windows,
- quantifies how strongly and how early each feature responds to fatigue using explicit, stated criteria,
- validates the whole method on synthetic signals with a known fatigue onset, and
- reports the ranking of features, whether it agrees with the classic hypotheses, and where it does not.

## 2. Contribution and Positioning

We do not claim a new fatigue index or new signal processing theory. Median and mean frequency as fatigue indicators are classical. Our contribution is a transparent, reproducible comparison implemented in MATLAB:

1. **A complete scripted pipeline** from raw recording to ranked indicators, built on Signal Processing Toolbox functions, with open code.
2. **An explicit definition of "onset".** We compare features with the same detection criteria (a z-score criterion, a fixed percentage criterion, and a change-point criterion) so that features with different natural variability are treated fairly.
3. **Validation on synthetic signals with known onset**, so that the detection method is tested before it is trusted on real data.
4. **A robustness study** showing whether the ranking of features changes with window length, overlap, and filter band.
5. **Honest reporting.** The classic hypotheses are tested, not assumed. Results that contradict them are reported.

### Prior work we build on

| | Classic sEMG fatigue literature | MathWorks example: arm motions with EMG and deep learning | **This work** |
|---|---|---|---|
| Goal | Characterize spectral and amplitude changes with fatigue | Classify forearm motions | Compare features for fatigue onset detection |
| Method | Median/mean frequency, RMS, other indices | CNN sequence-to-sequence classification | Classical features, change detection, statistics |
| Dataset | Varies by study | Carleton myoelectric dataset (motions, 3 s each) | Public multi-channel sEMG fatigue dataset (Section 4.1) |
| Output | Trends, indices | Accuracy, confusion chart | Feature ranking, onset times, robustness analysis |
| Interpretability | High | Lower (neural network) | High (physically meaningful features) |

The comparison reflects what the sources describe and is not a systematic review. `[TODO before submission: add 2 to 3 recent papers on sEMG fatigue detection to docs/literature.md and position this work against them.]`

## 3. Research Questions and Hypotheses

**Primary question (RQ1).** Among median frequency (MDF), mean frequency (MNF), RMS, and mean absolute value (MAV), which feature shows fatigue-related change most consistently and earliest in a sustained effort?

**Secondary questions.**

- **RQ2.** Does the ranking of features depend on analysis choices (window length, overlap, filter band)?
- **RQ3.** Are the effects consistent across the 8 recorded channels and across subjects?
- **RQ4 (optional).** Can the decline of MDF be summarized by a single fatigue time constant per subject?

**Hypotheses (from the classic literature, to be tested).**

| ID | Hypothesis | Expected direction |
|---|---|---|
| H1 | MDF and MNF decrease over the recording | Down |
| H2 | RMS and MAV increase over the recording | Up |
| H3 | Spectral features respond more consistently (higher effect size) and earlier than amplitude features | MDF/MNF rank above RMS/MAV |

These may be wrong for this dataset (low sampling rate, 8-bit resolution, one task type). The results section states whether each hypothesis is supported, partly supported, or not supported.

## 4. Solution Approach

### 4.1 Dataset

**Primary dataset:** *Multi-channel Surface EMG Dataset for Fatigue analysis* (Ebied, Awadallah, Abbass, El-Sharkawy; Zenodo, 2021). DOI: `10.5281/zenodo.5189275`. Licence: CC BY 4.0. Associated paper: DOI `10.1109/NILES50944.2020.9257909`.

As described on the dataset page:

| Property | Value |
|---|---|
| Subjects | 15 healthy |
| Channels | 8 sEMG channels |
| Task | 6 kg load held with the elbow flexed at 90 degrees |
| Duration | 120 s per subject |
| Sampling rate | 200 Hz |
| Resolution | 8 bit |
| Pre-processing already applied | 50 Hz notch filter |
| Format | One txt file per subject, or one .mat file with all subjects |
| Size | 10.6 MB (zip) |
| File | `Dataset EMG Fatigue.zip`, md5 `a954b4eff5594fd8b1670b1a1d0eb864` |

Direct download: `https://zenodo.org/records/5189275/files/Dataset%20EMG%20Fatigue.zip?download=1`

**Consequences of these properties for the method** (these drive several design choices below):

- **Sampling rate is 200 Hz**, so the usable band ends below 100 Hz (Nyquist). The common 20 to 450 Hz sEMG band cannot be used. We use 20 to 90 Hz.
- **A 50 Hz notch is already applied**, so we do not apply another one by default. It leaves a dip near 50 Hz in every spectrum. This biases absolute MDF/MNF values slightly but affects early and late windows alike, so normalized trends are much less affected.
- **8-bit resolution** means coarse amplitude quantization. We check the number of distinct amplitude levels per channel in the quality check.
- **There is no ground-truth fatigue label.** Onset is defined by the method (Section 4.5), not given by the data. We do not assume that subjects reached exhaustion within 120 s.
- **The mapping from channel to muscle is not stated on the dataset page.** `[TODO: read the NILES 2020 paper and fill the channel-to-muscle mapping in docs/dataset.md.]` Until then, channels are treated as numbered channels and are not assigned to muscles.
- **The exact file layout is not documented on the page** (orientation of the matrix, variable names, units). The loader must inspect the files and document what it finds (Section 10, Task 1).

**Optional second dataset (only if time remains):** Lim et al., *Assessment of Self-report, Palpation, and Surface Electromyography Dataset During Isometric Muscle Contraction*, Scientific Data, 2024 (DOI `10.1038/s41597-024-03030-8`), 30 male subjects, nine upper body muscles, isometric contraction. Its sampling rate, file format, and labels must be checked before use. This would allow a check on whether conclusions hold on a higher-bandwidth recording.

### 4.2 Pipeline overview

```
Raw sEMG (8 ch, 200 Hz)
   -> Stage 0: load + quality check
   -> Stage 1: preprocessing (DC removal, band-pass 20-90 Hz, optional notch)
   -> Stage 2: sliding-window segmentation (2 s, 50% overlap)
   -> Stage 3: feature extraction per window and channel (RMS, MAV, MDF, MNF, optional wavelet ratio)
   -> Stage 4: baseline normalization + causal smoothing
   -> Stage 5: sensitivity metrics + onset detection + feature ranking
   -> Stage 6 (bonus): MDF decay time constant, early-vs-late classification
   -> Validation: synthetic signals with known onset (Experiment E0)
```

### 4.3 Stage 1 and 2: preprocessing and segmentation

1. Remove the mean of each channel (DC offset).
2. Zero-phase Butterworth band-pass, default 20 to 90 Hz, order 4 (`butter` with `filtfilt`, which doubles the effective magnitude order). Configurable. The notch is off by default (`cfg.applyNotch = false`) because the dataset is already notch-filtered. If switched on, use `iirnotch`.
3. Segment each channel into windows of `winSec = 2` s (400 samples) with `overlap = 0.5`. Window times are recorded as the window center in seconds.

Window overlap makes neighbouring windows correlated. Statistics computed across windows are therefore descriptive and p-values over windows are not valid. Inference is done across subjects, never across windows.

### 4.4 Stage 3: features

Features are computed for every window and channel. Expected direction under fatigue is the classic one (Section 3).

| Feature | Definition | Domain | Expected |
|---|---|---|---|
| `rms` | `sqrt(mean(x.^2))` | Time | Up |
| `mav` | `mean(abs(x))` | Time | Up |
| `mdf` | Median frequency of the power spectrum within `specBand` | Frequency | Down |
| `mnf` | Mean frequency of the power spectrum within `specBand` | Frequency | Down |
| `wlr` (optional) | Wavelet energy ratio: energy in low-frequency levels divided by energy in high-frequency levels, from `modwt` | Time-frequency | Up |

Spectrum estimation: Welch estimate per window with `pwelch(x, hamming(200), 100, 512, fs)` (1 s sub-windows with 50% overlap, which reduces the variance of the estimate compared with a single periodogram). Then `medfreq(pxx, f, specBand)` and `meanfreq(pxx, f, specBand)`, with `specBand = [20 90]`. `[TODO for agent: confirm in the MATLAB documentation for the installed release that medfreq and meanfreq accept (pxx, f, rangeofinterest); if not, compute MDF and MNF directly from pxx with cumulative trapezoidal integration.]`

For `wlr` at 200 Hz, `modwt` detail levels cover approximately: D1 50 to 100 Hz, D2 25 to 50 Hz, D3 12.5 to 25 Hz, D4 6 to 12 Hz. The agent must state in `docs/formulation.md` which levels are used for "low" and "high" given the band-pass. Because the data are band-passed to 20 to 90 Hz, the default choice is low = D2 (25 to 50 Hz) and high = D1 (50 to 100 Hz). This feature is optional and is dropped if the Wavelet Toolbox is not available.

### 4.5 Stage 4 and 5: normalization, onset, and sensitivity metrics

**Normalization.** For each subject, channel, and feature, divide by the mean of the baseline windows (the first `baselineFrac = 0.10` of the recording). A normalized value of 1 means "same as baseline".

**Smoothing.** A causal (trailing) moving mean over `smoothWin = 5` windows, so that the smoothed value at time `t` uses only windows up to `t`. This is stated explicitly because it adds a lag to detected onsets.

**Sign convention.** Let `s = +1` for features expected to rise and `s = -1` for features expected to fall. All metrics below are sign-adjusted so that a positive value means "changed in the expected fatigue direction".

**Sensitivity metrics** (computed per subject, channel, and feature):

| ID | Metric | What it measures |
|---|---|---|
| M1 | Spearman correlation between the feature and time, multiplied by `s` | Consistency of the trend |
| M2 | Normalized slope: linear-fit slope of the normalized feature in percent of baseline per minute, multiplied by `s` | Speed of change |
| M3 | Cohen's d between the first `earlyLateFrac = 0.20` and the last 20% of windows, multiplied by `s` | Size of the change relative to natural variability |
| M4 | Onset time (below) | How early the change is detectable |

**Onset detection** (three criteria, reported separately):

- **O1 (primary), z-score criterion.** Onset is the time of the first window in the first run of `k = 3` consecutive smoothed windows where `s * (y - baselineMean) / baselineStd >= zThresh`, with `zThresh = 3`. If there is no such run, onset is `NaN` (not detected). This treats features fairly even though RMS is naturally noisier than MDF in relative terms.
- **O2, fixed percentage criterion.** Same logic, but the condition is `s * (y - 1) >= 0.10` on the normalized feature. Easy to explain, but not variability-adjusted.
- **O3, change-point criterion.** `findchangepts` on the normalized (unsmoothed) feature with `Statistic = "linear"` and `MaxNumChanges = 1`. The reported time is the change-point location.

Also report the **detection rate** (fraction of subject-channel pairs with a detected onset) per feature and criterion. A feature that rarely crosses its threshold is not "late", it is "not detected", and the two must not be mixed in averages.

**Aggregation across subjects.** Per feature: median and interquartile range of M1 to M3 over subjects (after taking the median across channels within a subject, and also reported per channel). Paired comparison between features across subjects with the Wilcoxon signed-rank test (`signrank`) and Holm correction. A Friedman test (`friedman`) is used as an omnibus check on M3. With 15 subjects, all tests are exploratory and effect sizes are emphasized over p-values.

### 4.6 Stage 6 (bonus): optional extensions

**B1: fatigue time constant (RQ4).** Fit the normalized MDF to `MDF(t) = a + (1 - a) * exp(-t / tau)` with `fminsearch` (base MATLAB) or `lsqcurvefit` if Optimization Toolbox is available. Report `tau` and `R^2` per subject. This is similar in spirit to parameter estimation in a Simulink model, but needs no Simulink. Subjects whose fit does not converge or has `R^2 < 0.3` are reported as such rather than dropped silently.

**B2: early-versus-late classification.** Train an SVM (`fitcsvm`) to separate early windows (first 20%) from late windows (last 20%), using leave-one-subject-out validation so that no subject appears in both training and test data. Compare single features and feature groups (spectral, time-domain, all). **Caveat that must appear in the results:** the labels are defined by time position, not by an independent fatigue measurement, so this tests whether a feature separates early from late, not whether it detects fatigue itself.

### 4.7 Validation checks

- **Synthetic validation (E0).** A generator (`+synth/makeSyntheticFatigue.m`) produces 120 s signals at 200 Hz with a known onset time. Before onset, the signal is stationary colored noise. After onset, the spectral content shifts toward lower frequencies and the amplitude rises gradually. The pipeline must recover MDF onset within a stated tolerance, and must not report an onset on purely stationary signals more often than a stated false-positive rate.
- **Unit tests** for RMS, MAV, MDF, MNF on known sinusoids and noise, window counting, filter gain, sign conventions, and onset logic.
- **Data checks**: number of subjects, channels, and samples per recording, flat or clipped channels, number of distinct amplitude levels (8-bit check).
- **Reproducibility**: fixed random seed (`rng(0)`), all parameters in `config/defaultConfig.m`, tested MATLAB release recorded in `results/run_info.json`.

## 5. How MATLAB Was Used

| Product | Used for |
|---|---|
| MATLAB | Data loading, pipeline, experiment scripts, figures, tables |
| Signal Processing Toolbox | `butter`/`filtfilt`/`bandpass`, `iirnotch`, `pwelch`, `medfreq`, `meanfreq`, `findchangepts` |
| Statistics and Machine Learning Toolbox | `corr` (Spearman), `signrank`, `friedman`, `fitcsvm`, `boxchart` |
| Wavelet Toolbox (optional) | `modwt` for the wavelet energy ratio |
| Unit testing framework | `matlab.unittest` tests in `tests/` |

## 6. How Generative AI Was Used

> This section must reflect what the team actually did. Fill it from `docs/genai_log.md`, which is updated at every working session.

**Tools used:** `[TODO: list the tools actually used, e.g. Claude, MATLAB Copilot, GitHub Copilot, an agentic coding assistant]`

### Workflow

| Stage | How AI was used | How we verified the output |
|---|---|---|
| Dataset search | Suggested candidate public sEMG fatigue datasets | Opened the dataset page and checked licence, sampling rate, channels, duration |
| Planning and design | Discussing the study design and feature definitions | Compared against the literature and tested on synthetic signals |
| Code | Drafting MATLAB functions and tests | Unit tests, synthetic validation (E0), manual inspection of figures |
| Debugging | Explaining errors and proposing fixes | Reproduced the bug and checked the fix with a test |
| Documentation | Drafting and editing README text | Team review against the actual results |

### Verification policy

- AI-generated code is not accepted until it passes a test we can explain.
- Every reference is checked against the original source before it is cited.
- Numbers in this README come from files in `results/`, not from AI text.
- Where the dataset is silent (for example channel-to-muscle mapping), the code and README say so instead of guessing.

### Examples where AI output was wrong and we caught it

`[Keep only entries that match your own log. Do not invent entries.]`

- `[TODO: add real examples from docs/genai_log.md]`

Full record: [`docs/genai_log.md`](docs/genai_log.md).

## 7. Experiments

All tables show planned results. Values are filled from the scripts in `experiments/` and from `results/tables/`.

**E0: Synthetic validation.** Signals with known onset `t0` (default 40 s). Report: detected onset versus `t0` for each feature and criterion, false-positive rate on stationary signals, and the effect of added noise. Pass criteria are in Section 10 (acceptance tests).

| Feature | True onset (s) | Detected, O1 (s) | Error (s) | False-positive rate (stationary) |
|---|---|---|---|---|
| MDF | 40 | `[TBD]` | `[TBD]` | `[TBD]` |
| MNF | 40 | `[TBD]` | `[TBD]` | `[TBD]` |
| RMS | 40 | `[TBD]` | `[TBD]` | `[TBD]` |
| MAV | 40 | `[TBD]` | `[TBD]` | `[TBD]` |

**E1: Signal quality and filtering (before and after).** For all subjects: samples per channel, number of distinct amplitude levels, flat or clipped channels. For one representative subject: raw versus filtered time series and the power spectral density of the first versus last 10% of the recording.

**E2: Feature trends.** Normalized feature versus time for each subject, plus the grand median with interquartile band across subjects. One figure per feature, and one combined figure with all features on the same normalized axis.

**E3: Sensitivity ranking.** The main result table.

| Feature | M1 Spearman (median [IQR]) | M2 slope (% baseline / min) | M3 Cohen's d | Direction as expected (subjects, of 15) |
|---|---|---|---|---|
| MDF | `[TBD]` | `[TBD]` | `[TBD]` | `[TBD]` |
| MNF | `[TBD]` | `[TBD]` | `[TBD]` | `[TBD]` |
| RMS | `[TBD]` | `[TBD]` | `[TBD]` | `[TBD]` |
| MAV | `[TBD]` | `[TBD]` | `[TBD]` | `[TBD]` |
| WLR (optional) | `[TBD]` | `[TBD]` | `[TBD]` | `[TBD]` |

**E4: Onset detection comparison.**

| Feature | Detection rate O1 | Median onset O1 (s) | Detection rate O2 | Median onset O2 (s) | Median change-point O3 (s) |
|---|---|---|---|---|---|
| MDF | `[TBD]` | `[TBD]` | `[TBD]` | `[TBD]` | `[TBD]` |
| MNF | `[TBD]` | `[TBD]` | `[TBD]` | `[TBD]` | `[TBD]` |
| RMS | `[TBD]` | `[TBD]` | `[TBD]` | `[TBD]` | `[TBD]` |
| MAV | `[TBD]` | `[TBD]` | `[TBD]` | `[TBD]` | `[TBD]` |

Paired comparisons (for example MDF versus RMS onset time across subjects where both are detected) are reported with the Wilcoxon signed-rank test, the Holm-corrected p-value, and the number of subjects entering the comparison.

**E5: Robustness to analysis choices.** Repeat E3 while varying one setting at a time: window length (1, 2, 4 s), overlap (0, 0.5, 0.75), filter band (`[20 90]`, `[10 90]`, `[30 90]`), baseline fraction (0.05, 0.10, 0.20). Report whether the feature ranking by M3 changes.

| Setting | Value | Ranking by M3 (best to worst) | Same as default? |
|---|---|---|---|
| Default | 2 s, 0.5, [20 90], 0.10 | `[TBD]` | n/a |
| Window | 1 s | `[TBD]` | `[TBD]` |
| Window | 4 s | `[TBD]` | `[TBD]` |
| Band | [10 90] | `[TBD]` | `[TBD]` |
| Band | [30 90] | `[TBD]` | `[TBD]` |

**E6: Channel consistency.** For each feature, the fraction of subject-channel pairs that change in the expected direction, per channel (1 to 8). Reveals whether the result depends on a few channels.

**E7 (bonus): Fatigue time constant.** Distribution of `tau` and `R^2` from B1, with the number of subjects where the fit failed.

**E8 (bonus): Early-versus-late classification.** Balanced accuracy under leave-one-subject-out validation for each feature and feature group, with the label caveat from Section 4.6 stated next to the table.

## 8. Key Results

> Fill this section with final figures and tables. Every claim must have a number next to it, and every number must be reproducible from `main.m` or a script in `experiments/`. Do not write results that are not in `results/`.

- Raw versus filtered signal and early versus late spectrum (E1), with the visible spectral shift quantified in Hz
- Normalized feature trends, grand median with spread (E2)
- Ranking of features with effect sizes and consistency (E3)
- Onset times and detection rates per feature (E4)
- Whether the ranking survives changes in analysis settings (E5)
- Support status of H1, H2, H3: supported, partly supported, or not supported, each with the evidence
- One headline sentence of the form: *"On this dataset, `[feature]` showed the largest effect size (median d = `[X]`) and the earliest detected onset (median `[Y]` s), `[Z]` s earlier than `[feature]`."* Only write it with real numbers.

## 9. Repository Structure and Data Contracts

```
.
├── README.md
├── main.m                      % runs the full pipeline from scratch (E0-E6, optional E7-E8)
├── downloadData.m              % downloads and verifies the dataset (md5), unzips to data/raw/
├── config/
│   └── defaultConfig.m         % all parameters in one struct
├── +data/                      % loading and quality checks
│   ├── loadDataset.m
│   └── qualityCheck.m
├── +preproc/                   % filtering and windowing
│   ├── bandpassEMG.m
│   └── segmentWindows.m
├── +features/                  % feature extraction
│   ├── timeDomain.m
│   ├── spectral.m
│   ├── waveletRatio.m          % optional
│   └── extractAll.m
├── +analysis/                  % normalization, onset, metrics, statistics
│   ├── normalizeBaseline.m
│   ├── detectOnset.m
│   ├── sensitivityMetrics.m
│   ├── rankFeatures.m
│   ├── fitFatigueTimeConstant.m   % bonus
│   └── classifyEarlyLate.m        % bonus
├── +synth/
│   └── makeSyntheticFatigue.m
├── +viz/                       % one function per figure type
├── experiments/                % run_E0.m ... run_E8.m
├── tests/                      % matlab.unittest tests
├── data/
│   └── raw/                    % NOT committed (see .gitignore); created by downloadData.m
├── results/
│   ├── figures/                % png, 300 dpi
│   ├── tables/                 % csv, source of every number in Section 8
│   └── run_info.json           % MATLAB release, toolboxes, date, seed, config
└── docs/
    ├── dataset.md              % what the files actually contain (filled by the agent)
    ├── formulation.md          % exact feature and onset definitions as implemented
    ├── literature.md
    ├── genai_log.md
    └── media/
```

### Shared data contracts

| From to | Structure |
|---|---|
| Loader to everything | `subjects` struct array. Fields: `id` (integer), `emg` (`N x 8` double, samples by channels), `fs` (Hz), `source` (file name) |
| Preprocessing to Features | `emgFilt` (`N x 8`), `fs` |
| Segmentation | `win` (`winLen x nWin x 8`), `tc` (`nWin x 1`, window center times in s) |
| Features to Analysis | Long-format `table` `T` with columns `subject, channel, win, t_s, rms, mav, mdf, mnf, wlr` (`wlr` is NaN if not computed) |
| Normalization | Same table plus `<feature>_n` (normalized) and `<feature>_s` (normalized and smoothed) columns |
| Metrics | `table` with columns `subject, channel, feature, M1, M2, M3, onset_O1, onset_O2, onset_O3` |
| Config | `cfg` struct from `config/defaultConfig.m`: `fs, band, filtOrder, applyNotch, winSec, overlap, specBand, baselineFrac, smoothWin, zThresh, kConsec, pctThresh, earlyLateFrac, seed` |

Default values: `fs = 200`, `band = [20 90]`, `filtOrder = 4`, `applyNotch = false`, `winSec = 2`, `overlap = 0.5`, `specBand = [20 90]`, `baselineFrac = 0.10`, `smoothWin = 5`, `zThresh = 3`, `kConsec = 3`, `pctThresh = 0.10`, `earlyLateFrac = 0.20`, `seed = 0`.

## 10. Implementation Plan and Agent Rules

*This section is a work plan for a coding agent. It can be removed from the final README once the code is complete.*

### 10.1 Agent rules

1. **Do not invent facts about the dataset.** Inspect the downloaded files and write what you find in `docs/dataset.md`. If something differs from Section 4.1 (number of subjects, channels, samples, sampling rate), stop treating the README as correct, adapt the code through `cfg`, and record the discrepancy in `docs/dataset.md`.
2. **Do not assign channels to muscles** unless the NILES 2020 paper or the dataset files state the mapping. Leave it as `[TODO]`.
3. **Do not invent numbers.** Every number in Section 8 must come from a CSV in `results/tables/`. If an experiment cannot run, say so in the README instead of filling in plausible values.
4. **Do not tune the method to make a hypothesis come true.** Parameters are fixed in `defaultConfig.m` before looking at E3 and E4. Changes after seeing results are allowed only if logged in `docs/genai_log.md` with the reason, and E5 reports the sensitivity to them.
5. **Keep it simple.** Plain functions and a `cfg` struct. No GUI, no deep learning, no toolboxes beyond those listed in Section 5. If an optional toolbox is missing, skip that feature and write the skip into `results/run_info.json`.
6. **Verify function signatures** in the installed MATLAB release documentation before using them (especially `medfreq`, `meanfreq`, `findchangepts`, `pwelch`, `boxchart`). Prefer the documented syntax over memory.
7. **Every function gets** a header comment (purpose, inputs with units, outputs), and every figure is saved to `results/figures/` with axis labels and units.
8. **If MATLAB cannot be run by the agent**, write all code and tests anyway, and list in the final message exactly which commands the human must run and what output to expect.
9. **Do not commit** the raw dataset. Add `data/raw/` to `.gitignore`.

### 10.2 Tasks (in order)

| # | Task | Output | Done when |
|---|---|---|---|
| 1 | `downloadData.m`: download the zip with `websave`, verify the md5 (Java `MessageDigest` or equivalent), unzip to `data/raw/`. Then inspect the contents and write `docs/dataset.md` (file names, variable names, matrix orientation, units if stated, anything unexpected). | `data/raw/`, `docs/dataset.md` | md5 matches; `docs/dataset.md` describes the real layout |
| 2 | `+data/loadDataset.m`: support both the per-subject txt files and the combined .mat file (whichever is present). Return the `subjects` contract. Assert and report subject count, channel count, samples, and duration. | `loadDataset.m` | Returns the expected struct; discrepancies are printed, not hidden |
| 3 | `+data/qualityCheck.m`: samples, duration, flat channels (near-zero variance), clipping (fraction of samples at min or max), distinct amplitude levels. | `results/tables/E1_quality.csv` | Table has one row per subject and channel |
| 4 | `config/defaultConfig.m` with the defaults from Section 9. | `defaultConfig.m` | All other functions take `cfg` |
| 5 | `+preproc/bandpassEMG.m` and `+preproc/segmentWindows.m`. | Two functions | Unit tests 4 and 5 pass |
| 6 | `+features/timeDomain.m`, `spectral.m`, `extractAll.m` (and `waveletRatio.m` if the Wavelet Toolbox is available). Document exact definitions in `docs/formulation.md`. | Functions, `docs/formulation.md` | Unit tests 1, 2, 3 pass |
| 7 | `+synth/makeSyntheticFatigue.m` and the E0 experiment. | `results/tables/E0_synthetic.csv`, figure | E0 acceptance criteria met (10.3) |
| 8 | `+analysis/normalizeBaseline.m`, `detectOnset.m`, `sensitivityMetrics.m`. | Functions | Unit tests 6 and 7 pass |
| 9 | Experiments E1 to E4 on the real data. | CSVs in `results/tables/`, figures in `results/figures/` | Files exist; figures labelled with units |
| 10 | `+analysis/rankFeatures.m` (median and IQR across subjects, `signrank` with Holm correction, `friedman`). E5 and E6. | CSVs and figures | Ranking table and robustness table exist |
| 11 | `main.m` runs Stage 0 to E6 from scratch, and writes `results/run_info.json`. | `main.m` | A fresh MATLAB session runs `main` without errors |
| 12 | Bonus, only if tasks 1 to 11 are done: B1 and E7, B2 and E8. | CSVs, figures | Caveats from Section 4.6 appear in the output |
| 13 | Fill Section 8 of this README from `results/tables/` only. Update `[TBD]` cells. Write the support status of H1 to H3. | Updated README | No `[TBD]` left in Sections 7 and 8, or each remaining one is explained |

Suggested time budget for a one-day run (human plus agent): data and loader 1 to 1.5 h, preprocessing and features 1.5 h, synthetic validation 1 h, experiments E1 to E6 2 h, figures and README 2 h, bonus only if time remains.

### 10.3 Acceptance tests (`tests/`, run with `runtests("tests")`)

| # | Test | Pass criterion |
|---|---|---|
| 1 | RMS and MAV of a sinusoid of amplitude `A` | RMS equals `A/sqrt(2)` and MAV equals `2A/pi` within 1% |
| 2 | MDF and MNF of a 40 Hz sinusoid with small noise | Both within 1.5 Hz of 40 Hz |
| 3 | MDF of a signal made of two sinusoids of equal power at 30 Hz and 60 Hz | MDF between 30 and 60 Hz; MNF within 2 Hz of 45 Hz |
| 4 | Band-pass gain | Gain at 50 Hz above 0.9, gain at 5 Hz below 0.1 (measured by filtering sinusoids) |
| 5 | Segmentation | Number of windows equals `floor((N - winLen)/hop) + 1`; window center times are correct |
| 6 | Sign convention | A synthetic rising feature gives positive M1 with `s = +1`, and a falling feature gives positive M1 with `s = -1` |
| 7 | Onset detector on a synthetic step | On a clean step at 40 s, the detected onset (O1) is within 12 s of the true time; on stationary noise it returns `NaN` in at least 90% of 100 seeded repetitions |
| 8 | Loader (real data) | Returns the number of subjects and channels recorded in `docs/dataset.md`; skipped with a message if data are absent |
| 9 | E0 end to end | MDF onset (O1) within 12 s of the true onset in at least 80% of 50 seeded synthetic runs |

If a criterion proves unreasonable (for example the 12 s tolerance given the smoothing lag), the agent changes it only with a written reason in `docs/genai_log.md`.

## 11. Getting Started

**Requirements:** MATLAB `[TODO: release]`, Signal Processing Toolbox, Statistics and Machine Learning Toolbox. Optional: Wavelet Toolbox.

```matlab
% 1. Clone the repository and open the project folder in MATLAB
% 2. Download and verify the dataset (about 10.6 MB)
downloadData

% 3. Run the tests
runtests("tests")

% 4. Run the full pipeline (E0 to E6)
main
```

Figures are written to `results/figures/` and tables to `results/tables/`. To use your own recording, provide a `subjects` struct (Section 9) with `emg` as samples by channels and `fs` in Hz, and set `cfg.band` below `fs/2`. Random seeds, parameters, and the MATLAB release are recorded in `results/run_info.json`. `[TODO: add expected run time on a stated machine.]`

## 12. Limitations and Future Work

- **No independent fatigue ground truth.** The dataset has no labels or force measurement that mark fatigue. "Onset" is defined by our criteria, so results say when a feature departs from its baseline, not when the muscle is physiologically fatigued.
- **Low bandwidth and resolution.** At 200 Hz and 8 bit, high-frequency content above 100 Hz is lost and quantization noise is larger than in typical lab recordings. Conclusions may not transfer to 1 to 2 kHz recordings.
- **One task, one muscle group (probably), small sample.** The task is a 6 kg load held at 90 degrees of elbow flexion for 120 s, with 15 subjects. We do not claim generality. Which muscles the 8 channels cover is not stated on the dataset page.
- **Already notch-filtered.** The 50 Hz notch distorts the spectrum near 50 Hz in all windows.
- **Overlapping windows are correlated.** Window-level statistics are descriptive; inference is across subjects only, and with n = 15 it is exploratory.
- **Onset criteria have free parameters** (`zThresh`, `kConsec`, `pctThresh`, smoothing). E5 and E0 examine sensitivity but cannot remove this subjectivity.
- **Not a clinical tool.** This is a demonstration of a MATLAB workflow and makes no diagnostic claim.
- Future work: validate on a higher-sampling-rate dataset (for example the second dataset in Section 4.1), include dynamic contractions, add additional indices (for example spectral indices and fractal dimension), relate onset to independent measures such as force decline or self-reported effort, and package the pipeline as an App Designer front end.

## 13. Team

| Member | Role | Responsibilities |
|---|---|---|
| **Jennifer** | `[TODO: confirm]` Signal processing and analysis lead | Pipeline design, feature extraction, statistics, results interpretation |
| **Kael** | `[TODO: confirm]` Validation and documentation lead | Synthetic validation, tests, figures, README and video |
| Both | | `docs/genai_log.md` entries, review of agent-written code, final check that every number in Section 8 traces to a file in `results/` |

## 14. References

> Check every entry against the original source before submission.

1. A. Ebied, A. M. Awadallah, M. A. Abbass, and Y. El-Sharkawy, *Multi-channel Surface EMG Dataset for Fatigue analysis*, Zenodo, 2021. DOI: 10.5281/zenodo.5189275. Licence CC BY 4.0.
   *Used for: the primary dataset.*
2. A. Ebied, A. M. Awadallah, M. A. Abbass, and Y. El-Sharkawy, "Upper Limb Muscle Fatigue Analysis Using Multi-channel Surface EMG," *2nd Novel Intelligent and Leading Emerging Sciences Conference (NILES)*, 2020, pp. 423-427. DOI: 10.1109/NILES50944.2020.9257909
   *Used for: the dataset's original paper; `[TODO: channel-to-muscle mapping and protocol details]`.*
3. J. Lim, L. Lu, K. Goonewardena, J. Z. Liu, and Y. Tan, "Assessment of Self-report, Palpation, and Surface Electromyography Dataset During Isometric Muscle Contraction," *Scientific Data*, vol. 11, 2024. DOI: 10.1038/s41597-024-03030-8
   *Used for: optional second dataset.*
4. C. J. De Luca, "Myoelectrical manifestations of localized muscular fatigue in humans," *Critical Reviews in Biomedical Engineering*, vol. 11, no. 4, pp. 251-279, 1984. `[TODO: verify details]`
   *Used for: spectral shift and amplitude changes as fatigue indicators.*
5. M. Cifrek, V. Medved, S. Tonkovic, and S. Ostojic, "Surface EMG based muscle fatigue evaluation in biomechanics," *Clinical Biomechanics*, vol. 24, no. 4, pp. 327-340, 2009. `[TODO: verify details]`
   *Used for: review of EMG fatigue indices.*
6. A. Phinyomark, P. Phukpattaranont, and C. Limsakul, "Feature reduction and selection for EMG signal classification," *Expert Systems with Applications*, vol. 39, no. 8, pp. 7420-7431, 2012. `[TODO: verify details]`
   *Used for: definitions of time-domain EMG features.*
7. MathWorks, *Classify Arm Motions Using EMG Signals and Deep Learning*. https://www.mathworks.com/help/signal/ug/classify-arm-motions-using-emg-signals-and-deep-learning.html
   *Used for: structure of a MATLAB EMG example and reference band-pass preprocessing; this work uses classical features instead of deep learning.*
8. MathWorks, *Muscle Reflex Parameter Estimation*. https://www.mathworks.com/help/sldo/ug/muscle-reflex-parameter-estimation.html
   *Used for: presentation structure (model, data, mismatch, estimation, validation) that inspired the bonus time-constant fit.*
9. `[TODO: add the recent sEMG fatigue detection papers from docs/literature.md.]`

## Acknowledgements

Built for `[TODO: program name]`. We thank `[TODO: academic advisor, if any]` for guidance. The dataset authors released their data under CC BY 4.0, which made this study possible. All analysis code in this repository was reviewed by the team; see Section 6 for how generative AI was used.

## Licence

`[TODO: e.g. MIT]` for the code. The dataset retains its own licence (CC BY 4.0) and is not redistributed in this repository.
