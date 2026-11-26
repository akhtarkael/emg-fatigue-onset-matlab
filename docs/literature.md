# Literature notes

This is a short positioning note, not a systematic review. Metadata below was checked against DOI landing pages, PubMed records, or the paper PDF bundled with the dataset. See each entry for how it relates to this demo.

## Classical background

1. **De Luca, C. J. (1984).** "Myoelectrical manifestations of localized muscular fatigue in humans." *Critical Reviews in Biomedical Engineering*, 11(4), 251–279. PMID 6391814.
   - Checked: PubMed record and full-text PDF.
   - Used for: the classical spectral-compression account that motivates expecting MDF and MNF to fall during sustained contractions.

2. **Cifrek, M., Medved, V., Tonković, S., & Ostojić, S. (2009).** "Surface EMG based muscle fatigue evaluation in biomechanics." *Clinical Biomechanics*, 24(4), 327–340. DOI `10.1016/j.clinbiomech.2009.01.010`.
   - Checked: journal page and PubMed record.
   - Used for: the survey of time-, frequency- and time-frequency-domain fatigue indices, and the caution that index choice depends on task and analysis parameters.

3. **Gazzoni, M., Botter, A., & Vieira, T. M. M. (2017).** "Surface EMG and muscle fatigue: multi-channel approaches to the study of myoelectric manifestations of muscle fatigue." *Physiological Measurement*, 38(5), R27. DOI `10.1088/1361-6579/aa60b9`.
   - Checked: IOPscience record.
   - Used for: motivation for retaining the eight recorded channels separately instead of averaging them away.

## Recent work

4. **Jamaluddin, F. N., Ibrahim, F., & Ahmad, S. A. (2023).** "A New Approach to Noninvasive-Prolonged Fatigue Identification Based on Surface EMG Time-Frequency and Wavelet Features." *Journal of Healthcare Engineering*, 2023, 1951165. DOI `10.1155/2023/1951165`.
   - Checked: DOI landing page.
   - Relationship to this work: supports using time-frequency features for prolonged fatigue identification. We probe that family only in the design; the wavelet ratio is not computed here because Wavelet Toolbox is unavailable. This is recorded in `results/run_info.json`.

5. **Cho, G., Yang, W., Lee, D., You, D., Lee, H., Kim, S., Lee, S., & Nam, W. (2023).** "Characterization of signal features for real-time sEMG onset detection." *Biomedical Signal Processing and Control*, 84, 104774. DOI `10.1016/j.bspc.2023.104774`.
   - Checked: DOI landing page.
   - Relationship to this work: compares features by detection delay, false detection and failure, which is the same three-way concern behind our E0 and E4 design. Our detector is a much simpler threshold/run/change-point baseline and is not claimed to match a tuned real-time detector.

6. **Cerqueira, S. M., Vilas Boas, R., Figueiredo, J., & Santos, C. P. (2024).** "A Comprehensive Dataset of Surface Electromyography and Self-Perceived Fatigue Levels for Muscle Fatigue Analysis." *Sensors*, 24(24), 8081. DOI `10.3390/s24248081`.
   - Checked: PubMed Central full text.
   - Relationship to this work: provides dynamic upper-limb movements with a three-level self-perceived fatigue label. It is a concrete candidate for future work because, unlike the primary dataset, it supplies an independent fatigue label. We did not import it into this demo.

## Dataset-specific sources

7. **Ebied, A., Awadallah, A. M., Abbass, M. A., & El-Sharkawy, Y. (2020).** "Upper Limb Muscle Fatigue Analysis Using Multi-channel Surface EMG." *NILES 2020*, pp. 423–427. DOI `10.1109/NILES50944.2020.9257909`.
   - Checked against the PDF bundled inside the downloaded archive.
   - Reports RMS and MDF slopes over 1 s epochs, uses an 8-electrode Myo-armband at 200 Hz / 8 bit, places channel 4 on the pronator teres, and states that electrode numbering was unified across subjects. It is the source of the primary dataset, not an independent validation of our feature ranking.

8. **Ebied, A., Awadallah, A. M., Abbass, M. A., & El-Sharkawy, Y. (2021).** *Multi-channel Surface EMG Dataset for Fatigue analysis.* Zenodo. DOI `10.5281/zenodo.5189275`. CC BY 4.0.
   - Checked: Zenodo landing page and downloaded archive.
   - Used for: all real-data experiments in this repository.

## MathWorks reference

9. **MathWorks.** *Classify Arm Motions Using EMG Signals and Deep Learning.* <https://www.mathworks.com/help/signal/ug/classify-arm-motions-using-emg-signals-and-deep-learning.html>
   - Used for: an example of a documented MATLAB EMG workflow. This demo deliberately uses interpretable classical features instead of deep learning.
