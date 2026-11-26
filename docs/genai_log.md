# Generative AI usage log

## Tools actually used

| Tool | Purpose |
|---|---|
| OpenCode coding agent | Read the supplied specification, drafted MATLAB functions, tests, experiment scripts, figures and documentation |
| MATLAB MCP `evaluate_matlab_code` | Ran MATLAB R2026b Update 1, inspected variables, executed `main` and `runtests` |
| Web search / web fetch | Checked Zenodo and DOI landing pages for dataset and literature metadata |
| `pdftotext` | Extracted text from the paper bundled in the dataset archive to check the electrode description |

No MATLAB Copilot, GitHub Copilot or other generative-AI coding tool was used in this build. Team review of the agent-written material is still a human step; this log is the record of what the agent did and how it was checked.

## Session record — 2026-11-26

| Stage | Agent action | Verification |
|---|---|---|
| Specification intake | Read `README (8).md` in full and extracted the data contracts, experiments and acceptance tests | Section 10 rules were followed; the work plan in the final README was replaced by a completion record |
| Data acquisition | Wrote `downloadData.m` with .NET MD5 because Java is unavailable in this MATLAB install | Downloaded 10,603,743-byte zip; MD5 matched `a954b4eff5594fd8b1670b1a1d0eb864`; archive unpacked |
| Data inspection | Loaded `All_15sub_Data.mat`, examined `Sub`, and compared with `subN.txt` files | `docs/dataset.md` records the real layout, sample-count range and channel facts; paper PDF text was extracted for the electrode statement |
| Pipeline implementation | Drafted loader, quality check, preprocessing, segmentation, features, normalization, metrics, ranking, onset detection and synthetic generator | `runtests('tests')`: 9 passed, 0 failed, 0 incomplete |
| Experiments | Implemented E0–E6 and, after those were complete, bonus E7 | `main` runs end to end; tables and figures are regenerated; final verification run took 73.6 s on this machine |
| Substitution handling | Replaced missing toolbox functions with documented base-MATLAB implementations | `results/run_info.json` lists installed products, skipped features and each substitute |
| Documentation | Drafted this log, `docs/dataset.md`, `docs/formulation.md`, `docs/literature.md` and the final README | Every reported experimental outcome in Sections 7/8 was checked against a CSV in `results/tables/`; design constants were checked against `config/defaultConfig.m` and the experiment scripts; no `[TBD]` cells remain |
| Final rerun | Ran `runtests('tests')`, then `main` | Tests passed; pipeline completed without errors and wrote all expected artifacts |

## Examples where agent output was wrong and was caught

1. **Butterworth passband gain.** The first implementation computed the digital gain from `real(1/H0)`. At the centre frequency the transfer function has non-zero phase, so this understated the gain. It was corrected to `1/abs(H0)` in `+preproc/bandpassEMG.m`. Acceptance test 4 (gain above 0.9 at 50 Hz, below 0.1 at 5 Hz) passes with the corrected code.
2. **Feature array orientation.** `squeeze` collapsed single-channel outputs into row vectors, which later corrupted table assignment. `+features/timeDomain.m` now transposes row outputs; this was confirmed by the full pipeline and unit tests 1–2.
3. **E0 summary table shape.** The first draft mixed one-row-per-feature data with one-row-per-run arrays. `run_E0.m` now writes one row per feature with explicit `medianSafe` handling for non-detections; `E0_synthetic.csv` has exactly four rows.
4. **Trend and ranking aggregation.** Early drafts averaged windows before computing subject medians and produced transposed IQR columns. The current code collapses channels within subject first, then aggregates across subjects; `E2_trends.csv` and `E3_ranking.csv` were inspected after the fix.
5. **E5 and E6 orientation.** Robustness labels and channel columns were initially misaligned, making channel 1 look like a feature. Both files now write labelled tables with explicit `VariableNames`; the final CSV headers were checked.
6. **E7 bound-hitting fits.** Five of the fifteen exponential fits reach the 1000 s tau bound. Rather than hide them or call them successful, `run_E7.m` marks them `usableFit = 0` when `R^2 < 0.3` and keeps them in the CSV.
7. **E4 paired-comparison indexing.** The first draft used `cfg.featureNames{1:2}`, which are RMS and MAV, while the CSV label claimed MDF vs RMS. `run_E4.m` now uses explicit `{'mdf','rms'}` names; `E4_onset_pairwise.csv` was regenerated after the fix.

## Parameter and decision discipline

- Parameters in `config/defaultConfig.m` were set from the supplied specification before E3 and E4 were inspected. No default was changed to improve a hypothesis test.
- E5 was run as the planned sensitivity study, not as a post-hoc search for a preferred configuration.
- E7 was added only after E0–E6 were complete. It addresses the optional RQ4 and is reported with its fit-quality caveat.
- E8 was not implemented: `fitcsvm` is unavailable, and time-position labels are not an independent fatigue ground truth. This skip is written into `results/run_info.json`.
- `wlr` was not implemented: Wavelet Toolbox is unavailable. The skip is written into `results/run_info.json` and the table rows are omitted rather than filled with plausible numbers.

## Verification policy applied

- AI-generated code was accepted only after `runtests('tests')` and a full `main` run.
- Literature metadata was checked against DOI landing pages or the bundled paper PDF.
- Numbers in the README come from files in `results/tables/`, not from generated prose.
- Where the dataset is silent — notably the full channel-to-muscle map and fatigue labels — the documentation says so instead of guessing.
