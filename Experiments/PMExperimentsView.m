classdef PMExperimentsView
    %PMEXPERIMENTSVIEW Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        
        Figure
        Experiments
        Groups
        GroupName
        Data
        
        Graph
        LineHandle
        
    end
    
    methods
        function obj = PMExperimentsView(varargin)
            %PMEXPERIMENTSVIEW Construct an instance of this class
            %   Detailed explanation goes here
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 0
                case 1
                    obj.Figure = varargin{1};
                    
                otherwise
                    error('Wrong number of arguments.')
                
            end
            
            obj = obj.setViewsFromHandles;
          
        end
        
        function obj = setViewsFromHandles(obj)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            
             MainWeightLoss_Handle=                     obj.Figure;

            %% create main figure object:
            if isempty(MainWeightLoss_Handle)
                MainWeightLoss_Handle=                  figure;
                MainWeightLoss_Handle.Tag=              'TimeCourseGroups_Main';
                MainWeightLoss_Handle.Name=             'TimeCourseGroups_Main';

                MainWeightLoss_Handle.Units=            'normalized';
                MainWeightLoss_Handle.Position=         [0.3 0.1 0.5 0.7];
                MainWeightLoss_Handle.MenuBar=          'none';
                MainWeightLoss_Handle.Resize=           'off';
                MainWeightLoss_Handle.Position=         [0.03  0.05  0.9  0.84   ];
            else
                clf(MainWeightLoss_Handle)
            end



            StringOfSelectedFile_Handle=                        uicontrol;
                StringOfSelectedFile_Handle.Tag=                    'CurrentlySelectedFile';

            StringOfSelectedFile_Handle.Style=                      'Listbox';
            StringOfSelectedFile_Handle.Units=                      'normalized';
            StringOfSelectedFile_Handle.Position=                   [0.02 0.86 0.3 0.13];
            StringOfSelectedFile_Handle.HorizontalAlignment=        'left';




         IndexOfGroup_Handle=             uicontrol;
                IndexOfGroup_Handle.Tag=         'CurrentlySelectedGroup';
            IndexOfGroup_Handle.String=             {'1'; '2'};
            IndexOfGroup_Handle.Value=              1;
            IndexOfGroup_Handle.Units=              'normalized';
            IndexOfGroup_Handle.Position=           [0.02 0.75 0.3 0.1];
            IndexOfGroup_Handle.Style=              'Listbox';




             NameOfGroup_Handle=                 uicontrol;
                NameOfGroup_Handle.Tag=             'NameOfGroup1';
            NameOfGroup_Handle.Style=               'Edit';
            NameOfGroup_Handle.Units=               'normalized';
            NameOfGroup_Handle.Position=            [0.02 0.7 0.3 0.03];




             EditData_Handle=                    uitable;
                EditData_Handle.Tag=                'DataOfGroup1';
            EditData_Handle.Units=                  'normalized';
            EditData_Handle.Position=               [0.02 0.03 0.4 0.62];

            EditData_Handle.ColumnEditable=         true;



            ViewPlot_Handle=                     axes;
                ViewPlot_Handle.Position=            [0.5 0.1 0.45 0.85];


                LineHandle(1)=         errorbar(0,0, 0,  '-o', 'LineWidth',1, 'Color', 'k', 'MarkerFaceColor', 'r', 'MarkerSize', 15);
                hold on
                LineHandle(2)=         errorbar(0,0, 0,   '-s', 'LineWidth',1, 'Color', 'b', 'MarkerFaceColor', 'w', 'MarkerSize', 15);
                LineHandle(3)=         errorbar(0,0, 0,   '--d', 'LineWidth',1, 'Color', 'k', 'MarkerFaceColor', 'g', 'MarkerSize', 15);
                LineHandle(4)=         errorbar(0,0, 0,    '--', 'LineWidth',1, 'Color', 'b');
                LineHandle(5)=         errorbar(0,0, 0,    '-', 'LineWidth',1, 'Color', 'k');     
                LineHandle(6)=         errorbar(0,0, 0,    '-', 'LineWidth',1, 'Color', 'g');     


                set(LineHandle,{'Visible'},{'off'})



            obj.Figure =        MainWeightLoss_Handle;
            obj.Experiments =   StringOfSelectedFile_Handle;
            obj.Groups =        IndexOfGroup_Handle;
            obj.GroupName =     NameOfGroup_Handle;
            obj.Data =          EditData_Handle;
            obj.Graph =         ViewPlot_Handle;
            obj.LineHandle =    LineHandle;
        
        end
        
        function obj = setExperiments(obj, Value)
            obj.Experiments.String=     Value(:,1);
            if isempty(obj.Experiments.Value) || obj.Experiments.Value < 1 || obj.Experiments.Value> length(Value)
                obj.Experiments.Value=      1;
            end
             
        end
        
        function obj = setGroups(obj, NumberOfGroups)
            obj.Groups.String=     1:NumberOfGroups;
            if isempty(obj.Groups.Value) || obj.Groups.Value < 1 || obj.Groups.Value> length(NumberOfGroups)
                obj.Groups.Value=      1;
            end
        end
        
        function obj = setGroupName(obj, Data)
            assert(ischar(Data), 'Wrong input type')
            obj.GroupName.String = Data;
        end
        
        function name = getGroupName(obj)
            name = obj.GroupName.String;
        end
        
        function index = getIndexOfSelectedExperiment(obj)
            index = obj.Experiments.Value;
        end
        
        function index = getIndexOfSelectedGroup(obj)
            index = obj.Groups.Value;
        end
        
        function name = getNameOfSelectedExperiment(obj)
            name = obj.Experiments.String{obj.Experiments.Value};
        end
        
    
        
        
         function obj = setData(obj, Data)
             assert(isnumeric(Data) && ismatrix(Data), 'Wrong input type')
             obj.Data.Data=                Data;
             obj.Data.RowName=             1:size(Data,1);
         end
         
         function Data = getData(obj) 
              Data = obj.Data.Data;
         end
         
         function obj = selectedLastExperiment(obj)
            obj.Experiments.Value=              length(obj.Experiments.String);
         end
         
          function obj = selectedLastGroup(obj)
            obj.Groups.Value=              length(obj.Groups.String);
         end
            
        function obj = moveFigureToFront(obj)
            figure(obj.Figure)
        end
        
    end
end

