classdef PMGroupSpreadsheet
    %PMGROUPSPREADSHEET object takes a spreadsheet plus information about the spreadsheet;
    %   can return a PMGroupStatisticsList object based on this spreadsheet;
    
    properties (Access = private)
        Spreadsheets
        
        DataTypeCodes
        
        GroupNames
        GroupRows
        
        ParameterTitles
        
        TimeTitles
    end
    
    properties (Access = private) % derivative
        GroupStatisticsList
        
    end
    
    methods %  initialization
        function obj = PMGroupSpreadsheet(varargin)
            %PMGROUPSPREADSHEET Construct an instance of this class
            %  takes 6 arguments;
            % 1: spreadsheet with numbers; each row: sample; each column: different parameters; input is either one spreadsheet or multiple spreadsheets for time series;
            % 2: GroupRows: cell-array; each cell contains numeric vector with number of rows in spread-sheet that corresponds to different groups;
            % 3: cell-string with names for each group
            % 4: cell-string with data-type codes: usually this is the name/date of a specific experiment;
            % 5: 5: cell-string with row titles
            % 6: 6: time-titles (can be empty when the data are not a time-course);
            NumberOfArguments= length(varargin);
            switch NumberOfArguments

            case 6
                
                obj.Spreadsheets =          varargin{1};
                obj.TimeTitles  =           varargin{6};
                obj.GroupRows =             obj.getGroupDescriptorsForInput( varargin{2});
                obj.GroupNames =            varargin{3};
                obj.DataTypeCodes =         varargin{4};
                obj.ParameterTitles =       varargin{5};
               
                obj =                       obj.verifyProperties;
                
            otherwise
                error('Wrong input.')

            end
            
            obj = obj.generateGroupRowsIfEmpty;
        end

        function obj = set.Spreadsheets(obj, Value)
            if isnumeric(Value)
                Value = {Value};
            end
            assert(iscell(Value), 'Wrong input.')
            obj.Spreadsheets = Value;
        end

        function obj = set.GroupRows(obj, Value)
            assert(iscell(Value), 'Wrong input.')
            obj.GroupRows = Value;
        end

        function obj = set.GroupNames(obj, Value)
            assert(iscellstr(Value) && isvector(Value), 'Wrong input.')
            obj.GroupNames = Value;
        end

        function obj = set.DataTypeCodes(obj, Value)
            assert(iscellstr(Value) && isvector(Value) , 'Wrong input.')
            obj.DataTypeCodes = Value;
        end
        
    end
    
    methods % summary;
        
         function obj = showSummary(obj)
            % SHOWSUMMARY prints summarized contents into console;
            fprintf('This group-spreadsheet is entitled "%s."\n', obj.getTitleFromDataCodes)
            fprintf('It has %i groups and %i parameters.\n', obj.getNumberOfGroups, obj.getNumberOfParameters)
            fprintf('The names of the groups are:\n')
            cellfun(@(x) fprintf('%s\n', x), obj.GroupNames)
            fprintf('\nThe names of the parameters are:\n')
            cellfun(@(x) fprintf('%s\n', x), obj.ParameterTitles)
        end
        
    end
    
    methods % getters
     

        function myGroupListStatistics = getGroupListStatistics(obj)
            % GETGROUPLISTSTATISTICS returns PMGroupStatisticsList;
            VectorWithGroupStatistics =                    obj.getGroupStatisticsVector;
            if iscell(VectorWithGroupStatistics)
                VectorWithGroupStatistics =     horzcat(VectorWithGroupStatistics{:});
                 obj.GroupStatisticsList =       PMGroupStatisticsList(VectorWithGroupStatistics, 'Time course');
            else
                obj.GroupStatisticsList =       PMGroupStatisticsList(VectorWithGroupStatistics, obj.getTitleFromDataCodes);
            end
            
            obj =                           obj.setRowTitlesIfEmpty(obj.ParameterTitles);
            obj.GroupStatisticsList =       obj.GroupStatisticsList.setTimeTitles(obj.TimeTitles);
            myGroupListStatistics =         obj.GroupStatisticsList;    
        end
        
       
        
    end
    
    methods(Access = private)
        
      
        function obj = verifyProperties(obj)
        %    obj.showSummary
            NumberOfSpreadSheets = obj.getNumberOfSpreadSheets;
            assert(length(obj.Spreadsheets) == length(obj.GroupRows), 'Properties are invalid. The number of spreadsheets and the number of group-row lists does not match.')
            
            for index = 1 : NumberOfSpreadSheets
                try
                   assert(size(obj.Spreadsheets{index}, 2) == length(obj.ParameterTitles), 'Properties are invalid. The number of columns in the spreadsheet does not match the number of parameters.')
                   assert(length(obj.GroupRows{index}) == length(obj.GroupNames), 'Properties are invalid.The number of group-rows and group-names does not match.')
                catch
                   error('test') 
                end
            end
            
        end
     
        
         function obj = generateGroupRowsIfEmpty(obj) % this is dangerous; 
             
             if obj.getNumberOfGroups == 1 && isempty(obj.GroupRows)
                   obj.GroupRows =     arrayfun(@(x) (1 : obj.getNumberOfRows)', (1 : obj.getNumberOfSpreadSheets)', 'UniformOutput', false);
             else
                 
                 for indexSpread = 1 : obj.getNumberOfSpreadSheets
                     for index = 1 : obj.getNumberOfGroups

                    if isempty(obj.GroupRows{indexSpread}{index})
                        obj.GroupRows{indexSpread}{index} = NaN;
                    end
                end
                     
                     
                 end
                
                 
                 
             end
             
            
    
         end
        
        
         
        function number = getNumberOfGroups(obj)
            number = length(obj.GroupNames);
        end
        
        function number = getNumberOfParameters(obj)
            number = length(obj.ParameterTitles);
        end
        
        
        
        
        
        %% get group rows cell (for each spreadsheet):
        function  [GroupRowsCell] = getGroupDescriptorsForInput(obj, GroupRows)
            % GETGROUPDESCRIPTORSFORINPUT finalizes group rows for input;
            % if group-rows are empty: create rows for all content ("one" group);
            % if time-titles are empty: multiply group-rows for each spreadsheet (they are supposed to be identical); it seems this is just to convert it into a cell;
            if isempty(GroupRows)
                GroupRowsCell = obj.generateDefaultGroupsRowsForTimeSeries;
                
            else
                if isempty(obj.TimeTitles)
                    GroupRowsCell =     arrayfun(@(x) GroupRows, (1 : obj.getNumberOfSpreadSheets)', 'UniformOutput', false);
                else
                    GroupRowsCell = GroupRows;
                end
            end

        end
        
         function GroupRowsCell = generateDefaultGroupsRowsForTimeSeries(obj)
              GroupRowsCell =   arrayfun(@(x) obj.generateDefaultGroupRows, (1 : obj.getNumberOfSpreadSheets)', 'UniformOutput', false);        
         end
        
         function number = getNumberOfSpreadSheets(obj)
             number = length(obj.Spreadsheets);
         end
     
        function GroupRows = generateDefaultGroupRows(obj) 
            GroupRows = (1 : obj.getNumberOfRows)';
        end
        
        function rows = getNumberOfRows(obj)
            rows = size(obj.Spreadsheets{1}, 1);
        end
        

        function groupLists = getGroupStatisticsVector(obj)
            
            
            if length(obj.Spreadsheets) == 1
                groupLists = (cellfun(@(x, y) obj.convertSpreadsheetIntoVectorWithGroupStatistics(x, y, obj.GroupNames), obj.Spreadsheets, obj.GroupRows, 'UniformOutput', false))';
                groupLists = groupLists{1};
            else
                groupLists = (cellfun(@(x, y) obj.convertSpreadsheetIntoVectorWithGroupStatistics(x, y, obj.GroupNames), obj.Spreadsheets, obj.GroupRows, 'UniformOutput', false))';
               
            end

        end
        
         function GroupStatisticsList = convertSpreadsheetIntoVectorWithGroupStatistics(obj, DataSpreadsheet, GroupRows, GroupNames)
            ListWithDataContainersForEachGroup =        obj.transferDataFromSpreadsheetIntoDataContainers( DataSpreadsheet, GroupRows);
            GroupStatisticsList=                        cellfun(@(x) PMGroupStatistics(x, GroupNames), ListWithDataContainersForEachGroup);     
        end
        
       
        
        function dataContainersForCurrentGroup = transferDataFromSpreadsheetIntoDataContainers(obj, Spreadsheet, RowsForDifferentGroups)
            
            assert(isnumeric(Spreadsheet) && ismatrix(Spreadsheet) , 'Wrong input')
            assert(iscell(RowsForDifferentGroups), 'Wrong input.')
            cellfun(@(x) assert(isnumeric(x) && isvector(x), 'Wrong input.'), RowsForDifferentGroups)
            
            
            dataContainersForCurrentGroup = cell(size(Spreadsheet, 2), 1);
            
            for DataTypeIndex = 1 : size(Spreadsheet, 2)
             
                for groupIndex = 1 : length(RowsForDifferentGroups)
                    
                    CurrentGroupRows =     RowsForDifferentGroups{groupIndex};
                    if isnan(CurrentGroupRows)
                        CurrentData =   NaN;
                    else
                         CurrentData =           Spreadsheet(CurrentGroupRows, DataTypeIndex);
                    end
                   
                    dataContainersForCurrentGroup{DataTypeIndex, 1}(groupIndex, 1) =                PMDataContainer(CurrentData); 
                    
                end
                  
            end
        end
        
        
              %% get title from data-codes:
        function Title = getTitleFromDataCodes(obj)
            Title =         obj.DataTypeCodes;
            Title =         (Title(:))';
            Title =         [Title{:}];
        end

         
         function obj = setRowTitlesIfEmpty(obj, rowTitles)
             if ~isempty(rowTitles)
                        obj.GroupStatisticsList =       obj.GroupStatisticsList.setRowTitles( rowTitles);
              end
        end
               
        
    end
    
end
