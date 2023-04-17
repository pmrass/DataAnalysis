classdef PMXVsYDataSeriesContainer < PMXVsYDataContainer
    %PMXVSYDATASERIESCONTAINER manage a series of XY-data
    %   manage a series of XY-data
    
    properties (Access = private)
        XYDataContainerVector
    end
    
    methods
        
        function obj = PMXVsYDataSeriesContainer(varargin)
            % PMXVSYDATASERIESCONTAINER initialize object;
            % takes 1 argument:
            % 1: vector of PMXVsYDataContainer objects;
            NumberOfInputArguments = length(varargin);
            switch NumberOfInputArguments
                case 0
                case 1
                    obj.XYDataContainerVector =  varargin{1};
                otherwise
                    error('Wrong number of input arguments')
            end
            
        end
        
       
        
        function obj = set.XYDataContainerVector(obj,Value)
            if isempty(Value)
                obj.XYDataContainerVector =  PMXVsYDataContainer(0, 0);
            else 
                assert(isvector(Value) && isa(Value, 'PMXVsYDataContainer'), 'Wrong input type')
                obj.XYDataContainerVector =  Value;
            end
        end

       
    end
    
    methods % SETTERS: 
        
        function obj = setData(obj, Value)
           obj.XYDataContainerVector = Value; 
        end
        
    end
    
    methods % GETTERS: 
        
        function  mergeByComputingMeans(obj)
            error('Use getXYDataContainerByPoolingMeanYOfXBins instead.')
            
        end
        
         function mergedXVsYContainer = getXYDataContainerByPoolingMeanYOfXBins(obj)
             % GETXYDATACONTAINERBYPOOLINGMEANYOFXBINS returns PMXVsYDataContainer for displacements of entire population;
             % gets mean value in each bin for each source datacontainer;
             % then creates new PMXVsYDataContainer where each of the mean values is a single datapoint;
             
                obj.XYDataContainerVector =     arrayfun(@(xyData) xyData.setXBinLimits(obj.getXBinLimits), obj.XYDataContainerVector);
                
                XBinCenterLists =               arrayfun(@(x) x.getXBinCenters, obj.XYDataContainerVector, 'UniformOutput', false);
                XBinCenterList =                vertcat(XBinCenterLists{:});
                
                meanYLists =                    arrayfun(@(x) x.getMeans, obj.XYDataContainerVector, 'UniformOutput', false);
                meanYList =                     vertcat(meanYLists{:});

                mergedXVsYContainer =           PMXVsYDataContainer(XBinCenterList, meanYList);
                mergedXVsYContainer =           mergedXVsYContainer.setXParameter(obj.getXParameter);
                mergedXVsYContainer =           mergedXVsYContainer.setYParameter(obj.getYParameter);
                mergedXVsYContainer =           mergedXVsYContainer.setXBinLimits(obj.getXBinLimits);
            
            
         end
        
        
    end
    
    
    
end

