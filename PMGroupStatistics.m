classdef PMGroupStatistics
    %PMSGROUPSTATISTICS allows statistical comparison between multiple groups;
    %   contains a vector of PMDataContainer as data source for each group;
    
    properties (Access = private)
        DataContainers
        
        PValueType = 'Student''s t-test';
        
    end
    
      properties (Constant, Access = private)
       
         PossiblePValueTests = {'Student''s t-test', ...
                        'Mann-Whitney test', ...
                        'Kruskal-Wallis test', ...
                        'Repeated Measures ANOVA test', ...
                        'Calculation of the p-value was not possible'...
                        };
        
      end
    
    
    methods % INITIALIZE
        
        function obj = PMGroupStatistics(varargin)
            %PMSGROUPSTATISTICS Construct an instance of this class
            %   takes 1 or 2 arguments:
            % 1: a vector with PMDataContainer as the data-source for each group;
            % 2: a string array with names for for each group;
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 0
                case 1
                    obj.DataContainers =     varargin{1};
                    
                case 2
                    obj.DataContainers =     varargin{1};
                    obj =                   obj.setGroupNames(varargin{2});
                    
                otherwise
                    error('Invalid input.')
                    
            end
        end
        
        function obj = set.DataContainers(obj, Value)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            assert(isa(Value, 'PMDataContainer') && isvector(Value), 'Wrong argument type')
            obj.DataContainers= Value;
        end
        
        function obj = set.PValueType(obj, Value)
            assert(ischar(Value) && max(strcmp(Value, obj.PossiblePValueTests)), 'Wrong input.')
           obj.PValueType = Value; 
        end
        
      
    end
    
    methods % SETTERS
       
        function obj = setPValueType(obj, Value)
           obj.PValueType = Value; 
        end
        
    end
    
    methods % SUMMARY
        
        function Text = getSummary(obj, varargin)
            
            switch length(varargin)
               
                case 0
                    Text = getGeneralSummary(obj);
                    
                case 1
                    assert(ischar(varargin{1}), 'Wrong input')
                    switch varargin{1}
                        case 'OneLine'
                            Text = obj.getOneLineSummary;
                        otherwise
                            error('Wrong input.')
                    end
                    
                otherwise
                    error('Wrong input.')
                
            end
                 
        end
            
        function obj = showSummary(obj, varargin)
            
            switch length(varargin)
                case 0
                    obj = obj.showGeneralSummary;
                    
                case 1
                    assert(ischar(varargin{1}), 'Wrong input')
                    switch varargin{1}
                        case 'OneLine'
                            obj = obj.showOneLineSummary;
                        otherwise
                            error('Wrong input.')
                    end
                    
                otherwise
                    error('Wrong input.')
                
            end
                 
        end
         
    end
    
    methods % GETTERS: BASIC
       
        function data =         getDataContainers(obj)
            data = obj.DataContainers; 
        end
        
        function names =        getGroupNames(obj)
            names = arrayfun(@(x) x.getDescription, obj.DataContainers, 'UniformOutput', false);
         end
         
        function number =       getNumberOfGroups(obj)
            number = length(obj.DataContainers); 
        end
        
        function means =        getValues(obj)
            means = (arrayfun(@(x) x.getValues, obj.DataContainers, 'UniformOutput', false))';
        end
         
        function medians =      getMedians(obj)
            medians = (arrayfun(@(x) x.getMedian, obj.DataContainers))';
        end
        
        function means =        getMeans(obj)
            means = (arrayfun(@(x) x.getMean, obj.DataContainers))';
        end
        
        function result =       getMaxOfValuesPooledFromAllGroups(obj)
            result = max(obj.getPooledValues);
        end
        
        function result =       getMinOfValuesPooledFromAllGroups(obj)
            result = min(obj.getPooledValues);
        end
        
        
    end
    
    methods % GETTERS
        
        function xydata = getXYData(obj, varargin)
             % GETXYDATA returns PMXVsYDataContainer for groups;
             % takes 0 or 1 arguments:
             % 1: indices of groups that should be analyzed (default: all groups);
             % returns PMXVsYDataContainer

            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 0
                   SelectedContainers =     obj.DataContainers;

                case 1
                    SelectedGroups =        varargin{1};
                    
                    if isnan(SelectedGroups)
                        SelectedContainers = PMDataContainer();
                    else
                         try
                            SelectedContainers =    obj.DataContainers(SelectedGroups);
                        catch
                           error('Wrong input.') 
                        end
                        
                    end
                    
                   

                otherwise
                    error('Wrong number of arguments')
            end

            xydata =           PMXVsYDataContainer(SelectedContainers);
            xydata =           xydata.setXParameter('Groups');
           
        end
 
        function PValueObject = getPValue(obj)
            
            switch obj.PValueType
                
                case 'Student''s t-test'
                    if obj.getNumberOfGroups == 2
                        MyValues =          obj.getValues;
                        [~, PValue] =       ttest2(MyValues{1},MyValues{2});
                        PValueObject =      PMPValue(PValue, obj.PValueType);
                        
                    else
                       PValueObject =      PMPValue(NaN, 'Calculation of the p-value was not possible'); 
                       warning('This test can be only performed with two groups.')
                    end
                      
                case 'Mann-Whitney test'
                    if obj.getNumberOfGroups == 2
                        MyValues =          obj.getValues;
                        try 
                            PValue =       ranksum(MyValues{1},MyValues{2});
                        catch
                           PValue = NaN; 
                        end
                        PValueObject =      PMPValue(PValue, obj.PValueType);
                        
                    else
                       PValueObject =      PMPValue(NaN, 'Calculation of the p-value was not possible'); 
                       warning('This test can be only performed with two groups.')
                    end
                     
                otherwise
                    error('P-value type not supported.')
                
            end
        end
        
      
         
             
    end
    
    methods % operations

        function obj = multiplyWith(obj, Value)
           
            Type = class(Value);
            
            switch Type
                
                 case 'double'
                    assert(isscalar(Value), 'Can only multiply with scalar.')
   
                    obj.DataContainers =         arrayfun(@(x) x.multiplyWith(Value), obj.DataContainers);
                    
                case 'PMGroupStatistics'
                    
                    assert(obj.getNumberOfGroups == Value.getNumberOfGroups, 'Can only multiply PMGroupStatistics with same number of groups')
                    obj.DataContainers =         arrayfun(@(x, y) x.multiplyWith(y), obj.DataContainers, Value.getDataContainers);
                    
                    
                otherwise
                    error('Wrong input.')
            end
            
            
        end

        function obj = subtractObjectFrom(obj, Value)
            Type = class(Value);
            switch Type
                case 'double'
                        assert(isscalar(Value), 'Can only multiply with scalar.')
                           obj.DataContainers =         arrayfun(@(x) x.subtractObjectFrom(Value), obj.DataContainers);
                   otherwise
                    error('Cannot multiply with %s .\n', Type)   
                            
            end
        end
 
    end
    
    
    methods (Access = private) % summary 
        
        function Text = getOneLineSummary(obj)
            
            Text = {sprintf('\n*** This PMGroupStatistics object contains %i groups (PMDataContainers).\n', obj.getNumberOfGroups)};
            for index = 1 : obj.getNumberOfGroups
                Text = [Text; sprintf('Group %i: ', index)];
                Text = [Text; obj.DataContainers(index).getSummary('OneLine')];
                Text = [Text; newline];
                
            end
            
            Text = [Text;sprintf('Statistical comparison of the groups led to the following result:\n')];
            Text = [Text; obj.getPValue.getSummary];

        end
        
        function obj = showOneLineSummary(obj)
           
              cellfun(@(x) fprintf('%s\n', x), obj.getOneLineSummary)
            
        end
        
        function text = getGeneralSummary(obj)

            text{1,1} = sprintf('\n*** This PMGroupStatistics object contains %i groups (PMDataContainers).\n', obj.getNumberOfGroups);
            
            for index = 1 : obj.getNumberOfGroups
                text = [text; sprintf('\nContents of datacontainer for group #%i:\n', index)];
                text = [text;  obj.DataContainers(index).getSummary('Concise')];
 
            end
            
            text = [text; sprintf('\nThe function getPValue will return a p-value object for comparison between the different groups.\n')];
            text = [text; sprintf('Current the p-value will be calculated with the "%s"', obj.PValueType)];


        end

        function obj = showGeneralSummary(obj)
            
           cellfun(@(x) fprintf('%s\n', x), obj.getGeneralSummary)
            
        end
        
        
        
    end
    

    methods (Access = private)
       
        
        function obj = setGroupNames(obj, Names)
            obj.DataContainers = cellfun(@(x, y) set(x, 'Description', y), num2cell(obj.DataContainers), Names);
        end
        
        %% get pooled values:
        function pooledValues = getPooledValues(obj)
             pooledValues =          obj.poolCellValues(obj.getValues);
        end
        
        %% get "fake" x-values for "fake" XY-dataset:
        function values = getXValuesPerSelectedGroups(obj, SelectedGroups)
            NumberOfEvents= obj.getNumberOfEventsPerGroup;
            
            if isnan(SelectedGroups)
                  values = arrayfun(@(x, y) repmat(x, y ,1), 1 : obj.getNumberOfGroups, NumberOfEvents, 'UniformOutput', false);
            else
                values = arrayfun(@(x, y) repmat(x, y ,1), 1 : length(SelectedGroups), NumberOfEvents(SelectedGroups), 'UniformOutput', false);
            end
        
        
        end
        
        
         function numbers = getNumberOfEventsPerGroup(obj)
             numbers = cellfun(@(x) length(x), obj.getValues);
         end
         
         function pooled = poolCellValues(obj, CellValues)
             pooled = cell2mat(CellValues(:));
         end
        
        
    end
    
    
end

