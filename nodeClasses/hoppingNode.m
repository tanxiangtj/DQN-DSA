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
            obj.actions = zeros(2,numChans);        % matrix than vector, fix than random
            % hopping occupy part of all channels
            obj.actions(1,2) = 1;   % hardcore stuff
            obj.actions(2,4) = 1;
%             obj.actions(2,3) = 1;   % actions(sequence, channel)

%             obj.actions(3,5) = 1;
%             obj.actions(4,7) = 1;
%             obj.actions(5,9) = 1;
%             obj.actions(6,11) = 1;
            
            % go and module these lines
            
            
            obj.numActions = size(obj.actions,1); 
            obj.actionTally = zeros(1,numChans+1);
            obj.actionHist = zeros(numSteps,numChans);
            obj.actionHistInd = zeros(1,numSteps);
            
            obj.hopRate = 1;    % hop rate, the freq it decide to hop next channel
            obj.hopPattern = [1,2];   % === configurable ======
        end    
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        % Determines an action from the node's possible actions
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        function action = getAction(obj,stepNum)    % do not mix actions and action
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
