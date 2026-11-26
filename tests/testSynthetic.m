classdef testSynthetic < matlab.unittest.TestCase
%TESTSYNTHETIC Acceptance tests 8-9 for loader and end-to-end E0.

    methods (Test)
        function testLoaderIfDataPresent(tc)
            root = fileparts(fileparts(mfilename('fullpath')));
            addpath(genpath(root));
            raw = fullfile(root,'data','raw');
            if ~exist(raw,'dir') || isempty(dir(fullfile(raw,'**','*.txt'))) && ...
                    isempty(dir(fullfile(raw,'**','*.mat')))
                tc.log(printfNotAvailable());
                return;
            end
            cfg = defaultConfig();
            subjects = data.loadDataset(raw, cfg);
            tc.verifyGreaterThan(numel(subjects), 0);
            tc.verifyEqual(size(subjects(1).emg,2), 8);
        end

        function testE0EndToEnd(tc)
            root = fileparts(fileparts(mfilename('fullpath')));
            addpath(genpath(root));
            cfg = defaultConfig();
            ok = 0;
            for r = 1:50
                S = synth.makeSyntheticFatigue(r-1, 40, cfg);
                subj = struct('id',1,'emg',S.x,'fs',cfg.fs,'source','synthetic');
                T = analysis.normalizeBaseline(features.extractAll(subj,cfg), cfg);
                idx = T.channel == 1;
                [o1,~,~] = analysis.detectOnset(T.mdf_s(idx), T.t_s(idx), ...
                    cfg.expectedSign.mdf, T.mdf_bstd(1), cfg);
                if isfinite(o1) && abs(o1-40) <= 12
                    ok = ok + 1;
                end
            end
            tc.verifyGreaterThanOrEqual(ok/50, 0.8);
        end
    end
end

function msg = printfNotAvailable()
    msg = 'Dataset not downloaded; loader test skipped. Run downloadData first.';
end
