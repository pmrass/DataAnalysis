classdef PMGroupStatisticsSeries
    %PMGROUPSTATISTICSSERIES list of group-lists, usually different
    %experiments;
    % has only one property a vector of PMGroupStatisticsList objects;
    % different lists contain the same parameters obtained from different measurements;
    % methods allow data retrieval and export of data into a spreadsheet;
    
    properties (Access = private)
        statisticsListsForDifferentSamples = PMGroupStatisticsList.empty(0,1);
        
    end
    
    methods % INITIALIZATION
        
        function obj = PMGroupStatisticsSeries(varargin)
            %PMGROUPSTATISTICSSERIES Construct an instance of this class
            %   takes one argument for a vector of PMGroupStatisticsList objects;
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 1
                    obj.statisticsListsForDifferentSamples = varargin{1};
                otherwise
                    error('Wrong number of arguments.')
                
            end
        end
        
       function obj = set.statisticsListsForDifferentSamples(obj, Value)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            assert(isa(Value, 'PMGroupStatisticsList') && isvector(Value), 'Wrong input type.')
            obj.statisticsListsForDifferentSamples = Value(:);
            assert(size(obj.statisticsListsForDifferentSamples, 2) == 1, 'Something wrong.')
        end
        
        
    end
    
    methods % SUMMARY
        
           function obj = showSummary(obj)
              fprintf('\nThis PMGroupStatisticsSeries contains PMGroupStatisticsLists from %i different data-sources.\n', obj.getNumberOfDatasets)
              
              for index = 1 : obj.getNumberOfDatasets
                  
                  fprintf('\nPMGroupStatisticsList number %i:\n', index)
                  obj.statisticsListsForDifferentSamples(index) = obj.statisticsListsForDifferentSamples(index).showSummary;
                  
                  
              end
              
              
          end
          
        
        
        
    end
    
    methods % GETTERS DESCRIPTION
        
        function titles = getTitles(obj)
            % GETTITLES returns cell-string of descriptive title of all experiments of the object ;
           titles = arrayfun(@(x) x.getTitle, obj.statisticsListsForDifferentSamples, 'UniformOutput', false);
        end
        
        function number = getNumberOfDatasets(obj)
            % GETNUMBEROFDATASETS returns number of experiments that are collected;
            number = size(obj.statisticsListsForDifferentSamples, 1);
        end
        
        
        function value = getTimeTitles(obj)
           value = obj.statisticsListsForDifferentSamples(1).getTimeTitles;
        end
        
        
    end
    
    methods % GETTERS PARAMETERS
        
        function number = getNumberOfSamples(obj)
            % GETNUMBEROFSAMPLES returns number of parameters in each experiment;
           number = obj.statisticsListsForDifferentSamples(1).getNumberOfDataTypes ;
        end
        
         function rowTitles = getDescriptionForIndex(obj, Index)
            % GETDESCRIPTIONFORINDEX returns a character string with the "row-titles" of the input index;
            % the row title is actually a descriptive title of the different "parameters" in the lists;
            % each contained list should have identical parameters;
          rowTitles = obj.statisticsListsForDifferentSamples(1).getDescriptionForIndex(Index);
         end
        
        
        
      
        
        
        
        
    end
    
    methods % GETTERS GROUPS
        
        function groupNames = getGroupnames(obj)
            % GETGROUPNAMES returns group names
            groupNames = obj.statisticsListsForDifferentSamples(1).getGroupnames;
        end

         function numberOfGroups = getNumberOfGroupsEach(obj)
            numberOfGroups = arrayfun(@(x) x.getNumberOfGroups, obj.statisticsListsForDifferentSamples);
         end
         
        function numberOfGroups = getNumberOfGroups(obj)
           numberOfGroups = obj.statisticsListsForDifferentSamples.getNumberOfGroups;
        end
        
             
        
        
    end
    
    methods % get contents:
        
        function data = getGroupStatisticsListsWithIndices(obj, Value)
              % GETGROUPSTATISTICSLISTSWITHINDICES returns PMGroupStatisticsList of index;
              assert(isnumeric(Value) && isvector(Value) && min(Value) >= 1 && max(Value) <= length(obj.statisticsListsForDifferentSamples), 'Invalid indices.')
              data = obj.statisticsListsForDifferentSamples(Value);

          end
          
        function data = getData(obj)
            data = obj.statisticsListsForDifferentSamples;
        end
        
        function maximumValue =         getMaximumForIndex(obj, Index)
            maximumValue = max(arrayfun(@(x) x.getMaximumValueForIndex(Index), obj.statisticsListsForDifferentSamples));
        end
        
        function maximumValues =        getMaximaForIndex(obj, Index)
             maximumValues = arrayfun(@(x) x.getMaximumValueForIndex(Index), obj.statisticsListsForDifferentSamples);
        end

        function maximumValue =         getMinimumForIndex(obj, Index)
            maximumValue = min(arrayfun(@(x) x.getMinimumValueForIndex(Index), obj.statisticsListsForDifferentSamples));
        end
        
        function xydata =               getXYDataForIndex(obj, Index, varargin) 
             xydata = arrayfun(@(x) x.getXYDataForIndex(Index, varargin{:}), obj.statisticsListsForDifferentSamples);
        end
        
        function result =               getPValueSpreadSheet(obj)
             result = [obj.getTitlesOfAnalysisTypes, [obj.getTitlesOfSamples; obj.getFormattedSpreadSheetOfPValues]];
        end
        
        function spreadsheets =         getFormattedSpreadsheets(obj)
           spreadsheets =  arrayfun(@(x) x.getFormattedSpreadsheet, obj.statisticsListsForDifferentSamples, 'UniformOutput', false);
        end
        
        
    end
    
    methods (Access = private)
        
        %% get titles of analysis types:
          function result = getTitlesOfAnalysisTypes(obj)
                rowTitles =         obj.statisticsListsForDifferentSamples(1).getRowTitles;
                result =            rowTitles(2:end);
          end
          
          %% get titles of samples:
         function SampleTitles = getTitlesOfSamples(obj)
            SampleTitles =          arrayfun(@(x) x.getTitle, obj.statisticsListsForDifferentSamples, 'UniformOutput', false);
            SampleTitles =          cellfun(@(x) obj.addComma(x), SampleTitles, 'UniformOutput', false);
            SampleTitles =          SampleTitles';
            SampleTitles =          [SampleTitles{:}];
        end
        
        function result = addComma(~, result)
            result = [result, ', '];
        end
        
        
        
        function StringData = getFormattedSpreadSheetOfPValues(obj)
            SpreadSheetOfPValues =      obj.getSpreadSheetOfPValues;
            StringData =                obj.convertPValueSpreadSheetToCellString(SpreadSheetOfPValues);
        end
        
        function SpreadSheetOfPValues = getSpreadSheetOfPValues(obj)
              PValueListsForAllSamples =          arrayfun(@(x) x.getPValues('ttest', 'Symbols'), obj.statisticsListsForDifferentSamples, 'UniformOutput', false);
            SpreadSheetOfPValues =              cell(obj.getNumberOfSamples, 1);
            for Index = 1: obj.getNumberOfDatasets
                SpreadSheetOfPValues(:, Index) =     PValueListsForAllSamples{Index};
            end
            SpreadSheetOfPValues = cellfun(@(x) obj.addComma(x), SpreadSheetOfPValues, 'UniformOutput', false);
        end


        function StringData = convertPValueSpreadSheetToCellString(obj, sheet)
              StringData = cell(size(sheet, 1), 1);
             for Index = 1: size(sheet, 1)
                 myData = sheet(Index, :);
                StringData{Index, 1} = [(myData{:})];
             end
            
        end
        
    end
    

end

