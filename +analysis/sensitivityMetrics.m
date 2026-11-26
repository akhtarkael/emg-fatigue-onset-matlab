function M = sensitivityMetrics(T, cfg)
%SENSITIVITYMETRICS Per subject/channel/feature sensitivity measures.
%   M = SENSITIVITYMETRICS(T, CFG) returns a table with columns subject,
%   channel, feature, M1, M2, M3, onset_O1, onset_O2, onset_O3, directionOK.
%   M1 = sign-adjusted Spearman rho with time (trend consistency),
%   M2 = sign-adjusted slope in percent of baseline per minute (speed),
%   M3 = sign-adjusted Cohen's d, late 20% versus early 20% (effect size).
%   A positive value always means "changed in the expected fatigue direction".

    names = cfg.featureNames(ismember(cfg.featureNames, T.Properties.VariableNames));
    rows = {};
    subs = unique(T.subject)';
    for i = 1:numel(subs)
        chans = unique(T.channel(T.subject == subs(i)))';
        for c = 1:numel(chans)
            idx = find(T.subject == subs(i) & T.channel == chans(c));
            t = T.t_s(idx);
            for f = 1:numel(names)
                base = names{f};
                y = T.([base '_s'])(idx);
                s = cfg.expectedSign.(base);
                bstd = T.([base '_bstd'])(idx);
                bstd = bstd(1);

                rho = localSpearman(y, t);
                M1 = s*rho;
                pp = polyfit(t/60, y, 1);
                M2 = 100*s*pp(1);

                ne = max(2, round(cfg.earlyLateFrac*numel(y)));
                e = y(1:ne); l = y(end-ne+1:end);
                sp = sqrt((var(e,1) + var(l,1))/2);
                M3 = NaN;
                if sp > 0
                    M3 = s*(mean(l) - mean(e))/sp;
                end

                [o1, o2, o3] = analysis.detectOnset(y, t, s, bstd, cfg);
                rows{end+1} = table(subs(i), chans(c), {base}, M1, M2, M3, ...
                    o1, o2, o3, M3 > 0, ...
                    'VariableNames', {'subject','channel','feature','M1','M2', ...
                                      'M3','onset_O1','onset_O2','onset_O3', ...
                                      'directionOK'}); %#ok<AGROW>
            end
        end
    end
    M = vertcat(rows{:});
end

function rho = localSpearman(x, y)
    rho = corrRank(localRank(x), localRank(y));
end

function r = localRank(x)
%LOCALRANK Midranks, with ties receiving their average rank.
    n = numel(x);
    [xs, ord] = sort(x);
    r = zeros(n,1);
    i = 1;
    while i <= n
        j = i;
        while j < n && xs(j+1) == xs(i)
            j = j + 1;
        end
        r(ord(i:j)) = (i + j)/2;
        i = j + 1;
    end
end

function rho = corrRank(x, y)
    x = x - mean(x); y = y - mean(y);
    d = sqrt(sum(x.^2)*sum(y.^2));
    if d == 0
        rho = NaN;
    else
        rho = sum(x.*y)/d;
    end
end
