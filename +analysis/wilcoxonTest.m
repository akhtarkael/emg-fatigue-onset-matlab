function p = wilcoxonTest(x, y)
%WILCOXONTEST Two-sided Wilcoxon signed-rank p-value (normal approximation).
%   P = WILCOXONTEST(X, Y) tests the paired differences X-Y, ignoring zeros
%   and NaNs. Ties are not corrected; with small n the result is exploratory.

    d = x - y;
    d = d(isfinite(d) & d ~= 0);
    n = numel(d);
    if n < 5
        p = NaN;
        return;
    end
    [~, ord] = sort(abs(d));
    r = zeros(n,1);
    i = 1;
    while i <= n
        j = i;
        while j < n && abs(d(ord(j+1))) == abs(d(ord(i))), j = j + 1; end
        r(ord(i:j)) = (i+j)/2;
        i = j+1;
    end
    W = min(sum(r(d > 0)), sum(r(d < 0)));
    mu = n*(n+1)/4;
    sd = sqrt(n*(n+1)*(2*n+1)/24);
    p = erfc(abs((W-mu)/sd)/sqrt(2));
end
