function F = timeDomain(win)
%TIMEDOMAIN RMS and mean absolute value for each window and channel.
%   F = TIMEDOMAIN(WIN), with WIN of size (winLen x nWin x C), returns
%   F.RMS and F.MAV, each (nWin x C). Units match the input signal.

    F.rms = sqrt(squeeze(mean(win.^2, 1)));
    F.mav = squeeze(mean(abs(win), 1));
    % MATLAB drops trailing singleton dimensions: a single-channel WIN is
    % often 2-D, which makes SQUEEZE return a row vector.
    if isrow(F.rms), F.rms = F.rms'; end
    if isrow(F.mav), F.mav = F.mav'; end
end
