classdef PMDataImport
    %PMDATAIMPORT For parsing standardized text file into PMDataContainer objects;
    %   file format:
    % contains two times "***", which surrounds numerical data
    % each group ends with ";"
    % each group starts with comment followed by ":";
    % numbers are separated by ","
    
    properties (Access = private)
        FolderName
        FileName
    end
    
    methods
        
        function obj = PMDataImport(varargin)
            %PMDATAIMPORT Construct an instance of this class
            %   two arguments:
            % 1: string with folder name
            % 2: string with file name
            
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 2
                        obj.FolderName = varargin{1};
                        obj.FileName =   varargin{2};
                otherwise
                    error('Wrong input.')
                
            end
            
            assert(exist(obj.getPath) == 2, 'Cannot connect to specified file.')
          
        end
        
        
    end
    
    methods % GETTERS
        
        function dataContainers = getDataContainers(obj)
            %GETDATACONTAINERS returns data containers after parsing file
            %   returns list of data containers;
            rawData =                                   fileread(obj.getPath);
            RawNumericalString =                        obj.extractStringWithNumericalData(rawData);
            NumericalCellString =                       obj.splitNumericalStringIntoCells(RawNumericalString);
            NumericalCellStringWithoutText =            obj.removeDescriptionFromNuermicalCells(NumericalCellString);
            NumericalCells=                             obj.convertStringCellsIntoNumericalStrings(NumericalCellStringWithoutText);
            dataContainers =                            cellfun(@(x) PMDataContainer(x), NumericalCells);
            
            TitleStrings =                              obj.removeNumbersFromNuermicalCells(NumericalCellString);
            
            dataContainers =                                   cellfun(@(x, y) x.setName(y), num2cell(dataContainers), TitleStrings);
            
            
             
            
        end
        
        
    end
    
    methods (Access = private)
        
        function path =                 getPath(obj)
             path = [obj.FolderName, '/', obj.FileName];
            
        end
        
        function coreData =             extractStringWithNumericalData(obj, rawData)
             
           Matches =    strfind(rawData, '***');
           assert(length(Matches) == 2, 'Text is invalid.')
           
           coreData =               rawData(Matches(1) + 3 :  Matches(2) - 1);
            
        end
        
        function splitDataRows =        splitNumericalStringIntoCells(obj, NumericalData)
            
           splitDataRows =              strsplit(NumericalData, ';');
           splitDataRows =              cellfun(@(x) strtrim(x), splitDataRows', 'UniformOutput', false);
           empty =                      cellfun(@(x) isempty(x), splitDataRows);
           splitDataRows(empty) =       [];
           
            
        end
        
        function splitData =            removeDescriptionFromNuermicalCells(obj, splitDataRows)
           splitData =              cellfun(@(x) strsplit(x, ':'), splitDataRows, 'UniformOutput', false);
           splitData =              cellfun(@(x) x{2}, splitData, 'UniformOutput', false);
            
        end
        
        function splitData =        removeNumbersFromNuermicalCells(obj, splitDataRows)
            splitData =              cellfun(@(x) strsplit(x, ':'), splitDataRows, 'UniformOutput', false);
            splitData =              cellfun(@(x) x{1}, splitData, 'UniformOutput', false);
            
        end
        
        function splitData =            convertStringCellsIntoNumericalStrings(obj, splitData)
            splitData =              cellfun(@(x) strsplit(x, ','), splitData,  'UniformOutput', false);
            splitData =              cellfun(@(x) cellfun(@(y) str2double(y), x, 'UniformOutput', false), splitData,  'UniformOutput', false);
            splitData =             cellfun(@(x) cell2mat(x), splitData,  'UniformOutput', false);
            
        end
            
    end
    
end

