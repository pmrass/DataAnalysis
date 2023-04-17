classdef PMMatrix
    %PMMATRIX Summary of this class goes here
    %   Detailed explanation goes here
    
    properties(Access = private)
        Matrix
    end
    
    methods
        function obj = PMMatrix(varargin)
            %PMMATRIX Construct an instance of this class
            %   Detailed explanation goes here
            obj.Matrix = varargin{1};
        end
        
      
    end
    
    
    methods
       
        function matrix = getMatrix(obj)
            matrix = obj.Matrix;
        end
        

        function percentageMatrix = getPercentageMatrix(obj)


            Values = obj.Matrix(:);
            Values(isnan(Values)) = [];
             Values(isinf(Values)) = [];

                    percentageMatrix = obj.Matrix / sum(Values) * 100;


            


        end


        function obj = verticalPoolWith(obj, Value, varargin)
            
            assert(isnumeric(Value) && ismatrix(Value), 'Wrong input.')
            assert(size(Value, 2) == size(obj.Matrix, 2), 'Matrices have to match number of columns.')
            
            switch length(varargin)
               
                case 0
                    IdentityColumn  = 1;
                    DeleteNew = 1;
                    
                case 1
                    assert(isnumeric(varargin{1}) && isscalar(varargin{1}) && varargin{1} >= 1 && mod(varargin{1}, 1) == 0, 'Wrong input.')
                    IdentityColumn = varargin{1};
                    DeleteNew = 1;
                    
                case 2
                    
                     IdentityColumn = varargin{1};
                     assert(ischar(varargin{2}), 'Wrong input.')
                     
                     switch varargin{2}
                         case 'RemoveNew'
                              DeleteNew = 1;
                             
                         case 'RemoveOld'
                              DeleteNew = false;
                             
                         otherwise
                             error('Wrong input.')
                         
                         
                     end
                   
                otherwise
                    error('Wrong input.')
                        
                
            end

            if isempty(Value)
                ComplementedStockData=      obj.Matrix;

            else
                
                obj.Matrix=                  sortrows(obj.Matrix, -IdentityColumn);
                if size(obj.Matrix,1)>7
                    obj.Matrix(1:7,:)=       []; % delete most recent entries of old; (if stock-data updated before the end of the day may not be recent)
                end


                if DeleteNew
                    MatchingRows=               ismember (Value (:, IdentityColumn), obj.Matrix (:, IdentityColumn) );
                    Value(MatchingRows,:)=      [];
                
                else
                     MatchingRows=               ismember (obj.Matrix(:, IdentityColumn), Value(:, IdentityColumn) );
                    obj.Matrix(MatchingRows,:)=      [];
                    
                end
                
                ComplementedStockData=      vertcat(Value, obj.Matrix);

            end

            obj.Matrix =     sortrows(ComplementedStockData, -IdentityColumn); % sort stock-info by date;


            
        end
        
        
        
        
        
    end
end

