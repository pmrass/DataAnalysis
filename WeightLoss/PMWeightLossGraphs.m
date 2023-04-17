classdef PMWeightLossGraphs
    %PMWEIGHTLOSSGRAPHS create weight-loss graphs from  PMWeighLossCurveSeries data source
    %   set styles and p-value settings and use methods to create specific weight-loss graphs;
    % also enables retrieval of data packaged in data-containers like PMXVsYDataContainer;
    
    properties (Access = private)
        WeightLossCurvesSeries
        
        GraphStyles
        LineIndexToAttachPValues = 1
        YShiftOfPValue = 10
        
        ShowPValues = true;
    end
    
    methods % initialization
        
        function obj = PMWeightLossGraphs(varargin)
            %PMWEIGHTLOSSGRAPHS Construct an instance of this class
            %   arguments:
            %   1: PMWeightLossCurvesSeries;
            %   2: PMSVGStyle vector
            %   3: Index of curve to which to attach p-value indicator
            %   4: Y-shift relative to curve of p-value indicator
            %   5: show p-values (logical scalar)
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 4
                    obj.WeightLossCurvesSeries =        varargin{1};
                    obj.GraphStyles =                   varargin{2};
                    obj.LineIndexToAttachPValues =      varargin{3};
                    obj.YShiftOfPValue =                varargin{4};

                case 5
                    obj.WeightLossCurvesSeries =        varargin{1};
                    obj.GraphStyles =                   varargin{2};
                    obj.LineIndexToAttachPValues =      varargin{3};
                    obj.YShiftOfPValue =                varargin{4};
                    obj.ShowPValues =                   varargin{5};

                    
                otherwise
                    error('Wrong input.')
                
            end
            
        end
        
        function obj = set.WeightLossCurvesSeries(obj, Value)
            assert(isa(Value, 'PMWeightLossCurvesSeries') && isscalar(Value), 'Wrong input.')
            obj.WeightLossCurvesSeries = Value;
        end
        
     
        
        function obj = set.GraphStyles(obj, Value)
            assert(isa(Value, 'PMSVGStyle') && isvector(Value), 'Wrong input.')
            obj.GraphStyles = Value;
        end
        
        function obj = set.LineIndexToAttachPValues(obj, Value)
            assert(isnumeric(Value) && isscalar(Value), 'Wrong input.')
            obj.LineIndexToAttachPValues = Value;
        end
        
        function obj = set.YShiftOfPValue(obj, Value)
            assert(isnumeric(Value) && isscalar(Value), 'Wrong input.')
            obj.YShiftOfPValue = Value;
        end
        
  
   
    end
    
      methods  % SETTERS
        
        function obj = setPValueSettings(obj, Value1, Value2)
            obj.LineIndexToAttachPValues = Value1;
            obj.YShiftOfPValue = Value2;    
        end
          
      end
    
      methods % GETTERS
          
        function Value = getWeightLossCurvesSeries(obj)
           Value = obj.WeightLossCurvesSeries; 
        end
            
      end
    
    methods  % GETTERS FOR DATA
        
         function XYData = getXYDataForDefaultWeightLossCurves(obj)
             % GETXYDATAFORDEFAULTWEIGHTLOSSCURVES returns PMXVsYDataContainer ;
             % should this be moved to PMWeightLossCurvesSeries?
             Matrices =          obj.WeightLossCurvesSeries.getActiveWeightPercentageTable;   
             XYData =            cellfun(@(x) PMXVsYDataContainer(x), Matrices);
             XYData =            arrayfun(@(x) set(x, 'ErrorType', 'Standard Deviation'), XYData);
               
         end
        
         function [Values, XYDataContainers, GainPercentages, pValue] = getXYDataForConsecutiveDayComparison(obj)
              
           
             GainsPerGroup = obj.WeightLossCurvesSeries.getActiveWeightPercentageTable;

             
             Values{1} = GainsPerGroup{1}{2,2};
             Values{2} = GainsPerGroup{2}{2,2};
             
            XYDataOne{1, 1}(:, 2) =             Values{1};
            XYDataOne{1, 1}(:, 1) =             1;
            XYDataOne{2, 1}(:, 2) =             Values{2};
            XYDataOne{2, 1}(:, 1) =             2;
            
            XYDataContainers =                cellfun(@(x) PMXVsYDataContainer(x(:, 1), x(:, 2)), XYDataOne);
            XYDataContainers =                arrayfun(@(x) x.setXBinLimits( 0.5 : 1: 2.5), XYDataContainers);
            XYDataContainers =                arrayfun(@(x) x.setCenterType('Median'), XYDataContainers);

            % the calculations should be moved back to model:
            GainPercentages(1) = sum(Values{1} > 100) / length(Values{1}) * 100;
            
             GainPercentages(2) = sum(Values{2} > 100) / length(Values{2}) * 100;
            
            
            
            
            Group1Gained = sum(Values{1}>100);
             Group1Lost = sum(Values{1}<=100);
             
                Group2Gained = sum(Values{2}>100);
             Group2Lost = sum(Values{2}<=100);
            
                  tables =    arrayfun(@(group1rec, group1not, group2rec, group2not) ... 
                obj.generateTwoWayTable(group1rec, group1not, group2rec, group2not), ...
                Group1Gained, Group1Lost,Group2Gained, Group2Lost, 'UniformOutput', false);
            
            
              [~, pValue, ~] =           cellfun(@(x) fishertest(x),  tables);
              
              
             
         end
         
         function myTable = generateTwoWayTable(~, Group1Recovered, Group1NotRecovered, Group2Recovered, Group2NotRecovered)
             myTable =               table([Group1Recovered; Group1NotRecovered],[Group2Recovered; Group2NotRecovered],'VariableNames',{'Group 1', 'Group 2'},'RowNames',{'Recovered','NotRecovered'});   
        end
         
         function [ GainsPerGroup,  LossPercentages, pValueFishers ] = getGainsForConsecutiveDayComparison(obj)
             error('Not supported anymore')
              [GainsPerGroup, LossPercentages, pValueFishers ] = obj.WeightLossCurvesSeries.getWeightGainsBetweenConsecutiveTimePointsForCutoff(0);
           
              
              obj.WeightLossCurvesSeries.getPValuesForWeightRecovery
             
         end
        
    end
    
    
    methods % MAIN FUNCTION, to add weight loss graph to input panel:
        
        
        function Panel =      addDefaultWeightLossGraphToPanel(obj, Panel)
            %ADDDEFAULTWEIGHTLOSSGRAPHTOPANEL add default weight-loss curve (PMSVGXVsYGraph) to panel;
            %   input: PMSVGSvgElement
            %   output: PMSVGSvgElement (after adding AttachedXYGraphs and p-value symbols); 
            % this indirect, should change to a different way (but maybe essential to add p-values;
            
                
             Panel =     obj.addWeightLossTableToPanel(Panel);
           
            
        end

        function weightLossXYGraphs = getWeightLossGraphs(obj)
            % 

                weightLossXYGraphs =            arrayfun(@(x, y) PMSVGXVsYGraph(x, y), obj.getXYDataForDefaultWeightLossCurves, obj.GraphStyles);

        end


    end
    

    
    methods (Access = private) % add default graphs to input panels:
        
        function Panel = addWeightLossTableToPanel(obj, Panel)
            
           weightLossXYGraphs = obj.getWeightLossGraphs;
            
            Panel.AttachedXYGraphs =        weightLossXYGraphs;
             if obj.ShowPValues
                 PValues_PercentageWeight =     obj.WeightLossCurvesSeries.getPValuesBetweenWeightPercentageTables(obj.WeightLossCurvesSeries.getActiveWeightPercentageTable);
                Panel =                         Panel.addPValues(weightLossXYGraphs(obj.LineIndexToAttachPValues), obj.YShiftOfPValue, PValues_PercentageWeight);
           
             end
            
            
        end
        
        
    end
    
    methods% add specialized graphs 

        function [PanelOne, PanelTwo] = addWeightGainBetweenTwoConsecutiveTimePointsGraphToPanel(obj, PanelOne, PanelTwo)  
            error('Not supported anymore. Retrieve graphs directly with getWeigthGainBetweenConsecutivTimePointsGraph.')
           
        end
        
        function [WeightChangeGraph, StatistitcsTextObject] = getGraphsWithWeigthChangesBetweenConsecutiveTimePoints(obj)
            
             [ GainsPerGroup, DataContainers,  ~, ~ ] =                obj.getXYDataForConsecutiveDayComparison;
         
             Edges = 95: 5: 110;
             WeightChangeGraph =            arrayfun(@(x, y) PMSVGViolinPlot(x, y, 0.75, Edges), DataContainers, obj.GraphStyles);
            
             
              WeightChangeGraph =            arrayfun(@(x)  x.setSymbolSize(7), WeightChangeGraph);
             WeightChangeGraph =            arrayfun(@(x)  x.setDefaultGraphType('Violin'), WeightChangeGraph);
              WeightChangeGraph =            arrayfun(@(x)  x.setHideViolin(true), WeightChangeGraph);
             
             

            WeightChangeGraph =            arrayfun(@(x, y) x.setShowError(false), WeightChangeGraph);
            WeightChangeGraph =            arrayfun(@(x, y) x.setShowXYCenterLines(true), WeightChangeGraph);
            WeightChangeGraph =            arrayfun(@(x, y) x.setWidthOfCenterLines(0.75), WeightChangeGraph);

            myStyle =                       PMSVGStyle('black', '2');
            WeightChangeGraph =            arrayfun(@(x, y) x.setStyleOfCenterLines(myStyle), WeightChangeGraph);
            
            
             
            
         
            p =                             ranksum(GainsPerGroup{1},GainsPerGroup{2});
            StatisticsTest =                sprintf('Mann Whitney test: p = %6.5f', p);
            
            StatistitcsTextObject =         PMSVGTextElement(35, 35, StatisticsTest);
            
        end
        
        function [weightLossXYGraphsTwo, StatisticsText ] = getGraphsWithWeigthGainsBetweenConsecutiveTimePoints(obj)
           
               [ ~, ~,  LossPercentages, pValueFishers ] =                obj.getXYDataForConsecutiveDayComparison;
           
            
             %% panel 2:
            DataTwo{1, 1}(1, 1) = 1;
            DataTwo{1, 1}(1, 2) = LossPercentages(1);
            DataTwo{2, 1}(1, 1) = 2;
            DataTwo{2, 1}(1, 2) = LossPercentages(2);
            
            DataContainers =                cellfun(@(x) PMXVsYDataContainer(x(:, 1), x(:, 2)), DataTwo);
            DataContainers =                arrayfun(@(x) x.setXBinLimits( 0.5 : 1: 2.5), DataContainers);
               DataContainers =            arrayfun(@(x) x.setCenterType('Median'), DataContainers);
               
            weightLossXYGraphsTwo =            arrayfun(@(x) PMSVGXVsYGraph(x), DataContainers);
            weightLossXYGraphsTwo =            arrayfun(@(x, y) x.setStyleOfXYSymbols(y), weightLossXYGraphsTwo, obj.GraphStyles(1:2));
            weightLossXYGraphsTwo =            arrayfun(@(x, y) x.setShowError(false), weightLossXYGraphsTwo);
            weightLossXYGraphsTwo =            arrayfun(@(x, y) x.setShowXYCenterLines(true), weightLossXYGraphsTwo);
         
 
            StatisticsText =                sprintf('Fisher''s exact test: p = %6.5f', pValueFishers);
            
            StatisticsText =             PMSVGTextElement(35, 35, StatisticsText);
         
            
        end
        
        function Panel = addWeightLossGraphToPanelRequirePercGainAfterIndex(obj, Panel, Percentage, StartDay, Value)
            
           Table =      obj.WeightLossCurvesSeries.getActiveWeightPercentageTableRequirePercGainAfterIndex(Percentage, StartDay);
           Panel =      obj.addWeightLossTableToPanel(Table, Panel, Value); 
            
        end
        
        function Panel = addWeightLossGraphToPanelRequirePercLossAfterIndex(obj, Panel, Percentage, StartDay, Value)
            
           Table =      obj.WeightLossCurvesSeries.getActiveWeightPercentageTableRequirePercLossAfterIndex(Percentage, StartDay);
           Panel =      obj.addWeightLossTableToPanel(Table, Panel, Value); 
            
        end
        
        function Panel = addWeightRecoveryGraphToPanel(obj, Panel)
            %ADDWEIGHTRECOVERYGRAPHTOPANEL add default weight-loss curve (PMSVGXVsYGraph) to panel;
            %   input: PMSVGSvgElement
            %   output: PMSVGSvgElement (after adding weight recovery graph with p-value symbols calculated with Fisher's test); 
             
            StartIndexForRecovery =         4;  
             PercentagesRecovery =          obj.WeightLossCurvesSeries.getPercentageTableOfRecoveredMice;
            weightLossXYGraphs =            cellfun(@(x) PMSVGXVsYGraph(PMXVsYDataContainer(x(StartIndexForRecovery : end, :))), PercentagesRecovery);
            weightLossXYGraphs =            arrayfun(@(x, y) x.setStyleOfXYSymbols(y), weightLossXYGraphs, PMFluPaper_StyleManager().weightLossAMD3100);
            Panel.AttachedXYGraphs =        weightLossXYGraphs;
            PValues_Recovery =              obj.WeightLossCurvesSeries.getPValuesForWeightRecovery;
            Panel =                         Panel.addPValues(weightLossXYGraphs(1), 30, PValues_Recovery(StartIndexForRecovery: end) );

            
        end
        
        function [PanelOne, PanelTwo] =  addFirstDayOfWeightRecoveryToPanels(obj, PanelOne, PanelTwo)
            % ADDFIRSTDAYOFWEIGHTRECOVERYTOPANELS:
            % input: two PMSVGSvgElements
            % output: two PMSVGSvgElements after adding bar graph and statistics depicting first recovery of start weight;
                StartDepictingRecovery = 4;
                DaysWhenWeightRecovered =       obj.WeightLossCurvesSeries.getDayWhenRegainingStartWeightFromDay(StartDepictingRecovery); 


                WeightRecovery =                [PMDataContainer(DaysWhenWeightRecovered{1}); PMDataContainer(DaysWhenWeightRecovered{2})];
                WeightRecovery =                arrayfun(@(x) set(x, 'Edges', 9.5:18), WeightRecovery);

                PanelOne.AttachedHistograms =      arrayfun(@(data,style) PMSVGHistogram(data,style),WeightRecovery(1), [PMFluPaper_StyleManager().PBSControlForAMD3100] );


                PanelTwo.AttachedHistograms =      arrayfun(@(data,style) PMSVGHistogram(data,style),WeightRecovery(2), [PMFluPaper_StyleManager().TreatmentWithAMD3100 ] );

            
        end
        
    end
    
  
    
end

