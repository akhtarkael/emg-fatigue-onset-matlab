function cons = run_E6(M, cfg)
%RUN_E6 Fraction of subject-channel pairs changing in expected direction.
%   CONS = RUN_E6(M, CFG) writes E6_channels.csv and a grouped bar figure.

    root = fileparts(fileparts(mfilename('fullpath')));
    chans = unique(M.channel);
    names = cfg.featureNames;
    frac = zeros(numel(chans), numel(names));
    for c = 1:numel(chans)
        for f = 1:numel(names)
            idx = M.channel == chans(c) & strcmp(M.feature,names{f});
            frac(c,f) = mean(M.directionOK(idx));
        end
    end
    cons = array2table(frac, 'VariableNames', names);
    cons = addvars(cons, chans, 'Before',1, 'NewVariableNames','channel');
    writetable(cons, fullfile(root,'results','tables','E6_channels.csv'));
    viz.channelFigure(cons, cfg, fullfile(root,'results','figures','E6_channels.png'));
end
