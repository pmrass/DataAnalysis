classdef PMPValue
    %PMPVALUE this class supports formatted output of P-value
    % it  does NOT calculate the p-values;
    
    properties (Access = private)
        PValue
        NameOfStatisticalTest
        IndicesOfComparedGroups % this is for graphical display when drawing p-values in x vs y graph;
    end
    
    properties (Constant, Access = private)
        
        PossibleTests = {'Student''s t-test', ...
                        'Mann-Whitney test', ...
                        'Kruskal-Wallis test', ...
                        'Repeated Measures ANOVA test', ...
                         'Chi-Square test', ...
                        'Calculation of the p-value was not possible'...
                        };
        
    end
    
    
    methods % initialization
        
        function obj = PMPValue(varargin)
            %PMPVALUE Construct an instance of this class
            %   takes 0, 2, or 3 arguments:
            % 1: numerical scalar (P-value)
            % 2: name of used statistical test;
            % 3: indices of compared groups;
            switch length(varargin)
                case 0
                    obj.PValue =                NaN;
                    obj.NameOfStatisticalTest = 'Calculation of the p-value was not possible';
                    
                case 2
                    obj.PValue = varargin{1};
                    obj.NameOfStatisticalTest = varargin{2};
                    
                case 3
                    obj.PValue = varargin{1};
                    obj.NameOfStatisticalTest = varargin{2};
                    obj.IndicesOfComparedGroups = varargin{3};
                    
                otherwise
                    error('Wrong input.')
                
                
            end
        end
        
        function obj = set.NameOfStatisticalTest(obj, Value)
           assert(ischar(Value), 'Wrong input.')
           assert(max(strcmp(Value, obj.PossibleTests)), 'Wrong input.')
            obj.NameOfStatisticalTest = Value;
            
        end
        
         function obj = set.PValue(obj, Value)
           assert(isnumeric(Value) && isscalar(Value), 'Wrong input.')
            obj.PValue = Value;
            
         end
         
         function obj = set.IndicesOfComparedGroups(obj, Value)
             
            assert(isnumeric(Value) && isvector(Value), 'Wrong input.')
             obj.IndicesOfComparedGroups = Value;
         end
        
        
         
             
         
    end
    
    methods % summary
        
        function Text = getSummary(obj)
            Text = {sprintf('%s (calculated the with %s.)\n', obj.getPValueString, obj.NameOfStatisticalTest)};
            
        end
        
        function obj = showSummary(obj)
            cellfun(@(x) fprintf('%s', x), obj.getSummary);
        end
        
    end
    
    methods % getters
        
        function number = getNumber(obj)
            number = obj.PValue;
            
        end
        
        function strings =                             getPValueString(obj)
                 strings = sprintf('P = %6.5f', obj.PValue);
        end
        
        function indices = getIndicesOfComparedGroups(obj)
           indices = obj.IndicesOfComparedGroups; 
        end
         
        
    end
    
    
end

