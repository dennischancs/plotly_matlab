function output = write_html(gcf, filename)

%% Function:
%% First to covert matlabFigures to plotlyFigures;
%% Second to write plotlyFigures to html embedded plotly.js for offline.
%% if filename is empty, it will be renamed by figure's title.

% covert matlabFigures to plotlyFigures
pfObj = plotlyfig(gcf); 

% filename
debug=0;
if nargin < 2
    % handle title
    tmpName = pfObj.layout.annotations{1,1}.text;
    filename = strrep(tmpName, '<b>', '');
    filename = strrep(filename, '</b>', '');
    if isempty(filename)
        filename = 'untitled';
    end
end
cleanFilename = filename(filename~=' ');  % remove the whitespace from the filename
htmlFilename = [cleanFilename '.html'];

% create dependency string unless not required
if pfObj.PlotOptions.IncludePlotlyjs
    % grab the bundled dependencies
    plotlyDir = getplotlydir();
    plotlyConfigFolder   = fullfile(plotlyDir,'.plotly_matlab');
    plotlyJSFolder = fullfile(plotlyDir, 'package_data'); % plotly.min.js in `pythonPath/lib/python3.*/site-packages/plotly/package_data` after command `pip install plotly`
    bundleName = 'plotly.min.js';
    bundleFile = fullfile(plotlyJSFolder, bundleName);

    % check that the bundle exists
    try
        bundle = fileread(bundleFile);
        % template dependencies
        depScript = sprintf(['<script type="text/javascript">window.PlotlyConfig = {MathJaxConfig: "local"};</script>\n', ...
                            '<script type="text/javascript">%s</script>\n'], bundle);
    catch
        error(['Error reading: %s.\nPlease download the required ', ...
                'dependencies using: >> pip install plotly \n', ...
                'or contact support@plot.ly for assistance.'], ...
                bundleFile);
    end
else
    depScript = '';
end

% handle plot div specs
id = char(java.util.UUID.randomUUID); 
width = [num2str(pfObj.layout.width) 'px']; 
height = [num2str(pfObj.layout.height) 'px']; 

% format the data and layout
jData = m2json(pfObj.data); 
jLayout = m2json(pfObj.layout);
jFrames = m2json(pfObj.frames); 
clean_jData = escapechars(jData); 
clean_jLayout = escapechars(jLayout);
clean_jFrames = escapechars(jFrames); 

% template Plotly.newPlot support plotly.min.js v1.58 & v2.x
script = sprintf(['\n window.PLOTLYENV=window.PLOTLYENV || {}; ', ...
                    '\n if (document.getElementById("%s")) {', ...
                    '\n Plotly.newPlot("%s", {\n"data": %s,\n"layout": %s,\n"frames": %s\n})', ...
                    '\n }; '], id, id, clean_jData, clean_jLayout, clean_jFrames);

plotlyScript = sprintf(['\n<div id="%s" style="height: %s;',...
                            'width: %s;" class="plotly-graph-div">' ...
                            '</div> \n<script type="text/javascript">' ...
                            '%s \n</script>'], id, height, width, ... 
                            script);

% template entire script
fullHtml = sprintf(['<html>\n<head><meta charset="utf-8" /></head>\n', ...
                    '<body>\n<div>\n', ...
                    '%s \n', ...
                    '%s \n', ...
                    '</div>\n</body></html>'], depScript, plotlyScript);



% save the html file in the working directory
plotlyOfflineFile = fullfile(pfObj.PlotOptions.SaveFolder, htmlFilename); 
fileID = fopen(plotlyOfflineFile, 'w');
fprintf(fileID, '%s', fullHtml);
fclose(fileID); 

% remove any whitespace from the plotlyOfflineFile path
plotlyOfflineFile = strrep(plotlyOfflineFile, ' ', '%20'); 

% return the local file url to be rendered in the browser
output = ['file:///' plotlyOfflineFile]; 
