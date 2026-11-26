classdef testFeatures < matlab.unittest.TestCase
%TESTFEATURES Acceptance tests 1-3 for RMS, MAV, MDF and MNF.

    methods (Test)
        function testRmsMavSinusoid(tc)
            root = fileparts(fileparts(mfilename('fullpath')));
            addpath(genpath(root));
            cfg = defaultConfig();
            cfg.fs = 2000;   % sample finely enough that sampled MAV ~ 2A/pi
            A = 2;
            t = (0:cfg.fs*2-1)'/cfg.fs;
            x = A*sin(2*pi*40*t);
            win = reshape(x, [], 1, 1);
            F = features.timeDomain(win);
            tc.verifyEqual(mean(F.rms), A/sqrt(2), 'AbsTol', 0.01*A/sqrt(2));
            tc.verifyEqual(mean(F.mav), 2*A/pi,  'AbsTol', 0.01*2*A/pi);
        end

        function testSingleToneSpectral(tc)
            root = fileparts(fileparts(mfilename('fullpath')));
            addpath(genpath(root));
            cfg = defaultConfig();
            rng(3);
            t = (0:cfg.fs*4-1)'/cfg.fs;
            x = sin(2*pi*40*t) + 0.05*randn(size(t));
            [win,~] = preproc.segmentWindows(x, cfg);
            F = features.spectral(win, cfg);
            tc.verifyEqual(mean(F.mdf), 40, 'AbsTol', 1.5);
            tc.verifyEqual(mean(F.mnf), 40, 'AbsTol', 1.5);
        end

        function testTwoToneSpectral(tc)
            root = fileparts(fileparts(mfilename('fullpath')));
            addpath(genpath(root));
            cfg = defaultConfig();
            t = (0:cfg.fs*4-1)'/cfg.fs;
            x = sin(2*pi*30*t) + sin(2*pi*60*t);
            [win,~] = preproc.segmentWindows(x, cfg);
            F = features.spectral(win, cfg);
            tc.verifyGreaterThan(mean(F.mdf), 30);
            tc.verifyLessThan(mean(F.mdf), 60);
            tc.verifyEqual(mean(F.mnf), 45, 'AbsTol', 2);
        end
    end
end
