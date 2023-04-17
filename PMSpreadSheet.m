classdef PMSpreadSheet
    %PMSPREADSHEET Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        RowTitles
        Matrix % 
    end
    
    methods
        function obj = PMSpreadSheet(varargin)
            %PMSPREADSHEET Construct an instance of this class
            %   Detailed explanation goes here
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 2
                    obj.RowTitles = varargin{1};
                    obj.Matrix = varargin{2};
                otherwise
                    error('Wrong input.')
                
            end
        end
        
        function Summary = getFormattedSpreadSheet(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
          
             Data =              obj.getDataPerSpecimen;
             Summary =  cellfun(@(x, y) obj.formatSpecimenSummary(x, y), obj.RowTitles, Data, 'UniformOutput', false);
             
        end
        
     
        
    
        
    end
    
    methods (Access = private)
        
        function data = getDataPerSpecimen(obj)
     
            number = size(obj.Matrix, 1);
            data = cell(size(obj.Matrix, 1), 1);
            for index = 1: number
                data{index, 1} =    obj.Matrix(index, 1 : end);
            end
        end
        
        
        function string = formatSpecimenSummary(obj, Title, Data)
            TitleString =       obj.formatString(Title);
            
            DataString =        obj.formatDataString(Data);
            string = [TitleString DataString];   
        end
        
        
        function TitleString = formatString(obj, Title)
             MaximumTitleLength =    50;
             if length(Title) > MaximumTitleLength
                    Title = Title(1:MaximumTitleLength);
             end
             formatSpec = ['%', num2str(MaximumTitleLength), 's: '];
             TitleString =    sprintf(formatSpec, Title);
        end
        
        function string = formatDataString(obj, Data)
            string = '';
            for DataIndex = 1:length(Data)
                string = [string sprintf('%6.2f', Data(DataIndex))];
            end
        end
        
   
        
        
        
        
        
    end
    
    
end

