classdef PMExperimentsManager < handle
    %PMEXPERIMENTSMANAGER For interactive display of data
    % 
    
    properties (Access = private)
        Experiments
        MainFigure
        Views
        Menu
        
    end
    
    methods
        function obj = PMExperimentsManager(varargin)
            %PMEXPERIMENTSMANAGER Construct an instance of this class
            %   Takes 0 arguments:
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 0
       
                    obj.Experiments =   PMExperiments();
                    obj.Views =         PMExperimentsView();
                    obj.MainFigure =    obj.Views.Figure;
                    
                    obj =               obj.setExperimentView;
                    obj =               obj.moveFigureToFront;
                    obj.Menu =          PMExperimentsMenu(obj.MainFigure);
                    obj =               obj.setMenuCallbacks;
                    obj =               obj.setViewCallbacks;
                    
                otherwise
                    error('Wrong number of arguments')
            end
        end
        
        function set.Experiments(obj, Value)
           assert(isa(Value, 'PMExperiments'), 'Wrong type.')
           obj.Experiments = Value;
        end
        
        function set.Views(obj, Value)
           assert(isa(Value, 'PMExperimentsView'), 'Wrong type.')
           obj.Views = Value;
        end
        
        function set.Menu(obj, Value)
            assert(isa(Value, 'PMExperimentsMenu'), 'Wrong type.')
            obj.Menu = Value;
        end
        
        function obj = setViewCallbacks(obj)
            % this should be converted to a method call:
            obj.Views.Experiments.Callback=                 @obj.setViewsBySelectedExperiment;
            obj.Views.Groups.Callback=                      @obj.callbackForGroupChange;
            obj.Views.Groups.KeyPressFcn=                   @obj.GroupList_KeypressCallback;
            obj.Views.GroupName.Callback=                   @obj.changeNameOfSelectedGroup;
            obj.Views.Data.CellEditCallback=                @obj.CallbackForWeightTable;
        end
        
        function obj = setMenuCallbacks(obj)
            obj.Menu.OpenNewProject.Callback=               @obj.Project_New;
            obj.Menu.ChangeProject.Callback=                @obj.Project_Change;
            obj.Menu.AddExperiment.Callback=                @obj.addExperiment;
            obj.Menu.DeleteExperiment.Callback=             @obj.Experiment_Delete_ViewController;
            obj.Menu.AddGroup.Callback=                     @obj.callbackByAddGroupMenu; 
            obj.Menu.DeleteGroup.Callback=                  @obj.callbackByDeleteGroupMenu;
            obj.Menu.ChangeExperimentName.Callback =        @obj.callbackByChangeExperimentName; 
            obj.Menu.RefreshGraph.Callback=                 @obj.callbackForRefreshGraph;
             
        end

        function Data = getData(obj)
            Data = obj.Experiments.getData;
        end
        
    end
    
    methods (Access = private) % EXPERIMENT CHANGE
        
        function obj =      setViewsBySelectedExperiment(obj, src, ~)
            obj =          obj.setGroupView;
            obj =          obj.setGroupNameView;
            obj =          obj.setDataView;
            obj =          obj.PlotGroups;
        end

        function obj =      setGroupView(obj)
        obj.Views =     obj.Views.setGroups(obj.getNumberOfGroupsForSelectedExperiment);
        end

        function obj =      setGroupNameView(obj)
        selectedGroupName = obj.Experiments.getGroupNamesForIndex(obj.getIndexOfSelectedExperiment);
        obj.Views =         obj.Views.setGroupName(selectedGroupName{obj.Views.getIndexOfSelectedGroup});
        end

        function obj =      setDataView(obj)
        rawData =            obj.Experiments.getRawDataForExperimentName(obj.Views.getNameOfSelectedExperiment);
        if isempty(rawData)
        else
            obj.Views =          obj.Views.setData(rawData{obj.Views.getIndexOfSelectedGroup});
        end
        end

        function obj =      PlotGroups(obj)
        SelectedExpString =        obj.Experiments.Data.getExperimentNames{obj.Views.Experiments.Value, 1};
        weightLossSourceData =     [obj.Experiments.Data.getCurvesOfExperiment(SelectedExpString)];
        weightLossXYData =         arrayfun(@(x) PMXVsYDataContainer(x.getPercentageWeightList), weightLossSourceData);

        myXYDataView =              PMXVsYDataView('Day(s) after infection', 'Weight in comparison to day 0 (%)', weightLossXYData, obj.Views.Graph, obj.Views.LineHandle, weightLossSourceData);
        myXYDataView =              myXYDataView.refresh;
        end


        
    end
    
    methods(Access = private)
       
        function obj =              callbackForGroupChange(obj, src, ~)
            obj = obj.setViewsAfterGroupChange ;
         end
        
        function numberOfGroups=    getNumberOfGroupsForSelectedExperiment(obj)
            numberOfGroups =  length(obj.Experiments.getGroupNamesForIndex(obj.getIndexOfSelectedExperiment));
        end
        
        function SelectedData =     getDataOfSelectedExperiments(obj)
            AllData=    obj.Experiments.getData; 
            SelectedData = AllData{obj.getIndexOfSelectedExperiment};
         end
        
        function index=             getIndexOfSelectedExperiment(obj)
            index = obj.Views.getIndexOfSelectedExperiment;
            
        end
        
        function obj =              moveFigureToFront(obj)
            obj.Views = obj.Views.moveFigureToFront;
        end
        
        function obj =              addExperiment(obj, src, ~)
                %EXPERIMENT_ADD_VIEWCONTROLLE Summary of this function goes here
                %   Detailed explanation goes here
                obj =               obj.addNewExperiment;
        end
        
        function obj =              addNewExperiment(obj)
                obj.Experiments = 	obj.Experiments.addNewExperiment; 
                obj =               obj.SaveCurrentData;
                obj =               obj.setExperimentView;
                obj.Views =         obj.Views.selectedLastExperiment;
                obj =               obj.setDataView;
                 
          end
          
        function obj =              setExperimentView(obj)
            obj.Views = obj.Views.setExperiments(obj.Experiments.getNamesOfAllExperiments);
        end
         
        function obj =              Experiment_Delete_ViewController(obj, ~, ~)
            %EXPERIMENT_DELETE Summary of this function goes here
            %   Detailed explanation goes here

            obj.Experiments = obj.Experiments.deleteExperimentWithIndex(obj.getIndexOfSelectedExperiment);
            obj =           obj.SaveCurrentData;

            obj =           obj.setExperimentView;
            obj =           obj.setDataView;
        end
        
        function obj =              changeNameOfSelectedGroup(obj, src, ~)
            %CALLBACKFORGROUPNAME Summary of this function goes here
            %   Detailed explanation goes here
           
            GroupNames =                                        obj.getGroupNamesOfSelectedExperiment;
            GroupNames{obj.Views.getIndexOfSelectedGroup} =     obj.Views.getGroupName;
            obj.Experiments =   obj.Experiments.setGroupNamesOfExperimentWithName(obj.getNameOfSelectedExperiment, GroupNames);
            obj =               obj.setGroupNameView;

             obj = obj.SaveCurrentData;
           
        end
        
        function name =             getNameOfSelectedExperiment(obj)
            name = obj.Experiments.getNamesOfAllExperiments{obj.getIndexOfSelectedExperiment};
        end
        
        function groupNames =       getGroupNamesOfSelectedExperiment(obj)
             groupNames = obj.Experiments.getGroupNamesForIndex(obj.getIndexOfSelectedExperiment);
        end
        
        function obj =              callbackByDeleteGroupMenu(obj, src, ~)
           obj =    obj.Group_Delete;
        end
        
        function obj =              callbackByAddGroupMenu(obj, src, ~)
           obj =  obj.Group_Add;
        end
        
        function obj =              GroupList_KeypressCallback(obj, src, ~)
        %GROUPLIST_KEYPRESSCALLBACK Summary of this function goes here
        %   Detailed explanation goes here

            global Handles 
            switch Handles.MainWeightLoss_Handle.CurrentCharacter
                case 'd'
                    obj = obj.Group_Delete;
                case 'a'
                    obj =  obj.Group_Add;
            end
            Handles.MainWeightLoss_Handle.CurrentCharacter=             'X';

        end
        
        function obj =              Group_Add(obj)
            %GROUP_ADD Summary of this function goes here
            %   Detailed explanation goes here

                obj.Experiments =   obj.Experiments.addGroupToExperimentWithName(obj.getNameOfSelectedExperiment);
                obj =               obj.setGroupView;
                obj.Views =         obj.Views.selectedLastGroup;
                obj =               obj.setViewsAfterGroupChange;
                obj =                   obj.SaveCurrentData;

        end
           
        function obj =              Group_Delete(obj)
            %GROUP_DELETE Summary of this function goes here
            %   Detailed explanation goes here
                groups =            obj.Experiments.getGroupsOfExperimentWithName(obj.getNameOfSelectedExperiment);
                groups(obj.Views.getIndexOfSelectedGroup) = [];
                obj.Experiments =   obj.Experiments.setGroupsOfExperimentWithName(obj.getNameOfSelectedExperiment, groups);
                obj =               obj.setGroupView;
                obj =               obj.setViewsAfterGroupChange;
               
                obj =                   obj.SaveCurrentData;

        end
        
        function obj =              setViewsAfterGroupChange(obj)
            obj =          obj.setGroupNameView;
            obj =          obj.setDataView;
        end
        
        function obj =              Project_New(obj)
        %PROJECT_NEW Summary of this function goes here
        %   Detailed explanation goes here
            global AllFluData PreviousSettings Handles MenuHandles
            [AllFluData]=              obj.Project_CreateNewAllFluData;
            [file,path] =              uiputfile('NewWeightlossProject.mat','Save new weight-loss project as');
            CompletePath=              [path '/' file];
            PreviousSettings.ProjectName= CompletePath; 
            obj = obj.SaveCurrentData;
            % this currently always loads the same file; will ignore new project;
            myExpManager =          PMExperimentsManager(PMExperiments(), PMExperimentsView(Handles), PMExperimentsMenu(MenuHandles));
            AllFluData =            myExpManager.getData;
        end

        function [ AllFluData ] = Project_CreateNewAllFluData(obj)
            %PROJECT_CREATENEWALLFLUDATA Summary of this function goes here
            %   Detailed explanation goes here
            AllFluData=                                                 cell(1,1);
            AllFluData{1, 1}=                                           'Experiment 1';
            AllFluData{1, 2}.StructureWithData.Groups{1, 1}.Name=       'Group 1';
            AllFluData{1, 2}.StructureWithData.Groups{1, 1}.Data=       0;
        end

        function Project_Change(obj)

                global   PreviousSettings Handles AllFluData
                %%  file with AllFluData
                [FileName,PathName]=                            uigetfile;
                if FileName(1,1)~=0 && PathName(1,1)~=0
                    CompleteFileName=                           strcat ('/', PathName, FileName);
                else
                    return
                end

                PreviousSettings.ProjectName=                       CompleteFileName;

                StringOfSelectedFile_Handle=                        Handles.StringOfSelectedFile_Handle;
                StringOfSelectedFile_Handle.Value=                  1;

                % this currently always loads the same file; will ignore new project;
                myExpManager =                                      PMExperimentsManager(PMExperiments(), PMExperimentsView(Handles));
                AllFluData =                                        myExpManager.getData;

        end

        function  CallbackForWeightTable(obj, src, ~)
               updateTableView(obj);
        end

        function obj =              updateTableView(obj)

            CurrentData=               obj.Views.getData;
            if size(CurrentData,1)>= 3 &&  min(isnan(CurrentData(end,:))) && min(isnan(CurrentData(end - 1,:)))
               CurrentData(end,:)= [];
            elseif ~min(isnan(CurrentData(end,:)))
                CurrentData(end + 1, :)=     NaN;
            end    

            if size(CurrentData,2)>= 3 && min(isnan(CurrentData(:, end))) && min(isnan(CurrentData(:,end - 1)))
                 CurrentData(:,end)= [];
            elseif ~min(isnan(CurrentData(:, end)))
                CurrentData(:,end + 1)=     NaN;
            end  

            groups =            obj.Experiments.getGroupsOfExperimentWithName(obj.getNameOfSelectedExperiment);
            groups{obj.Views.getIndexOfSelectedGroup, 1}.Data = CurrentData;

            obj.Experiments =   obj.Experiments.setGroupsOfExperimentWithName(obj.getNameOfSelectedExperiment, groups);
            obj =               obj.setDataView;
            obj =               obj.SaveCurrentData;

        end

        function obj =              callbackForRefreshGraph(obj, ~, ~)
            obj = PlotGroups(obj);
        end

        function obj =              callbackByChangeExperimentName(obj, ~, ~ )


        OldName = obj.Views.getNameOfSelectedExperiment;
        NewName =   inputdlg;


        obj.Experiments.Data = obj.Experiments.Data.setNameOfExperimentWithIndexTo(obj.Views.getIndexOfSelectedExperiment, NewName{1});


        obj =           obj.setExperimentView;

        end


    end
    
    methods (Access = private) % FILE-MANAGEMENT:
        
          function obj =              SaveCurrentData(obj)
            %SAVECURRENTDATA Summary of this function goes here
            %   Detailed explanation goes here
                AllFluData =        obj.getData;
                save(PMExperiments().getPath, 'AllFluData')

          end
        
        
    end
            
    
    
    
    end


