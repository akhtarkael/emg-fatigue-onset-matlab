function downloadData(destDir)
%DOWNLOADDATA Download, verify and unpack the public sEMG fatigue dataset.
%   DOWNLOADDATA() downloads the Zenodo archive into <project>/data/raw,
%   checks its MD5 checksum, and unpacks it there.
%   DOWNLOADDATA(DESTDIR) uses a custom destination folder.
%
%   Source: Ebied et al., Zenodo record 5189275, CC BY 4.0.
%   The archive itself is NOT redistributed with this repository.

    if nargin < 1 || isempty(destDir)
        root = fileparts(mfilename('fullpath'));
        destDir = fullfile(root, 'data', 'raw');
    end
    if ~exist(destDir, 'dir')
        mkdir(destDir);
    end

    url = 'https://zenodo.org/records/5189275/files/Dataset%20EMG%20Fatigue.zip?download=1';
    expectedMD5 = 'a954b4eff5594fd8b1670b1a1d0eb864';
    zipFile = fullfile(fileparts(destDir), 'Dataset EMG Fatigue.zip');

    if exist(zipFile, 'file')
        fprintf('Archive already present: %s\n', zipFile);
    else
        fprintf('Downloading %s ...\n', url);
        websave(zipFile, url);
        fprintf('Saved %s (%d bytes)\n', zipFile, dir(zipFile).bytes);
    end

    actualMD5 = localMD5(zipFile);
    fprintf('MD5 expected: %s\nMD5 actual:   %s\n', expectedMD5, actualMD5);
    if ~strcmpi(actualMD5, expectedMD5)
        error('downloadData:Checksum', ...
              'MD5 mismatch. Archive may be incomplete; delete it and retry.');
    end

    fprintf('Unpacking to %s ...\n', destDir);
    unzip(zipFile, destDir);
    fprintf('Done.\n');
end

function digest = localMD5(file)
%LOCALMD5 MD5 hex digest using the .NET implementation available on Windows.
    md5 = System.Security.Cryptography.MD5.Create();
    bytes = System.IO.File.ReadAllBytes(file);
    hash = md5.ComputeHash(bytes);
    digest = sprintf('%02x', uint8(hash));
end
