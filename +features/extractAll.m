function T = extractAll(subjects, cfg)
%EXTRACTALL Build the long-format feature table for all subjects.
%   T = EXTRACTALL(SUBJECTS, CFG) filters each subject, segments it into
%   windows, and computes rms, mav, mdf and mnf for every window/channel.
%   T has columns: subject, channel, win, t_s, rms, mav, mdf, mnf, wlr
%   (WLR is NaN unless Wavelet Toolbox is available and enabled).

    parts = {};
    for i = 1:numel(subjects)
        s = subjects(i);
        filt = preproc.bandpassEMG(s.emg, cfg);
        [win, tc] = preproc.segmentWindows(filt, cfg);
        nWin = numel(tc);
        nCh = size(win, 3);
        td = features.timeDomain(win);
        sp = features.spectral(win, cfg);

        for c = 1:nCh
            parts{end+1} = table( ...
                repmat(i, nWin, 1), repmat(c, nWin, 1), (1:nWin)', tc, ...
                td.rms(:,c), td.mav(:,c), sp.mdf(:,c), sp.mnf(:,c), ...
                nan(nWin,1), ...
                'VariableNames', {'subject','channel','win','t_s', ...
                                  'rms','mav','mdf','mnf','wlr'});
        end
    end
    T = vertcat(parts{:});
end
