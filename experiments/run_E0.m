function res = run_E0(cfg)
%RUN_E0 Synthetic validation with a known fatigue onset (t0 = 40 s).
%   RES = RUN_E0(CFG) runs 50 seeded synthetic recordings and 100 stationary
%   recordings, writes results/tables/E0_synthetic.csv and a figure, and
%   returns a struct with the same numbers.

    root = fileparts(fileparts(mfilename('fullpath')));
    outTab = fullfile(root, 'results', 'tables');
    outFig = fullfile(root, 'results', 'figures');
    if ~exist(outTab,'dir'), mkdir(outTab); end
    if ~exist(outFig,'dir'), mkdir(outFig); end

    names = cfg.featureNames;
    k = numel(names);
    t0 = 40;
    nRuns = 50;
    nNull = 100;
    onsets = nan(nRuns,k);
    errors = nan(nRuns,k);
    fp = zeros(nNull,k);

    for r = 1:nRuns
        S = synth.makeSyntheticFatigue(r-1, t0, cfg);
        T = localFeatureTable(S, cfg);
        for f = 1:k
            b = names{f};
            idx = T.channel == 1;
            [o1,~,~] = analysis.detectOnset(T.([b '_s'])(idx), T.t_s(idx), ...
                cfg.expectedSign.(b), T.([b '_bstd'])(1), cfg);
            onsets(r,f) = o1;
            if isfinite(o1), errors(r,f) = abs(o1 - t0); end
        end
    end

    for r = 1:nNull
        S = synth.makeSyntheticFatigue(500+r, Inf, cfg);
        T = localFeatureTable(S, cfg);
        for f = 1:k
            b = names{f};
            idx = T.channel == 1;
            [o1,~,~] = analysis.detectOnset(T.([b '_s'])(idx), T.t_s(idx), ...
                cfg.expectedSign.(b), T.([b '_bstd'])(1), cfg);
            fp(r,f) = isfinite(o1);
        end
    end

    pass = sum(errors <= 12,1)/nRuns;
    res = table(names', repmat(t0,k,1), medianSafe(onsets), medianSafe(errors), ...
        pass(:), mean(fp,1)', ...
        'VariableNames', {'feature','trueOnset_s','medianDetected_s', ...
                          'medianAbsError_s','passRate_12s','falsePositiveRate'});
    writetable(res, fullfile(outTab,'E0_synthetic.csv'));

    fig = figure('Visible','off','Position',[100 100 900 420]);
    subplot(1,2,1);
    bar(pass*100); set(gca,'XTick',1:k,'XTickLabels',names,'Ylim',[0 100]);
    ylabel('Runs within 12 s (%)'); title('E0: detection rate at known onset');
    grid on;
    subplot(1,2,2);
    bar(mean(fp,1)*100); set(gca,'XTick',1:k,'XTickLabels',names,'Ylim',[0 100]);
    ylabel('Stationary runs with onset (%)'); title('E0: false positives');
    grid on;
    saveas(fig, fullfile(outFig,'E0_synthetic.png'));
    close(fig);
end

function T = localFeatureTable(S, cfg)
    subj = struct('id',1,'emg',S.x,'fs',cfg.fs,'source','synthetic');
    T = features.extractAll(subj, cfg);
    T = analysis.normalizeBaseline(T, cfg);
end

function v = medianSafe(x)
    v = nan(size(x,2),1);
    for j = 1:size(x,2)
        xj = x(:,j); xj = xj(isfinite(xj));
        if isempty(xj), v(j) = NaN; else, v(j) = median(xj); end
    end
end
