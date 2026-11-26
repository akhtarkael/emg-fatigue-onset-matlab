function G = trendFigures(T, cfg, outDir)
%TRENDFIGURES Per-feature and combined normalized trend figures.
%   G = TRENDFIGURES(T, CFG, OUTDIR) plots each subject's channel-median
%   normalized feature versus time, plus the grand median and IQR band.
%   G is a table with one row per window and grand median/IQR per feature.

    names = cfg.featureNames;
    subs = unique(T.subject)';
    nSub = numel(subs);
    G = table;
    for f = 1:numel(names)
        b = names{f};
        col = [b '_s'];
        ys = cell(nSub,1);
        tRef = [];
        for i = 1:nSub
            idx = T.subject == subs(i);
            tt = unique(T.t_s(idx));
            if isempty(tRef), tRef = tt; end
            y = nan(numel(tRef),1);
            for j = 1:numel(tRef)
                ii = idx & T.t_s == tRef(j);
                y(j) = median(T.(col)(ii), 'omitnan');
            end
            ys{i} = y;
        end
        series = horzcat(ys{:});
        med = median(series,2,'omitnan');
        lo = quantile(series,0.25,2); hi = quantile(series,0.75,2);

        fig = figure('Visible','off','Position',[100 100 800 450]);
        plot(tRef, series, 'Color', [0.75 0.75 0.75], 'LineWidth', 0.5); hold on;
        x = [tRef; tRef(end:-1:1)]; yb = [hi; lo(end:-1:1)];
        fill(x, yb, [0.85 0.85 1], 'EdgeColor','none', 'FaceAlpha',0.7);
        plot(tRef, med, 'k', 'LineWidth', 2);
        yline(1,'--r');
        xlabel('Window centre time (s)'); ylabel('Normalized feature (baseline = 1)');
        title(sprintf('%s across %d subjects', upper(b), nSub));
        legend('Subjects','IQR','Grand median','Baseline','Location','best');
        grid on;
        saveas(fig, fullfile(outDir, sprintf('E2_trend_%s.png', b)));
        close(fig);

        if isempty(G)
            G = table(tRef, med, hi-med, 'VariableNames', {'t_s',[b '_median'],[b '_iqr']});
        else
            G.([b '_median']) = med;
            G.([b '_iqr']) = hi-med;
        end
    end

    fig = figure('Visible','off','Position',[100 100 900 500]);
    hold on;
    style = {'b','r','g','m','c'};
    for f = 1:numel(names)
        plot(T.t_s(1:numel(G.t_s)), G.([names{f} '_median']), style{f}, ...
             'LineWidth',1.5);
    end
    yline(1,'--k');
    xlabel('Window centre time (s)'); ylabel('Normalized feature (baseline = 1)');
    title('Grand median of all features'); legend(names,'Location','best'); grid on;
    saveas(fig, fullfile(outDir,'E2_trend_combined.png'));
    close(fig);
end
