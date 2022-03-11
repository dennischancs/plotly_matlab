function output = write_image(gcf, varargin)
%--------------------------WRITE_IMAGE-------------------------------%
% Function:
% First to covert matlabFigures to plotlyFigures;
% Second to write plotlyFigures to a supported static image format.

% [CALL]:

% output = write_image(fig_han)
% output = write_image(fig_han, 'imageFormat','png', 'filename', 'test', 'saveFile', true, ...)

% [INPUTS]: [TYPE]{default} - description/'options'

% fig_han: [handle]{gcf} - figure handle
% fig_struct: [structure array]{get(gcf)} - figure handle structure array

% [VALID PROPERTIES / VALUES]:

% imageFormat: 
    % "png", "jpg", "jpeg", "webp", "svg", "pdf", "json" need install `kaleido`
    % "eps" need install `poppler` 
% filename: [string]{'untitled'} - filename as appears on Plotly
% height: px
% width: px
% scale: zoom image
% saveFile: 'true' save a image file, 'false' just return base64 image
%--------------------------------------------------------------------%


pfObj = plotlyfig(gcf); 

%---- DEFAULT VALUES ----%
imageFormat='png';

% handle title
tmpName = pfObj.layout.annotations{1,1}.text;
filename = strrep(tmpName, '<b>', '');
filename = strrep(filename, '</b>', '');
if isempty(filename)
    filename = 'untitled';
end

height=pfObj.layout.height;
width=pfObj.layout.width;
scale=1;
saveFile=true;
%------- END -------%


if length(varargin) >= 2
% parse property/values if input
    parseinit = 1;
    for a = parseinit:2:length(varargin)
        if(strcmpi(varargin{a},'imageFormat'))
            imageFormat = varargin{a+1};
        end
        if(strcmpi(varargin{a},'filename'))
            filename = varargin{a+1};
        end
        if(strcmpi(varargin{a},'height'))
            height = varargin{a+1};
        end
        if(strcmpi(varargin{a},'width'))
            width = varargin{a+1};
        end
        if(strcmpi(varargin{a},'scale'))
            scale = varargin{a+1};
        end
        if(strcmpi(varargin{a},'saveFile'))
            saveFile = varargin{a+1};
        end
    end
end

if strcmpi(imageFormat,'jpg')
    imageFormat = 'jpeg';
end

% remove the whitespace from the filename
cleanFilename = filename(filename~=' '); 
filename = [cleanFilename, '.', imageFormat];


% write plotlyFigures to a supported static image format
debug=0;
[status, wd]=getKaleido();
output=[];

if ~isa(pfObj,'plotlyfig')
    fprintf('\nError: Input is not a plotlyfig object.\n\n');
    return
end

if isunix()
    kExec = string(fullfile(wd,'kaleido'));
    cc="cat";
else
    kExec = string(fullfile(wd,'kaleido.cmd'));
    cc="type";
end

plyJsLoc = string(fullfile(getplotlydir(), 'package_data', 'plotly.min.js')); % plotly.min.js in `pythonPath/lib/python3.*/site-packages/plotly/package_data` after command `pip install plotly`


if ~isfile(kExec) || ~isfile(plyJsLoc)
    status=getKaleido();
    getplotlydir();
else
    status=1;
end

if status == 0 
    return 
end

mjLoc = replace(string(fullfile(wd,'etc','mathjax','MathJax.js')),'\','/');
scope="plotly";


% Prepare input plotly object for Kaleido
q=struct();
q.data.data = pfObj.data;
q.data.layout = pfObj.layout;
q.data.layout = rmfield(q.data.layout,'height');
q.data.layout = rmfield(q.data.layout,'width');
q.format = string(imageFormat);
q.height = height;
q.scale = scale;
q.width = width;

pfJson = native2unicode(jsonencode(q),'UTF-8');
tFile = string(fullfile(wd,'temp.txt'));
f=fopen(tFile,'w');
fprintf(f,"%s",pfJson);
fclose(f);

cmd=[cc," ",tFile," | ",kExec," ",scope," --plotlyjs='",plyJsLoc,"' ","--mathjax='file:///",mjLoc,"' --no-sandbox --disable-gpu --allow-file-access-from-files --disable-breakpad --disable-dev-shm-usage"];

if debug
    inputCmd=char(join(cmd,''));
    fprintf('\nDebug info:\n%s\n\n',inputCmd);
end

[code,out]=system(char(join(cmd,'')));
if debug
    disp(out);
end

if code ~= 0
    fprintf('\nFatal: Failed to run Kaleido.\n\n');
    return;
else
    a=string(split(out,newline));
    if a(end)==""
        a(end)=[];
    end
    output = jsondecode(a(end));
end

if output.code ~= 0
    fprintf('\nError: %s\n',output.message);
else
    if saveFile
        if strcmpi(output.format, 'svg')
            f=fopen(char(filename),'w'); % text
            fwrite(f,output.result);
            fclose(f);
        else
            out=unicode2native(output.result,'UTF-8');
            out=base64decode(out);
            f=fopen(char(filename),'wb'); % bytes
            fwrite(f,out);
            fclose(f);
        end
    else
        output = output.result;
    end
end
