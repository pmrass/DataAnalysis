classdef PMVector
    %PMVECTOR Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = private)
        Vector
        
    end
    
    methods % initialize
        
          function obj = PMVector(varargin)
            %PMVECTOR Construct an instance of this class
            %   Detailed explanation goes here
            NumberOfArguments = length(varargin);
            switch  NumberOfArguments
                case 0
                case 1
                    obj.Vector = varargin{1};
                    
                otherwise
                    error('Wrong input.')
                
                
            end
        end
        
        function obj = set.Vector(obj, Value)
            %METHOD1 Summary of this method goes here
            %   Detailed explanation goes here
            assert(isnumeric(Value) && isvector(Value), 'Wrong input.')
            obj.Vector = Value;
        end
        
        
        
    end
    
    methods % basic getters
        
        function vector = getValues(obj)
            vector = obj.Vector;
        end
        
        
    end
    
    methods % split
        
        function splitted = getLinearlySplitVectors(obj, Number)
            % GETLINEARLYSPLITVECTORS split vector into linearly spaced subvectors;
            % takes 1 argument:
            % 1: numeric positive integer scalar: number of wanted splits;
            % returns cell array of subectors;
            assert(isscalar(Number) && mod(Number, 1) == 0 && Number >= 1, 'Wrong input.') 
            
        end
        
        
        
    end
    
    methods
       
        function Limits = getLimitsOfSurroundedFirstForwardGap(obj)
            % GETLIMITSOFSURROUNDEDFIRSTFORWARDGAP
            % returns 1 value:
            % vector of 2 values:
            % first value: index of gap start:
            % second value: index of gap end
            % requirement is that gap is surrounded at beginning and end by "full" values;
            [GapPositions, ~] =    obj.getGapPositions;
            
            if isempty(GapPositions)
                    Limits = zeros(0,2);

            elseif length(GapPositions) >= 1
                 
                 ValueBeforeGap =   obj.Vector(GapPositions(1) - 1);
                 ValueAfterGap =    obj.Vector(GapPositions(1));
                 Limits =           [ValueBeforeGap + 1, ValueAfterGap - 1];
            end
            
        end
        
        function Limits = getLimitsOfFirstForwardGapForLimitValue(obj, LimitValue)
            % GETLIMITSOFFIRSTFORWARDGAPFORLIMITVALUE
            % returns 1 value:
            % numerical matrix:
            % each row contains data for a gap
            % first column: index of gap start:
            % second column index of gap end
            [GapPositions, ~] =    obj.getGapPositions;
            
            if isempty(GapPositions)
                
                if max(obj.Vector) < LimitValue
                    Limits = [max(obj.Vector) + 1, LimitValue];
                else 
                    Limits = zeros(0,2);
             
                end
                
            elseif length(GapPositions) >= 1
                 ValueBeforeGap =   obj.Vector(GapPositions(1) - 1);
                 ValueAfterGap =    obj.Vector(GapPositions(1));
                 Limits =           [ValueBeforeGap + 1, ValueAfterGap - 1];
            end
            
        end
        
        function Limits = getLimitsOfFirstBackwardGapForLimitValue(obj, LimitValue)
            % GETLIMITSOFFIRSTBACKWARDGAPFORLIMITVALUE
            % similar to getLimitsOfFirstForwardGapForLimitValue except that the range is between high and low frame (instead between low and high frame);
            
            [GapPositions, ~] =    obj.getGapPositions;
            
            if isempty(GapPositions)
                
                if min(obj.Vector) > 1
                    Limits = [1, min(obj.Vector) - 1];
                else
                    Limits = zeros(0,2);
                end
                
            elseif length(GapPositions) >= 1
                
                ValueBeforeGap = obj.Vector(GapPositions(1) - 1);
                 ValueAfterGap = obj.Vector(GapPositions(1));
                 Limits = [ValueAfterGap - 1, ValueBeforeGap + 1];
            end
            
            
        end
        
        function [GapPositions, GapLengths] = getGapPositions(obj)
            % GETGAPPOSITIONS find "gaps" in vector:
            % a gap is when the numbers change by a value higher than one;
            % returns a list of all gaps:
            % 1: position (index) of gap
            % 2: length of gap
            Differences =       diff(obj.Vector);
            GapPositions=       find(Differences > 1);
            GapLengths =        Differences(GapPositions) - 1;
            GapPositions =      GapPositions + 1;
        end
        
        
        function HighestValue = getLastValueOfGaplessIntegerSeriesStartingFromValue(obj, Value)
            % 0 1 2 4 5 6 8 9 10; 5
            obj.Vector(obj.Vector < Value,:) = []; % 5 6 8 9 10
            FirstGapIndex = find(diff(obj.Vector) > 1, 1, 'first') + 1; %  at value 8
            if ~isempty(FirstGapIndex)
                obj.Vector(FirstGapIndex:end,:) = []; % 5 6
            end
            HighestValue = obj.Vector(end); % 6

        end
        
         function StartingValue = getFirstValueOfGaplessIntegerSeriesStartingFromValue(obj, Index)
             % 0 1 2 4 5 6 8 9 10 : 5
                obj.Vector(obj.Vector > Index,:) = []; % 0 1 2 4 5
                LastGapIndex = find(diff(obj.Vector) > 1, 1, 'last') ; % at value 4 : double check if this is corrector whetherthis is off by one;
               if ~isempty(LastGapIndex)
                   obj.Vector(1: LastGapIndex,:) = []; % 4 5
               end
               StartingValue = obj.Vector(1); % 4

        end
        
        function [ ListWithSubvectors ] = ExtractOverlappingSubvectorsWithLength( Vector, LengthOfSubVector )
            %EXTRACTOVERLAPPINGSUBVECTORS Summary of this function goes here
            %   Detailed explanation goes here



            TotalNumberOfColumns=   length(Vector)-LengthOfSubVector+ 1;
            ListWithSubvectors=     zeros(LengthOfSubVector,TotalNumberOfColumns);

            LastPosition= 0;
            for CurrentStartStep= 1 : LengthOfSubVector
                MatrixWithSplitVectors=Vector;

                NumberOfVectorElementsBeforeTruncation=     length(MatrixWithSplitVectors);
                NumberOfElementsThatDoNotFit=               mod(NumberOfVectorElementsBeforeTruncation,LengthOfSubVector);
                MatrixWithSplitVectors(NumberOfVectorElementsBeforeTruncation-NumberOfElementsThatDoNotFit+1:NumberOfVectorElementsBeforeTruncation)=[];
                NumberOfVectorElementsAfterTrunction=       length(MatrixWithSplitVectors);
                NumberOfVectors=                            NumberOfVectorElementsAfterTrunction/LengthOfSubVector;

                FirstPosition=      LastPosition+ 1;
                LastPosition=       FirstPosition+NumberOfVectors-1;

                ListWithSubvectors(1:LengthOfSubVector,FirstPosition:LastPosition)=  reshape(MatrixWithSplitVectors,3,NumberOfVectors);
                Vector(:,1)=[];


            end



            end

        
        
    end
end

