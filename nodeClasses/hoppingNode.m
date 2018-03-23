classdef hoppingNode < radioNode
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Defines a node with the default behavior of always hopping between
    % its available channels.
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    properties
        hopRate
        hopPattern
        hopIndex = 1
    end
    
    methods
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Constructor
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function obj = hoppingNode(numChans,numSteps)
            obj.actions = zeros(6,numChans);
            obj.actions(1,1) = 1;
            obj.actions(2,3) = 1;
            obj.actions(3,5) = 1;
            obj.actions(4,7) = 1;
            obj.actions(5,9) = 1;
            obj.actions(6,11) = 1;
            
            obj.numActions = size(obj.actions,1); 
            obj.actionTally = zeros(1,numChans+1);
            obj.actionHist = zeros(numSteps,numChans);
            obj.actionHistInd = zeros(1,numSteps);
            
            obj.hopRate = 1;
            obj.hopPattern = [1,2,3,4,5,6];
        end    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Determines an action from the node's possible actions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function action = getAction(obj,stepNum)
            if ~mod(stepNum,obj.hopRate)
                obj.hopIndex = obj.hopIndex + 1;
                if obj.hopIndex > length(obj.hopPattern)
                    obj.hopIndex = 1;
                end
            end
            action = obj.actions(obj.hopIndex,:);
            
            obj.actionHist(stepNum,:) = action;
            obj.actionHistInd(stepNum) = find(action == 1) + 1;
            
            if ~sum(action)
                obj.actionTally(1) = obj.actionTally(1) + 1;
            else
                obj.actionTally(2:end) = obj.actionTally(2:end) + action;
            end
        end
    end
end
