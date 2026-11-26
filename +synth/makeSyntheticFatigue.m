function S = makeSyntheticFatigue(seed, t0, cfg)
%MAKESYNTHETICFATIGUE Generate a 120 s sEMG-like signal with known onset.
%   S = MAKESYNTHETICFATIGUE(SEED, T0, CFG) returns a struct with fields
%   X (N x 1), FS (Hz), T (s) and T0 (s). Before T0 the signal is stationary
%   coloured noise centred near 70 Hz; after T0 the spectral content shifts
%   towards 25-50 Hz and the amplitude rises gradually. T0 = Inf gives a
%   purely stationary signal for false-positive testing.

    if nargin < 1 || isempty(seed), seed = 0; end
    if nargin < 2 || isempty(t0), t0 = 40; end
    if nargin < 3 || isempty(cfg), cfg = defaultConfig(); end

    rng(seed);
    n = round(120*cfg.fs);
    t = (0:n-1)'/cfg.fs;

    cfgHi = cfg; cfgHi.band = [60 85];
    cfgLo = cfg; cfgLo.band = [25 50];
    hi = preproc.bandpassEMG(randn(n,1), cfgHi);
    lo = preproc.bandpassEMG(randn(n,1), cfgLo);
    hi = hi/sqrt(mean(hi.^2));
    lo = lo/sqrt(mean(lo.^2));

    if isinf(t0)
        p = zeros(size(t));
    else
        p = 1./(1 + exp(-(t - t0)/2));   % logistic transition, 2 s width
    end
    x = (1 + 0.6*p) .* ((1-p).*hi + p.*lo);

    S = struct('x', x, 'fs', cfg.fs, 't', t, 't0', t0);
end
