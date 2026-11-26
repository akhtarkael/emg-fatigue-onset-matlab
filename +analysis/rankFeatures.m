function out = rankFeatures(M, cfg)
%RANKEFEATURES Aggregate metrics across subjects and compare features.
%   OUT = RANKFEATURES(M, CFG) returns:
%     OUT.R          per-feature table: medians/IQRs, direction counts,
%                    detection rates, median onsets and M3 ranking,
%     OUT.pairwise   Wilcoxon signed-rank comparisons with Holm correction,
%     OUT.friedman   Friedman omnibus test on M3,
%     OUT.subjectM3  subjects x features matrix of subject-level M3 values.
%
%   Inference is across subjects only (n = 15), never across correlated
%   windows. The Wilcoxon p-values use the normal approximation with no tie
%   correction; with this sample size all tests are exploratory.

    names = cfg.featureNames;
    k = numel(names);
    subs = unique(M.subject)';
    nSub = numel(subs);

    subjM1 = nan(nSub,k); subjM2 = nan(nSub,k); subjM3 = nan(nSub,k);
    subjO1 = nan(nSub,k); subjO2 = nan(nSub,k); subjO3 = nan(nSub,k);
    rateO1 = zeros(k,1); rateO2 = zeros(k,1);

    for f = 1:k
        idx = strcmp(M.feature, names{f});
        Mf = M(idx,:);
        rateO1(f) = mean(isfinite(Mf.onset_O1));
        rateO2(f) = mean(isfinite(Mf.onset_O2));
        for i = 1:nSub
            ii = Mf.subject == subs(i);
            subjM1(i,f) = localNanMedian(Mf.M1(ii));
            subjM2(i,f) = localNanMedian(Mf.M2(ii));
            subjM3(i,f) = localNanMedian(Mf.M3(ii));
            subjO1(i,f) = localNanMedian(Mf.onset_O1(ii));
            subjO2(i,f) = localNanMedian(Mf.onset_O2(ii));
            subjO3(i,f) = localNanMedian(Mf.onset_O3(ii));
        end
    end

    R = table(names', ...
        localNanMedian(subjM1)', localNanIQR(subjM1)', ...
        localNanMedian(subjM2)', localNanIQR(subjM2)', ...
        localNanMedian(subjM3)', localNanIQR(subjM3)', ...
        sum(subjM3 > 0,1)', rateO1, ...
        localNanMedian(subjO1)', rateO2, localNanMedian(subjO2)', ...
        localNanMedian(subjO3)', zeros(k,1), ...
        'VariableNames', {'feature','M1_med','M1_iqr','M2_med','M2_iqr', ...
                          'M3_med','M3_iqr','dirCount','detectRate_O1', ...
                          'medianOnset_O1','detectRate_O2','medianOnset_O2', ...
                          'medianOnset_O3','rankByM3'});
    [~, ord] = sort(R.M3_med, 'descend');
    finalRank = zeros(k,1);
    for j = 1:k, finalRank(ord(j)) = j; end
    R.rankByM3 = finalRank;

    % Pairwise Wilcoxon signed-rank tests on subject-level M3
    pairs = nchoosek(1:k, 2);
    pRaw = zeros(size(pairs,1),1);
    medDiff = zeros(size(pairs,1),1);
    for j = 1:size(pairs,1)
        a = subjM3(:,pairs(j,1));
        b = subjM3(:,pairs(j,2));
        ok = isfinite(a) & isfinite(b);
        medDiff(j) = median(a(ok) - b(ok));
        pRaw(j) = localWilcoxon(a(ok), b(ok));
    end
    pHolm = localHolm(pRaw);
    pairwise = table(names(pairs(:,1))', names(pairs(:,2))', medDiff(:), pRaw(:), pHolm(:), ...
        repmat(nSub, numel(pRaw), 1), ...
        'VariableNames', {'featureA','featureB','medianDiff','p_raw','p_holm','nSubjects'});

    % Friedman test across features on subject-level M3
    ranks = zeros(nSub,k);
    for i = 1:nSub
        ranks(i,:) = localRank(subjM3(i,:));
    end
    Rj = sum(ranks,1);
    Q = 12/(nSub*k*(k+1))*sum(Rj.^2) - 3*nSub*(k+1);
    pFried = NaN;
    if Q > 0
        pFried = 1 - gammainc(Q/2, (k-1)/2);
    end
    friedman = struct('Q',Q,'p',pFried,'k',k,'nSubjects',nSub);

    out = struct('R',R,'pairwise',pairwise,'friedman',friedman, ...
                 'subjectM3',subjM3);
end

function v = localNanMedian(x)
    if isvector(x)
        x = x(isfinite(x));
        v = nanOr(median(x));
    else
        v = zeros(1,size(x,2));
        for j = 1:size(x,2)
            xj = x(:,j);
            v(j) = nanOr(median(xj(isfinite(xj))));
        end
    end
end

function v = localNanIQR(x)
    if isvector(x)
        x = x(isfinite(x));
        v = nanOr(iqr(x));
    else
        v = zeros(1,size(x,2));
        for j = 1:size(x,2)
            xj = x(:,j);
            v(j) = nanOr(iqr(xj(isfinite(xj))));
        end
    end
end

function y = nanOr(x)
    if isempty(x), y = NaN; else, y = x; end
end

function r = localRank(x)
    n = numel(x);
    [xs, ord] = sort(x);
    r = zeros(n,1);
    i = 1;
    while i <= n
        j = i;
        while j < n && xs(j+1) == xs(i), j = j + 1; end
        r(ord(i:j)) = (i + j)/2;
        i = j + 1;
    end
end

function p = localWilcoxon(x, y)
    d = x - y;
    d = d(isfinite(d) & d ~= 0);
    n = numel(d);
    if n < 5
        p = NaN;
        return;
    end
    r = localRank(abs(d));
    W = min(sum(r(d > 0)), sum(r(d < 0)));
    mu = n*(n+1)/4;
    sd = sqrt(n*(n+1)*(2*n+1)/24);
    z = (W - mu)/sd;
    p = erfc(abs(z)/sqrt(2));
end

function padj = localHolm(p)
    m = numel(p);
    padj = nan(m,1);
    [ps, ord] = sort(p, 'ascend');
    run = 0;
    for j = 1:m
        run = max(run, (m-j+1)*ps(j));
        padj(ord(j)) = min(1, run);
    end
end
