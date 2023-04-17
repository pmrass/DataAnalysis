classdef PMWeightLossCurvesSeries
    %PMWEIGHTLOSSCURVESSERIES Summary of this class goes here
    % store and retrieve weight-loss data for multiple experiments;
    
    properties
        RawData
    end
    
    properties (Access = private)
        Folder
        
        ActiveExperiments
        ActiveGroups
        
        StartWeightLimit = 99
        TimeIndicesForFilteringSourceData % filters ata data-retrieval, e.g.: if starting from day 10: day 10 values are 100 % (not day 0);
        ActiveTimeIndices % only relevant when TimeIndicesForFilteringSourceData not selected;
        
    end
    
    properties (Constant, Access = private)
        FileName = 'WeightMeasurements.mat'
        ExperimentNameColumn = 1;
    end
    
    methods % initialization:
        
          function obj = PMWeightLossCurvesSeries(varargin)
            %PMWEIGHTLOSSCURVESSERIES Construct an instance of this class
            %   takes 0, 1, or 3 arguments:
            % 1: folder with source data
            % 2: active experiments: cell string with name of active experiments;
            % 3: active groups:  cell string with name of groups to show;
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 0
                case 1
                    obj.Folder =    varargin{1};
                    obj =           obj.initializeRawData;
                    
                case 3
                    obj.Folder =                varargin{1};
                    obj.ActiveExperiments  =    varargin{2};
                    obj.ActiveGroups  =         varargin{3};
                    
                    obj =                       obj.initializeRawData;
                    
                otherwise
                    error('Wrong number of arguments')
            end
            
          end
        
          
          function obj = set.Folder(obj, Value)
              assert(ischar(Value), 'Wrong input.')
             obj.Folder = Value; 
          end
          
        function obj = set.ActiveTimeIndices(obj, Value)
            assert(isnumeric(Value) && isvector(Value) , 'Wrong argument type')
            obj.ActiveTimeIndices =        Value;
        end
          
         function obj = set.ActiveExperiments(obj, Value)
            assert(iscell(Value) && isvector(Value) && iscellstr(Value), 'Wrong argument type')
            obj.ActiveExperiments =        Value;
         end
        
          function obj = set.ActiveGroups(obj, Value)
            assert(iscell(Value) && isvector(Value) && iscellstr(Value), 'Wrong argument type')
            obj.ActiveGroups =        Value;
        end
        
        function obj = set.RawData(obj, Value)
            assert(iscell(Value) && ismatrix(Value) && size(Value,2) == 2, 'Wrong argument type')
            obj.RawData =        Value;
        end
        
           function obj = set.TimeIndicesForFilteringSourceData(obj, Value)
            assert((isnumeric(Value) && isvector(Value)) || isempty(Value) , 'Wrong argument type')
            obj.TimeIndicesForFilteringSourceData =        Value;
        end
        
        
        
    end
    
    methods (Access = private) % initialization
        
        function obj = initializeRawData(obj)
            
            Result =        load([obj.Folder, '/', obj.FileName]);
            FieldName =     fieldnames(Result);
            assert(length(FieldName) == 1, 'Wrong file type')
            obj.RawData =   Result.(FieldName{1});
            obj =               obj.verifyExperimentNames;
            
        end
        
    end
    
    methods % summary:
        
        function Text = getSummary(obj)
            
            Text{1,1} = sprintf('\n*** This PMWeightLossCurvesSeries object has access to weight loss file "%s" in folder "%s".\n', obj.FileName, obj.Folder);
            Text = [Text; sprintf('\nIt will retrieve by default data from experiments:\n')];
           Text = [Text; cellfun(@(x) sprintf('%s\n', x), obj.ActiveExperiments(:), 'UniformOutput', false)];
           Text = [Text; sprintf('from time indices ')];
           Text = [Text; arrayfun(@(x) sprintf('%i ', x), obj.ActiveTimeIndices(:), 'UniformOutput', false)];
           Text = [Text; sprintf('\nand from active groups\n')];
           Text = [Text; cellfun(@(x) sprintf('%s\n', x), obj.ActiveGroups(:), 'UniformOutput', false)];
            
           if ~isempty(obj.TimeIndicesForFilteringSourceData)
              Text = [Text; sprintf('This object also has TimeIndicesForFilteringSourceData set at:\n')];
              Text = [Text; arrayfun(@(x) sprintf('%i ', x), obj.TimeIndicesForFilteringSourceData(:), 'UniformOutput', false)];
              Text = [Text; sprintf('\nThis will override the filtering by ActiveTimeIndices. This is somewhat overlapping and should be unified.\n')];
              
           end
           
           Text = [Text; sprintf('\nDetailed information about each group:\n')];
            curves = obj.getCurvesOfActiveExperiments;
           
           CurveText =   arrayfun(@(x) x.getSummary, curves(:), 'UniformOutput', false);
            Text = [Text; vertcat(CurveText{:})];
            ListWithExperimentNames = obj.getExperimentNames;
            
            Groups = cellfun(@(x) obj.getGroupsOfExperimentWithName(x), ListWithExperimentNames, 'UniformOutput', false);
            for index = 1 : length(Groups)
                GroupNames{index, 1} = cellfun(@(x) x.Name, Groups{index}, 'UniformOutput', false);
                
                Text = [Text;  sprintf('\nExperiment "%s":\n', ListWithExperimentNames{index})];
                Text = [Text;  cellfun(@(x) sprintf('%s\n', x), GroupNames{index, 1}, 'UniformOutput', false)];
                
            end
            
        end
        
        function obj = showSummary(obj)
           
         
        end
        
    end
     
    methods % SETTERS EXPERIMENTS:
        
        function obj =              addNewExperiment(obj)
        RowOfNewExperiment=                                     size(obj.RawData,1)+1;
        obj.RawData{RowOfNewExperiment,1}=                       ['Experiment ' num2str(RowOfNewExperiment)];
        obj.RawData{RowOfNewExperiment,2}.StructureWithData=     obj.Experiment_Create;

        end

        function [StructureWithData]=   Experiment_Create(obj)
        %EXPERIMENT_CREATE Summary of this function goes here
        %   Detailed explanation goes here
        StructureWithData.Groups{1, 1}.Name=            obj.getDefaultGroupNameForGroupNumber(1);
        StructureWithData.Groups{1, 1}.Data=            obj.getDefaultGroupData;

        end

        function obj =              deleteExperimentWithIndex(obj, index)
        obj.RawData(index, :)=        [];

        end

        function obj =              setNameOfExperimentWithNameTo(obj, Name, NewName)
        assert(ischar(Name) && ischar(NewName), 'Wrong input type')
        obj.RawData{obj.getIndexOfExperimentName(Name), 1}=      NewName;

        end

        function obj =              setNameOfExperimentWithIndexTo(obj, Index, NewName)
        assert(ischar(NewName), 'Wrong input type')
        obj.RawData{Index, 1}=      NewName;

        end
  
    end
    
    methods % setters groups:
        
        function obj = addGroupToExperimentWithName(obj, Name)
            NumberOfGroupsBeforeAdding = obj.getNumberOfGroupsForExperimenWithName(Name);
            obj.RawData{obj.getIndexOfExperimentName(Name), 2}.StructureWithData.Groups{NumberOfGroupsBeforeAdding + 1, 1}.Name=            obj.getDefaultGroupNameForExperimentWithName(Name);
            obj.RawData{obj.getIndexOfExperimentName(Name), 2}.StructureWithData.Groups{NumberOfGroupsBeforeAdding + 1, 1}.Data=            obj.getDefaultGroupData;
            
        end
         
    end
    
    methods % setters group names
        
        function obj = setGroupsOfExperimentWithName(obj, Name, groups)
           obj = obj.setGroupsOfExperimentWithIndex(obj.getIndexOfExperimentName(Name), groups);
           
        end
        
         function obj = setGroupNamesOfExperimentWithName(obj, Name, Value)
            assert(iscellstr(Value), 'Wrong input type')
            assert(length(Value) == obj.getNumberOfGroupsForExperimenWithName(Name), 'Mismatch with group number')
            for Index = 1:obj.getNumberOfGroupsForExperimenWithName(Name)
                obj.RawData{obj.getIndexOfExperimentName(Name), 2}.StructureWithData.Groups{Index, 1}.Name = Value{Index};
            end
            
         end
        
        
    end
    
    methods % SETTERS
          
        function obj = setTimeIndicesForFilteringSourceData(obj, Value)
            obj.TimeIndicesForFilteringSourceData = Value;
            
        end

        function obj = setActiveTimeIndices(obj, Value)
            obj.ActiveTimeIndices =        Value;
            
        end
                
         function obj = setActiveExperiments(obj, Value)
            obj.ActiveExperiments =        Value;
            
        end
        
        function obj = setActiveGroups(obj, Value)
            obj.ActiveGroups =        Value;
            
        end
        
    end
    
    methods % GETTERS: BASIC
        
        function rawData =      getRawData(obj)
            rawData = obj.RawData;
        end
        
        function groups =       getGroupsOfExperimentWithName(obj, Name)
            % GETGROUPSOFEXPERIMENTWITHNAME get groups cell array with group names and group weight matrices;
            groups = obj.getGroupsForIndex(obj.getIndexOfExperimentName(Name));
        end
         
        function rawData =      getRawDataForExperimentName(obj, Name)
            % GETRAWDATAFOREXPERIMENTNAME get groups cell array with group names and group weight matrices;
            % seems same like getGroupsOfExperimentWithName;
            row =           obj.getIndexOfExperimentName(Name);
            if isempty(row)
                rawData = '';
            else
                rawData =       cellfun(@(x) x.Data, obj.RawData{row, 2}.StructureWithData.Groups, 'UniformOutput', false); 
            end
        end
                
        function experimentNames = getExperimentNames(obj)
            % GETEXPERIMENTNAMES returns cell-string array with experiment names;
            experimentNames =   obj.RawData(:,obj.ExperimentNameColumn);
        end
        
        function Names =        getNamesOfAllExperiments(obj)
            % GETNAMESOFALLEXPERIMENTS returns cell-string array with experiment names;
            % same like getExperimentNames;
            Names = getNamesOfAllExperimentsInternal(obj);
        end

        function Names =        getGroupNamesForIndex(obj, row)
            Names = getGroupNamesForIndexInternal(obj, row);
        end
        
    end
    
    methods % GETTERS
        
        function GroupName = getDefaultGroupNameForExperimentWithName(obj, Name)
            rows =          obj.getNumberOfGroupsForExperimenWithName(Name);
            GroupName =     obj.getDefaultGroupNameForGroupNumber(rows + 1);
        end
        
        function NumberOfGroups = getNumberOfGroupsForExperimenWithName(obj, Name)    
             NumberOfGroups =    length(obj.RawData{obj.getIndexOfExperimentName(Name), 2}.StructureWithData.Groups);    
         end
        
        function GroupName = getDefaultGroupNameForGroupNumber(~, Number)
             GroupName = ['Group '  num2str(Number)];
        end
        
        function data =  getDefaultGroupData(obj)
            data =  [20 NaN; NaN NaN];
        end
        
        function curves = getCurvesOfActiveExperiments(obj)
            curves = obj.getCurvesOfExperiments(obj.ActiveExperiments);
        end
        
        
    end
    
    methods % GETTERS DATA TABLES
        
       
         function weightLossExportData =        getWeightPercentageTableOfExperimentAndGroups(obj, ExperimentName, GroupNames)
                % GETACTIVEWEIGHTPERCENTAGETABLE get cell with weight-percentages for each active group;
                % returns cell for each group:
                % each cell contains another cell with the following content:
                % column 1: time-value in each row;
                % column 2: list of percentage-values for each mouse for the different time-points;

                weightLossExportData = obj.getWeightPercentageTableOfExperimentAndGroupsInternal(ExperimentName, GroupNames);
            
          end
        
        function weightLossExportData =         getActiveWeightPercentageTable(obj)
            % GETACTIVEWEIGHTPERCENTAGETABLE 
            weightLossExportData =  obj.getWeightPercentageTableOfExperimentAndGroups(obj.ActiveExperiments, obj.ActiveGroups);
        end
        
        function curves =                       getCurvesOfExperiment(obj, Name)
            curves = obj.getCurvesOfExperimentInternal(Name);
        end
         
        function percentagesChanges =           getPercentagesChangesAfterIndex(obj, Index)
            
            
             weightLossExportData =  obj.getWeightPercentageTableOfExperimentAndGroups(obj.ActiveExperiments, obj.ActiveGroups);
            
             PercentageChange = obj.getPercentageChangeFromPercDataAferIndex( Data, Index);
            
        end
        
        function weightLossExportData =         getActiveWeightPercentageTableRequirePercLossAfterIndex(obj, RequiredPercentage, StartDay)
        weightLossExportData =  obj.getWeightPercentageTableOfExperimentAndGroups(obj.ActiveExperiments, obj.ActiveGroups);
        weightLossExportData = cellfun(@(x) obj.keepOnlyDataWithPercLossFromDay(x, RequiredPercentage, StartDay), weightLossExportData, 'UniformOutput', false);

        end

        function weightLossExportData =         getActiveWeightPercentageTableRequirePercGainAfterIndex(obj, RequiredPercentage, StartDay)
        weightLossExportData =  obj.getWeightPercentageTableOfExperimentAndGroups(obj.ActiveExperiments, obj.ActiveGroups);
        weightLossExportData = cellfun(@(x) obj.keepOnlyDataWithPercGainFromDay(x, RequiredPercentage, StartDay), weightLossExportData, 'UniformOutput', false);

        end

        function matrices =                     getWeightPercentagesAsMatrix(obj)
        matrices = cellfun(@(x) cell2mat(x), obj.getWeightPercentages, 'UniformOutput', false);
        end
             
        function percentages =                  getPercentageTableOfRecoveredMice(obj)
            % GETPERCENTAGETABLEOFRECOVEREDMICE: get percentages of mice that have recovered the starting weight for each time-point;
            % returns a cell-array vector with each cell containing data for one group;
            % each cell contains another cell with two columns:
            % column 1: time-point
            % column 2: percentage of mice in this group that have weight >= starting weight;
           percentages = obj.getPercentageTableOfRecoveredMiceForExperimentAndGroups(obj.ActiveExperiments, obj.ActiveGroups);
        end
          
    end
    
  
    
    methods % GETTERS P-VALUES
        
        function PValues =          getPValuesBetweenWeightPercentageTables(~, Table)
            % GETPVALUESBETWEENWEIGHTPERCENTAGETABLES p-value between two weight-loss curves;
            % takes 1 argument: 
            % 1: a cell vector with weight contents as you would get with "getWeightPercentageTableOfExperimentAndGroups";
            % returns vector of p-values;
            assert(iscell(Table) && isvector(Table) && length(Table) == 2, 'Cannot perform statistics analysis on input data')
            [~, PValues] =              cellfun(@(x, y) ttest2(x, y), Table{1}(:, 2), Table{2}(:, 2));
        end

        function pValues =          getPValuesForWeightRecovery(obj)
            % GETPVALUESFORWEIGHTRECOVERY: get p-values for weight recovery when comparing two different groups;
            % returns vector of p-value numbers; obtained by comparing
            % numbers of recovered mice with Fisher's test;
            pValues =      obj.getPValuesForWeightRecoveryForExperimentsAndGroups(obj.ActiveExperiments, obj.ActiveGroups);
        end
        
        function statistics =       getTwoWayAnovaStatistics(obj)
           PercentageMatrices = obj.getWeightPercentagesAsMatrix;
           statistics =    PMTwoWayAnova(PercentageMatrices).getStatistics;
        end
            
    end
    
    methods % weight gains
        
          function percentages = getPercentageOfRecoveredMice(obj)
            percentages = getPercentageOfRecoveredMiceForExperimentAndGroups(obj, obj.ActiveExperiments, obj.ActiveGroups);
            
        end
          
    end
    
    
    methods (Access = private) % weight change between two days:
        
          function Results = getDayWhenRegainingStartWeightFromDay(obj, DayLimit)
            % GETDAYWHENREGAININGSTARTWEIGHTFROMDAY: get day when first reaching start-weight;
            % input: daylimit (do not look for weight recovery before that);
            % returns: cell with cell-elment for each group:
            % each of these cell elements contains a number vector with the day when the start weight was recovered:
            Results = getDayWhenRegainingStartWeightForExperimentAndGroups(obj, obj.ActiveExperiments, obj.ActiveGroups, DayLimit);
          end
        
        
    end
    
    methods (Access = private) % weight-loss percentages:
        
         function Data = keepOnlyDataWithPercLossFromDay(obj, Data, RequiredPercentage, Index)
                PercentageChange =      obj.getPercentageChangeFromPercDataAferIndex(Data, Index);
                AcceptedColumns =       PercentageChange < RequiredPercentage;
                Data(:, 2) =            obj.getPercentagesToPutBackInTableForFilter(Data, AcceptedColumns);
                
         end
            
        function Data = keepOnlyDataWithPercGainFromDay(obj, Data, RequiredPercentage, Index)
           
            PercentageChange =  obj.getPercentageChangeFromPercDataAferIndex(Data, Index);
            AcceptedColumns =   PercentageChange > RequiredPercentage;
            Data(:, 2) =        obj.getPercentagesToPutBackInTableForFilter(Data, AcceptedColumns);
            
        end
         
         function PercentageChange = getPercentageChangeFromPercDataAferIndex(~, Data, Index)
                PercentageData =        cell2mat(Data(:, 2));
                ValuesOfInterest =      PercentageData(Index : Index + 1, :);
                PercentageChange =      ValuesOfInterest(2, :) - ValuesOfInterest(1, :);
                
         end
         
          function PercentagesToPutBackInTable = getPercentagesToPutBackInTableForFilter(~, Data, AcceptedColumns)
            PercentageData =                cell2mat(Data(:, 2));
            AcceptedPercentageData =        PercentageData(:, AcceptedColumns);
            PercentagesToPutBackInTable =   arrayfun(@(x) AcceptedPercentageData(x, :), (1 : size(AcceptedPercentageData, 1))', 'UniformOutput', false);
            
            
          end
        
        
          
        
          
         
    end
    
     methods (Access = private) % setters group names
         function obj = setGroupsOfExperimentWithIndex(obj, index, groups)
            assert(isnumeric(index) && isscalar(index), 'Wrong argument type.')
            obj.RawData{index, 2}.StructureWithData.Groups = groups;
            
         end
        
     end
    
    methods (Access = private) % GETTERS  getWeightPercentageTableOfExperimentAndGroupsInternal
        
          function PercentageTablesForSelectedGroups = getWeightPercentageTableOfExperimentAndGroupsInternal(obj, ExperimentName, GroupNames)
                % GETWEIGHTPERCENTAGETABLEOFEXPERIMENTANDGROUPSINTERNAL get specified percentage tables;
                % takes 2 arguments:
                % 1: experiment names (cell-string vector);
                % 2: group names (cell-string vector);
                % returns cell-vector with each cell containing:
                % a cell matrix with two columns:
                % column 1: number of selcted days
                % column 2: vector with percentage weights of each mouse;
                
                assert(isvector(ExperimentName) && iscellstr(ExperimentName), 'Wrong input.')
                assert(isvector(GroupNames) && iscellstr(GroupNames), 'Wrong input.')
                
                
                WeightLossCurvesPerGroup =         obj.getCurvesOfExperiments(ExperimentName);

                 PercentageTablesForSelectedGroups =     cell(length(GroupNames), 1);
                 for GroupIndex = 1: length(GroupNames)

                    WeightlossCurveOfCurrentGroup =        obj.selectCurveByName(WeightLossCurvesPerGroup, GroupNames{GroupIndex}); 
                    PercentageTableOfCurrentGroup =        WeightlossCurveOfCurrentGroup.getPercentageWeightList;
                    
                    if isempty(obj.ActiveTimeIndices) || ~isempty(obj.TimeIndicesForFilteringSourceData)
                        FilteredPercentageTableOfCurrentGroup =          PercentageTableOfCurrentGroup; 
                    else
                        FilteredPercentageTableOfCurrentGroup =           PercentageTableOfCurrentGroup(obj.ActiveTimeIndices, :);
                    end

                    PercentageTablesForSelectedGroups{GroupIndex, 1} = FilteredPercentageTableOfCurrentGroup;
                 end
          end
        
          function WeightlossCurveOfCurrentGroup = selectCurveByName(obj, WeightLossCurvesPerGroup, MyWantedGroupName)
                ListWithGroupNames =        arrayfun(@(x) x.getName, WeightLossCurvesPerGroup, 'UniformOutput', false);
                    currentRow =                strcmp(ListWithGroupNames, MyWantedGroupName);

                    assert(sum(currentRow) == 1, 'No unique match found.')

                    WeightlossCurveOfCurrentGroup =    WeightLossCurvesPerGroup(currentRow);
          end
        
        
    end
    
    methods (Access = private) % GETTERS
        
        %% verifyExperimentNames:
        function obj = verifyExperimentNames(obj)
            assert(iscellstr(obj.RawData(:,obj.ExperimentNameColumn)), 'Wrong type')
            UniqueNames = unique(getExperimentNames(obj));
            assert(length(UniqueNames) == length(getExperimentNames(obj)), 'Wrong type')
        end
        
        
        function percentages = getWeightPercentages(obj)
            percentages =      obj.getWeightPercentageOfExperimentAndGroups(obj.ActiveExperiments, obj.ActiveGroups);
            
        end
        
         
        
        function weightLossExportData = getWeightPercentageOfExperimentAndGroups(obj, ExperimentName, GroupNames)

            WeightLossCurves =      obj.getCurvesOfExperiments(ExperimentName);

            weightLossExportData =       cell(length(GroupNames), 1);
            for GroupIndex = 1: length(GroupNames)
                currentRow =                strcmp(arrayfun(@(x) x.getName, WeightLossCurves, 'UniformOutput', false), GroupNames{GroupIndex});
                WeightlossCurveOfCurrentGroup =    WeightLossCurves(currentRow);
                
                PercentageTable =                        WeightlossCurveOfCurrentGroup.getPercentageWeightsInCell;
                  if isempty(obj.ActiveTimeIndices) || ~isempty(obj.TimeIndicesForFilteringSourceData)
                else
                    PercentageTable = PercentageTable(obj.ActiveTimeIndices, :);
                  end
                
                weightLossExportData{GroupIndex, 1} = PercentageTable;
            end
            
        end
        
        
     
        
      
        
        
        function curves = getCurvesOfExperiments(obj, ExperimentNames)
            % GETCURVESOFEXPERIMENTS returns vector of PMWeightLossCurves
            % takes 1 argument: character string or cell string with names of experiments;
            % each group is represented by one PMWeightLossCurves

            if ischar(ExperimentNames)
                curves = getCurvesOfExperimentInternal(obj, ExperimentNames);

            elseif iscellstr(ExperimentNames)
                GroupNamesPerExp = obj.getGroupNamesOfExperimentsWithNames(ExperimentNames);
                assert(min(cellfun(@(x) isequal(x, GroupNamesPerExp{1}), GroupNamesPerExp)), 'In order to combine all group names must be identical')
                curvesPerExperiment = cellfun(@(x) obj.getCurvesOfExperimentInternal(x), ExperimentNames, 'UniformOutput', false);
                curves  = obj.poolCurvesList(curvesPerExperiment);

            else
                error('Wrong input')
            end

        end
        
        function curves = getCurvesOfExperimentInternal(obj, Name)

            TimeSeries =        obj.getTimeSeriesForIndex(obj.getIndexOfExperimentName(Name));
            WeightData =        obj.getWeightDataForIndex(obj.getIndexOfExperimentName(Name));
            Names =             obj.getGroupNamesForIndexInternal( obj.getIndexOfExperimentName(Name));

            if isempty(obj.TimeIndicesForFilteringSourceData)
                curves =            cellfun(@(x, y, z) PMWeightLossCurves(x, y, z), Names, TimeSeries, WeightData); 

            else
                
                try
                 curves =            cellfun(@(x, y, z) ...
                                    PMWeightLossCurves(x, y(obj.TimeIndicesForFilteringSourceData, :), ...
                                    z(obj.TimeIndicesForFilteringSourceData, :)), ...
                                    Names, TimeSeries, WeightData); 
                catch
                   error('Something went wrong.') 
                end

            end
            
        end
        
        function TimeSeries =   getTimeSeriesForIndex(obj, row)
            WeightData =        obj.getWeightDataForIndex(row);
            TimeSeries =         cellfun(@(x) (0:size(x,1)-1)',   WeightData, 'UniformOutput', false);
        end
        
        function row = getIndexOfExperimentName(obj, Name) 
            experimentNames =   obj.getExperimentNames;
            row =               find(strcmp(experimentNames, Name));
            try
            assert(~isempty(row), 'No matches found.')
            catch
               error('Something went wrong.') 
            end
        end

        function WeightData =   getWeightDataForIndex(obj, row)
            WeightData =       cellfun(@(x) x.Data(1:end-1, 1:end-1), obj.RawData{row, 2}.StructureWithData.Groups, 'UniformOutput', false); 
        end

        function Names = getNamesOfAllExperimentsInternal(obj)
              Names =       obj.RawData(:,1);
        end
        
        function GroupNames = getGroupNamesOfExperimentsWithNames(obj, ExperimentNames)
            GroupNames = cellfun(@(x) obj.getGroupNamesForIndexInternal(obj.getIndexOfExperimentName(x)), ExperimentNames, 'UniformOutput', false);
        end
        
         function Names = getGroupNamesForIndexInternal(obj, row)
              Names =       cellfun(@(x) x.Name, obj.getGroupsForIndex(row), 'UniformOutput', false); 
        end
        
        function groups = getGroupsForIndex(obj, row)
            % GETGROUPSFORINDEX returns a cell vector with group-data structures;
            % structure: contains Name field with name and Data field with a numerical matrix with actual data;
            assert(isnumeric(row) && isscalar(row), 'Wrong argument type.')
            groups = obj.RawData{row, 2}.StructureWithData.Groups;
        end
        
        
        function curves = poolCurvesList(~, listOfCurvesPerExperiment)
            
            % this was written quickly: improve when you have time:;
            NumberOfGroups =    length(listOfCurvesPerExperiment{1});
           
            
            for GroupIndex = 1 : NumberOfGroups
                
                 TimeListForCurrentGroup =          listOfCurvesPerExperiment{1}(GroupIndex).TimeList;
             
               NamesPerExperimentForCurrentGroup =  cellfun(@(x) x(GroupIndex).getName, listOfCurvesPerExperiment, 'UniformOutput', false);
               CurrentGroupName =                  unique(NamesPerExperimentForCurrentGroup);
               assert(length(CurrentGroupName) == 1, 'Group name mismatch')
               
               WeightDataPerExperiment_CurrentGroup = cellfun(@(x) x(GroupIndex).getWeightList, listOfCurvesPerExperiment', 'UniformOutput', false);
               ConcatenatedWeightList = WeightDataPerExperiment_CurrentGroup{1}; % start with experiment 1:
               for expIndex = 2: length(WeightDataPerExperiment_CurrentGroup)
                   NewGroupDataForCurrentExp = WeightDataPerExperiment_CurrentGroup{expIndex};
                   ConcatenatedWeightList(...
                       1: size(NewGroupDataForCurrentExp, 1), ...
                       size(ConcatenatedWeightList, 2) + 1 : size(ConcatenatedWeightList, 2) +  size(NewGroupDataForCurrentExp, 2)) = NewGroupDataForCurrentExp;
               end
               ConcatenatedWeightList(ConcatenatedWeightList == 0 ) = NaN;
               
               curves(GroupIndex, 1) = PMWeightLossCurves(CurrentGroupName{1}, TimeListForCurrentGroup, ConcatenatedWeightList);
            end    
        end
        
        %% getPercentageTableOfRecoveredMiceForExperimentAndGroups:
        function percentages = getPercentageTableOfRecoveredMiceForExperimentAndGroups(obj, ExperimentName, GroupNames)
            percentageWeights =      obj.getWeightPercentageOfExperimentAndGroups(ExperimentName, GroupNames);
            percentages =            cellfun(@(x) obj.getPercentageTableOfRecoveredMiceForPercentageWeights(x), percentageWeights, 'UniformOutput', false);
        end
        
        function result = getPercentageTableOfRecoveredMiceForPercentageWeights(obj, percentages)
            numberRecovered =       obj.getNumberOfRecoveredMiceForPercentages(percentages);
            numberNotRecovered =    obj.getNumberOfNotRecoveredMiceForPercentages(percentages);
            percentages =           numberRecovered ./ (numberRecovered  + numberNotRecovered) * 100;
            result(:, 2) =          percentages;
            result(:, 1) =          0 : size(percentages, 1) - 1;
            result =                num2cell(result); % has to be cell so that it can be read by XYData class;
        end
        
        function numbers = getNumberOfRecoveredMiceForPercentages(obj, percentages)
            numbers =       cellfun(@(x) sum(x >= obj.StartWeightLimit), percentages);
        end

        function numbers = getNumberOfNotRecoveredMiceForPercentages(obj, percentages)
            numbers =      cellfun(@(x) sum(x < obj.StartWeightLimit), percentages);
        end
        

        %% get percentage of mice recovered:
        
      
        
        
        function percentages = getPercentageOfRecoveredMiceForExperimentAndGroups(obj, ExperimentName, GroupNames)
            percentageWeights =      obj.getWeightPercentageOfExperimentAndGroups(ExperimentName, GroupNames);
            percentages =            cellfun(@(x) obj.getPercentageOfRecoveredMiceForPercentageWeights(x), percentageWeights, 'UniformOutput', false);
            
        end
        
        function percentages = getPercentageOfRecoveredMiceForPercentageWeights(obj, percentages)
            numberRecovered =       obj.getNumberOfRecoveredMiceForPercentages(percentages);
            numberNotRecovered =    obj.getNumberOfNotRecoveredMiceForPercentages(percentages);
            percentages =          numberRecovered ./ (numberRecovered  + numberNotRecovered) * 100;
        end
        
        %% getPValuesForWeightRecoveryForExperimentsAndGroups:
        function pValues = getPValuesForWeightRecoveryForExperimentsAndGroups(obj, ExperimentName, GroupNames)
            percentageWeights =      obj.getWeightPercentageOfExperimentAndGroups(ExperimentName, GroupNames);
            numbersRecovered =       cellfun(@(x) obj.getNumberOfRecoveredMiceForPercentages(x), percentageWeights, 'UniformOutput', false);
            numbersNotRecovered =    cellfun(@(x) obj.getNumberOfNotRecoveredMiceForPercentages(x), percentageWeights, 'UniformOutput', false);
            
            tables =    arrayfun(@(group1rec, group1not, group2rec, group2not) ... 
                obj.generateTwoWayTable(group1rec, group1not, group2rec, group2not), ...
                numbersRecovered{1}, numbersNotRecovered{1}, numbersRecovered{2}, numbersNotRecovered{2}, 'UniformOutput', false);
              [~, pValues, ~] =           cellfun(@(x) fishertest(x),  tables);
            
        end
        
        function myTable = generateTwoWayTable(~, Group1Recovered, Group1NotRecovered, Group2Recovered, Group2NotRecovered)
             myTable =               table([Group1Recovered; Group1NotRecovered],[Group2Recovered; Group2NotRecovered],'VariableNames',{'Group 1', 'Group 2'},'RowNames',{'Recovered','NotRecovered'});   
        end
        
        %% getDayWhenRegainingStartWeightForExperimentAndGroups:
        function Results = getDayWhenRegainingStartWeightForExperimentAndGroups(obj, ExperimentName, GroupNames, DayLimit)
            percentageWeights =      obj.getWeightPercentageOfExperimentAndGroups(ExperimentName, GroupNames);
            
            NumberOfGroups = length(percentageWeights);
            Results = cell(NumberOfGroups, 1);
            for GroupIndex = 1:NumberOfGroups
                
                CurrentGroupWeights = percentageWeights{GroupIndex};
                AcceptedWeights =   CurrentGroupWeights(DayLimit + 1: end, 1);
                AcceptedWeights =       cell2mat(AcceptedWeights);
  
                NumberOfMice = size(AcceptedWeights, 2);
                ResultsForCurrentGroup = zeros(NumberOfMice, 1);
                for MouseIndex = 1:NumberOfMice
                    CurrentMouseWeights = AcceptedWeights(:, MouseIndex);
                    RowExceedingLimit = find(CurrentMouseWeights >= obj.StartWeightLimit, 1, 'first');
                    if isempty(RowExceedingLimit)
                        ResultsForCurrentGroup(MouseIndex, 1) = length(AcceptedWeights)+ DayLimit;
                    else
                        ResultsForCurrentGroup(MouseIndex, 1) = RowExceedingLimit + DayLimit - 1;
                    end
                end
                Results{GroupIndex, 1} = ResultsForCurrentGroup;
            end
        end
        
        
        
        
        
        
        
      
        
        
       
        
        
       

      
   
     
        
        %% get group names:
        
        
    end
    
    
end

