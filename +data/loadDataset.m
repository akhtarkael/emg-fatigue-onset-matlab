function subjects = loadDataset(dataDir, cfg)
%LOADDATASET Load the public sEMG fatigue recordings into the shared contract.
%   SUBJECTS = LOADDATASET(DATADIR, CFG) returns a struct array with fields
%   ID (integer), EMG (N x 8 double, samples by channels), FS (Hz) and
%   SOURCE (file name).
%
%   Verified layout of Zenodo record 5189275:
%     All_15sub_Data.mat -> variable Sub, a 1 x 15 struct array, each with
%                           field emg, roughly 24085 x 8 (about 120 s at
%                           200 Hz; the extra samples are not explained in
%                           the archive's Read ME.txt).
%     Data as txt Files  -> sub1.txt ... sub15.txt, each 8 columns of
%                           8-bit values in the range -128..127.
%   The MAT file is preferred; the txt files are the fallback.

    if ~exist(dataDir,'dir')
        error('loadDataset:NoData','No data folder at %s. Run downloadData first.', dataDir);
    end

    matFiles = dir(fullfile(dataDir,'**','*.mat'));
    txtFiles = dir(fullfile(dataDir,'**','*.txt'));
    subjects = struct('id',{},'emg',{},'fs',{},'source',{});

    if ~isempty(matFiles)
        f = fullfile(matFiles(1).folder, matFiles(1).name);
        S = load(f);
        fprintf('loadDataset: %s, variables: %s\n', matFiles(1).name, ...
            strjoin(fieldnames(S)',', '));
        if isfield(S,'Sub') && isstruct(S.Sub)
            for k = 1:numel(S.Sub)
                subjects(end+1) = localMakeSubject(S.Sub(k).emg, f, cfg, k); %#ok<AGROW>
            end
        else
            candidates = localCandidates(S);
            for k = 1:numel(candidates)
                subjects(end+1) = localMakeSubject(candidates{k}, f, cfg, k); %#ok<AGROW>
            end
        end
    elseif ~isempty(txtFiles)
        fprintf('loadDataset: found %d TXT file(s)\n', numel(txtFiles));
        for k = 1:numel(txtFiles)
            f = fullfile(txtFiles(k).folder, txtFiles(k).name);
            M = readmatrix(f);
            subjects(end+1) = localMakeSubject(M, f, cfg, k); %#ok<AGROW>
        end
    else
        error('loadDataset:NoData','No .mat or .txt files found under %s', dataDir);
    end

    if isempty(subjects)
        error('loadDataset:NoSubjects','Could not identify any subject matrices.');
    end
    fprintf('loadDataset: %d subjects, %d channels, %d samples (subject 1), %.2f s at %d Hz\n', ...
        numel(subjects), size(subjects(1).emg,2), size(subjects(1).emg,1), ...
        size(subjects(1).emg,1)/cfg.fs, cfg.fs);
end

function list = localCandidates(S)
    list = {};
    names = fieldnames(S);
    for i = 1:numel(names)
        v = S.(names{i});
        if iscell(v)
            for j = 1:numel(v)
                if isnumeric(v{j}) && ismatrix(v{j})
                    list{end+1} = v{j}; %#ok<AGROW>
                end
            end
        elseif isnumeric(v) && ismatrix(v)
            list{end+1} = v; %#ok<AGROW>
        end
    end
end

function s = localMakeSubject(M, file, cfg, id)
    if size(M,2) == 8
        x = double(M);
    elseif size(M,1) == 8
        x = double(M');
    else
        warning('loadDataset:Shape','Skipping %s: expected 8 channels, got %d x %d.', ...
            file, size(M,1), size(M,2));
        x = double(M);
    end
    s = struct('id',id,'emg',x,'fs',cfg.fs,'source',file);
end
