function fit = fitFatigueTimeConstant(t, y)
%FITFATIGUETIMECONSTANT Fit the exponential MDF decay model to one series.
%   FIT = FITFATIGUETIMECONSTANT(T, Y) fits y(t) = a + (1-a)*exp(-t/tau)
%   with base-MATLAB FMINSEARCH. T is a vector of window-centre times in s
%   and Y is the normalized MDF series (baseline = 1).
%
%   FIT has fields TAU_S (s), A (asymptote), R2, EXITFLAG and N. TAU_S is
%   parameterized as exp(logTau) so it stays positive; A is bounded to
%   [0.5, 1.5]. A fit with R2 < 0.3 is reported as a poor fit, not dropped.

    t = t(:); y = y(:);
    ok = isfinite(t) & isfinite(y);
    t = t(ok); y = y(ok);
    fit = struct('tau_s',NaN,'a',NaN,'r2',NaN,'exitflag',0,'n',numel(y));
    if numel(y) < 10 || var(y) == 0
        return;
    end

    % Fit in (a, log tau) coordinates; return Inf outside plausible bounds.
    obj = @(p) localObj(p, t, y);
    p0 = [min(1, max(0.5, y(end))), log(30)];
    [p, ~, exitflag] = fminsearch(obj, p0);
    a = p(1);
    tau = exp(p(2));
    pred = a + (1-a)*exp(-t/tau);
    sse = sum((y - pred).^2);
    sst = sum((y - mean(y)).^2);
    fit.tau_s = tau;
    fit.a = a;
    fit.r2 = 1 - sse/sst;
    fit.exitflag = exitflag;
end

function v = localObj(p, t, y)
    a = p(1);
    tau = exp(p(2));
    if a < 0.5 || a > 1.5 || tau < 1 || tau > 1000
        v = Inf;
        return;
    end
    pred = a + (1-a)*exp(-t/tau);
    v = sum((y - pred).^2);
end
