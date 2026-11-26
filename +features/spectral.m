function F = spectral(win, cfg)
%SPECTRAL Median and mean frequency from a Welch PSD of each window.
%   F = SPECTRAL(WIN, CFG), WIN of size (winLen x nWin x C), returns
%   F.MDF and F.MNF (nWin x C) in Hz, computed inside CFG.SPECBAND.
%
%   A Welch estimate is formed per window from Hamming sub-windows of
%   CFG.WELCHSEG samples with CFG.WELCHOVERLAP samples of overlap and a
%   CFG.NFFT-point DFT. All operations use base MATLAB FFT.

    [winLen, nWin, nCh] = size(win);
    seg  = min(cfg.welchSeg, winLen);
    hop  = seg - cfg.welchOverlap;
    if hop <= 0
        error('spectral:BadOverlap', 'Welch overlap must be smaller than segment length.');
    end
    nfft = max(cfg.nfft, seg);
    nSeg = floor((winLen - seg)/hop) + 1;

    % Analytic Hamming window (no Signal Processing Toolbox needed)
    w = 0.54 - 0.46*cos(2*pi*(0:seg-1)'/(seg-1));
    wScale = cfg.fs*sum(w.^2);
    f = (0:nfft/2)'*(cfg.fs/nfft);

    F.mdf = nan(nWin, nCh);
    F.mnf = nan(nWin, nCh);

    for k = 1:nWin
        for c = 1:nCh
            P = zeros(nfft/2 + 1, 1);
            for j = 1:nSeg
                idx = (j-1)*hop + (1:seg);
                x = win(idx, k, c);
                x = x - mean(x);
                X = fft(x.*w, nfft);
                Pk = (abs(X(1:nfft/2+1)).^2)/wScale;
                Pk(2:end-1) = 2*Pk(2:end-1);   % single-sided PSD
                P = P + Pk;
            end
            P = P/nSeg;

            inBand = f >= cfg.specBand(1) & f <= cfg.specBand(2);
            fb = f(inBand); pb = P(inBand);
            if sum(pb) <= 0
                continue;
            end
            cum = cumtrapz(fb, pb);
            half = cum(end)/2;
            idx = find(cum >= half, 1, 'first');
            if isempty(idx), idx = numel(fb); end
            F.mdf(k, c) = fb(idx);
            F.mnf(k, c) = trapz(fb, fb.*pb)/trapz(fb, pb);
        end
    end
end
