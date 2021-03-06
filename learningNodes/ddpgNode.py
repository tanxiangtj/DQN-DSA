#!/usr/bin/env python2
# -*- coding: utf-8 -*-
"""
Created on Mon Apr  2 00:45:09 2018

@author: Jet
"""

from dumbNodes.radioNode import radioNode
from myFunction import ismember   #
import random
import numpy as np

#from actor import Actor
#from critic import Critic

import ddpg

import tensorflow as tf

np.random.seed(2)
tf.set_random_seed(2)  # reproducible

class ddpgNode(radioNode):
    goodChans     = [ ]    
    numStates     = [ ]
    states        = [ ]
    stateHist     = [ ]
    stateTally    = [ ]
    stateTrans    = [ ]
    avgStateTrans = [ ]
    
    discountFactor   = 0.9
    policyAdjustRate = 5         # Policy is adjusted at this step increment
    
            
    policy           = [ ] 
    policyHist       = [ ]        
    # [Not transmitting, Good Channel no Interference, Good Channel Interference, 
    # Bad Channel no Interference, Bad Channel Interference]
    rewards          = [-200, 100, -200, 50, -100]   
    # different duty cycle need different rewards   
    rewardHist       = [ ]
    rewardTally      = [ ]        
    rewardTrans      = [ ]
    cumulativeReward = [ ]
    

    
    def __init__(self,numChans,states,numSteps):
        self.actions = np.zeros((numChans+1,numChans))
        for k in range(0,numChans):
            self.actions[k+1,k] = 1
        self.numChans      = numChans
        self.numActions    = np.shape(self.actions)[0]
        self.actionTally   = np.zeros(numChans+1)
        self.actionHist    = np.zeros((numSteps,numChans))
        self.actionHistInd = np.zeros(numSteps)
        
        self.goodChans     = np.ones(numChans)
        
        self.states        = states
        self.numStates     = np.shape(states)[0]
        
        self.stateHist     = np.zeros((numSteps,numChans))
        self.stateTally    = np.zeros(self.numStates)
      
        self.rewardHist    = np.zeros(numSteps)
        self.rewardTally   = np.zeros(numChans+1)
        self.cumulativeReward = np.zeros(numSteps)
        self.rewardTrans   = np.zeros((self.numActions, self.numStates,self.numStates) )
        
        self.exploreHist   = [ ]
        
        self.policy = np.zeros(numChans)
               
        self.n_actions     = numChans + 1   
        self.n_features    = numChans 
        
        self.ddpg_         = ddpg.DDPG(self, self.n_actions, self.n_features, self.n_actions + 1 )
        
        self.type          = "ddpg"
        self.hyperType     = "learning"
        
        self.var = 1
        
        
        

    
        
    def getAction(self, stepNum ,observation):
        
        temp = self.ddpg_.choose_action(observation)  
#        print "raw action%s"%(temp)
        temp = np.clip(np.random.normal(temp, self.var), 0, 4)
#        temp = np.clip(temp, 0, 4)
#        print "clip action%s"%(temp)
        temp = int(max(np.ceil(temp)))
#        print "final action%s"%(temp)
#        print "---------------------"
#        print "action%s"%(temp)
        # !!! new define, convert action from a int to a array
        action       = np.zeros(self.numChans) 
        if temp > 0:
            action[temp-1] = 1 
        
        self.actionHist[stepNum,:] = action                   
        if not np.sum(action):
            self.actionTally[0] +=    1
            self.actionHistInd[stepNum] = 0
        else:
            self.actionHistInd[stepNum] = np.where(action == 1)[0] + 1
            self.actionTally[1:] += action
        
        return action, temp  
    
    
    def getReward(self,collision,stepNum, isWait):
        
        if isWait == True:
             self.rewards  = [-50, 100, -200, 50, -100] 
        action = self.actionHist[stepNum,:]
        if not np.sum(action):
            reward = self.rewards[0]
            self.rewardTally[0] +=  reward
        else:
            if any(np.array(self.goodChans+action) > 1): 
                if collision == 1:
                    reward = self.rewards[2]
                else:
                    reward = self.rewards[1]             
            else:
                if collision == 1:
                    reward = self.rewards[4]
                else:
                    reward = self.rewards[3]  
                    
#            if stepNum > 5000:
#                reward *= stepNum*0.1   
#            else:
#                pass
 
            self.rewardTally[1:] += action * reward        
        self.rewardHist[stepNum] = reward   
        
        if stepNum == 0:
            self.cumulativeReward[stepNum] = reward
        else:
            self.cumulativeReward[stepNum] = self.cumulativeReward[stepNum-1] + reward
        return reward  
    
    
    def storeTransition(self, s, a, r, s_):
         self.ddpg_.store_transition(s, a, r/10, s_)   

        
    def learn(self):      
        self.ddpg_.learn()
        

       
        
        
        