function onsetFigure(R, cfg, outFile)
%ONSETFIGURE Median detected onset times for the three criteria.
%   ONSETFIGURE(R, CFG, OUTFILE) plots median onset times (s) for O1, O2 and
%   O3. NaNs (not detected) are excluded and the detection rate is stated in
%   the companion table, not averaged as if it were a late onset.

    names = cfg.featureNames;
    fig = figure('Visible','off','Position',[100 100 800 450]);
    x = (1:numel(names))';
    w = 0.25;
    b1 = bar(x-w, R.medianOnset_O1, w); hold on;
    b2 = bar(x,   R.medianOnset_O2, w);
    b3 = bar(x+w, R.medianOnset_O3, w);
    set(gca,'XTick',x,'XTickLabels',names);
    ylabel('Detected onset (s)');
    title('Median onset by criterion (detected pairs only)');
    legend([b1 b2 b3],{'O1 z-score','O2 10% fixed','O3 change point'}, ...
           'Location','best');
    grid on;
    saveas(fig, outFile);
    close(fig);
end
