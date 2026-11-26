function tab = run_E7(T, cfg)
%RUN_E7 Bonus: exponential fatigue time constant per subject (RQ4).
%   TAB = RUN_E7(T, CFG) fits MDF(t) = a + (1-a)*exp(-t/tau) to each
%   subject's channel-median normalized MDF and writes E7_timeConstant.csv,
%   E7_summary.csv and E7_timeConstant.png. Fits with R2 < 0.3 are flagged,
%   not dropped.
%   No independent fatigue label is used; this only summarizes the trend.

    root = fileparts(fileparts(mfilename('fullpath')));
    subs = unique(T.subject)';
    rows = {};
    for i = 1:numel(subs)
        idx = T.subject == subs(i);
        tt = unique(T.t_s(idx));
        y = zeros(numel(tt),1);
        for j = 1:numel(tt)
            y(j) = median(T.mdf_n(idx & T.t_s == tt(j)));
        end
        f = analysis.fitFatigueTimeConstant(tt, y);
        rows{end+1} = table(i, f.tau_s, f.a, f.r2, f.exitflag, f.n, ...
            isfinite(f.tau_s) && f.r2 >= 0.3, ...
            'VariableNames', {'subject','tau_s','asymptote_a','r2', ...
                              'exitflag','nWindows','usableFit'}); %#ok<AGROW>
    end
    tab = vertcat(rows{:});
    writetable(tab, fullfile(root,'results','tables','E7_timeConstant.csv'));

    nOk = sum(tab.usableFit);
    summary = table(numel(subs), nOk, median(tab.tau_s(tab.usableFit)), ...
        median(tab.r2(tab.usableFit)), ...
        'VariableNames', {'nSubjects','nUsable','medianTau_s','medianR2_usable'});
    writetable(summary, fullfile(root,'results','tables','E7_summary.csv'));

    viz.timeConstantFigure(tab, cfg, fullfile(root,'results','figures','E7_timeConstant.png'));
    fprintf('E7: %d/%d fits usable (R2 >= 0.3), median tau = %.1f s\n', ...
        nOk, numel(subs), summary.medianTau_s);
end
