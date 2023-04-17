classdef PMDataContainer
    %PMDATACONTAINER container for one-dimensonal data;
    %   main function is as input for graphical displays, for example PMSVGHistogram;
    %   these graphics objects can use the PMDataContainer to convert the data into a graphical display;
    
    properties (Access = private)
        Description
        Data
    end
    
    properties (Access = private) % histogram
        Edges
        AnalysisType =      'Percentage';
        SpecialFeatures
        
    end
    
    properties (Access = private, Constant)
        PossibleAnalysisTypes = {'Percentage', 'Counts', 'Percentage', 'WeightedPercentage'};
        PossibleSpecialFeatures = {'CollectAllRemainingInLastBin'}; % this is not a good feature, it should be removed; there is a disconnect between the "real" data and the bin data;
        % use as an alternative an enforced maximum: all data above a
        % particular value are set to the real maximum value with: applyToDataMaximumValue;
            
         
    end
    
    methods  % initialization
        
        function obj = PMDataContainer(varargin)
            %PMDATACONTAINER Construct an instance of this class
            %   takes 0, 1, 2, 3 or 4 input arguments:
            % 1: Data: can be vector of numbers;
            %           alternatively can be cell-array: contents of cell-array are extracted: if the extracted content is a vector of numbers the input is accepted;
            % 2: edges: numeric vector with neigbhoring "edges" of histogram (need to be set to make histograms later);
            % 3: "description" (name): character string


            NumberOfInputData = length(varargin);
            switch NumberOfInputData
                
                case 0
                    obj.Data =              NaN;
                    obj.Edges =             '';
                    
                case 1

                    Type = class(varargin{1});
                    switch Type
                        case {'cell', 'double'}
                             obj.Data =             varargin{1};

                        otherwise
                            error('Wrong input.')
                    end


                case 2 
                    obj.Data =              varargin{1};
                    obj.Edges =             varargin{2};

                case 3
                    obj.Data =              varargin{1};
                    obj.Edges =             varargin{2};
                    obj.Description =       varargin{3};


                case 4
                    obj.Data  =             varargin{1};
                    obj.Description =       varargin{2};
                    obj.AnalysisType =      varargin{3};
                    obj.SpecialFeatures =   varargin{4};

                otherwise
                    error('Incorrect number of input arguments')
            end

        end

        function obj = set.Data(obj,Value)
             if iscell(Value) % this is a bit wild; maybe just require the user to be more specific with input
                Value=     vertcat(Value{:});
                if isempty(Value)
                  Value = NaN;
                end

                if iscell(Value(1,1)) 
                    Value=          vertcat(Value{:});
                end

                if iscell(Value)
                    Value = cell2mat(Value);
                end
             end
             
            assert( (isnumeric(Value) && isvector(Value)), 'Input must be numeric and vector.')
            obj.Data =  Value(:);
        end

        function obj = set.Edges(obj,Value)
            if isempty(Value)
                
            else
                   if iscell(Value)
                         Value = cell2mat(Value);
                   end
                   assert(isnumeric(Value) && isvector(Value), 'Input must be numeric and vector.')
                   obj.Edges =  Value(:);
                
            end
            
      
        end

        function obj = set.AnalysisType(obj,Value)
          if isempty(Value)

          else
               assert(ischar(Value), 'Input must be char.')
            assert(max(strcmp(obj.PossibleAnalysisTypes, Value)), 'Analysis type not supported.')
            obj.AnalysisType =  Value;
          end

        end

        function obj = set.SpecialFeatures(obj,Value)
           if isempty(Value)

           else
                 assert(ischar(Value), 'Input must be char.')
            assert(max(strcmp(obj.PossibleSpecialFeatures, Value)), 'Entered special feature not supported.')
            obj.SpecialFeatures =  Value;
           end

        end

        function obj = set.Description(obj, Value)
            assert(ischar(Value), 'Input must be char.')
            obj.Description =  Value;
        end
  
    end
    
    methods % summary
        
        function summary = getSummary(obj, varargin)
            
           switch length(varargin)

                case 1
                    assert(ischar(varargin{1}), 'Wrong input.')
                    switch varargin{1}
                        case 'OneLine'
                            summary = obj.getOneLineSummary;
                        case 'Concise'
                            summary = obj.getConciseSummary;
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
                    assert(ischar(varargin{1}), 'Wrong input.')
                    switch varargin{1}
                        case 'NumbersPerBin'
                            obj = obj.showNumbersPerBin;
                        case 'Concise'
                            cellfun(@(x) fprintf('%s', x), obj.getConciseSummary);
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
    

    methods % setters:
    
        function obj = setName(obj, Value)
            obj.Description = Value;
        end

        function obj = setDescription(obj, Value)
            obj.Description = Value; 
        end

        function obj = setEdges(obj, Value, varargin)
            obj.Edges = Value; 

            NumberOfArguments = length(varargin);
            switch NumberOfArguments
               case 0
               case 1
                   obj.SpecialFeatures = varargin{1};
               otherwise
                   error('Wrong input.')
            end

        end

        function obj = set(obj, property, value)

           switch property
               case 'Data'
                   obj.(property) = value; 
               case 'Edges'
                   obj.(property) = value; 
               case 'AnalysisType'
                   obj.(property) = value;
               case 'SpecialFeatures'
                   obj.(property) = value; 
               case 'Description'
                   obj.(property) = value; 
               otherwise
                   error('Parameter not supported.')
           end
        end

    end
    
    methods % interrogate state
        
        function Value = testForValidEdges(obj)
           if isempty(obj.Edges)
               Value = false;
           else
               Value = true;
           end
        end
        
    end
    
    methods % setters content
        
        function obj = applyToDataMaximumValue(obj, MaximumValue)
            assert(isnumeric(MaximumValue) && isscalar(MaximumValue), 'Wrong input.')
            obj.Data(obj.Data > MaximumValue) = MaximumValue;
        end
        
        
       
    end
    
    methods % GETTERS CONTENT
        
        function number = getNumberOfDataPoints(obj)
            number =  length(obj.Data);
        end

        function description = getDescription(obj)
           description = obj.Description ;
        end
        
        function description = getName(obj)
           description = obj.Description ;
        end

        function Values = getValues(obj)
            Values =        obj.Data(:);
        end

        function Maximum =    getMaximum(obj)
            Maximum =       max(obj.Data);
        end

        function Median =      getMedian(obj)
            Median =        nanmedian(obj.Data);
        end

        function Mean =      getMean(obj)
            Mean =          nanmean(obj.Data);
        end
        
        function value = getSEM(obj)
            value = obj.getStandardDeviation / sqrt(obj.getNumberOfDataPoints);
            
        end
        
         function value = getStandardDeviation(obj)
             value = nanstd(obj.Data);
            
         end
         
         function value = getPercentile(obj, Value)
             value = prctile(obj.Data, Value); 
         end

         function value = getPercentageAboveValue(obj, Value)

             value = sum(obj.Data > Value) / obj.getNumberOfDataPoints * 100;

         end
        
        
    end
    
    methods % getters histogram
        
          function Values = getHistogramYValues(obj)
              
             switch obj.AnalysisType
                 case 'Counts'
                     Values =           obj.getCountsOfEachBin;
                     
                 case 'Percentage'
                     Values =           obj.getPercentageOfEachBin;
                     
                 case 'WeightedPercentage'
                     Values =           obj.getWeightedPercentageOfEachBin;
                     
                 otherwise
                     error('Parameter not available')
             end
          end
         
         
          
            function Result = getBinCenterVersusPercentage(obj)
                Result =            obj.getBinCenterVersusCount;
                TotalValues =       sum(Result(:,2));
                Result(:,2) =       Result(:,2)/TotalValues*100;
            end

            function Result =  getBinCenterVersusCount(obj)
                % GETBINCENTERVERSUSCOUNT returns matrix with two columns:
                % column 1: bin centers
                % column 2: number of values in respective bins
                Result =                        [obj.getCenterOfEachBin, obj.getCountsOfEachBin];
            end

           function binCenter = getCenterOfEachBin(obj)
             bins =             obj.getEdgeLimitsOfEachBin;
             binCenter =        cellfun(@(x) mean(x), bins);
           end
           
             function binEdges =        getEdgeLimitsOfEachBin(obj)
                assert(~isempty(obj.Edges), 'Edges are empty. Cannot create bin-edges.')
                 NumberOfBins =         length(obj.Edges)-1;
                 binEdges  =            cell(NumberOfBins,1);
                 for BinIndex = 1:NumberOfBins
                     binEdges{BinIndex,1} = [obj.Edges(BinIndex), obj.Edges(BinIndex+1)];
                 end
             end
             
            function ValuesInBins =        getValuesOfEachBin(obj)
                % GETVALUESOFEACHBIN get cell with values in bins;
                % takes 0 arguments
                % returns cell array vector; each cell contains values that are contained in a specific bin;
                NumberOfBins =                                  size(obj.getEdgeLimitsOfEachBinForDataCollection,1);
                ValuesInBins =                                  cell(NumberOfBins-1,1);
                for CurrentBin = 1:NumberOfBins
                    FilterOne =                                 obj.Data >= obj.getEdgeLimitsOfEachBinForDataCollection{CurrentBin}(1);
                    FilterTwo =                                 obj.Data <= obj.getEdgeLimitsOfEachBinForDataCollection{CurrentBin}(2);
                    Filter =                                    min([FilterOne FilterTwo], [], 2);
                    ValuesInBins{CurrentBin,1} =                obj.Data(Filter,:);
                end
            end
            
           function Counts = getCountsOfEachBin(obj)
                assert(~isempty(obj.Edges), 'Edges not set. Histogram data can be only processed when the edges are set.')
                Counts =          histcounts(obj.Data, obj.Edges);
                Counts =          Counts(:);
           end


            

            
        
    end
    
    methods % operations
       
        function obj =      convertDataToLog10(obj)
            obj.Data =  log10(obj.Data);
            
        end
        
        function obj =      multiplyWith(obj, varargin)
            % MULTIPLYWITH multiply all datapoints by input
            % 1 or 2 arguments:
            % 1: scalar (multiply all values with scalar)
            %    or PMDataContainer with same number of values like object (multiply individual values in each list);
            % 2: character: rename description of object in one go;
            
            
            switch length(varargin)
                case 1
                       Value = varargin{1};
                case 2
                    Value = varargin{1};
                    assert(ischar(varargin{2}), 'Wrong input.')
                    obj.Description = varargin{2};
                    
                    
                otherwise
                    error('Wrong input.')
                
            end
            
            Type = class(Value);
            switch Type
                case 'double'
                    assert(isscalar(Value), 'Can only multiply with scalar.')
                    obj.Data = obj.Data * Value;
                case 'PMDataContainer'
                   assert(length(obj.getValues) == length(Value.getValues), 'Can only multiply when both inputs have same number of values.')
                    obj.Data = obj.Data .* Value.getValues;
                    
                otherwise
                    error('Cannot multiply with %s .\n', Type)
            end
        end
        
        function obj =      subtractObjectFrom(obj, Value)
            Type = class(Value);
            switch Type
                case 'double'
                        assert(isscalar(Value), 'Can only multiply with scalar.')
                        obj.Data = Value - obj.Data;
                   otherwise
                    error('Cannot multiply with %s .\n', Type)   
                            
            end
        end
          
        function obj =      removeIndices(obj, Indices)
            
            obj.Data(Indices) = [];
        end
        
    end
    
    methods (Access = private) % summary
        
        function obj = showGeneralSummary(obj)
            
            cellfun(@(x) fprintf('%s', x), obj.getConciseSummary);
           
            cellfun(@(x) fprintf('%s\n', x), obj.getHistogramText);
            
        end
        
        function Text = getConciseSummary(obj)
            Text{1} = sprintf('\n**** This PMDataContainer object functions as a container for a data-vector.\n');
            Text = [Text; sprintf('It can be used as input for graphical objects, for example PMSVGHistogram which can display the data graphically.\n')];
            Text = [Text; sprintf('The description of this data-container is: "%s".\n', obj.Description)];
            Text = [Text; sprintf('It contains a total of %i datapoints: \n', length(obj.Data))];
            
            Text = [Text; arrayfun(@(x) sprintf('%6.2f ', x), obj.Data, 'UniformOutput', false)];
            Text = [Text; newline];
            
        end
        
        function Text = getOneLineSummary(obj)
             Text = {sprintf('"%s": The data have a mean of %.2f (n = %i)', obj.Description, obj.getMean, obj.getNumberOfDataPoints)};
            
        end
        
        function obj = showOneLineSummary(obj)
           cellfun(@(x) fprintf('%s', x),  obj.getOneLineSummary);
            
        end
        
        function obj = showNumbersPerBin(obj)
            
            NumberPerBin=       obj.getCountsOfEachBin;
            EdgeLimits = obj.getEdgeLimitsOfEachBin;
            
            fprintf('\nHistograms generated by this PMDataContainer object contain measurement of "%s".\n', obj.Description)
            fprintf('\nNumber of values per bin:\n')
            for index = 1 : length(NumberPerBin)
               
                fprintf('Bin limits: "%6.2f to %6.2f": "%i" values\n', EdgeLimits{index}(1), EdgeLimits{index}(2), NumberPerBin(index));
                
            end
            
            
        end
        
        
        end

    methods (Access = private) % histogram
        
        function text =             getHistogramText(obj)
            
            fprintf('Information about histogram retrieval:\n')
            if isempty(obj.Edges)
               text{1} = 'The data-container has no edges defined. Set edges if you want to retrieve histogram data.'; 
            
            else     
                textTop = sprintf('If you retrieve histograms from this object, the following bins will be used:\n');
                binEdges = cellfun(@(x) sprintf('%6.2f %6.2f\n', x(1), x(2)), obj.getEdgeLimitsOfEachBin, 'UniformOutput', false);
                textEnd = sprintf('The content of the retrieved bins is %s\n.', obj.AnalysisType);
                textEnd2 = sprintf('The histogram has the following special feature: %s.\n', obj.SpecialFeatures);
   
                text = [textTop; binEdges; textEnd; textEnd2];
                
            end
            
        end
          
        function Percentages =      getPercentageOfEachBin(obj)
            Counts =            obj.getCountsOfEachBin;
            TotalCount =        sum(Counts);
            Percentages =       Counts/TotalCount*100;
        end

        function [PercentTimeSpentInEachBin] =       getWeightedPercentageOfEachBin(obj)
            ValuesInBins =                            obj.getValuesOfEachBin;

            TotalSumInEachBin =                         cellfun(@(x) sum(x), ValuesInBins);
            SumOfEntirePopulation =                     sum(TotalSumInEachBin);
            PercentTimeSpentInEachBin =                 TotalSumInEachBin / SumOfEntirePopulation * 100;
            PercentTimeSpentInEachBin =                 PercentTimeSpentInEachBin(:);
        end

        function binEdges =         getEdgeLimitsOfEachBinForDataCollection(obj)
            binEdges =        obj.getEdgeLimitsOfEachBin;
            if max(strcmp(obj.SpecialFeatures, 'CollectAllRemainingInLastBin'))
                Max = obj.getMaximum;
                if ~isempty(Max)
                    binEdges{end}(2) =    obj.getMaximum;
                end
            end
        end
       
    end
    
end

