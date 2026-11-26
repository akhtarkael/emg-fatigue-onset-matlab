function cfg = defaultConfig()
%DEFAULTCONFIG All parameters for the sEMG fatigue pipeline.
%   CFG = DEFAULTCONFIG() returns a struct with the default settings used by
%   every experiment. Units: Hz for frequencies, seconds for times.

    cfg.fs            = 200;          % sampling rate (Hz), from dataset
    cfg.band          = [20 90];      % band-pass band (Hz)
    cfg.filtOrder     = 4;            % Butterworth order (doubled by zero phase)
    cfg.applyNotch    = false;        % dataset already notch-filtered at 50 Hz
    cfg.notchFreq     = 50;           % Hz
    cfg.notchQ        = 10;           % notch quality factor
    cfg.winSec        = 2;            % window length (s)
    cfg.overlap       = 0.5;          % window overlap fraction
    cfg.specBand      = [20 90];      % band for MDF/MNF (Hz)
    cfg.baselineFrac  = 0.10;         % first fraction of recording = baseline
    cfg.smoothWin     = 5;            % causal moving-mean length (windows)
    cfg.zThresh       = 3;            % O1 z-score threshold
    cfg.kConsec       = 3;            % O1 required consecutive windows
    cfg.pctThresh     = 0.10;         % O2 threshold on normalized feature
    cfg.earlyLateFrac = 0.20;         % first/last fraction for Cohen's d
    cfg.seed          = 0;            % master random seed

    cfg.featureNames  = {'rms','mav','mdf','mnf'};
    cfg.expectedSign  = struct('rms',1,'mav',1,'mdf',-1,'mnf',-1);

    % Welch PSD settings: 1 s Hamming sub-windows, 50% overlap, 512-point DFT
    cfg.welchSeg      = 200;
    cfg.welchOverlap  = 100;
    cfg.nfft          = 512;
end
