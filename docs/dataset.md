# Dataset record: Ebied et al., Zenodo 5189275

## Source and licence

- Dataset: *Multi-channel Surface EMG Dataset for Fatigue analysis*, Ebied, Awadallah, Abbass and El-Sharkawy, Zenodo, 2021.
- DOI: `10.5281/zenodo.5189275`; URL: <https://zenodo.org/records/5189275>
- Associated paper: Ebied et al., "Upper Limb Muscle Fatigue Analysis Using Multi-channel Surface EMG," NILES 2020, pp. 423–427, DOI `10.1109/NILES50944.2020.9257909`. A PDF copy is included inside the downloaded archive.
- Licence: CC BY 4.0. The raw data are **not** committed to this repository; `.gitignore` excludes `data/raw/` and the downloaded zip.
- Downloaded file: `Dataset EMG Fatigue.zip`, 10,603,743 bytes. The MD5 recorded in the specification, `a954b4eff5594fd8b1670b1a1d0eb864`, was verified by `downloadData.m` before unzipping.

## Files actually found in the archive

```
Dataset EMG Fatigue/
├── All_15sub_Data.mat
├── Data as txt Files/
│   ├── sub1.txt ... sub15.txt
├── Ebied et al._Upper Limb Muscle Fatigue Analysis Using Multi-channel Surface EMG.pdf
└── Read ME.txt
```

`Read ME.txt` repeats the metadata on the Zenodo page: 200 Hz, 8-bit resolution, 15 healthy subjects, a 6 kg load held with the elbow flexed at 90°, 120 s duration, 8 sEMG channels, and an applied 50 Hz notch filter.

## Verified in-memory layout

`All_15sub_Data.mat` contains one variable, `Sub`, a `1 x 15` struct array. Each `Sub(k).emg` is a numeric matrix with 8 columns (samples × channels). Subject 1 has 24,085 samples, i.e. 120.425 s at 200 Hz. The loader prefers this MAT file. The fallback `Data as txt Files/subN.txt` files are 8-column numeric matrices with the same orientation.

The loader normalises both sources to the shared contract: `subjects` is a struct array with fields `id`, `emg` (samples × 8, double), `fs` (200 Hz, taken from the documented dataset metadata) and `source` (file name). No physical units are stated for the amplitude values in the archive; this code treats them as ADC counts.

## Quality checks actually observed

`results/tables/E1_quality.csv` has 120 rows (15 subjects × 8 channels). From that file:

| Check | Observed value |
|---|---|
| Samples per channel | 24,049–24,193 |
| Duration at 200 Hz | 120.245–120.965 s |
| Distinct amplitude levels per channel | 40–256 (median 245.5) |
| Flat channels (`std < 1e-3`) | 0 |
| Fraction of samples equal to that channel's own min or max | median 0.001309, maximum 0.08783 |

The stated "120 s" is therefore a nominal duration. This pipeline uses all samples supplied and records the true window-centre time from `cfg.fs = 200`; it does not truncate recordings to exactly 120 s. The 8-bit description is broadly consistent with the distinct-level counts, but quantization is coarser in some channels than the nominal 256 levels would suggest.

## Electrodes and channel identity

The associated paper states that an 8-electrode Myo-armband was worn on the forearm, that the electrodes were aligned along the palm side of the wrist, and that **channel 4 was placed on the pronator teres muscle**. It also states that electrode placement was unified across subjects so that channel numbering was the same for all subjects.

The paper's Figure 1 shows the electrode positions, but the text extract does not enumerate a muscle name for every one of the eight channels. This repository therefore keeps channels as numbered channels 1–8 and does **not** assign the remaining seven channels to named muscles. Any muscle-specific claim beyond channel 4 would be an invention.

## Processing consequences

- Nyquist is 100 Hz, so the default analysis band is 20–90 Hz rather than the wider band often used for sEMG.
- The data are already 50 Hz notch-filtered in the archive. `cfg.applyNotch` is `false` by default so that no second notch is applied. The notch leaves a dip near 50 Hz in every spectrum; absolute MDF/MNF are slightly biased, but early and late windows are affected alike.
- There is no force trace, fatigue label, or self-reported fatigue score in the archive. "Onset" in this repository means a departure from each subject/channel's baseline under the explicit criteria in `docs/formulation.md`; it is not a physiological label.
