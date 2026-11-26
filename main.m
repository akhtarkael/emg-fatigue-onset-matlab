function main()
%MAIN Run the complete sEMG fatigue demo (E0 to E7) from scratch.
%   MAIN() loads the dataset, builds the feature table and runs every
%   experiment. Tables go to results/tables/, figures to results/figures/,
%   and provenance to results/run_info.json.

    root = fileparts(mfilename('fullpath'));
    addpath(genpath(root));
    cfg = defaultConfig();
    rng(cfg.seed);

    outTab = fullfile(root,'results','tables');
    outFig = fullfile(root,'results','figures');
    outHero = fullfile(root,'docs','media');
    if ~exist(outTab,'dir'), mkdir(outTab); end
    if ~exist(outFig,'dir'), mkdir(outFig); end
    if ~exist(outHero,'dir'), mkdir(outHero); end

    fprintf('=== Stage 0: load + quality check ===\n');
    subjects = data.loadDataset(fullfile(root,'data','raw'), cfg);
    run_E1(subjects, cfg);

    fprintf('=== Stage 1-4: filter, segment, features, normalize ===\n');
    T = features.extractAll(subjects, cfg);
    T = analysis.normalizeBaseline(T, cfg);

    fprintf('=== E0: synthetic validation ===\n');
    run_E0(cfg);

    fprintf('=== E2: trends ===\n');
    run_E2(T, cfg);
    viz.heroFigure(subjects, T, cfg, fullfile(outHero,'hero.png'));

    fprintf('=== E3-E4: ranking + onset ===\n');
    M = analysis.sensitivityMetrics(T, cfg);
    out = analysis.rankFeatures(M, cfg);
    run_E3(T, cfg);
    run_E4(M, out, cfg);

    fprintf('=== E5-E6: robustness + channel consistency ===\n');
    run_E5(subjects, cfg);
    run_E6(M, cfg);

    fprintf('=== E7: fatigue time constant (bonus) ===\n');
    run_E7(T, cfg);

    writeRunInfo(root, cfg, subjects, out);
    [~, ord] = sort(out.R.rankByM3);
    fprintf('\nDone. Headline ranking by M3: %s\n', ...
        strjoin(out.R.feature(ord)', ' > '));
end

function writeRunInfo(root, cfg, subjects, out)
    v = ver;
    info = struct();
    info.date = datestr(now, 'yyyy-mm-dd HH:MM:SS');
    info.matlabRelease = version;
    info.seed = cfg.seed;
    info.config = cfg;
    info.nSubjects = numel(subjects);
    info.nChannels = size(subjects(1).emg, 2);
    info.installedProducts = {v.Name};
    info.skippedFeatures = { ...
        'wlr (Wavelet Toolbox not installed)', ...
        'E8 early-vs-late SVM (fitcsvm unavailable; time-position labels are not independent fatigue labels)'};
    info.substitutes = { ...
        'Butterworth design and zero-phase filtering implemented in base MATLAB', ...
        'Welch PSD implemented with FFT (base MATLAB)', ...
        'Spearman, Wilcoxon and Friedman implemented in base MATLAB', ...
        'findchangepts replaced by a two-segment linear least-squares change point'};
    fid = fopen(fullfile(root,'results','run_info.json'),'w');
    fprintf(fid, '%s', jsonencode(info, 'PrettyPrint', true));
    fclose(fid);
end
