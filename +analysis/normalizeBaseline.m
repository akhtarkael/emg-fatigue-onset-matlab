function T = normalizeBaseline(T, cfg)
%NORMALIZEBASELINE Baseline-normalize and causally smooth the feature table.
%   T = NORMALIZEBASELINE(T, CFG) adds <feature>_n (feature divided by the
%   mean of the first CFG.BASELINEFRAC windows), <feature>_s (causal moving
%   mean of the normalized feature) and <feature>_bstd (baseline standard
%   deviation of the normalized feature) for every feature in CFG.FEATURENAMES.
%
%   Grouping is by subject and channel. The causal smoother introduces a
%   known lag of about (SMOOTHWIN-1)/2 windows in detected onsets.

    names = cfg.featureNames;
    n = height(T);
    for f = 1:numel(names)
        base = names{f};
        T.([base '_n'])    = zeros(n,1);
        T.([base '_s'])    = zeros(n,1);
        T.([base '_bstd']) = zeros(n,1);
    end

    subs = unique(T.subject)';
    for i = 1:numel(subs)
        chans = unique(T.channel(T.subject == subs(i)))';
        for c = 1:numel(chans)
            idx = find(T.subject == subs(i) & T.channel == chans(c));
            for f = 1:numel(names)
                base = names{f};
                [yn, ys, bstd] = analysis.normalizeSeries(T.(base)(idx), cfg);
                T.([base '_n'])(idx)    = yn;
                T.([base '_s'])(idx)    = ys;
                T.([base '_bstd'])(idx) = bstd;
            end
        end
    end
end
