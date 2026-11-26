function timeConstantFigure(tab, cfg, outFile) %#ok<INUSD>
%TIMECONSTANTFIGURE Distribution and quality of the per-subject tau fits.
%   TIMECONSTANTFIGURE(TAB, CFG, OUTFILE) saves a labelled 300-dpi PNG:
%   (a) histogram of tau (s) for usable fits, (b) R2 versus tau with the
%   usability threshold. Unusable fits are shown as open circles.

    fig = figure('Visible','off','Position',[100 100 900 380]);

    subplot(1,2,1);
    tau = tab.tau_s(tab.usableFit);
    if ~isempty(tau)
        histogram(tau, 'BinWidth', 20, 'FaceColor', [0.3 0.5 0.8]);
        xline(median(tau), 'r--', 'LineWidth', 1.2);
        text(median(tau), 0, sprintf(' median %.0f s', median(tau)), ...
            'Color','r','VerticalAlignment','bottom');
    end
    xlabel('\tau (s)'); ylabel('Subjects');
    title('(a) Fatigue time constant, usable fits'); grid on;

    subplot(1,2,2);
    plot(tab.tau_s(~tab.usableFit), tab.r2(~tab.usableFit), 'o', ...
        'MarkerFaceColor','w','MarkerEdgeColor',[0.5 0.5 0.5]); hold on;
    plot(tab.tau_s(tab.usableFit), tab.r2(tab.usableFit), 'o', ...
        'MarkerFaceColor',[0.3 0.5 0.8],'MarkerEdgeColor','k');
    yline(0.3, 'r--');
    xlabel('\tau (s)'); ylabel('R^2');
    title('(b) Fit quality vs time constant');
    legend('R^2 < 0.3','Usable','Threshold','Location','best'); grid on;

    print(fig, outFile, '-dpng', '-r300');
    close(fig);
end
