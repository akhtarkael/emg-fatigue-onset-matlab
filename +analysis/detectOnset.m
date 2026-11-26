function [on1, on2, on3] = detectOnset(y, t, s, bstd, cfg)
%DETECTONSET Three onset criteria for one normalized, smoothed feature.
%   [ON1, ON2, ON3] = DETECTONSET(Y, T, S, BSTD, CFG) returns onset times in
%   seconds. Y is the smoothed normalized feature, T the window-centre times,
%   S the expected sign (+1 rising, -1 falling) and BSTD the baseline standard
%   deviation on the normalized scale.
%
%   O1: first window of the first run of KCONSEC windows with
%       S*(Y-1)/BSTD >= ZTHRESH.
%   O2: same run rule with S*(Y-1) >= PCTTHRESH.
%   O3: single change point in the unsmoothed-normalized series (here Y is
%       the smoothed series supplied by the caller) fitted with two linear
%       segments; the reported time is the last pre-change window centre.
%   NaN means "not detected", which is kept distinct from "late".

    on1 = localRunOnset(s*(y - 1)/bstd, t, cfg.zThresh, cfg.kConsec);
    on2 = localRunOnset(s*(y - 1),      t, cfg.pctThresh, cfg.kConsec);
    on3 = localChangePoint(y, t);
end

function onset = localRunOnset(z, t, thresh, k)
    hit = z >= thresh;
    onset = NaN;
    for i = 1:(numel(hit)-k+1)
        if all(hit(i:i+k-1))
            onset = t(i);
            return;
        end
    end
end

function cp = localChangePoint(y, t)
    n = numel(y);
    minPts = max(5, round(0.10*n));
    if n < 2*minPts + 1
        cp = NaN;
        return;
    end
    best = Inf;
    cp = NaN;
    for i = minPts:(n-minPts)
        sse = localLinearSSE(t(1:i), y(1:i)) + localLinearSSE(t(i+1:end), y(i+1:end));
        if sse < best
            best = sse;
            cp = i;
        end
    end
    if ~isnan(cp)
        cp = t(cp);
    end
end

function sse = localLinearSSE(x, y)
    p = polyfit(x, y, 1);
    r = y - polyval(p, x);
    sse = sum(r.^2);
end
