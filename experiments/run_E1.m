function Q = run_E1(subjects, cfg)
%RUN_E1 Signal quality and filtering figures.
%   Q = RUN_E1(SUBJECTS, CFG) writes E1_quality.csv (one row per subject and
%   channel) and E1_quality.png (raw/filtered signal and early/late PSD).

    root = fileparts(fileparts(mfilename('fullpath')));
    Q = data.qualityCheck(subjects, cfg);
    writetable(Q, fullfile(root,'results','tables','E1_quality.csv'));
    viz.qualityFigure(subjects, cfg, fullfile(root,'results','figures','E1_quality.png'));
end
