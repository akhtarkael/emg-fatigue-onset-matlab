function [P, f] = welchPSD(x, cfg)
%WELCHPSD Single-sided Welch power spectral density estimate.
%   [P, F] = WELCHPSD(X, CFG) uses analytic Hamming windows of
%   CFG.WELCHSEG samples with CFG.WELCHOVERLAP overlap and a CFG.NFFT-point
%   DFT. X is a column vector; P and F are column vectors.

    x = x(:);
    seg = min(cfg.welchSeg, numel(x));
    hop = seg - cfg.welchOverlap;
    if hop <= 0, error('welchPSD:BadOverlap','Overlap must be below segment size.'); end
    nfft = max(cfg.nfft, seg);
    nSeg = floor((numel(x) - seg)/hop) + 1;
    w = 0.54 - 0.46*cos(2*pi*(0:seg-1)'/(seg-1));
    P = zeros(nfft/2+1,1);
    for j = 1:nSeg
        idx = (j-1)*hop + (1:seg);
        xx = x(idx) - mean(x(idx));
        X = fft(xx.*w, nfft);
        p = (abs(X(1:nfft/2+1)).^2)/(cfg.fs*sum(w.^2));
        p(2:end-1) = 2*p(2:end-1);
        P = P + p;
    end
    P = P/nSeg;
    f = (0:nfft/2)'*(cfg.fs/nfft);
end
