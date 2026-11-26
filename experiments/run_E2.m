function G = run_E2(T, cfg)
%RUN_E2 Normalized feature trends across subjects.
%   G = RUN_E2(T, CFG) writes E2_trends.csv (normalized medians and IQRs),
%   E2_spectralShift.csv (absolute MDF/MNF in Hz, early vs late) and the
%   trend figures to results/figures/.

    root = fileparts(fileparts(mfilename('fullpath')));
    outDir = fullfile(root,'results','figures');
    if ~exist(outDir,'dir'), mkdir(outDir); end
    G = viz.trendFigures(T, cfg, outDir);
    writetable(G, fullfile(root,'results','tables','E2_trends.csv'));

    % Absolute spectral shift, in Hz, from the unnormalized features.
    names = {'mdf','mnf'};
    rows = {};
    subs = unique(T.subject)';
    for f = 1:numel(names)
        b = names{f};
        early = []; late = [];
        for i = 1:numel(subs)
            idx = T.subject == subs(i);
            chans = unique(T.channel(idx));
            for c = 1:numel(chans)
                ii = idx & T.channel == chans(c);
                x = T.(b)(ii);
                ne = max(1, round(cfg.baselineFrac*numel(x)));
                early(end+1) = mean(x(1:ne)); %#ok<AGROW>
                late(end+1)  = mean(x(end-ne+1:end)); %#ok<AGROW>
            end
        end
        rows{end+1} = table({b}, median(early), median(late), median(late)-median(early), ...
            'VariableNames', {'feature','earlyMedianHz','lateMedianHz','shiftHz'});
    end
    writetable(vertcat(rows{:}), fullfile(root,'results','tables','E2_spectralShift.csv'));
end
