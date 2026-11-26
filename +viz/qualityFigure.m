function qualityFigure(subjects, cfg, outFile)
%QUALITYFIGURE Raw versus filtered signal and early versus late PSD.
%   QUALITYFIGURE(SUBJECTS, CFG, OUTFILE) saves a labelled figure for
%   subject 1, channel 1. Frequencies are in Hz, amplitude in ADC counts.

    x = subjects(1).emg(:,1);
    xf = preproc.bandpassEMG(x, cfg);
    nShow = min(2000, numel(x));
    t = (0:nShow-1)'/cfg.fs;

    fig = figure('Visible','off','Position',[100 100 1000 420]);
    subplot(1,2,1);
    plot(t, x(1:nShow), 'Color', [0.6 0.6 0.6]); hold on;
    plot(t, xf(1:nShow), 'b', 'LineWidth', 0.8);
    xlabel('Time (s)'); ylabel('Amplitude (ADC counts)');
    title('Raw vs band-pass filtered (subject 1, ch 1)');
    legend('Raw','Filtered','Location','best'); grid on;

    subplot(1,2,2);
    nb = max(1, round(0.10*numel(xf)));
    [Pe, f] = features.welchPSD(xf(1:nb), cfg);
    [Pl, ~] = features.welchPSD(xf(end-nb+1:end), cfg);
    sel = f >= 15 & f <= 95;
    semilogy(f(sel), Pe(sel), 'b', 'LineWidth', 1.2); hold on;
    semilogy(f(sel), Pl(sel), 'r', 'LineWidth', 1.2);
    xlabel('Frequency (Hz)'); ylabel('PSD (counts^2/Hz)');
    title('First vs last 10% of recording');
    legend('Early','Late','Location','best'); grid on;

    saveas(fig, outFile);
    close(fig);
end
