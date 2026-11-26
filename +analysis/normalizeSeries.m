function [yn, ys, bstd] = normalizeSeries(x, cfg)
%NORMALIZESERIES Baseline-normalize and causally smooth one feature series.
%   [YN, YS, BSTD] = NORMALIZESERIES(X, CFG) divides X by the mean of its
%   first CFG.BASELINEFRAC samples, returns the trailing moving mean of the
%   normalized series (YS), and the baseline standard deviation on the
%   normalized scale (BSTD).

    nb = max(1, round(cfg.baselineFrac*numel(x)));
    mu = mean(x(1:nb));
    if mu == 0, mu = eps; end
    sd = std(x(1:nb));
    if sd == 0, sd = eps; end
    yn = x/mu;
    ys = zeros(size(x));
    for i = 1:numel(x)
        lo = max(1, i-cfg.smoothWin+1);
        ys(i) = mean(yn(lo:i));
    end
    bstd = sd/mu;
end
