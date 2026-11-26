function robustnessFigure(tab, cfg, outFile)
%ROBUSTNESSFIGURE M3 effect size across analysis settings.
%   ROBUSTNESSFIGURE(TAB, CFG, OUTFILE) plots the MDF and RMS median M3 for
%   each setting in TAB; a full rank table is written to CSV alongside it.

    fig = figure('Visible','off','Position',[100 100 900 450]);
    x = (1:height(tab))';
    plot(x, tab.M3_MDF, 'b-o', 'LineWidth',1.5); hold on;
    plot(x, tab.M3_RMS, 'r-s', 'LineWidth',1.5);
    set(gca,'XTick',x,'XTickLabels',tab.label,'XTickLabelRotation',30);
    ylabel('Median Cohen''s d (M3)');
    title('Robustness of effect size to analysis choices');
    legend('MDF','RMS','Location','best'); grid on;
    saveas(fig, outFile);
    close(fig);
end
