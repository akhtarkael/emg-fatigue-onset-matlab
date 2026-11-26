classdef testAnalysis < matlab.unittest.TestCase
%TESTANALYSIS Acceptance tests 6-7 for sign convention and onset logic.

    methods (Test)
        function testSignConvention(tc)
            root = fileparts(fileparts(mfilename('fullpath')));
            addpath(genpath(root));
            cfg = defaultConfig();
            n = 40;
            t = (1:n)'*0.5;
            rms = linspace(1,2,n)';
            mdf = linspace(2,1,n)';
            T = table(ones(n,1), ones(n,1), (1:n)', t, rms, mdf, ...
                'VariableNames',{'subject','channel','win','t_s','rms','mdf'});
            T.rms_n = rms; T.rms_s = rms; T.rms_bstd = ones(n,1)*0.1;
            T.mdf_n = mdf; T.mdf_s = mdf; T.mdf_bstd = ones(n,1)*0.1;
            M = analysis.sensitivityMetrics(T, cfg);
            tc.verifyGreaterThan(M.M1(strcmp(M.feature,'rms')), 0);
            tc.verifyGreaterThan(M.M1(strcmp(M.feature,'mdf')), 0);
        end

        function testOnsetStepAndFalsePositive(tc)
            root = fileparts(fileparts(mfilename('fullpath')));
            addpath(genpath(root));
            cfg = defaultConfig();
            n = 80;
            t = ((1:n)'-1)*2;
            y = [ones(20,1); 2*ones(n-20,1)];
            on = analysis.detectOnset(y, t, 1, 0.05, cfg);
            tc.verifyLessThan(abs(on - 40), 12);

            rng(7);
            fp = 0;
            for r = 1:100
                y = 1 + 0.05*randn(n,1);
                on = analysis.detectOnset(y, t, 1, 0.05, cfg);
                if isfinite(on), fp = fp + 1; end
            end
            tc.verifyLessThanOrEqual(fp, 10);
        end
    end
end
