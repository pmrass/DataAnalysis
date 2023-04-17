classdef PMExperimentsMenu
    %PMEXPERIMENTSMENU Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        MainFigure
        
        OpenNewProject
        ChangeProject
        
        AddExperiment
        DeleteExperiment
        ChangeExperimentName
        
        AddGroup
        DeleteGroup
        
        RefreshGraph
    end
    
    methods
        function obj = PMExperimentsMenu(varargin)
            %PMEXPERIMENTSMENU Construct an instance of this class
            %   Detailed explanation goes here
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 0
                case 1
                     obj.MainFigure = varargin{1};
                     obj = obj.setMenu;
                otherwise
                    error('Wrong number of arguments')     
            end
            
        end
        
        function obj = setMenu(obj)
            
            WeightLossMenu_File=                                    uimenu(obj.MainFigure);
            WeightLossMenu_File.Tag=                                'WeightLossMenu_File';
            WeightLossMenu_File.Label=                              'Project';

            WeightLossMenu_Load=                                    uimenu(WeightLossMenu_File);
            WeightLossMenu_Load.Tag=                                'WeightLossMenu_Load';
            WeightLossMenu_Load.Label=                              'Load other project';

            WeightLossMenu_New=                                     uimenu(WeightLossMenu_File);
            WeightLossMenu_New.Tag=                                 'WeightLossMenu_New';
            WeightLossMenu_New.Label=                               'Create new project';

            %% experiment menu:
            WeightLossMenu_Experiment=                              uimenu(obj.MainFigure);
            WeightLossMenu_Experiment.Tag=                          'WeightLossMenu_Experiment';
            WeightLossMenu_Experiment.Label=                        'Experiment';

            WeightLossMenu_AddExperiment=                            uimenu(WeightLossMenu_Experiment);
            WeightLossMenu_AddExperiment.Tag=                        'WeightLossMenu_AddExperiment';
            WeightLossMenu_AddExperiment.Label=                      'Add experiment';

            WeightLossMenu_DeleteExperiment=                            uimenu(WeightLossMenu_Experiment);
            WeightLossMenu_DeleteExperiment.Tag=                        'WeightLossMenu_DeleteExperiment';
            WeightLossMenu_DeleteExperiment.Label=                      'Delete experiment';

             WeightLossMenu_ChangeExperimentName=                            uimenu(WeightLossMenu_Experiment);
            WeightLossMenu_ChangeExperimentName.Label=                      'Chnange experiment name';

            
            
            WeightLossMenu_Group=                                   uimenu(obj.MainFigure);
            WeightLossMenu_Group.Tag=                               'WeightLossMenu_Group';
            WeightLossMenu_Group.Label=                             'Group';

            WeightLossMenu_AddGroup=                                uimenu(WeightLossMenu_Group);
            WeightLossMenu_AddGroup.Tag=                            'WeightLossMenu_AddGroup';
            WeightLossMenu_AddGroup.Label=                          'Add group';


            WeightLossMenu_DeleteGroup=                            uimenu(WeightLossMenu_Group);
            WeightLossMenu_DeleteGroup.Tag=                        'WeightLossMenu_DeleteGroup';
            WeightLossMenu_DeleteGroup.Label=                      'Delete group';

            WeightLossMenu_View=                                    uimenu(obj.MainFigure);
            WeightLossMenu_View.Tag=                                'WeightLossMenu_View';
            WeightLossMenu_View.Label=                              'View';

            WeightLossMenu_PlotData=                                uimenu(WeightLossMenu_View);
            WeightLossMenu_PlotData.Tag=                            'WeightLossMenu_PlotData';
            WeightLossMenu_PlotData.Label=                          'Plot data';


            
            obj.OpenNewProject =    WeightLossMenu_New;
            obj.ChangeProject =     WeightLossMenu_Load;
            obj.AddExperiment =     WeightLossMenu_AddExperiment;
            obj.DeleteExperiment =  WeightLossMenu_DeleteExperiment;
            obj.ChangeExperimentName = WeightLossMenu_ChangeExperimentName;
            obj.AddGroup =          WeightLossMenu_AddGroup;
            obj.DeleteGroup =       WeightLossMenu_DeleteGroup;
            obj.RefreshGraph =      WeightLossMenu_PlotData;
    
    
            
        end
        
        
 
        
        
        
        
    end
end

