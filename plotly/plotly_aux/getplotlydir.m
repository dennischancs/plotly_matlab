function plotlyDir = getplotlydir()
%%% --- new version ---
%% firstly: `pip install -U plotly`
%% secondly: matlab function to find `pip path`
%%% -------------------

% get pipFolder
[~, pipVersionReturn] = system("pip -V");
pipVersionReturn = split(pipVersionReturn, ' ');
pipPath = pipVersionReturn{4};
pipFolder = pipPath(1:end-4);

plotlyFolder = fullfile(pipFolder,'plotly'); % plotly Folder by `pip install -U plotly`

if exist(plotlyFolder) == 7
    plotlyDir = plotlyFolder;
else
    system("pip install -U plotly");
    if exist(plotlyFolder) == 7
        fprintf('plotly install succeed. \n\n');
        plotlyDir = plotlyFolder;
    else
        plotlyDir='';
        fprintf('Trying to install plotly by `pip install -U plotly` manually. \n\n');
    end
end



%-------------- old version --------------
% function userDir = getuserdir()
% GETUSERDIR  Retrieve the user directory
%   - Under Windows returns the %APPDATA% directory
%   - For other OSs uses java to retrieve the user.home directory

% if ispc
    % %     userDir = winqueryreg('HKEY_CURRENT_USER',...
    % %         ['Software\Microsoft\Windows\CurrentVersion\' ...
    % %          'Explorer\Shell Folders'],'Personal');
    % userDir = getenv('appdata');
% else
    % userDir = char(java.lang.System.getProperty('user.home'));
% end
