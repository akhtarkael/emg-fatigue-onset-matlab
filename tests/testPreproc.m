classdef testPreproc < matlab.unittest.TestCase
%TESTPREPROC Acceptance tests 4-5 for filter gain and windowing.

    methods (Test)
        function testBandpassGain(tc)
            root = fileparts(fileparts(mfilename('fullpath')));
            addpath(genpath(root));
            cfg = defaultConfig();
            t = (0:cfg.fs*4-1)'/cfg.fs;
            y50 = preproc.bandpassEMG(sin(2*pi*50*t), cfg);
            y5  = preproc.bandpassEMG(sin(2*pi*5*t),  cfg);
            g50 = sqrt(2*mean(y50(end-2*cfg.fs+1:end).^2));
            g5  = sqrt(2*mean(y5(end-2*cfg.fs+1:end).^2));
            tc.verifyGreaterThan(g50, 0.9);
            tc.verifyLessThan(g5, 0.1);
        end

        function testSegmentation(tc)
            root = fileparts(fileparts(mfilename('fullpath')));
            addpath(genpath(root));
            cfg = defaultConfig();
            n = cfg.fs*10;
            x = randn(n,2);
            [win, tcVec] = preproc.segmentWindows(x, cfg);
            winLen = round(cfg.winSec*cfg.fs);
            hop = round(winLen*(1-cfg.overlap));
            expected = floor((n-winLen)/hop) + 1;
            tc.verifyEqual(size(win,2), expected);
            tc.verifyEqual(size(win,1), winLen);
            tc.verifyEqual(tcVec(1), winLen/(2*cfg.fs), 'AbsTol',1e-10);
            tc.verifyEqual(tcVec(end), ((expected-1)*hop + winLen/2)/cfg.fs, ...
                'AbsTol',1e-10);
        end
    end
end
