classdef PMNumericalCellArray
    %PMNUMERICALCELLS Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        CellArray
    end
    
    methods
        function obj = PMNumericalCellArray(varargin)
            %PMNUMERICALCELLS Construct an instance of this class
            %   takes one argument:
            % 1: cell vector:
            NumberOfArguments = length(varargin);
            switch NumberOfArguments
                case 1
                     obj.CellArray = varargin{1};
                otherwise
                    error('Wrong input.')
            end
            
            
           
        end
        
        function obj = set.CellArray(obj, Value)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            assert(iscell(Value) && isvector(Value), 'Wrong input.')
            obj.CellArray = Value;
        end
    end
    
    methods
       
           function [Matrix]=  getMatrix(obj)

                NumberOfMainCat=    size(obj.CellArray,1);
                NumberOfSubCat=     max(cellfun(@(x) length(x), obj.CellArray));
                Matrix=             zeros(NumberOfMainCat, NumberOfSubCat);
                
                for MainCatInd = 1 : NumberOfMainCat
                    CurrentEntries=     obj.CellArray{MainCatInd,1};
                    Matrix(MainCatInd, 1 : length(CurrentEntries))=    CurrentEntries;

                end


            end
        
        
    end
    
end

