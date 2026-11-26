function out = run_E3(T, cfg)
%RUN_E3 Sensitivity metrics, feature ranking and paired statistics.
%   OUT = RUN_E3(T, CFG) writes E3_subjectMetrics.csv, E3_ranking.csv,
%   E3_pairwise.csv and E3_friedman.csv, and saves the ranking figure.

    root = fileparts(fileparts(mfilename('fullpath')));
    M = analysis.sensitivityMetrics(T, cfg);
    out = analysis.rankFeatures(M, cfg);
    writetable(M, fullfile(root,'results','tables','E3_subjectMetrics.csv'));
    writetable(out.R, fullfile(root,'results','tables','E3_ranking.csv'));
    writetable(out.pairwise, fullfile(root,'results','tables','E3_pairwise.csv'));
    F = table(out.friedman.Q, out.friedman.p, out.friedman.k, ...
        out.friedman.nSubjects, 'VariableNames', ...
        {'Q','p','nFeatures','nSubjects'});
    writetable(F, fullfile(root,'results','tables','E3_friedman.csv'));
    viz.rankingFigure(out, cfg, fullfile(root,'results','figures','E3_ranking.png'));
end
