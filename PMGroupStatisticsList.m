classdef PMGroupStatisticsList
    %PMGROUPSTATISTICSLIST series of group-data
    %   list of group-comparisons from single experiment
    
    properties (Access = private)
        Title
        GroupDataList
 
    end
    
    properties (Access = private) % optional properties
        AddPValues = false
        RowTitles               % cell-string vector 
        TimeTitles
        TypeIndexForPairedAnalysis
        
    end
    
    methods % INITILIZATION
        
        function obj = PMGroupStatisticsList(varargin)
            %PMGROUPSTATISTICSLIST Construct an instance of this class
            % 1 or 2 arguments
            % 1: matrix of PMGroupStatistics; rows: different parameters; columns: different timepoints;
            % 2: title: character; this can be an experiment title that has a series of measured parameters;
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 0
                case 1
                    obj.GroupDataList = varargin{1};
                case 2
                    obj.GroupDataList = varargin{1};
                    obj.Title =         varargin{2};
                otherwise
                    error('Invalid input')
            end
            
             if obj.getNumberOfGroups == 2
                    obj =                    obj.setAddPValues(true);
            else
                 obj =                    obj.setAddPValues(false);
             end
            
        end
        
        function obj = set.GroupDataList(obj, Value)
            assert(isa(Value, 'PMGroupStatistics') && ismatrix(Value), 'Invalid input.')
            obj.GroupDataList =     Value;
            numberOfGroups =        obj.getNumberOfGroups;
            assert(length(numberOfGroups) == 1, 'Inconsistent numbers in group')
        end
        
        function obj = set.Title(obj, Value)
            if ischar(Value)
                
            else
                error('Wrong input.')
            end
                obj.Title = Value;
        end
        
        function obj = set.AddPValues(obj, Value)
            assert(islogical(Value) && isscalar(Value), 'Wrong input type.')
            obj.AddPValues =    Value;
        end
        
        function obj = set.TimeTitles(obj, Value)
            assert(iscellstr(Value) || isempty(Value), 'Wrong input.')
            obj.TimeTitles =    Value;
        end
        
    end
    
    methods % SUMMARY
       
        function obj = showSummary(obj)
            
            fprintf('PMGroupStatisticsList with title %s.\n', obj.Title)
            fprintf('Number of parameters = %i.\n', obj.getNumberOfParameters)
            fprintf('Number of timepoints = %i.\n', obj.getNumberOfTimePoints)
           
            if obj.AddPValues
                fprintf('P-values will be shown.\n') 
            else
                fprintf('P-values will not be shown.\n') 
            end
            
            if isempty(obj.TimeTitles)
                MyTimeTitels{1} = 'No time series';
            else
                MyTimeTitels = obj.TimeTitles;
            end
            
            
            for index = 1 : obj.getNumberOfParameters
                
                try
                    for timeIndex = 1 : obj.getNumberOfTimePoints
                        fprintf('\nThe PMGroupStatistics object for parameter #%i (%s) and timepoint #%i (%s) is:\n\n', index, obj.RowTitles{index}, timeIndex, MyTimeTitels{timeIndex})
                        obj.GroupDataList(index) = obj.GroupDataList(index).showSummary;
                    end
                catch ME
                   rethrow(ME)
                end
                  
            end
            
  
        end
        
        
    end
    
    methods % SETTERS
        
        
        function obj = setAddPValues(obj, Value)
            % SETADDPVALUES the user turns on or off whether he wants to see p-values in the output (e.g. spreadsheet) or suppress this info;
            obj.AddPValues =    Value;
        end
        
        function obj = setRowTitlesByManualAndClusters(obj, ManualRowTitles, MainDataTypes, SubDataTypes)
            titles =            obj.getRowTitlesByManualAndClusters(ManualRowTitles, MainDataTypes, SubDataTypes);
            obj =               obj.setRowTitles(titles);
        end
        
         function obj = setRowTitles(obj, Value)
            obj = setRowTitlesInternal(obj, Value);
         end
        
        function obj = setTimeTitles(obj, Value)
            obj.TimeTitles =    Value;
        end
        
         function obj = pairByIndex(obj, Value)
             % PAIRBYINDEX allows setting TypeIndexForPairedAnalysis, this enables "pairing" of values of interest by a certain mechanism;
             % currently not sure how this works, don't rely on this now, use unpaired statistcs analysis instead;
            obj.TypeIndexForPairedAnalysis = Value;
        end
        
        
    end
    
    methods % GETTERS
       
         
        function title = getTitle(obj)
            title = obj.Title;
        end
        
        
    end
    
    methods % GETTERS DESCRIPTION OF CONTENTS
        
        function myRowTitles = getRowTitles(obj)
            %GETROWTITLES returns a cell-string array with "row-titles";
            % the row titles are actually a descriptive title of the different "parameters" in the list;
            % therefore the number must equal to the number of rows in the
            % GroupDataList (but the methods gets two empty extra-rows, for making it fit to the spreadsheet);
        
            myRowTitles = obj.getParameters;
            TwoEmptyRows = {' , , '; ...
                '  , , ';...
                };
            myRowTitles = [TwoEmptyRows; myRowTitles];

        end
        
        function myRowTitles = getParameters(obj)
            % GETPARAMETERS returns the names of the parameters that are contained;
            
            myRowTitles = obj.RowTitles;
            if isempty(myRowTitles)
                myRowTitles = obj.getDefaultParameterNames;
            end
        end
        
        function description = getDescriptionForIndex(obj, Index) % bad name;
            % GETDESCRIPTIONFORINDEX returns a character string with the "row-titles" of the input index;
            % the row title is actually a descriptive title of the different "parameters" in the list;
            
            description = obj.RowTitles{Index};
        end
        
        
        function parameters = getDefaultParameterNames(obj)
              parameters =  arrayfun(@(x) ['Data', num2str(x), ', ,'],  (1: obj.getNumberOfDataTypes)', 'UniformOutput', false);
        end
        
        function number = getNumberOfDataTypes(obj)
            number =    size(obj.GroupDataList, 1);
        end
        
        
        
        function value = getTimeTitles(obj)
           value = obj.TimeTitles; 
            
        end
        
        
       function title = getRowTitlesByManualAndClusters(obj, ManualRowTitles, MainDataTypes, SubDataTypes)
           title = obj.getRowTitlesByManualAndClustersInternal(ManualRowTitles, MainDataTypes, SubDataTypes);
       end
       
   
    end
    

    
    methods % GETTERS GROUPS
       
       function NumberOfGroupsPerEntry = getNumberOfGroupsEach(obj) % bad name: 
            NumberOfGroupsPerEntry = arrayfun(@(x) x.getNumberOfGroups, obj.GroupDataList);
            
        end
        
        function numberOfGroups = getNumberOfGroups(obj) 
            temp =                      obj.GroupDataList;
            NumberOfGroupsPerEntry =    arrayfun(@(x) x.getNumberOfGroups, temp);
            numberOfGroups =            unique(NumberOfGroupsPerEntry);
        end
        
        function names = getGroupnames(obj)
           names = ( obj.GroupDataList(1).getGroupNames)';
        end
        
    end
    
    methods % GETTERS FOR CONTENT
        
        function data =             getGroupStatisticsWithParameterName(obj, Name)
            % GETGROUPSTATISTICSWITHPARAMETERNAME returns PMGroupStatistics for entry matching input;
           assert(ischar(Name), 'Wrong name.')
           
           AllParameters =      obj.getParameters;
           Match =              find(strcmp(AllParameters, Name));
           switch length(Match)

               case 0

                   fprintf('Requested parameter: "%s".\n', Name)
                   fprintf('Available parameters:\n')
                   cellfun(@(x) fprintf("%s\n", x), AllParameters)
                   error('The requested parameter has no matches in the available parameters. Check your input.')
                   
                  

               case 1

                        data =               obj.getGroupStatisticsWithIndices(Match);

               otherwise
                    fprintf('Requested parameter: "%s".\n', Name)
                   fprintf('Available parameters:\n')
                   cellfun(@(x) fprintf("%s\n", x), AllParameters)
                    error('The requested parameter has more than 1 match in the available parameters. Check your input.')




           end
         

        end
        
        function data =             getGroupStatisticsWithIndices(obj, Indices)
            assert(isnumeric(Indices) && isvector(Indices), 'Wrong input.')
            try
                assert(isvector(Indices) && isnumeric(Indices) , 'Indices must be a numeric vector.')
                assert(min(Indices) >= 1 , 'MinimumIndex must be at least 1.')
                Temp =                          obj.GroupDataList;
                assert(max(Indices) <= size(Temp, 1) , 'Maximum index must be maximal number of rows in group-list.')

            catch ME
                rethrow(ME)
            end
            
            data =      obj.GroupDataList(Indices, :);
            
        end
        
        function maximumValue =     getMaximumValueForIndex(obj, Index)
            maximumValue = obj.getMaxOfPooledValues{Index}; 
        end
        
        function maximumValue =     getMinimumValueForIndex(obj, Index)
            maximumValue = obj.getMinOfPooleValues{Index}; 
        end
        
        function values =           getValuesForIndex(obj, Index)
            %GETVALUESFORINDEX returns cell vector; each cell contains numerical vector with data content for input index;
             values =       obj.getCellListOfValues{Index};
        end
        
        function values =           getMeansForIndex(obj, Index)
            values =        obj.getMediansPerGroup;
            values =        values(Index, :);
         end
         
        
        
    end
    
    methods % GETTERS: getGroupXYDataSeriesForIndices
       
         function XYDataContainer = getGroupXYDataSeriesForIndices(obj, Indices)
            % GETGROUPXYDATASERIESFORINDICES returns vector of PMXVsYDataContainer objects;
            % takes 1 argument:
            % 1: numerical vector with indices
            % each group gets 1 PMXVsYDataContainer;
            % each PMXVsYDataContainer contains data of specified indices;
            assert(isnumeric(Indices) && isvector(Indices), 'Wrong input.')
            
            Values =                arrayfun(@(x) obj.getValuesForIndex(x), Indices, 'UniformOutput', false);
            [xGroupOne, y1, x2, y2] =   obj.convertToXY(Values);

            xData_CXCR4 =           {xGroupOne; x2};
            yData_CXCR4 =           {y1; y2};

            XYDataContainer =       cellfun(@(x, y) PMXVsYDataContainer(x,y), xData_CXCR4, yData_CXCR4);
            Min =                   min(arrayfun(@(x) x.getMinX, XYDataContainer)) - 0.5;
            Max =                   min(arrayfun(@(x) x.getMaxX, XYDataContainer)) + 0.5;
            XYDataContainer =       arrayfun(@(x) set(x, 'XBinLimits', Min: Max), XYDataContainer);
 
        end
        
        
         
        
       
        
    end
    
    methods %% GETTERS
         
        function [PValues, PValueText] =    getPValues(obj, varargin)
            % GETPVALUES calculates list of p-values for all data-groups in list;
            % P-value is calculated between first two groups in list
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 0
                    [PValues, PValueText] =   obj.calculateTTest;
                case 1
                    switch varargin{1}
                        case {'MannWhitney', 'Mann-Whitney test'}
                             [PValues, PValueText] =   obj.calculateMannWhitney;
                             
                        case {'TTest', 'Student''s t-test'}
                            [PValues, PValueText] =   obj.calculateTTest;
                            
                        otherwise
                         error('Not supported.')
                    end
                    
                case 2
                    assert(ischar(varargin{1}) , 'Wrong argument type.')
                    assert(ischar(varargin{2}) , 'Wrong argument type.')
                    PValues =   obj.getPValuesInternal(varargin{1});
                    switch varargin{2}
                        case {'Symbols', 'symbols', 'Symbol', 'symbol'}
                            myPValueLabelManager =  PMSVGPValueLabels({'-', '+++', '++', '+'});
                            PValues =               myPValueLabelManager.convertPValuesToSymbols(PValues);
                        otherwise
                            error('Parameter not supported.')
                    end
       
                    
                otherwise
                    error('Wrong number of arguments.')
            end
             
        end
        
        function spreadSheet =              getFormattedSpreadsheet(obj)
            spreadSheet =         [obj.getRowTitles,     [obj.getColumnTitles;  obj.getStatisticsInteral]];    
        end
        
        function SelectedXYContainer =      getXYDataForIndex(obj, Index, varargin)
            
            if isempty(varargin)
                Groups = NaN;
            elseif length(varargin) == 1
                Groups = varargin{1};
            end
            
           % DataTest = 
            
            AllData =  obj.getXYData(Groups);
            if isempty(obj.TimeTitles)
                SelectedXYContainer =               AllData{Index};
                
            else
                XYDataOfDifferentTimePoints =       AllData(Index, :);
                DataContainersForDifferentTimes =   cellfun(@(x) PMDataContainer(x.getListOfAllYValues), XYDataOfDifferentTimePoints);
                SelectedXYContainer =               PMXVsYDataContainer(DataContainersForDifferentTimes);
                SelectedXYContainer =               SelectedXYContainer.setXParameter('Timepoints');
                SelectedXYContainer =               SelectedXYContainer.setYParameter(obj.getDescriptionForIndex(Index));
                SelectedXYContainer =               SelectedXYContainer.setSpecimen('Not defined');
                
            end
        end
        
        function xyValues =                 getXYData(obj, varargin)
            
             if isempty(varargin)
                Groups = NaN;
            elseif length(varargin) == 1
                Groups = varargin{1};
             else
                 error('Wrong input.')
            end
            
            
            xyValues =         arrayfun(@(x) x.getXYData(Groups), obj.GroupDataList, 'UniformOutput', false);
        end
        
        function XYDataContainer =          getTimeCourseDataForIndex(obj, Index)
            myData =                                    obj.GroupDataList(Index, :);
            dataPerTimePointForFirstGroup =             arrayfun(@(x) PMDataContainer(x.getValues{1}), myData);  
            XYDataContainer =                           PMXVsYDataContainer(dataPerTimePointForFirstGroup);
        end
          
        
    end
    
    methods (Access = private) % GETTERS: getGroupXYDataSeriesForIndices
       
           function [xgroup1, ygroup1, xgroup2, ygroup2] = convertToXY(obj, Input)
               
                
                ygroup1=        cellfun(@(x) x{1}, Input, 'UniformOutput', false);
                xgroup1 =       obj.getXValues(ygroup1);

                ygroup1=        vertcat(ygroup1{:}); 
                xgroup1=        vertcat(xgroup1{:});      

                ygroup2=        cellfun(@(x) x{2}, Input, 'UniformOutput', false);
                xgroup2 =       obj.getXValues(ygroup2);

                ygroup2=        vertcat(ygroup2{:}); 
                xgroup2=        vertcat(xgroup2{:});    

           end
        
    end
    
    methods (Access = private) % GETTERS: getValueSpreadSheet;
       
            
         function valueSpreadSheet = getValueSpreadSheet(obj)
            valueSpreadSheet =            obj.getCellListOfValues;
             if isempty(obj.TimeTitles)
                    valueSpreadSheet = obj.expandCells(valueSpreadSheet);
             else
                 valueSpreadSheet = cellfun(@(x) x{1}, valueSpreadSheet, 'UniformOutput', false);
             end
            valueSpreadSheet =            cellfun(@(x) obj.roundCell(x), valueSpreadSheet, 'UniformOutput', false);
         end
        
         function ListOfValues = getCellListOfValues(obj)
             
                ListOfValues =          arrayfun(@(x) x.getValues, obj.GroupDataList, 'UniformOutput', false);  
                if ~isempty(obj.TypeIndexForPairedAnalysis)
                     ReferenceValues =      ListOfValues(obj.TypeIndexForPairedAnalysis, :);
                     ListOfValues =         obj.orderAllValuesByReference(ListOfValues, ReferenceValues);
                end
         end
         
         function Expanded = expandCells(obj, ListOfValues)
             Expanded = cell(length(ListOfValues), 1);
             for index = 1 : length(ListOfValues)
                 Expanded(index, 1: size(ListOfValues{index}, 2))  = ListOfValues{index};
                 
             end
             
         end
         
         function ListOfValues = orderAllValuesByReference(obj, ListOfValues, ReferenceValues)
              for RowIndex = 1: size(ListOfValues, 1)
                  for ColumnIndex = 1: size(ListOfValues, 2)
                      DisorderedData =              ListOfValues{RowIndex}{ColumnIndex};
                      ReferenceData =     ReferenceValues{1}{ColumnIndex};
                      ListOfValues{RowIndex}{ColumnIndex} = obj.orderValuesByReference(DisorderedData, ReferenceData);
                  end
              end
         end
         
         function myData = orderValuesByReference(obj,myData, myReferenceData)
                myData =              [myData, myReferenceData];
                myData =              sortrows(myData, -2);
                myData(:,2 ) =        [];
         end
             
         function Values = roundCell(obj, Values)
            Values = round(Values);
            Values = round(Values);
         end
        
        
    end
    
    
    methods (Access = private)
        
        
       
        

          function xValues = getXValues(obj, Input)
            for Index = 1: length(Input)
                 xValues{Index, 1} = repmat(Index, length(Input{Index}), 1);
            end
        end
        
        
        %% create column titles:
        function titles = getColumnTitles(obj)
            TopHeaderWithGroupName =    [obj.getBasicUpperColumTitles, obj.getPValueUpperColumnTitles];  
            bottomHeaders =             [obj.getBasicBottomColumTitles,  obj.getPValueLowerColumnTitles];
            titles =                    [{TopHeaderWithGroupName}; {bottomHeaders}];
        end
        
        function TopHeaderWithGroupName = getBasicUpperColumTitles(obj)
            GroupNamesInternal =            obj.getGroupnames;
            for index = 1: length(GroupNamesInternal)
                    CurrentGroupName = GroupNamesInternal{index};
                    if ~isempty(  obj.TimeTitles)
                        NamesWithTime = cellfun(@(x) [CurrentGroupName, ' ', x, ', '], (obj.TimeTitles(:))', 'UniformOutput', false);
                    else
                        NamesWithTime{1, index} = CurrentGroupName;
                    end
            end  
            
             TopHeaderWithGroupName = '';
              for index = 1: length(NamesWithTime)
                    TopHeaderWithGroupName =    sprintf('%s%s, , ,', TopHeaderWithGroupName, NamesWithTime{index});
              end
                
        end
        
        function bottomHeaders = getBasicBottomColumTitles(obj)
              bottomHeaders =             arrayfun(@(x) obj.getBottomHeaderGroupUnit, 1:obj.getNumberOfGroups, 'UniformOutput', false);
            bottomHeaders =             horzcat(bottomHeaders{:});
          
        end

         function bottomHeader = getBottomHeaderGroupUnit(obj)
            bottomHeader = 'Values, Mean, Median, ';
         end
         
         function columnTitles = getPValueUpperColumnTitles(obj)
             OneComma = ', ';
            columnTitles = repmat(OneComma, 1, obj.getNumberOfPValues);
         end
         
        function number = getNumberOfPValues(obj)
            switch  obj.AddPValues
                case true
                     assert(obj.getNumberOfGroups == 2, 'P-values can only be generated for two groups.')
                    if isempty(obj.TypeIndexForPairedAnalysis)
                        number = 2;
                    else
                        number = 3;
                    end
                otherwise
                    number = 0;
            end
        end
        
        function bottomHeaders = getPValueLowerColumnTitles(obj)
            
            switch obj.getNumberOfPValues
                case 0
                    bottomHeaders =             '';
                case 2
                     bottomHeaders =             'T-test, Mann-Whitney, ';
                case 3
                      bottomHeaders =             'T-test, Mann-Whitney, Paired t-test,';
                    
                otherwise
                    error('Wrong number of p-values requested.')
                    
                
                
            end
        end
      
         
        %% set row titles:
          function obj = setRowTitlesInternal(obj, Value)
               assert(iscellstr(Value) && isvector(Value), 'Wrong argument type.')
               
              if length(Value) ~= obj.getNumberOfDataTypes
                  obj = obj.showSummary;
                  fprintf('\nInput for row titles = \n')
                  cellfun(@(x) fprintf('%s\n', x), Value)
                  error('Number of datatypes does not match row-title input. Datatypes = %i, input (row titles) = %i', obj.getNumberOfDataTypes, length(Value))
              else
                  
                    obj.RowTitles =     Value(:);
              end
            
          end
        
        %% get row titles by input:
        function rowTitles = getRowTitlesByManualAndClustersInternal(obj, ManualRowTitles, MainDataTypes, SubDataTypes)
             clusterTitles =        obj.getRowTitlesFromMainAndSubTitles(MainDataTypes, SubDataTypes);
             if isempty(ManualRowTitles)
                  rowTitles =            clusterTitles;
             else
                 rowTitles =            [ManualRowTitles; clusterTitles];
             end
             
        end
        
        function rowTitles = getRowTitlesFromMainAndSubTitles(obj, Main, SubTitles)
             rowTitles =        obj.CreateRowTitles(Main, SubTitles);
        end
        
        function finalRows = CreateRowTitles(obj, MainTitles, SubTitles)
            strings =       cellfun(@(x) obj.CreateMainTitleCell(x, SubTitles), MainTitles, 'UniformOutput', false);
            finalRows =     vertcat(strings{:});
        end

        function strings = CreateMainTitleCell(obj, MainTitle, SubTitles)
            strings=                cellfun(@(x) sprintf('%s, %s, ', MainTitle, x), SubTitles, 'UniformOutput', false);
        end 
        
  
        %% get statistics:
        function formattedStats = getStatisticsInteral(obj)
            assert(obj.getNumberOfGroups >= 1, 'Wrong group number')
            formattedStats =        obj.horzconCellStrings([obj.getSpreadsheetWithDescriptiveStatistics, obj.getSpreadSheetWithPValues]);
        end
        
       function pooled = horzconCellStrings(obj, NotPooled)
            
            pooled = cell(size(NotPooled, 1), 1);
            for RowIndex = 1: size(NotPooled, 1)
                 HorizontallyConcatenatedString = '';
                   for ColumnIndex = 1 : size(NotPooled, 2)
                       HorizontallyConcatenatedString = sprintf('%s%s', HorizontallyConcatenatedString, NotPooled{RowIndex, ColumnIndex});
                   end
                 pooled{RowIndex, 1} = HorizontallyConcatenatedString;
                
            end
            
        end
        
        %% get spreadsheet with descriptive statistics:
        function formattedDescrStat = getSpreadsheetWithDescriptiveStatistics(obj)
            
            values =                obj.getSpreadSheetOfFormattedValues;
            medians =               obj.getMediansPerGroup;
            means =                 obj.getMeansPerGroup;
            formattedDescrStat =    obj.convertNumbersIntoFormattedDescriptiveStatistics(values, means, medians);
          
        end
        
        function formattedDescrStat = convertNumbersIntoFormattedDescriptiveStatistics(obj, AllFormattedValuesPerGroup, AllMeansPerGroup, AllMediansPerGroup)
              formattedDescrStat =             cell(obj.getNumberOfDataTypes, 1);
            for DataTypeIndex = 1 : obj.getNumberOfDataTypes
                [values_CurrentType, means_CurrentType, medians_CurrentType] = obj.getDataOfRow(DataTypeIndex, AllFormattedValuesPerGroup, AllMeansPerGroup, AllMediansPerGroup);
               formattedDescrStat{DataTypeIndex, 1} = obj.getFormattedStatistcsForType(values_CurrentType, means_CurrentType, medians_CurrentType);
            end
        end
        
        function [values, means, medians] = getDataOfRow(obj, row, AllFormattedValuesPerGroup, AllMeansPerGroup, AllMediansPerGroup)
            values =          AllFormattedValuesPerGroup(row, :);
            means =           AllMeansPerGroup(row, :); 
            medians =         AllMediansPerGroup(row, :); 
        end
        
        function [string] = getFormattedStatistcsForType(obj, values_CurrentType, means_CurrentType, medians_CurrentType)
            FormattedCell = cell(1,  length(values_CurrentType));
            for GroupIndex = 1 : length(values_CurrentType)
                    [values, mean, median] =                        obj.extractStatisticsForGroupIndex(GroupIndex, values_CurrentType, means_CurrentType, medians_CurrentType);
                    
                    if mean < 10 || median < 10
                        FormattedDataForTypeAndGroup =                  sprintf('%s, %4.2f, %4.2f,', values, mean, median);
                    else
                         FormattedDataForTypeAndGroup =                  sprintf('%s, %i, %i,', values, round(mean), round(median));
                    end
                    FormattedCell{	1, GroupIndex} =      FormattedDataForTypeAndGroup;
             end
              result = obj.horzconCellStrings(FormattedCell);
             string = result{1};
        end
        
        function [values, mean, median] = extractStatisticsForGroupIndex(obj, GroupIndex, values_CurrentType, means_CurrentType, medians_CurrentType)
            values =             values_CurrentType{GroupIndex};
            mean =               means_CurrentType(GroupIndex); 
            median =             medians_CurrentType(GroupIndex);  
        end
        
        function medians =  getMediansPerGroup(obj)
            medians =       cell2mat(arrayfun(@(x) x.getMedians, obj.GroupDataList, 'UniformOutput', false));
        end
           
        function medians =  getMeansPerGroup(obj)
            medians =         cell2mat(arrayfun(@(x) x.getMeans, obj.GroupDataList, 'UniformOutput', false));
        end
        
 
        
        %% get spreadsheet of formatted values:
        function formattedSpreadSheet = getSpreadSheetOfFormattedValues(obj)
            valueSpreadSheet = obj.getValueSpreadSheet;
            
           
            
             Formatters =                obj.getFormattersForGroupValues;
          %  Formatters =                vertcat(Formatters{:});
            formattedSpreadSheet =      cellfun(@(x, y) obj.formatSingleDataUnit(x, y), Formatters, valueSpreadSheet, 'UniformOutput', false);
           
            
            
        end
        
        function ColumnString = formatSingleDataUnit(obj, Formatters, Data)
            assert(isvector(Data) && isnumeric(Data), 'Wrong input type')
            ColumnString = '';
            for ColumnIndex = 1: length(Data)
            myFormatter =   ['%s' Formatters{ColumnIndex}];
            ColumnString =  sprintf(myFormatter, ColumnString, Data(ColumnIndex));
            end
        end
    
         %% format value spread-sheet
      
          
        function Formatters = getFormattersForGroupValues(obj) 
             Numbers =       cellfun(@(group) length(group), obj.getValueSpreadSheet);  
            Formatters =         arrayfun(@(numbers) obj.getFormattersForValuesOfSingleGroup(round(numbers)) ,  Numbers, 'UniformOutput', false);  
        end
        
     
        
        function formatters = getFormattersForValuesOfSingleGroup(obj, Number)
             formatters =   arrayfun(@(x) '%i;', (1:Number)', 'UniformOutput', false);
        end
        

        
        
        
        %% get spreadsheet with p-values:
        function formattedStats = getSpreadSheetWithPValues(obj)
            switch getNumberOfPValues(obj)
                case 0
                    formattedStats = '';
                case 3
                    formattedStats =        [obj.getFormattedPValuesForTTest,  obj.getFormattedPValuesForMannWhitney, obj.getFormattedPValuesForPairedTTest];    
                    formattedStats =        obj.horzconCellStrings(formattedStats);
                case 2
                    formattedStats =        [obj.getFormattedPValuesForTTest,  obj.getFormattedPValuesForMannWhitney];    
                    formattedStats =        obj.horzconCellStrings(formattedStats);
                otherwise
                    error('Invalid error type')    
            end     
        end
        
        function [FormattedPValues] = getFormattedPValuesForTTest(obj)
  
             FormattedPValues = obj.getFormattedPValuesForValues( obj.calculateTTest);
            
        end
        
        function FormattedPValues = getFormattedPValuesForValues(obj, Values)
            FormattedPValues =           arrayfun(@(x) obj.formatSingleDataUnit({'%6.5f,'}, x), Values, 'UniformOutput', false);   
        end

        function [PValues, FormattedPValues] =  calculateTTest(obj)
            Data= obj.getCellListOfValues;
            if isempty(obj.TimeTitles)
                [~, PValues] =   cellfun(@(x) ttest2(x{1}, x{2}), Data); % this should be moved out to the individual PMGroupsStatistics objects;
                
             
                
            else
                  [~, PValues] =   arrayfun(@(x) ttest2(Data{x, 1}{1}, Data{x, 2}{1}), (1 : size(Data, 1))');
            end
            FormattedPValues = obj.getFormattedPValuesForValues(PValues);
          %  text = sprintf('The following p-values were calculated with the t-test\n') ;
          
          %  FormattedPValues = [text; FormattedPValues];
          %  cellfun(@(x) fprintf('%s\n', x), FormattedPValues)
        end
        
        function FormattedPValues= getFormattedPValuesForMannWhitney(obj)
            FormattedPValues =           arrayfun(@(x) obj.formatSingleDataUnit({'%6.5f,'}, x), obj.calculateMannWhitney, 'UniformOutput', false);   
        end
        
        function [PValues, FormattedPValues] =  calculateMannWhitney(obj) 
            PValues =   cellfun(@(x) obj.getMannValue(x{1}, x{2}), obj.getCellListOfValues);
            
            
            FormattedPValues = getFormattedPValuesForValues(obj, PValues);
            text = sprintf('The following p-values were calculated with the Mann-Whitney test:\n') ;
          
            FormattedPValues = [text; FormattedPValues];
        end
        
        function  Value = getMannValue(~, ValuesOne, ValuesTwo)
            ValuesOne(isnan(ValuesOne), :) = [];
            ValuesTwo(isnan(ValuesTwo), :) = [];
            if isempty(ValuesOne) || isempty(ValuesTwo)
                Value = NaN;
            else
                Value = ranksum(ValuesOne,ValuesTwo);
            end
        end

        function FormattedPValues= getFormattedPValuesForPairedTTest(obj)
            FormattedPValues =           arrayfun(@(x) obj.formatSingleDataUnit({'%6.5f,'}, x), obj.calculatePairedTTest, 'UniformOutput', false);   
        end
        
        function PValues =  calculatePairedTTest(obj)
              [  VectorOne,  VectorTwo] =       cellfun(@(x) obj.equalizeVectorLength(x{1}, x{2}), obj.getCellListOfValues, 'UniformOutput', false);
              PValues =                         cellfun(@(x, y) ttest(x, y), VectorOne, VectorTwo);
        end
         
        function [VectorOne, VectorTwo] = equalizeVectorLength(obj, VectorOne, VectorTwo)
             if (length(VectorOne) < length(VectorTwo))
                  VectorTwo(length(VectorOne)+1:end,:) = [];
              elseif (length(VectorOne) > length(VectorTwo))
                  VectorOne(length(VectorTwo)+1:end,:) = [];
             end
        end
        
          
       

      
        
        %% get max
        function maxValues = getMaxOfPooledValues(obj)
             maxValues =         arrayfun(@(x) x.getMaxOfValuesPooledFromAllGroups, obj.GroupDataList, 'UniformOutput', false);   
        end
        
        function maxValues = getMinOfPooleValues(obj)
             maxValues =         arrayfun(@(x) x.getMinOfValuesPooledFromAllGroups, obj.GroupDataList, 'UniformOutput', false);   
        end
        
        
            %% get p-Values
         function Values = getPValuesInternal(obj, varargin)
             NumberOfArguments = length(varargin);
             switch NumberOfArguments
                 case 0
                     Values =  obj.calculateTTest;
                 case 1
                     assert(ischar(varargin{1}) , 'Wrong argument type.')
                     switch varargin{1}
                         case {'ttest', 't-test'}
                             Values =  obj.calculateTTest;
                         case {'MannWhitney', 'mannwhitney', 'Mann-Whitney', 'mann-whitney', 'Mann-Whitney test'}
                              Values =  obj.calculateMannWhitney;
                         otherwise
                             error('Statistics not supported')
                     end
                 otherwise
                     error('Wrong number of arguments.') 
             end
             
         end
        

         %% get formatters:
        function Formatters = getFormatters(obj) 
            switch obj.AddPValues
                case true
                     ValueFormatters =  arrayfun(@(x) '%6.0f, ', (1:obj.getNumberOfColumnsPerGroup)', 'UniformOutput', false);
                     Formatters =       [ValueFormatters; '%6.5f, '; ValueFormatters; '%6.5f'];
                     
                otherwise
                    ValueFormatters =   arrayfun(@(x) '%6.0f, ', (1:obj.getNumberOfColumnsPerGroup)', 'UniformOutput', false);
                    Formatters =        [ValueFormatters; ValueFormatters];
                    Formatters{end} =   '%6.0f';
            end
        end
        
        function numberOfColumns = getNumberOfColumnsPerGroup(obj)
            numberOfColumns = obj.getNumberOfTimePoints * obj.getNumberOfGroups;
        end
        
        function number = getNumberOfTimePoints(obj)
           number = size(obj.GroupDataList, 2);
        end
        
        function number = getNumberOfParameters(obj)
           number = size(obj.GroupDataList, 1); 
            
        end

    end
    
end

