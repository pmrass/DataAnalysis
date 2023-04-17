classdef PMXVsyGroupDataContainer
    %PMXVSYGROUPDATACONTAINER contains xy data from different groups;
    %   allows statistical comparison between the different groups
    
    properties (Access = private)
        XYDataOfDifferentGroups
        PValueType = 'Repeated Measures ANOVA test';
        
    end
    
    properties (Constant, Access = private)
       
         PossiblePValueTests = {'Student''s t-test', ...
                        'Mann-Whitney test', ...
                        'Kruskal-Wallis test', ...
                        'Repeated Measures ANOVA test', ...
                        'Chi-Square test', ...
                        'Calculation of the p-value was not possible'...
                        };
        
        
        
    end
     
    
    methods % initialization
        
          function obj = PMXVsyGroupDataContainer(varargin)
            %PMXVSYGROUPDATACONTAINER Construct an instance of this class
            %   takes 1 argument
            % 1: vector of PMXVsYDataContainer objects
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 1
                    obj.XYDataOfDifferentGroups = varargin{1};
                otherwise
                    error('Wrong input.')
                
                
            end
            
        end
        
        function obj = set.XYDataOfDifferentGroups(obj, Value)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            assert(isa(Value, 'PMXVsYDataContainer') && isvector(Value), 'Wrong input.')
            obj.XYDataOfDifferentGroups = Value;
        end
        
         function obj = set.PValueType(obj, Value)
            assert(ischar(Value) && max(strcmp(Value, obj.PossiblePValueTests)), 'Wrong input.')
           obj.PValueType = Value; 
         end
     
    end
    
    methods % setters
        function obj = setPValueType(obj, Value)
           obj.PValueType = Value; 
        end
        
      end
      
    methods % summary
        
        function obj = getSummary(obj, varargin)
            switch length(varargin)
                case 0
                    obj = obj.getGeneralSummary;

                otherwise
                    error('Wrong input.')

            end

        end

        function obj = showSummary(obj, varargin)

            switch length(varargin)
            case 0
                obj = obj.showGeneralSummary;

            otherwise
                error('Wrong input.')

            end

        end

      end
       
 
    methods % getters
        
         function number = getNumberOfGroups(obj)
            number = length(obj.XYDataOfDifferentGroups); 
          end
        
    end
    
    methods % p-values
        
        function PValueObject = getPValue(obj)
            
                switch obj.PValueType
                    case 'Repeated Measures ANOVA test'
                        RepatedMeasuresTable =          obj.getRepeatedMeasuresTable;
                        PValue =                        RepatedMeasuresTable{2, 5};
                        
                    case  'Chi-Square test'
                        Matrices =      obj.getMatricesForEachGroup;
                        assert(min(cellfun(@(x) isvector(x), Matrices)), 'Datasets have to be vectors.')
                        FinalInput =    round(cell2mat(Matrices));
                        PValue =        PMChiSquare(FinalInput).getPValue;
                   
                    case 'Calculation of the p-value was not possible'
                        PValue =   NaN;
                        
                        
                         
                    otherwise
                        error('Wrong input.')
                    
                    
                end
                
                 PValueObject =                  PMPValue( PValue, obj.PValueType);
          
            
        end
        
        
        function PValues = getPValues(obj)
            
                GroupDesignationOne =       arrayfun(@(x)  obj.XYDataOfDifferentGroups(x).getListOfAllXValues, (1 : length(obj.XYDataOfDifferentGroups))', 'UniformOutput', false);
                GroupDesignationTwo =       arrayfun(@(x)   repmat(x, length(obj.XYDataOfDifferentGroups(x).getListOfAllXValues), 1), (1 : length(obj.XYDataOfDifferentGroups))', 'UniformOutput', false);
                Content =                   arrayfun(@(x)  obj.XYDataOfDifferentGroups(x).getListOfAllYValues, (1 : length(obj.XYDataOfDifferentGroups))', 'UniformOutput', false);

                TimeGroup =                 vertcat(GroupDesignationOne{:});
                InhibitionGroup =           vertcat(GroupDesignationTwo{:});
                ContentPooled =             vertcat(Content{:});

                [~,tbl,~]  =                anovan(ContentPooled,{TimeGroup, InhibitionGroup}, 'model','interaction', 'varnames',{'Category 1','Category 2'});

                PValues =                   cell2mat(tbl(2:3, 7));
                
            
                myTable =   table(ContentPooled, TimeGroup, InhibitionGroup);
           
         
        end
        
          function PValues = getPValuesForEachBin(obj, varargin)
              % GETPVALUESFOREACHBIN returns p-values for comparisons for all data values in each bin for the different groups;
              % only available when exactly to xy-series are collected;
              
              switch length(varargin)
                 
                  
                  case 0
                      ColumnShiftSecondGroup = 0;
                  case 1
                      ColumnShiftSecondGroup = varargin{1};
                  case 2
                      ColumnShiftSecondGroup = varargin{1};
                      
                  otherwise
                      error('Wrong input.')
                  
              end
              
              assert(obj.getNumberOfGroups == 2, 'Bin for bin comparison can be performed only when exactly two groups exist.')
              
              
              
              Data =                  arrayfun(@(x) transpose(x.getDataInMatrixForm), obj.XYDataOfDifferentGroups, 'UniformOutput', false);
              
              Rows = size(Data{2}, 1);
              Inster = nan(Rows, ColumnShiftSecondGroup);
              
              Data{2} = [Inster, Data{2}];
              NumberOfComparisons = size(Data{1}, 2);
              PValues = zeros(NumberOfComparisons, 1);
              for index = 1 : NumberOfComparisons
                  try 
                        [~, p] = ttest2(Data{1}(:, index), Data{2}(:, index));
                  catch
                      p = NaN; 
                  end
                    PValues(index, 1) = p;
              end
              
              
          end
        
        
         
        
        
     
        
    end
    
       methods (Access = private) % summary 

        function Text = getGeneralSummary(obj)
        Text = {sprintf('\n*** THis PMXVsyGroupDataContainer object contains data of %i PMXVsYDataContainer objects.\n\n', obj.getNumberOfGroups )};


         for index = 1 : obj.getNumberOfGroups                      
               Text = [Text; sprintf('Data source %i:\n', index)];
               obj.XYDataOfDifferentGroups(index) = obj.XYDataOfDifferentGroups(index).setPValueType('Suppress');                       
               Text = [Text; obj.XYDataOfDifferentGroups(index).getSummary];
               Text = [Text; newline];
         end

         Text = [Text; sprintf('Comparison of the groups led to the following result:\n')];
         Text = [Text; obj.getPValue.getSummary];



        end

        function obj = showGeneralSummary(obj)
            cellfun(@(x) fprintf('%s', x), obj.getGeneralSummary);

        end

    end
    
  
    
    methods (Access = private) % get table for repeated measures test
        
           function ranovatbl = getRepeatedMeasuresTable(obj)
                Matrices =                      obj.getMatricesForEachGroup;
                [MyGroups, MeasuresCell] =      obj.extractDataFromMatricesForANOVA( Matrices);
                
                  UniqueLength =      unique(cellfun(@(x) length(x), MeasuresCell));
                assert(length(UniqueLength) == 1, 'Input is incosistent.')
                if UniqueLength <= length(Matrices)
                    ranovatbl = num2cell(NaN(100));
                    
                else
                      myTable = table(MyGroups, MeasuresCell{:});
                      try
                          NumberOfGroups = length(Matrices);
                          NumberOfTimePoints = size(myTable, 2);
                          String = sprintf('Var%i-Var%i~MyGroups', NumberOfGroups, NumberOfTimePoints);
                            rm =            fitrm(myTable,String);
                            ranovatbl =     ranova(rm);
                      catch
                          ranovatbl{2, 5} = NaN;
                      end
                
                end
              
            
           end
            
           function Matrices = getMatricesForEachGroup(obj)
               Matrices =                  arrayfun(@(x) transpose(x.getDataInMatrixForm), obj.XYDataOfDifferentGroups, 'UniformOutput', false);
               
           end
           
           function [MyGroups, MeasuresCell] =  extractDataFromMatricesForANOVA(obj, Matrices)
               
                for Index = 1 : length(Matrices)
                    Matrices{Index} = [repmat(Index, size(Matrices{Index}, 1), 1),  Matrices{Index}];
                end                
                FinalData = vertcat(Matrices{:});
                
                MyGroups = FinalData(:, 1);
                
                Measures =          FinalData(:, 2: end);
                MeasuresCell =      arrayfun(@(x) Measures(:, x), 1 : size(Measures, 2), 'UniformOutput', false);
              
                
               
           end
        
      
        
        
    end
end

