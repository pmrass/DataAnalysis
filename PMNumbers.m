classdef PMNumbers
    %PMNUMBER Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        Value
    end
    
    methods

        function obj = PMNumbers(varargin)
            %PMNUMBER Construct an instance of this class
            %   Detailed explanation goes here
            switch length(varargin)
               
                case 1
                    obj.Value = varargin{1};
                    
                    
                otherwise
                    error('Wrong input.')
                
            end
        end
        
        function obj = set.Value(obj, Value)
            assert(isnumeric(Value) , 'Wrong input.')
           obj.Value = Value; 
        end
  
    end
    
    methods % GETTERS
        
        function value = getType(obj)
            
            if obj.isIntegerScalar
                value = 'IntegerScalar';
                
            elseif obj.isIntegerVector
                value = 'IntegerVector';
                
            elseif obj.isNumericVector
                value = 'NumericVector';
                
            else
                value = 'UnknownType';
                
                
            end
            
            
        end
        
        
        function value = isNanScalar(obj)
             value = isnumeric(obj.Value) && isscalar(obj.Value) && isnan(obj.Value);
        end
        
        function  value = isNoNanScalar(obj)
             value = isnumeric(obj.Value) && isscalar(obj.Value) && ~isnan(obj.Value);
            
        end
        
        function value = isNoNanVector(obj)
             valueOne =        obj.isNumericVector;
             valueTwo =        (min(isnan(obj.Value)) == 0);
             
             value =        valueOne && valueTwo;
        end
        
        function value = isNumericVector(obj, varargin)
            value = isvector(obj.Value) && isnumeric(obj.Value);
            
            switch length(varargin)
               
                case 0
                
                case 1
                    value = (value && length(obj.Value) == varargin{1});
                    
                otherwise
                    error('Wrong input.')
                    
                    
            end
           
            
        end
        
        function value = isIntegerVector(obj)
            
            if isvector(obj.Value)
                value =             min(arrayfun(@(x) obj.isIntegerForValue(x), obj.Value));
                
            else
                value =             false;
                
            end
            
            
        end
        
        function value = isIntegerScalar(obj)
            
            if obj.isIntegerForValue(obj.Value)
                
                if isscalar(obj.Value)
                    value = true;
                else
                    value = false;
                end
            else
                
                value = false;
                
            end
            
        end
        
        
        
        
        
        
    end
    
    methods (Access = private)
        
         function value = isScalarIntegerForValue(obj , MyValue)
            
            if obj.isIntegerForValue(MyValue)
                
                if isscalar(MyValue)
                    value = true;
                else
                    value = false;
                end
            else
                
                value = false;
                
            end
            
         end
         
           function value = isIntegerForValue(obj, Value)
            %ISINTEGER tests whether number is integer
            
            if isnumeric(Value)
                
                  result = mod(Value, 1);
                    if result == 0
                        value = true;
                    else
                        value = false;
                    end
                
                    
                
            else
                value = false;
               
            end
            
           
           end
          
        
        
    end
    
    
end

