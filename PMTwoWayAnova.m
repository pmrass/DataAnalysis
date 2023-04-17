classdef PMTwoWayAnova
    %PMTWOWAYANOVA Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        Matrix
        Repeats
    end
    
    methods
        function obj = PMTwoWayAnova(varargin)
            %PMTWOWAYANOVA Construct an instance of this class
            %   input is a single value:
            % input is a cell-array:
            % each element corresponds to a single group;
            % each element contains a matrix:
            % in this matrix: each row is different observation; different columns are for differnt values;
            % for example in a time series with multiple measurements each row would be for a different timepoint and each column for a single measurement at this timepoint; 
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 1
                    obj.Repeats =   size(varargin{1}{1}, 2);
                    Vectors = cellfun(@(x) obj.convertMatrixIntoVector(x), (varargin{1})', 'UniformOutput', false);
                    obj.Matrix = cell2mat(Vectors);
                    
                otherwise
                    error('Wrong input.')
            end
            
            
        end
        
        function stats = getStatistics(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            [~, stats] = anova2(obj.Matrix, obj.Repeats);
        end
    end
    
    methods (Access = private)
        
        function vector = convertMatrixIntoVector(obj, Value)
            % add more checks:
            
            Value = transpose(Value);
            vector = Value(:);
            
        end
        
        
    end
end

