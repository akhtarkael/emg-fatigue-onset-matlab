function heroFigure(subjects, T, cfg, outFile)
%HEROFIGURE Promotional overview of cleaning and the fatigue-related shift.
%   HEROFIGURE(SUBJECTS, T, CFG, OUTFILE) saves a 300-dpi PNG with three
%   panels: (a) raw versus band-pass filtered sEMG for subject 1, channel 1,
%   (b) Welch PSD of the first and last 10% of that recording with the
%   median frequency (MDF) marked, and (c) the grand-median normalized MDF
%   across all 15 subjects and 8 channels with its interquartile band.
%
%   Time is in seconds, amplitude in ADC counts, frequency in Hz, and PSD
%   in counts^2/Hz. All values come from the same functions used by the
%   experiments; nothing is drawn from a stored image.

    if ~exist(fileparts(outFile),'dir'), mkdir(fileparts(outFile)); end

    x = subjects(1).emg(:,1);
    xf = preproc.bandpassEMG(x, cfg);
    nShow = min(round(5*cfg.fs), numel(x));
    t = (0:nShow-1)'/cfg.fs;

    nb = max(1, round(0.10*numel(xf)));
    [Pe, f] = features.welchPSD(xf(1:nb), cfg);
    [Pl, ~] = features.welchPSD(xf(end-nb+1:end), cfg);
    in = f >= cfg.specBand(1) & f <= cfg.specBand(2);
    fb = f(in);
    mdfE = localMdf(fb, Pe(in));
    mdfL = localMdf(fb, Pl(in));

    fig = figure('Visible','off','Position',[100 100 1320 430]);

    subplot(1,3,1);
    plot(t, x(1:nShow), 'Color', [0.65 0.65 0.65]); hold on;
    plot(t, xf(1:nShow), 'b', 'LineWidth', 0.9);
    xlabel('Time (s)'); ylabel('Amplitude (ADC counts)');
    title('(a) Raw vs filtered, subject 1 ch 1');
    legend('Raw','20-90 Hz','Location','best'); grid on;

    subplot(1,3,2);
    sel = f >= 15 & f <= 95;
    semilogy(f(sel), Pe(sel), 'b', 'LineWidth', 1.3); hold on;
    semilogy(f(sel), Pl(sel), 'r', 'LineWidth', 1.3);
    xline(mdfE, 'b--', 'LineWidth', 1.0);
    xline(mdfL, 'r--', 'LineWidth', 1.0);
    xlabel('Frequency (Hz)'); ylabel('PSD (counts^2/Hz)');
    title(sprintf('(b) MDF %.1f -> %.1f Hz (%+.1f Hz)', mdfE, mdfL, mdfL-mdfE));
    legend('Early 10%','Late 10%','Location','best'); grid on;

    subplot(1,3,3);
    tt = unique(T.t_s);
    med = nan(size(tt)); qlo = nan(size(tt)); qhi = nan(size(tt));
    for j = 1:numel(tt)
        y = T.mdf_n(T.t_s == tt(j));
        med(j) = median(y);
        q = quantile(y, [0.25 0.75]);
        qlo(j) = q(1); qhi(j) = q(2);
    end
    plot(tt, med, 'k', 'LineWidth', 1.6); hold on;
    fill([tt; tt(end:-1:1)], [qhi; qlo(end:-1:1)], [0.8 0.8 0.8], ...
        'EdgeColor','none', 'FaceAlpha', 0.6);
    yline(1, 'k:');
    xlabel('Time (s)'); ylabel('MDF / baseline');
    title('(c) Normalized MDF, grand median');
    legend('Median','IQR','Baseline','Location','best'); grid on;

    print(fig, outFile, '-dpng', '-r300');
    close(fig);
end

function m = localMdf(f, p)
    c = cumtrapz(f, p);
    i = find(c >= c(end)/2, 1, 'first');
    if isempty(i), i = numel(f); end
    m = f(i);
end
