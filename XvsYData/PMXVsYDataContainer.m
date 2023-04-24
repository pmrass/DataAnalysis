classdef PMXVsYDataContainer
    %PMXVSYDATACONTAINER to manage X versus Y data
    %   contains data where each value is defined by one X-value and one Y-value;
    %   allows retrieval of data in defined X-bins;
    
    properties (Access = private)
        Specimen
        
        XParameter
        YParameter
        ListOfAllXValues
        ListOfAllYValues

        RawData % this is optional it may contain additional information that can be extracted at some point;

        XBinLimits =        cell(0,1)
        NamesOfBins

        CenterType =        'Mean'
        ErrorType =         'SEM'
        ErrorPercentileValue = 75;
        
          WidthForIndividualValues = 0.2;

    end

    properties (Access = private) % p - values
        PValueType =         'Student''s t-test';
        PValueIndices

    end

    properties (Constant, Access = private)

         PossiblePValueTests = {...
                        'Student''s t-test', ...
                        'Mann-Whitney test', ...
                        'Kruskal-Wallis test', ...
                        'Repeated Measures ANOVA test', ...
                        'Calculation of the p-value was not possible',...
                        'Suppress'
                        };



    end

    methods % initialziation

        function obj = PMXVsYDataContainer(varargin)
            %PMXVSYDATACONTAINER Construct an instance of this class
            % takes 0, 1, 2, or 3 arguments:
            % 1 argument: a) vector of PMDataContainers: values of first container have X-value of 1, second 2 and so on; the bins will be set to 0.5 to 1.5, 1.5 to 2 and so on;
            %             b) input is a cell-array: each cell contains 1 value for the X-value and a vector of Y-values that correspond to the X-value;
            % 2 arguments: 1: vector of all X-values; 2: vector with all Y-values;
            % 3 arguments: like to 2 arguments, but third input is list of X-bin limits;
            NumberOfInputArguments = length(varargin);
            switch NumberOfInputArguments

                case 0

                case 1

                    Type = class(varargin{1});

                    switch Type
                        case 'PMDataContainer'
                            obj = obj.setPropertiesWithDataContainer(varargin{1});

                        case 'PMGroupStatistics'
                            obj = obj.setPropertiesWithDataContainer(varargin{1}.getDataContainers);

                        otherwise
                            obj.RawData =      varargin{1};
                            obj =              obj.setSourceDataFromCell(varargin{1});
                    end

                case 2
                    
                    
                    Type = class(varargin{1});
                     switch Type
                        case 'PMDataContainer'
                            obj = obj.setPropertiesWithDataContainer(varargin{1}, varargin{2});

                        case 'PMGroupStatistics'
                            obj = obj.setPropertiesWithDataContainer(varargin{1}.getDataContainers, varargin{2});

                        otherwise
                            obj.ListOfAllXValues =                  varargin{1};
                            obj.ListOfAllYValues =                  varargin{2};
                    end

                    
                    
                    
                    

                   

                case 3

                    FirstArgumentType= class(varargin{1});
                    switch FirstArgumentType
                        case 'cell'
                            obj.RawData =                       varargin{1};
                            obj =                              setSourceDataFromCell(obj,varargin{1});
                            obj.Specimen =                      varargin{2};
                            obj.YParameter =                    varargin{3};

                        case 'double'
                            obj.ListOfAllXValues =                  varargin{1};
                            obj.ListOfAllYValues =                   varargin{2};
                            obj.XBinLimits =                        varargin{3};

                        otherwise
                            error('Input type not supported')

                    end

                otherwise

                    error('Number of input arguments not supported')


            end

            obj =     obj.removeInvalidData;



        end

        function obj = set.Specimen(obj,Value)
            assert(ischar(Value), 'Wrong input format.')
            obj.Specimen =  Value;
        end

        function obj = set.XParameter(obj,Value)
        assert(ischar(Value), 'Wrong input format.')
        obj.XParameter =  Value;
        end

        function obj = set.YParameter(obj,Value)
        assert(ischar(Value), 'Wrong input format.')
        obj.YParameter =  Value;
        end

        function obj = set.ListOfAllXValues(obj,Value)
         if ~isempty(Value)
            assert(isnumeric(Value) && isvector(Value), 'Wrong input format.')
         end
        obj.ListOfAllXValues =  Value(:);
        end

        function obj = set.ListOfAllYValues(obj,Value)
            if ~isempty(Value)
                assert(isnumeric(Value) && isvector(Value), 'Wrong input format.')
            end
            obj.ListOfAllYValues =  Value(:);
        end

        function obj = set.XBinLimits(obj,Value)
         InputType =    class(Value);
         switch InputType
             case 'double'
                 Value =    obj.convertBinVectorIntoBinLimits(Value);
             case 'cell'
             otherwise
                error('Wrong input type.')
         end

        assert(iscell(Value), 'Wrong input format.')
        if ~isempty(Value)
            assert(min(cellfun(@(x) ismatrix(x), Value)), 'Wrong input format.')
            Length =    unique(cellfun(@(x) size(x,1), Value));
            assert(isscalar(Length) && Length ==1, 'Wrong input format.') 
            Width =     unique(cellfun(@(x) size(x,2), Value));
            assert(isscalar(Width) && Width ==2, 'Wrong input format.') 
        end
        obj.XBinLimits =    Value;

        end

        function obj = set.NamesOfBins(obj, Value)
             assert(iscellstr(Value) && isvector(Value) && length(Value) == obj.getNumberOfBins, 'Wrong input.')
            obj.NamesOfBins = Value(:); 
        end

     
    end
    
    methods % INITIALIZATION STATISTICS
        
        function obj =  set.CenterType(obj,Value)
            assert(ischar(Value), 'Wrong input type')
            assert(max(strcmp(Value, {'Median', 'Mean'})), 'Parameter not supported')
            obj.CenterType =  Value;
        end

        function obj =  set.ErrorType(obj,Value)
            assert(ischar(Value), 'Wrong input type')
            assert(max(strcmp(Value, {'SEM', 'Standard Deviation', 'Percentile'})), 'Parameter not supported')
            obj.ErrorType =  Value;
        end

        function obj = set.PValueType(obj, Value)
           assert(ischar(Value) && max(strcmp(Value, obj.PossiblePValueTests)), 'Wrong input.')
          obj.PValueType = Value;
        end

        function obj = set.PValueIndices(obj, Value)
           assert(isnumeric(Value) && ismatrix(Value) && size(Value, 2) == 2, 'Wrong input.')
           obj.PValueIndices = Value;
        end
   
    end
    


    methods % setters

        function obj = set(obj, property, value)
           switch property
               case 'RawData'
                        obj.(property) = value;   
                        
               case 'Specimen'
                        obj.(property) = value;  
                        
               case 'XParameter'
                        obj.(property) = value;  
                        
               case 'YParameter'
                        obj.(property) = value; 
                        
               case 'ListOfAllXValues'
                        obj.(property) = value; 
                        
               case 'ListOfAllYValues'
                        obj.(property) = value; 
                        
           
                        
               case 'ErrorType'
                        obj.(property) = value;  
                        
               otherwise
                        error('Parameter not specified')
           end
         end

      


    end
    
    methods % SETTERS OPERATIONS
        
          function obj = multiplyY(obj, Value)
           obj.ListOfAllYValues = obj.ListOfAllYValues * Value;
          end
          
          function obj = subtractFromY(obj, Value)
            obj.ListOfAllYValues = obj.ListOfAllYValues - Value;
          end

        
          
        
    end
    
    methods % SETTERS BINS
       
        function obj = setXBinLimits(obj, Value)
            obj.XBinLimits =    Value;
            obj =               obj.setBinNamesWhenEmpty;

        end

      
        
        
    end
    
    methods % SETTERS DESCRIPTION

        function obj = setName(obj, Value)
            obj.Specimen = Value;
        end

        function obj = setSpecimen(obj, Value)
            obj.Specimen = Value;
        end
        
          function obj = setXParameter(obj, Value)
            obj.XParameter = Value;
        end

        function obj = setYParameter(obj, Value)
            obj.YParameter = Value;
        end
        

    end
    
    
    methods % SETTERS STATISTICS
        
        function obj = setCenterType(obj, Value)
          obj.CenterType = Value; 
          
          switch obj.CenterType 
              case 'Mean'
                   obj.ErrorType =         'SEM';
              case 'Median'
                 obj.ErrorType =         'Percentile';
              
              
          end
         
        end

        function obj = setPValueType(obj, Value)
            obj.PValueType = Value; 
        end
        
        function obj = setPValueIndices(obj, Value)
             obj.PValueIndices = Value;
        end
    
    end

    methods % SUMMARY

       function Text = getSummary(obj)

           Text = {sprintf('\n*** This PMXVsYDataContainer object processes data for X-Y graphs.\n')};

            Text = [Text; sprintf('It contains data of the specimen "%s".\n', obj.Specimen)];
            Text = [Text;sprintf('Data have the X-parameter "%s" and the Y-parameter "%s".\n', obj.XParameter, obj.YParameter)];

            Text = [Text; sprintf('Center type = %s.\n', obj.CenterType)];
                  Text = [Text; sprintf('ErrorType type = %s.\n', obj.ErrorType)];
      
            
            Text = [Text;sprintf('The object has a total of %i X-values and %i Y-values.\n', length(obj.ListOfAllXValues), length(obj.ListOfAllYValues))];
            Text = [Text; obj.getNumberOfDataPointsInBins];

            if ~strcmp(obj.PValueType, 'Suppress')
                Text =                  [Text; newline];

                myPValueObjects =       obj.getPValue;
                myNewTexts =            arrayfun(@(x) x.getSummary{1}, myPValueObjects, 'UniformOutput', false);

                Text =                  [Text; myNewTexts];

            end

       end

         function obj = showSummary(obj)
            cellfun(@(x) fprintf('%s', x), obj.getSummary)
         end

         function obj = showNumberOfDataPointsInBins(obj)      
             cellfun(@(x) fprintf('%s', x), obj.getNumberOfDataPointsInBins)
         end

         function Text = getNumberOfDataPointsInBins(obj)

              Text = { sprintf('\nDescription of X-bin values:\n')};

              MyErrors = obj.getErrors;
                Text = [Text; ...
                cellfun(@(x,  y, name, center, error) ...
                            sprintf('%6.2f %6.2f: %i values ("%s", %s= %6.2f +/- %6.2f %s)\n', ...
                            x(1), x(2), y, name, obj.CenterType, center, error, obj.ErrorType), ...
                            obj.XBinLimits, ...
                            num2cell(obj.getNumberOfValuesInBins), ...
                            obj.getNamesOfBins, ...
                            num2cell( obj.getYCenters), ...
                            num2cell(MyErrors(:, 1) ), ...
                             'UniformOutput', false)...
                             ];

                 NumbersInBins  = num2cell(obj.getNumberOfValuesInBins);
                 if isempty(NumbersInBins)
                     Text = [Text; sprintf('Bins are empty.\n')];
                 else
                    Text = [Text; sprintf('Numbers per bin for copy-and-paste:\n(%i', NumbersInBins{1})];

                    Text = [Text; cellfun(@(y) sprintf(', %i', y),  NumbersInBins(2:end), 'UniformOutput', false)];
                    Text = [Text; sprintf(')\n')];

                 end


         end


    end

    methods % GETTERS DESCRIPTION
        
        function Values = getXParameter(obj)
            Values = obj.XParameter;
        end

        function Values = getYParameter(obj)
            Values = obj.YParameter;
        end
    
        
    end
    
    methods % GETTERS DATA

        function Values = getListOfAllXValues(obj)
            % GETLISTOFALLXVALUES returns list of all X-values (pooled from different "groups");
            Values = obj.ListOfAllXValues;
        end

        function Values = getListOfAllYValues(obj)
            % GETLISTOFALLYVALUES returns list of all Y-values (pooled from different "groups");
            Values = obj.ListOfAllYValues;
        end

        function Value = getMinX(obj)
            % GETMINX returns minimum X value of all Y data (pooled from different "groups");
            Value = min([obj.ListOfAllXValues]);
        end

        function Value = getMaxX(obj)
            % GETMAXX returns maximum X value of all Y data (pooled from different "groups");
           Value = max([obj.ListOfAllXValues]);
        end

        function Value = getMinY(obj)
            % GETMINY returns minimum Y value of all Y data (pooled from different "groups");
            Value = min([obj.ListOfAllYValues]);
        end

        function Value = getMaxY(obj)
            % GETMAXY returns maximum Y value of all Y data (pooled from different "groups");
           Value = max([obj.ListOfAllYValues]);
        end

    end

    methods % GETTERS Y-DATA IN BINS: X versus Y
        
          function data =         getXVsYForIndividualValues(obj, varargin)
            % GETXVSYFORINDIVIDUALVALUES returns a matrix with two columns;
            % column 1: X-values for each measurement; this is approximately the bin value of each measurement; introduction of some "fluctuation" so that values with similar Y do not overlap;
            % column 2: Y-values for each measurement;
            % this method is usueful for graphical representation of individual values;

             YDataForEachBin =       obj.getYDataInBins;
            
             switch length(varargin)
               
                case 0
                    Spread = repmat(0.2, size(YDataForEachBin, 1), 1);
                    
                case 1
                    Spread = varargin{1};
                    if isempty(Spread)
                         Spread = repmat(0.2, size(YDataForEachBin, 1), 1);
                    end
                    
                otherwise
                    error('Wrong input.')
                
             end
            
             
             XDataForEachBin = cell(length(YDataForEachBin), 1);
            for index = 1 : length(YDataForEachBin)
                YDataInCurrentBin =             YDataForEachBin{index};
                XDataForEachBin{index, 1} =     obj.getXForSingleValueSymbolsForBin(index, YDataInCurrentBin, Spread(index));
                   
            end
            
              
            
            
            data =                  [cell2mat(XDataForEachBin), cell2mat(YDataForEachBin)];
              
           
          end
          
          function dataContainers = getDataContainersForBins(obj, varargin)
              dataContainers = cellfun(@(x) PMDataContainer(x), obj.getYDataInBins(varargin{:}));
              
          end
        
          function YDataInXBins = getYDataInBins(obj, varargin)
            % GETYDATAINBINS get values of each bin
            % takes 0 or 1 arguments:
            % 1: numerical vector with indices of wanted bins;
            % returns cell array with values of each bin;

             
            switch length(varargin)

                case 0
                    ListWithBinIndices = obj.getAllBinIndices;

                case 1
                    assert(PMNumbers(varargin{1}).isIntegerVector, 'Wrong input.')
                    ListWithBinIndices = varargin{1}(:);

                otherwise
                    error('Wrong input.')

            end

            assert(~isempty(ListWithBinIndices), 'Bins are retrieved with non-set bins.')
            
            
             YDataInXBins =             arrayfun(@(x) obj.getValuesInBin(x), ListWithBinIndices, 'UniformOutput', false);

             emptyRows =            cellfun(@(x) isempty(x), YDataInXBins);
             YDataInXBins(emptyRows, :) = {NaN};
             
          end
          
             function values =       getValuesInBin(obj, Value)
                % GETVALUESINBIN returns values of selected BinIndex
                % takes 1 argument
                % 1: integer scalar to selected one of the group-bins
                % returns vector with sorted values in the selected BinIndex;
                assert(PMNumbers(Value).isIntegerScalar && Value >= 1 , 'Wrong input.')
                rowIndices =            obj.getRowIndicesForBinIndex(Value);
                values=                 sort(obj.ListOfAllYValues(rowIndices,:));

             end
        
        
        
             
        
        
    end
    
     methods % GETTERS Y-DATA IN BINS: HISTOGRAM TABLE
         
         
         
            function myTable =      getHistogramTable(obj)
                % GETHISTOGRAMTABLE returns X versus Y matrix in table form;
                matrix =                                transpose(obj.getDataInMatrixForm);
                matrixCell  =                           arrayfun(@(x) matrix(:, x), (1: size(matrix, 2)), 'UniformOutput', false);
                myTable =                               table(   matrixCell{:});    
                myTable.Properties.VariableNames =      obj.NamesOfBins;
            end
        
          function dataMatrix =   getDataInMatrixForm(obj)
            % GETDATAINMATRIXFORM returns matrix;
            % each row holds the contents of a bin;
            % the columns hold the actual values;
            % each bin will not have the same number of values; "empty" columns hold "NaN" as a placeholder;


            assert(length(obj) == 1, 'This method needs an input of precisly one object')

            dataMatrix = nan( length(obj.XBinLimits), 1);
            for index = 1 : length(obj.XBinLimits)
                values = obj.getValuesInBin(index);
                dataMatrix(index, 1:length(values)) = values;

            end

            dataMatrix(dataMatrix == 0) = NaN;

          end
        
          
         
         
     end
     
     methods % GETTERS Y-DATA IN BINS: PERCENTAGES
         
            function Output =       getPercentagesPerBin(obj, LimitValues, varargin)
                    % GETPERCENTAGESPERBIN returns PMXVsYDataContainer where Y values in each bin are single percentage value for numbers in the specified range;
                    % takes 1 or 2 arguments:
                    % 1: numeric scalar or vector with two values (limit ranges);
                    % 2: require when argument 1 is scalar: 'Above' or 'Below';

                    switch length(varargin)

                        case 0
                            
                            
                            assert(PMNumbers(LimitValues).isNumericVector,  'Wrong input.')
                            LowerLimit = min(LimitValues);
                            UpperLimit = max(LimitValues);

                            
                        case 1
                                switch PMNumbers(LimitValues).getType

                                    case 'IntegerScalar'
                                         switch varargin{1}
                                            case 'Above'
                                                LowerLimit = LimitValues;
                                                UpperLimit = max(obj.ListOfAllYValues) + 1;

                                            case 'Below'
                                                LowerLimit = min(obj.ListOfAllYValues) - 1;
                                                UpperLimit = LimitValues;

                                            otherwise
                                                error('Wrong input.')
                                        end


                                    otherwise
                                        error('Wrong input.')


                                end





                        otherwise
                            error('Wrong input.')



                    end

                    Percentage =                cellfun(@(x) length(obj.filterValues(x, LowerLimit, UpperLimit)) / length(x) * 100,  obj.getYDataInBins);
                    Output =                    obj;
                    Output.ListOfAllXValues =   Output.getXBinCenters;
                    Output.ListOfAllYValues =   Percentage;

            end
             
            function Values =       filterValues(obj, Values, LowerLimit, UpperLimit)
                
                Filter(:, 1) =      Values > LowerLimit;
                Filter(:, 2) =      Values < UpperLimit;
                
                Filter =            min(Filter, [], 2);
                
                Values(~Filter) = [];
                
                
            end

        
         
     end
     
     
    
    methods % GETTERS Y-DATA FOR STACKED BARS

        function YValues =      getStackBarValues(obj)
            % GETSTACKBARVALUES returns a cell vector
            % each cell contains data for an individual bin;
            % each bin returns the cumsum of all values (these Y-values can be used to create "stacked bars");
            
            YValues =           obj.getYDataInBins;
            YValues =           cellfun(@(x) [0; x], YValues, 'UniformOutput', false);
            YValues =           cellfun(@(x) cumsum(x), YValues, 'UniformOutput', false);

            
        end
        
    end
    
    methods % GETTERS: Y-STATISTICS

        function result =       getYCenters(obj)
            switch obj.CenterType
              case 'Mean'
                  result =      obj.getMeans;
              case 'Median'
                 result =      obj.getMedians;
            end

        end

        function medians =      getMedians(obj)
            medians =         arrayfun(@(x) x.getMedian, obj.getDataContainersForBins);
        end

        function means =        getMeans(obj)
            means =         arrayfun(@(x) x.getMean, obj.getDataContainersForBins);
        end

        function values = getUpperErrorBoundaries(obj)
            
             MyErrors =    obj.getErrors;
             
             switch obj.ErrorType

                 case 'Percentile'
                     values =  MyErrors(:, 2); 
                 otherwise
                      
                    values =   obj.getYCenters + MyErrors; 
                 
                 
             end
           
            
        end
        
        function values = getLowerErrorBoundaries(obj)
            
             MyError = obj.getErrors;
             
             switch obj.ErrorType
                
                 case 'Percentile'
                     values =  MyError(:, 1); 
                     
                 otherwise
                       
                    values =   obj.getYCenters - MyError; 
                 
                 
             end
             
             
          
        end
        
         function sems =       getSEMs(obj)
          sems =            arrayfun(@(x) x.getSEM, obj.getDataContainersForBins);
        end
        
        function MyErrors =        getErrors(obj)
            switch obj.ErrorType

              case 'SEM'
                  MyErrors = obj.getSEMs;
                  
              case 'Standard Deviation'
                  MyErrors =             obj.getStandardDeviations;
                  
                case 'Percentile'
                   MyErrors(:, 1) =            arrayfun(@(x) x.getPercentile(20), obj.getDataContainersForBins);
                   MyErrors(:, 2) =            arrayfun(@(x) x.getPercentile(80), obj.getDataContainersForBins);
                  
              otherwise
                  error('Error type not supported.')


            end

        end
        
     
        

        
        
        
    end
    
    methods (Access = private)
        
          

        function stdevs =    getStandardDeviations(obj)
            stdevs =            arrayfun(@(x) x.getStandardDeviation, obj.getDataContainersForBins);
        end

        
    end
    
    methods % GETTERS BINS: INFO ABOUT X:
       
          function names =        getNamesOfBins(obj)
            % GETNAMESOFBINS returns names of bins:
            % when not set, returns default names;
            obj =           obj.setBinNamesWhenEmpty;
            names =         obj.NamesOfBins;

          end
          
        function Value =        getNumberOfBins(obj)
            Value =                  size(obj.XBinLimits,1);
        end

        function Value =        getXBinLimits(obj)
            Value =               obj.XBinLimits;
        end

        function binCenters =   getXBinCenters(obj)
            binCenters =       cellfun(@(x) mean(x), obj.XBinLimits);
        end

        
    end

    methods % GETTERS STATISTICS

        function PValueObjects = getPValue(obj)

              switch obj.PValueType

                 case {'Student''s t-test', 'Mann-Whitney test'}
                     PValueObjects = obj.calculateTTestForBins(obj.getBinIndicesForSerialPValueComparison);

                  case 'Kruskal-Wallis test'
                    MatrixForAngles =     transpose(obj.getDataInMatrixForm);
                    [PValue,~,~] =        kruskalwallis(MatrixForAngles);
                    PValueObjects =        PMPValue(PValue, obj.PValueType); 

                  case 'Calculation of the p-value was not possible'
                      PValueObjects =        PMPValue(NaN, obj.PValueType); 

                  otherwise
                      error('Wrong input.')

          end



    end





    end

    methods  % GETTERS ERROR

      
    end

    methods (Access = private) % bins
        
        function binIndex = getAllBinIndices(obj)
             binIndex = (1 : obj.getNumberOfBins)';
            
        end
        
        function rowIndices = getRowIndicesForBinIndex(obj, BinIndex)
            LowLimit =            obj.XBinLimits{BinIndex}(1);
            UpperLimit =          obj.XBinLimits{BinIndex}(2);
            RowsOkOne =           obj.ListOfAllXValues >= LowLimit;
            RowsOkTwo=            obj.ListOfAllXValues <= UpperLimit;
            rowIndices =          min([RowsOkOne, RowsOkTwo], [], 2);
               
        end
        
    end
    
    methods (Access = private) % get adjusted bins per value for graphical representation;
        
     
        
         function numbers = getNumberOfValuesInBins(obj)
            numbers = cellfun(@(x) length(x), obj.getYDataInBins);
         end
        
        
        function flucutatingTransform = getXForSingleValueSymbolsForBin(obj, ValueOfBinCenter, YValues, varargin)
            % GETXFORSINGLEVALUESYMBOLSFORBIN this is used for creating data for a scatter plot:
            % each Y-value gets an X-value that is within limits of its bin;
            % the bins here are usually group numbers
            % returns numerical vector with X-values for each Y;
            
            switch length(varargin)
                 case 0
                       Spread =                    0.2;
                case 1
                      Spread =                    varargin{1};
                otherwise
                    error('Wrong input.')
               
                
            end
          
            switch class(Spread)
               
                case 'cell'
                    
                    MyLimitValues = Spread{1};
                 %   MyLimitValues(:, 2) = MyLimitValues(:, 2) / max(MyLimitValues(:, 2)) * 0.2;
                    
                    XValues = nan(size(YValues, 1), 1);
                    
                    YLimits= [0; MyLimitValues(:,1)];
                    for spreadIndex = 1 : size(MyLimitValues, 1) - 1
                       
                        AcceptedRowsOne =               YValues >= YLimits(spreadIndex);
                        AccecptedRowsTwo =              YValues < YLimits(spreadIndex + 2);
                        AcceptedRows =                  min([AcceptedRowsOne, AccecptedRowsTwo], [], 2);
                        
                        MyYInput =              YValues(AcceptedRows, :);
                        
                       XOut =      obj.getXForSingleValueSymbols(...
                                                           MyYInput , ...
                                                            MyLimitValues(spreadIndex, 2), 'Rotate');
                                                        
                                                        
                                                        XValues(AcceptedRows, :) = XOut;
                                                        
                        
                    end
                    
                otherwise
                     XValues =                    obj.getXForSingleValueSymbols(YValues, Spread);
                    
                
            end
           
           flucutatingTransform =      XValues + ValueOfBinCenter; % translate center of 0 to bin center
                
          
            
        end
        
        function XValues = getXForSingleValueSymbols(obj, YValues, Spread, varargin)
            
            switch length(varargin)
               
                case 0
                    Type = 'Rotate';
                case 1
                    Type = varargin{1};
                
            end
            
            NumberOfValues = length(YValues);
            
            if NumberOfValues == 0
                XValues = zeros(0,1);
            elseif NumberOfValues == 1
                    XValues = 0;
                     XValues =       XValues * Spread; % adjust limits to "spread"; e.g. if set to 0.2 values will range between -0.2 and 0.2

                    
            elseif NumberOfValues == 2
                    XValues = [-1; 1];
                     XValues =       XValues * Spread; % adjust limits to "spread"; e.g. if set to 0.2 values will range between -0.2 and 0.2

                 
            elseif NumberOfValues >= 3
                
                switch Type
                    
                    case 'Rotate'
                    linearSpace=   (linspace(pi, pi * NumberOfValues * 3, NumberOfValues))'; 
                    XValues =       sin(linearSpace); % convert linear values into oscillating between - 1 and 1;
                     XValues =       XValues * Spread; % adjust limits to "spread"; e.g. if set to 0.2 values will range between -0.2 and 0.2

                    
                    case 'Direct'
                        XValues  = linspace(-1, 1, NumberOfValues);
                         XValues =       XValues * Spread; % adjust limits to "spread"; e.g. if set to 0.2 values will range between -0.2 and 0.2

                    otherwise
                        error('Wrong input.')
                end
                    
            
                
            end
            
           
        end

        
      end
    
    methods (Access = private) % getters p-value

        function [PValueIndices] = getBinIndicesForSerialPValueComparison(obj)
            
            if isempty(obj.PValueIndices)
                
                if obj.getNumberOfBins <= 1
                    PValueIndices = NaN;
                else
                    PValueIndices(:, 1) = 1 : obj.getNumberOfBins - 1;
                    PValueIndices(:, 2) = 2 : obj.getNumberOfBins;
                    
                    
                end
                
            else
                
                PValueIndices = obj.PValueIndices;
               
                
            end
            
        end
        
        function PValueObjects = calculateTTestForBins(obj, Bins)
            try assert(ismatrix(Bins) && isnumeric(Bins) && size(Bins, 2) == 2, 'Wrong input.')
           
                if isnan(Bins(1,1))
                     PValueObjects = PMPValue(NaN, 'Calculation of the p-value was not possible');

                else

                   arrayfun(@(x) verifyBinIndex(obj, x), Bins);
                   PValueObjects =   arrayfun(@(x, y) obj.getPValueBetweenBins(x, y), Bins(:, 1), Bins(:, 2));


                end
            
            catch
                PValueObjects = PMPValue(NaN, 'Calculation of the p-value was not possible');
                
            end
            
            
            
              
        end
        
        function verifyBinIndex(obj, Value)
            assert(isscalar(Value) && isnumeric(Value) && mod(Value, 1) == 0 && Value >= 1 && Value <= obj.getNumberOfBins, 'Wrong input.')
            
        end
        
        function PVAlue = getPValueBetweenBins(obj, Bin1, Bin2)
                MyData =                obj.getYDataInBins([Bin1, Bin2]);
                
                switch obj.PValueType
                    case 'Student''s t-test'
                         [~, pValueTemp ]=       ttest2(MyData{:});
                    case 'Mann-Whitney test'
                        [pValueTemp, ~ ]=       ranksum(MyData{:});
                    otherwise
                        error('Statistics test not supported.')
                     
                end
               
                PVAlue =                PMPValue(pValueTemp, obj.PValueType, [Bin1, Bin2]);
            
        end
        
        
    end
    
    methods (Access = private) % not in use?
          function binValues = getBinsForAllValues(obj)
              binValues  = arrayfun(@(x, y) repmat(x, y, 1), obj.getXBinCenters, obj.getNumberOfValuesInBins, 'UniformOutput', false);
              binValues = cell2mat(binValues);
        end
        
    end
    
    methods (Access = private) % summary
        
        function obj = showOneLineSummary(obj)
            fprintf('The data have a mean of %.2f (n = %i)', obj.getMean, obj.getNumberOfDataPoints)
            
        end
        
        
     end

    methods (Access = private) % bins
        
        function obj =          setPropertiesWithDataContainer(obj, dataContainers, varargin)
            
             assert(isvector(dataContainers) && isa(dataContainers, 'PMDataContainer'), 'Wrong input.')

               NumberOfContainers =                length(dataContainers);
              ContainerRange = (1 : NumberOfContainers)';
              
            switch length(varargin)
               
                case 0
                   XShift = 0;
                    
                case 1
                    XShift = varargin{1};
                otherwise
                    error('Wrong input.')
                
            end
            
               
              
                dataContainers =                    dataContainers(:);

                AllValues =                         arrayfun(@(x) ...
                    [ (linspace(x, x, length(dataContainers(x).getValues)))',  ...
                    dataContainers(x).getValues], ...
                    ContainerRange, ...
                    'UniformOutput', false);

                AllValues =                         vertcat(AllValues{:});

                obj.ListOfAllXValues =              AllValues(:, 1) + XShift;
                obj.ListOfAllYValues =              AllValues(:, 2);
                obj.XBinLimits =                    0.5 + XShift : NumberOfContainers + 0.5 + XShift;
                
                NameOfContainers =                  arrayfun(@(x) x.getName, dataContainers, 'UniformOutput', false);
                EmptyRows =                         cellfun(@(x) isempty(x), NameOfContainers);
                DefaultNames =                      obj.getDefaultBinNames;
                NameOfContainers(EmptyRows) =       DefaultNames(EmptyRows);      
                
                obj.NamesOfBins =                   NameOfContainers;
            
        end
        
        function obj =          setBinNamesWhenEmpty(obj)
            
            if isempty(obj.NamesOfBins)
                obj.NamesOfBins = obj.getDefaultBinNames;
                
            end
            
        end
        
         
        function obj =          removeInvalidData(obj)
             % removes all data-points where either X- or Y-value is NaN;
            XValues =                               obj.ListOfAllXValues;
            XInvalidRows =                          isnan(XValues);
            
            YValues =                               obj.ListOfAllYValues;
            YInvalidRows =                          isnan(YValues);
            
            InvalidRows =                           max([ XInvalidRows  YInvalidRows], [], 2);
            obj.ListOfAllXValues(InvalidRows) =     [];
            obj.ListOfAllYValues(InvalidRows) =     [];
            
        end
        
        function obj =          removeEmptyBins(obj)
            [YDataInXBins] =                        obj.getYDataInBins;
            EmptyBins =                             cellfun(@(x) isempty(x), YDataInXBins);
            obj.XBinLimits(EmptyBins) =             [];
            obj.NamesOfBins(EmptyBins) =        [];
        end
        
          
    end
    
    methods (Access = private) % GETTERS BINS
        
        function names =        getDefaultBinNames(obj)
            names = arrayfun(@(x) ['Bin_', num2str(x)], obj.getAllBinIndices, 'UniformOutput', false);
        end
        
         function BinLimits =    convertBinVectorIntoBinLimits(obj, Vector)
            assert(isnumeric(Vector) && isvector(Vector), 'Wrong input type.')
            Vector =                Vector(:);
            BinLimits =            arrayfun(@(x, y) [x y], Vector(1:end-1), Vector(2:end), 'UniformOutput', false);
         end
       
        
     
        
        
    end
    
    methods (Access = private) % data processing
       
          function obj =    setSourceDataFromCell(obj, myCell)
              
                % this is when the input contains a column 1 with all possible X-data and column two contains a list of all Y-Values for each X-datapoint;
                AllYData =                      myCell(:,2);
                AllYData =                      cellfun(@(y) (y(:))', AllYData,'UniformOutput', false);

                XDataOri =                      myCell(:,1);
                MatchingXData=                  cellfun(@(x,y) repmat(x,1,length(y)), XDataOri, AllYData,'UniformOutput', false);

                obj.ListOfAllXValues =          ([MatchingXData{:}])';
                obj.ListOfAllYValues =          ([AllYData{:}])';
                obj.XBinLimits =                cellfun(@(x) [x x], XDataOri, 'UniformOutput', false);

        end
            
    end
         
end