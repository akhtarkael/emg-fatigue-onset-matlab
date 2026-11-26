function [win, tc] = segmentWindows(x, cfg)
%SEGMENTWINDOWS Split an N x C signal into overlapping windows.
%   [WIN, TC] = SEGMENTWINDOWS(X, CFG) returns WIN as (winLen x nWin x C)
%   and TC as (nWin x 1) window-centre times in seconds.
%   winLen = round(CFG.WINSEC*CFG.FS); hop = round(winLen*(1-CFG.OVERLAP));
%   nWin = floor((N-winLen)/hop) + 1.

    winLen = round(cfg.winSec*cfg.fs);
    hop    = round(winLen*(1 - cfg.overlap));
    [n, c] = size(x);
    if n < winLen
        error('segmentWindows:Short', 'Signal shorter than one window.');
    end
    nWin = floor((n - winLen)/hop) + 1;

    win = zeros(winLen, nWin, c);
    for k = 1:nWin
        idx = (k-1)*hop + (1:winLen);
        win(:, k, :) = x(idx, :);
    end
    tc = ((0:nWin-1)'*hop + winLen/2)/cfg.fs;
end
