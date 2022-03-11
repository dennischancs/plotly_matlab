function response = plotlyoffline2(gcf, varargin)

% Function:
% Generate offline Plotly figure with three layers for better compatibility as ipynb file inserted cell.
% three layers: `"application/vnd.plotly.v1+json": {json_compatible_fig_dict}`, `"image/png":"base64"` and `"text/html":"plotly_fig_html"` 
% need install [dennischancs/plotly_matlab](https://github.com/dennischancs/plotly_matlab)

% [CALL]:

% output = plotlyoffline2(fig_han)
% output = plotlyoffline2(fig_han, 'filename', 'test')

% PS: `write_html()` function can write offline Plotly figure to a single html file.
    
pfObj = plotlyfig(gcf); 

%---- DEFAULT VALUES ----%
% handle title
tmpName = pfObj.layout.annotations{1,1}.text;
filename = strrep(tmpName, '<b>', '');
filename = strrep(filename, '</b>', '');
if isempty(filename)
    filename = 'untitled';
end
%------- END -------%

if length(varargin) >= 2
% parse property/values if input
    parseinit = 1;
    for a = parseinit:2:length(varargin)
        if(strcmpi(varargin{a},'filename'))
            filename = varargin{a+1};
        end
    end
end

% remove the whitespace from the filename
cleanFilename = filename(filename~=' '); 
htmlFilename = [cleanFilename, '.html'];

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

%-- first layer: `"application/vnd.plotly.v1+json": {json_compatible_fig_dict}`
plotlyJson = sprintf(['{"config": {"plotlyServerURL": "https://plot.ly"},', ...
                    '\n"data": %s,\n"layout": %s,\n"frames": %s\n}'], ...
                    clean_jData, clean_jLayout, clean_jFrames);

%-- second layer: `"image/png":"base64"`
plotlyPngBase64 = write_image(gcf,'imageFormat','png','saveFile', false);

%-- third layer: `"text/html":"plotly_fig_html"`
% template Plotly.newPlot support plotly.min.js v1.58 & v2.x
script = sprintf(['\n require(["plotly"], function(Plotly) {window.PLOTLYENV=window.PLOTLYENV || {}; ', ...
                    '\n if (document.getElementById("%s")) {', ...
                    '\n Plotly.newPlot("%s", {\n"data": %s,\n"layout": %s,\n"frames": %s\n}).then(function(){', ...
                    '\n    var gd = document.getElementById("%s");', ...
                    '\n    var x = new MutationObserver(function (mutations, observer) {{', ...
                    '\n            var display = window.getComputedStyle(gd).display;', ...
                    '\n            if (!display || display === "none") {{', ...
                    '\n                console.log([gd, "removed!"]);', ...
                    '\n                Plotly.purge(gd);', ...
                    '\n                observer.disconnect();}}', ...
                    '\n    }});', ...
                    '\n // Listen for the removal of the full notebook cells', ...
                    '\n var notebookContainer = gd.closest("#notebook-container");', ...
                    '\n if (notebookContainer) {{x.observe(notebookContainer, {childList: true});}}', ...
                    '\n // Listen for the clearing of the current output cell', ...
                    '\n var outputEl = gd.closest(".output");', ...
                    '\n if (outputEl) {{x.observe(outputEl, {childList: true});}}', ...
                    '\n       })         };      });'], id, id, clean_jData, ...
                    clean_jLayout, clean_jFrames, id);

plotlyScript = sprintf(['<div id="%s" style="height: %s;',...
                            'width: %s;" class="plotly-graph-div">' ...
                            '</div> \n<script type="text/javascript">' ...
                            '%s \n</script>'], id, height, width, ... 
                            script);

% template entire script
offlineScript = sprintf(['<plotlyJson>%s</plotlyJson>', ...
                            '<plotlyPngBase64>%s</plotlyPngBase64>', ...
                            '<plotlyScript>%s</plotlyScript>'], ...
                            plotlyJson, plotlyPngBase64, plotlyScript);

    
% save the html file in the working directory
plotlyOfflineFile = fullfile(pfObj.PlotOptions.SaveFolder, htmlFilename); 
fileID = fopen(plotlyOfflineFile, 'w');
fprintf(fileID, '%s', offlineScript); 
fclose(fileID); 

% remove any whitespace from the plotlyOfflineFile path
plotlyOfflineFile = strrep(plotlyOfflineFile, ' ', '%20'); 

% return the local file url to be rendered in the browser
response = ['file:///' plotlyOfflineFile]; 

