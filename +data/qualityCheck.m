function Q = qualityCheck(subjects, cfg)
%QUALITYCHECK Per-subject/channel data quality table.
%   Q = QUALITYCHECK(SUBJECTS, CFG) returns one row per subject and channel:
%   samples, duration (s), number of distinct amplitude levels, flat-channel
%   flag, fraction of samples at the extreme values, min and max.

    rows = {};
    for i = 1:numel(subjects)
        s = subjects(i);
        for c = 1:size(s.emg,2)
            x = s.emg(:,c);
            rows{end+1} = table(i, c, numel(x), numel(x)/cfg.fs, ...
                numel(unique(x)), std(x) < 1e-3, ...
                mean(x == min(x)) + mean(x == max(x)), min(x), max(x), ...
                {s.source}, ...
                'VariableNames', {'subject','channel','samples','duration_s', ...
                                  'distinctLevels','isFlat','clippedFraction', ...
                                  'minValue','maxValue','source'}); %#ok<AGROW>
        end
    end
    Q = vertcat(rows{:});
end
