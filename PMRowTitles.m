classdef PMRowTitles
    %PMROWTITLES allows retrieval of row titles (corresponding to analyzed parameters) from file;
    % the text-file has the following format: a list of row titles, separated by semi-colons;
    % each title contains two elements, separated by a comma;
    % the first part is the name of the analyzed population; the second part is the name of the analyzed parameter;
    % example with two row-titles:      CXCR4 High, Mean FI CD69, ;
    %                                   CXCR4 High, Median FI CD69, 
    
    properties (Access = private)
        FolderName
        FileName = 'AnalysisTypeRowTitles.txt'
    end
    
    methods
        function obj = PMRowTitles(varargin)
            %PMROWTITLES Construct an instance of this class
            %  one or two arguments;
            % 1: character-string with folder name of title-file;
            % 2: optional: character-string with file-name of title source: default: 'AnalysisTypeRowTitles.txt';
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 1
                        obj.FolderName =    varargin{1};

                case 2
                        obj.FolderName =    varargin{1};
                        obj.FileName =      varargin{2};
                        
                otherwise
                    error('Wrong input.')
                
            end
         
        end
 
         function rowTitles = getRowTitles(obj)
            % GETROWTITLES gets cell array with row titles;
            % each cell contains, "gate" and "value" designation separated by comma;
            text =          obj.getText;
            rowTitles =     obj.getRowTitlesFromText(text);
        end
        
        
    end
    
    methods
       
        function obj = showSummary(obj)
           text = getSummary(obj);
           cellfun(@(x) fprintf('%s', x), text)
      
        end
        
        function text = getSummary(obj)
             text{1} = sprintf('This PMRowTitles object helps to retrieve "row-titles", which typically represent a list of parameters for an experimental analysis.\n');
            text = [text; sprintf('The data are retrieved from the file %s, which is located in the folder %s.\n', obj.FileName, obj.FolderName)];
            text = [text; sprintf('The following row-titles were retrieved from this file:\n')];
            MyTitles =  obj.getRowTitles;
            text = [text; cellfun(@(x) sprintf('%s\n', x),MyTitles(:), 'UniformOutput', false)];
            
        end
        
        
        
        
    end
    
    methods (Access = private)
        
        function text = getText(obj)
            text = fileread([obj.FolderName '/' obj.FileName]);
        end
        
        function titles = getRowTitlesFromText(~, text)
            titles = strsplit(text, ';');
            titles = cellfun(@(x) strtrim(x), titles, 'UniformOutput', false);
            
            empty = cellfun(@(x) isempty(x), titles);
            titles(empty) = [];
            
        end
        

            

        
    end
    
end

