function [status, kDir] = getKaleido()
%%% --- new version ---
%% firstly: `pip install -U kaleido`
%% secondly: matlab function to find `pip path`
%% third: check kaleido path
%%% -------------------


% get pipFolder
[~, pipVersionReturn] = system("pip -V");
pipVersionReturn = split(pipVersionReturn, ' ');
pipPath = pipVersionReturn{4};
pipFolder = pipPath(1:end-4);

KaleidoFolder = fullfile(pipFolder,'kaleido','executable'); % Kaleido Folder by `pip install -U kaleido`

if exist(KaleidoFolder) == 7
    status=1;
    kDir = KaleidoFolder;
else
    system("pip install -U kaleido");
    if exist(KaleidoFolder) == 7
        fprintf('kaleido install succeed. \n\n');
        status=1;
        kDir = KaleidoFolder;
    else
        status=0;
        kDir='';
        fprintf('Trying to install Kaleido by `pip install -U kaleido` manually. \n\n');
    end
end




%-------------- old version --------------

% status=0;
% kDir = fullfile(fileparts(mfilename('fullpath')),'..','kaleido');
% arch = computer('arch');
% plotlyJS = 'https://cdn.plot.ly/plotly-latest.min.js';

% if isunix()
    % if ismac()
        % if strcmp(arch,'maci64')
            % url = 'https://github.com/plotly/Kaleido/releases/download/v0.2.1/kaleido_mac_x64.zip';
        % else
            % url = 'https://github.com/plotly/Kaleido/releases/download/v0.2.1/kaleido_mac_arm64.zip';
        % end
    % else
        % if strcmp(arch,'glnxa64')
            % url = 'https://github.com/plotly/Kaleido/releases/download/v0.2.1/kaleido_linux_x64.zip';
        % else
            % url = 'https://github.com/plotly/Kaleido/releases/download/v0.2.1/kaleido_linux_arm64.zip';
        % end
    % end
% elseif ispc()
    % if strcmp(arch,'win64')
        % url = 'https://github.com/plotly/Kaleido/releases/download/v0.2.1/kaleido_win_x64.zip';
    % else
        % url = 'https://github.com/plotly/Kaleido/releases/download/v0.2.1/kaleido_win_x86.zip';
    % end
% else
    % fprintf('\nCouldn''t find a suitable version of "Kaleido" required for exporting plots, for your system\n');
    % fprintf('https://github.com/plotly/Kaleido/tags\n');
    % fprintf('Please download a suitable Kaleido version for your system, and unzip the files in plotly/Kaleido folder.\n\n');
    % return;
% end

% fprintf('\nTrying to download Kaleido executable and plotly javascript (one-time download)... please wait...');
% try
    % file = websave(fullfile(kDir,'kaleido.zip'),url);
    % websave(fullfile(kDir,'plotly-latest.min.js'),plotlyJS);
% catch
    % fprintf('\nFailed to download Kaleido.\n');
    % fprintf('https://github.com/plotly/Kaleido/tags\n');
    % fprintf('Please download a suitable Kaleido version for your system, and unzip the files in plotly/Kaleido folder.\n\n');
    % return;
% end
% unzip(file,kDir);
% status=1;
% fprintf(' Done\n\n');
