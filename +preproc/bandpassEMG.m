function emgFilt = bandpassEMG(emg, cfg)
%BANDPASSEMG Zero-phase Butterworth band-pass (and optional notch) for sEMG.
%   EMGFILT = BANDPASSEMG(EMG, CFG) filters an N x C signal (samples x
%   channels) with a zero-phase 4th-order Butterworth band-pass between
%   CFG.BAND(1) and CFG.BAND(2) Hz. Sampling rate is CFG.FS (Hz). If
%   CFG.APPLYNOTCH is true a notch at CFG.NOTCHFREQ is also applied.
%
%   Signal Processing Toolbox is not installed on this machine, so the
%   Butterworth design and the forward-backward filtering are implemented
%   here with base MATLAB (bilinear transform + FILTER).

    [b, a] = localButterBandpass(cfg.filtOrder, cfg.band, cfg.fs);
    if cfg.applyNotch
        [bn, an] = localNotch(cfg.notchFreq, cfg.fs, cfg.notchQ);
        b = conv(b, bn);
        a = conv(a, an);
    end

    emgFilt = zeros(size(emg));
    for c = 1:size(emg, 2)
        y = filter(b, a, emg(:, c));
        y = filter(b, a, y(end:-1:1));
        emgFilt(:, c) = y(end:-1:1);
    end
end

function [b, a] = localButterBandpass(N, band, fs)
%LOCALBUTTERBANDPASS Digital band-pass coefficients via analog prototype.
    f1 = band(1); f2 = band(2);
    if ~(0 < f1 && f1 < f2 && f2 < fs/2)
        error('bandpassEMG:Band', 'Require 0 < band(1) < band(2) < fs/2.');
    end

    % Frequency prewarping for the bilinear transform
    O1 = 2*fs*tan(pi*f1/fs);
    O2 = 2*fs*tan(pi*f2/fs);
    O0 = sqrt(O1*O2);                 % analog centre frequency
    BW = O2 - O1;                     % analog bandwidth

    % Normalized Butterworth low-pass prototype poles (cutoff 1 rad/s)
    k = 1:N;
    pk = exp(1j*pi*(2*k + N - 1)/(2*N));

    % LP -> BP substitution: s -> (s^2 + O0^2)/(BW*s) gives, for each pole,
    % s^2 - p*BW*s + O0^2 = 0. Keep the stable (left-half-plane) roots.
    poles = [];
    for m = 1:N
        r = roots([1, -pk(m)*BW, O0^2]);
        poles = [poles; r(real(r) < 0)]; %#ok<AGROW>
    end

    % Analog zeros: N at s=0 and N at s=Inf -> digital z=+1 and z=-1.
    zAnalog = [ones(N,1); -ones(N,1)];
    zDigit  = (2*fs + poles)./(2*fs - poles);

    % Unity magnitude in the passband: use |H|, not real(H), because the
    % transfer function has a non-zero phase in the middle of the band.
    w0 = 2*atan(O0/(2*fs));
    z0 = exp(1j*w0);
    H0 = prod(z0 - zAnalog)./prod(z0 - zDigit);
    gain = 1/abs(H0);

    b = gain * real(poly(zAnalog));
    a = real(poly(zDigit));
end

function [b, a] = localNotch(f0, fs, Q)
%LOCALNOTCH Second-order notch: zeros on the unit circle, poles inside it.
    w0 = 2*pi*f0/fs;
    zz = [exp(1j*w0); exp(-1j*w0)];
    r  = exp(-pi*f0/(fs*Q));
    pp = r*zz;
    b = real(poly(zz));
    a = real(poly(pp));
    b = b/(sum(b)/sum(a));            % unity gain at DC
end
