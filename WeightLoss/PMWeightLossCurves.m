classdef PMWeightLossCurves
    %PMWEIGHTLOSSCURVES Summary of this class goes here
    %   Detailed explanation goes here
    
    properties 
        Name
        TimeList
        WeightList
    end
    
    methods % initialize
        
          function obj = PMWeightLossCurves(varargin)
                %PMWEIGHTLOSSCURVES Construct an instance of this class
                %   Detailed explanation goes here
                NumberOfArguments = length(varargin);
                switch NumberOfArguments
                    case 0
                    case 3
                        obj.Name =              varargin{1};
                        obj.TimeList =          varargin{2};
                        obj.WeightList =        varargin{3};
                        assert(size(varargin{2}, 1) == size(varargin{3}, 1), 'Wrong input.')

                    otherwise
                        error('Invalid number of arguments')
                end

          end
        
          function obj = set.Name(obj, Value)
              assert(ischar(Value), 'Wrong input.')
              obj.Name = Value;
          end
          
          function obj = set.TimeList(obj, Value)
              assert(isnumeric(Value) && isvector(Value), 'Wrong input.')
              obj.TimeList = Value;
          end
          
          function obj = set.WeightList(obj, Value)
              assert(isnumeric(Value) && ismatrix(Value), 'Wrong input.')
              obj.WeightList = Value;
          end
          
          
    end
    
    methods % summary
        
         function Text = getSummary(obj)
            
            Text{1,1} = sprintf('\n*** This PMWeightLossCurves object provides data after specific pre-processing functions.\n');
            Text = [Text; sprintf('The object contains data described as "%s".\n', obj.Name)];
            Text = [Text; sprintf('The list contains %i timepoints and %i samples per timepoint.\n', length(obj.TimeList), size(obj.WeightList, 2))];
            
            for index = 1 : length(obj.TimeList)
                Text = [Text; sprintf('Timepoint :%i\n', obj.TimeList(index))];
                Text = [Text; (arrayfun(@(x) sprintf('%6.2f ', x), obj.WeightList(index, :), 'UniformOutput', false))'];
                Text = [Text; newline];
            end

        
        end
        
         function obj = showSummary(obj)
            
            Text = obj.getSummary;
            cellfun(@(x) sprintf('%s', x), Text);
        
        end
        
        
    end
    
    
    methods %getters

         function percentageWeightList = getPercentageWeightList(obj)
            percentageWeightList(:,1) =         num2cell(obj.TimeList);
            percentageWeightList(:,2) =         obj.getPercentageWeightsInCell;
         end
         
         function list = getPercentageWeightsInCell(obj)
              WeightListPercentage =    obj.getPercentageWeights;
              list =                    arrayfun(@(x) WeightListPercentage(x,:), (1:size(obj.WeightList,1))', 'UniformOutput', false);
         end
         
         function percentages = getPercentageWeightsForIndices(obj, Indices)
             percentages=   obj.WeightList(Indices, :) ./ obj.WeightList(min(Indices),:) * 100;
         end
         
        function WeightListPercentage = getPercentageWeights(obj)
            WeightListPercentage=   obj.WeightList ./ obj.WeightList(1,:) * 100;
        end
        
       
               
        function name = getName(obj)
           name = obj.Name;
        end
        
          function name = getTimeList(obj)
           name = obj.TimeList;
          end
        
            function name = getWeightList(obj)
           name = obj.WeightList;
        end
        
        
    end
    
    methods ( Access = private)
        
        
    end
    
end

