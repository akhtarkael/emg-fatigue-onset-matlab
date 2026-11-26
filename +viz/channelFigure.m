function channelFigure(cons, cfg, outFile)
%CHANNELFIGURE Fraction of expected-direction changes per channel.
%   CHANNELFIGURE(CONS, CFG, OUTFILE) grouped bar chart of CONS, whose rows
%   are channels and whose columns are features.

    fig = figure('Visible','off','Position',[100 100 850 450]);
    b = bar(cons{:,cfg.featureNames});
    set(gca,'XTick',1:size(cons,1),'XTickLabels',cons.channel);
    xlabel('Channel'); ylabel('Fraction of subjects in expected direction');
    ylim([0 1]);
    title('E6: channel consistency');
    legend(cfg.featureNames,'Location','best'); grid on;
    saveas(fig, outFile);
    close(fig);
end
