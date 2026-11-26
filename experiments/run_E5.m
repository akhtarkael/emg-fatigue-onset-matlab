function tab = run_E5(subjects, cfg)
%RUN_E5 Robustness of the M3 ranking to analysis choices.
%   TAB = RUN_E5(SUBJECTS, CFG) reruns the pipeline while varying one setting
%   at a time and writes E5_robustness.csv. "sameAsDefault" compares the
%   full feature order, not just the winner.

    root = fileparts(fileparts(mfilename('fullpath')));
    settings = {
        'Default',        @(c) c
        'Window 1 s',     @(c) setfield(c,'winSec',1)
        'Window 4 s',     @(c) setfield(c,'winSec',4)
        'Overlap 0',      @(c) setfield(c,'overlap',0)
        'Overlap 0.75',   @(c) setfield(c,'overlap',0.75)
        'Band [10 90]',   @(c) setfield(c,'band',[10 90])
        'Band [30 90]',   @(c) setfield(c,'band',[30 90])
        'Baseline 0.05',  @(c) setfield(c,'baselineFrac',0.05)
        'Baseline 0.20',  @(c) setfield(c,'baselineFrac',0.20)
        };

    rows = {};
    defaultOrder = '';
    for s = 1:size(settings,1)
        c = settings{s,2}(cfg);
        T = features.extractAll(subjects, c);
        T = analysis.normalizeBaseline(T, c);
        M = analysis.sensitivityMetrics(T, c);
        o = analysis.rankFeatures(M, c);
        [~, ord] = sort(o.R.rankByM3);
        order = strjoin(o.R.feature(ord)', ' > ');
        if s == 1, defaultOrder = order; end
        iMdf = find(strcmpi(o.R.feature,'MDF'));
        iRms = find(strcmpi(o.R.feature,'RMS'));
        rows{end+1} = table({settings{s,1}}, {order}, strcmp(order,defaultOrder), ...
            o.R.M3_med(iMdf), o.R.M3_med(iRms), ...
            'VariableNames', {'label','rankingByM3','sameAsDefault','M3_MDF','M3_RMS'}); %#ok<AGROW>
        fprintf('E5: %-16s -> %s\n', settings{s,1}, order);
    end
    tab = vertcat(rows{:});
    writetable(tab, fullfile(root,'results','tables','E5_robustness.csv'));
    viz.robustnessFigure(tab, cfg, fullfile(root,'results','figures','E5_robustness.png'));
end
