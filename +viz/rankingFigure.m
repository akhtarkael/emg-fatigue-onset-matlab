function rankingFigure(out, cfg, outFile)
%RANKINGFIGURE Effect sizes and detection rates for the feature ranking.
%   RANKINGFIGURE(OUT, CFG, OUTFILE) bar-charts median Cohen's d with IQR and
%   the O1 detection rate, using OUT.R from analysis.rankFeatures.

    R = out.R;
    names = cfg.featureNames;
    fig = figure('Visible','off','Position',[100 100 900 420]);
    subplot(1,2,1);
    b = bar(R.M3_med); hold on;
    err = errorbar((1:numel(names))', R.M3_med, R.M3_iqr, 'LineStyle','none');
    err.Color = [0.2 0.2 0.2];
    set(gca,'XTick',1:numel(names),'XTickLabels',names);
    ylabel('Cohen''s d (sign-adjusted)');
    title('Effect size (median across subjects)'); grid on;
    subplot(1,2,2);
    bar(R.detectRate_O1*100);
    set(gca,'XTick',1:numel(names),'XTickLabels',names,'YLim',[0 100]);
    ylabel('Subject-channel pairs (%)');
    title('O1 detection rate'); grid on;
    saveas(fig, outFile);
    close(fig);
end
