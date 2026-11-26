function [E, cmp] = run_E4(M, out, cfg)
%RUN_E4 Onset detection comparison across features and criteria.
%   [E, CMP] = RUN_E4(M, OUT, CFG) writes E4_onsets.csv with detection rates
%   and median onsets (NaNs excluded), compares MDF vs RMS onset times with a
%   Wilcoxon signed-rank test plus Holm-adjusted p, and saves the onset figure.

    root = fileparts(fileparts(mfilename('fullpath')));
    E = out.R(:,{'feature','detectRate_O1','medianOnset_O1', ...
                 'detectRate_O2','medianOnset_O2','medianOnset_O3'});
    writetable(E, fullfile(root,'results','tables','E4_onsets.csv'));
    viz.onsetFigure(out.R, cfg, fullfile(root,'results','figures','E4_onsets.png'));

    subs = unique(M.subject)';
    pairNames = {'mdf','rms'};   % comparison is MDF minus RMS
    on = zeros(numel(subs),2);
    for f = 1:2
        name = pairNames{f};
        for i = 1:numel(subs)
            idx = strcmp(M.feature,name) & M.subject == subs(i);
            x = M.onset_O1(idx);
            x = x(isfinite(x));
            if ~isempty(x), on(i,f) = median(x); else, on(i,f) = NaN; end
        end
    end
    ok = isfinite(on(:,1)) & isfinite(on(:,2));
    p = analysis.wilcoxonTest(on(ok,1), on(ok,2));
    % This comparison is the only member of its Holm family, so the
    % Holm-adjusted p-value equals the raw p-value. Keeping the column
    % explicitly makes the correction auditable in the CSV.
    pHolm = p;
    cmp = table({'MDF vs RMS onset O1'}, sum(ok), ...
        median(on(ok,1)-on(ok,2)), p, pHolm, ...
        'VariableNames',{'comparison','nSubjects','medianDifference_s', ...
                         'p_raw','p_holm'});
    writetable(cmp, fullfile(root,'results','tables','E4_onset_pairwise.csv'));
end
