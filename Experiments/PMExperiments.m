classdef PMExperiments
    %PMEXPERIMENTS For bookkeeping of list of experiments
    % each experiment is a"data" object, which have groupnames
    % currently data need to support the following methods
    % getRawData, getNamesOfAllExperiments, getGroupNamesForIndex, getGroupsOfExperimentWithName, getRawDataForExperimentName;
    % addNewExperiment, deleteExperimentWithIndex, setGroupNamesOfExperimentWithName,  addGroupToExperimentWithName, setGroupsOfExperimentWithName;
    
    properties 
        FolderName
        FileName   
        Data
    
    end
    
    methods % INITIALIZATION:
       
        function obj = PMExperiments(varargin)
            %PMEXPERIMENTS Construct an instance of this class
            %  Takes 0 arguments:
            % Currently used specifally for analysis of influenza-weight data;
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 0
                    obj.FolderName =        PMFluPaperFiles('/WeightLossAfterFluInfection').getFigureSourcesFolder;
                    obj.FileName =          '/WeightMeasurements.mat';
                    obj.Data =              PMWeightLossCurvesSeries(obj.FolderName);
                    
                otherwise
                    error('Wrong number of arguments')
            end
        end
        
        function obj = set.FolderName(obj, Value)
            assert(ischar(Value), 'Wrong input type')
            obj.FolderName = Value;
        end
        
        function obj = set.FileName(obj, Value)
            assert(ischar(Value), 'Wrong input type')
            obj.FileName = Value;
        end
        
        function fileName = getPath(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
             fileName=       [obj.FolderName  obj.FileName];
        end
        
 
    end
    
    methods % GETTERS
       
        function data = getData(obj)
            data = obj.Data.getRawData;
        end
        
        function experimentNames = getNamesOfAllExperiments(obj)
            experimentNames = obj.Data.getNamesOfAllExperiments;
        end
        
        function groupNames = getGroupNamesForIndex(obj, index)
            groupNames = obj.Data.getGroupNamesForIndex(index);
        end
        
         function groups = getGroupsOfExperimentWithName(obj, Name)
             groups = obj.Data.getGroupsOfExperimentWithName( Name);
         end
        
        function rawData = getRawDataForExperimentName(obj, Name)
            rawData = obj.Data.getRawDataForExperimentName(Name);
        end

    end
    
    methods % SETTERS:
        
        function obj = addNewExperiment(obj)
            obj.Data = obj.Data.addNewExperiment;
        end
        
        function obj = deleteExperimentWithIndex(obj, index)
            obj.Data = obj.Data.deleteExperimentWithIndex(index);
        end
        
        function obj = setGroupNamesOfExperimentWithName(obj, Name, Value)
            obj.Data = obj.Data.setGroupNamesOfExperimentWithName( Name, Value);
        end
        
        function obj = addGroupToExperimentWithName(obj, Name)
            obj.Data = obj.Data.addGroupToExperimentWithName( Name);
        end
        
        function obj = setGroupsOfExperimentWithName(obj, Name, groups)
             obj.Data = obj.Data.setGroupsOfExperimentWithName( Name, groups);
        end
         
        
    end
    
    methods(Access = private)
        
         function data = getRawData(obj)
            data = obj.Data;
        end
        
    end
end

