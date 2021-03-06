![Build](https://travis-ci.org/pemami4911/POMDPy.svg?branch=master) ![Python27](https://img.shields.io/badge/python-2.7-blue.svg) ![Tensorflow16](https://img.shields.io/badge/tensorflow-1.6-blue.svg)

README FILE  
Author: Jianyuan (Jet) Yu  
Affiliation: Wireless, ECE, Virginia Tech  
Email : *jianyuan@vt.edu*  
Date  : April, 2018 

# Simulator Framework
``` C
Construct different Type of Nodes
for t in 1 to numberStep
    for each node
        observation <- get previous observation
        action      <- epsilon-greedy get action based on observation
    update global states
    for each node
        reward      <- get reward based on observation,action
        observation' <- get updated observation
        if nodeType is DQN
            store  [observation, action, reward, observation']
        elseif nodeType is MDP
            update Transition Matrix by observation'
        update policy
```


## Metirc
[terms refer](http://www.cns.nyu.edu/~david/courses/perception/lecturenotes/sdt/sdt.html)

| -    | learning node take one channel to TX   __1__ | learning node WAIT __0__
|----------|----------|----------
| none of channel availble  __1__ | _hit_: __collision__, part of fail| _miss_: __dodge__,correct
| at leat one __0__  |  _false alarm_: __occupy__ correct  | _correct reject_: __absent__, part of fail


```
N_fail    = N_11 + N_00 = N_collision + N_absent
N_success = N_10 + N_01 = N_dodge     + N_occupy
```
Therefore, we only care about __PCR(Packet Collision Rate)__ and __PAR(Packet Absent Rate)__.

```
PCR(Packet Collision Rate) = N_collision              / (N_collision + N_dodge + N_fill + N_absent)
PDR(Packet Dodge     Rate) = N_dodge                  / (N_collision + N_dodge + N_fill + N_absent)
PFR(Packet Fill      Rate) = N_occupy                 / (N_collision + N_dodge + N_fill + N_absent)
PAR(Packet Absent    Rate) = N_absent                 / (N_collision + N_dodge + N_fill + N_absent)
PFR(Packet Failure   Rate) = (N_collision + N_absent) / (N_collision + N_dodge + N_fill + N_absent)
PSR(Packet Success   Rate) = (N_occupy    + N_dodge)  / (N_collision + N_dodge + N_fill + N_absent)
```

1. By default, we adopt PFR and PCR, and expect __low failure rate with low collision rate__.
2. Notice PCR is the only __local__ metric, while others are global.  
3. when met multi-agent, only PCR(Packet __Collision Rate__) stands. 

# Reward Structure
| case    | reward
|----------|----------
| Wait  | -100
| Tranmission | +100
| Transmission and Collision  | -200


Since there is no feedback for wait(you got no idea it is "good" not "bad" wait), the set of Wait is tricky.  

Once learning node have to share one  channel with another legacy, like intermittent, __there should be less penalty for wait(at cost of lower through put, quick but not a recommend way)__, the table becomes
| case    | reward
|----------|----------
| Wait  | -100
| Tranmission | +100
| Transmission and Collision  | -200 -> __-50__


Once channel quality is introduced, the table could be extend to
| case    | reward
|----------|----------
| Wait  | -100
| Tranmission on Good channel | +100
| Transmission Good channel and Collision  | -200
| Tranmission on bad channel | +50
| Transmission on bad channel and Collision  | -100

# Online MDP
``` C
Init transition matrix P, reward matrix R
for t in 1 to numberStep
    for each node
        observation <- get previous observation
        action      <- epsilon-greedy get action based on observation
    update global states
    for each node
        reward      <- get reward based on observation,action
        observation' <- get updated observation

        if nodeType is MDP
            update P,R by observation'
        update policy


```


## epsilon-greedy to get action
![](/README_fig/epsilonGreedy.png)
| type    | scheme    | _`exploreDecayType`_
|----------|----------|----------
| __MDP__  | NOT require `Frozen Time` | _`exp`_, _`step`_, _`perf`_ in _`updatePolicy()`_ of `mdpNode.py`  
| __DQN__ |  -  | _`incre`_, _`exp`_ in _`choose_action()`_  of `dqn.py`  
| __DRQN__ |  require longer explore time   | _`exp`_ in  _`choose_action()`_  of `drqn.py`  
```
```

Besides, the _`timeLearnStart`_ (default value _`1000`_) could be set at `multiNodeLearning.py`, the _`exploreDecay`_(decay rate, default value _`0.01`_),  _`exploreMin`_(default value _`0.01`_) could be set at `mdpNode.py`, `dqn.py`.



## multi-agent



# Different Type of Nodes

## dumb
### constant
![](/README_fig/constant.png)
<!-- <img align="left" width="" height="100" src="/README_fig/constant.png">  -->


### hopping
![](/README_fig/hop.png)
<!-- <img align="left" width="" height="150" src="/README_fig/hop.png">  -->

### intermittent
![](/README_fig/im.png)
<!-- <img align="left" width="" height="100" src="/README_fig/im.png">  -->

## stochastic

### G-E Model/ 2-state Markov Chain
![](/README_fig/ge.png)
<!-- <img align="left" width="" height="150" src="/README_fig/ge.png">  -->

### Possion/ M/M/1 Queue Model
![](/README_fig/mm1.png)
<!-- <img align="left" width="" height="150" src="/README_fig/mm1.png">  -->

## heuristic
### DSA 
| type    | scheme    | comment   |
|----------|----------|----------
| __preSense__  | make action based on __current__ observation | classic, __reactive__ ,perfect, require full observation, low throughput  | 
| __postSense__ |  make action based on __previous__ observation  | would fail when meet hopping or intermittent |     
```
```
![](/README_fig/dsa.png)    
<!-- <img align="left" width="" height="150" src="/README_fig/dsa.png">  -->


Notice DSA do perfect when make action based on current state, while would __fail by making action based on previous state__. It is reactive, not predict or learn.


# Model
![](/README_fig/model.png)
<!-- <img align="left" width="" height="200" src="/README_fig/model.png">  -->


# Single Agent to Multiple Agent DQN
![](/README_fig/sync.png)
![](/README_fig/async1.png)
![](/README_fig/async2.png)


# Noise
![](/README_fig/noise.png)
call function _`noise()`_ would "mess" the observation, with _`noiseErrorProb`_,  _`noiseFlipNum`_.
``` python
messedObservation = noise(observation , noiseErrorProb, noiseFlipNum) 
```  
And `Average corrputed bit = noiseErrorProb * noiseFlipNum `


# Hidden & Expore Node
TODO

# Partial Observation

## partial
```
observation <- state[m:n]
```
![](/README_fig/partial.png)


## padding
```
state[m:n] <- Nan
observation <- state
```
![](/README_fig/pad.png)

## padding with self-action
```
state[m:n] <- Nan
observation <- [state, action]
```
the function _`partialObservtion()`_  is expired, generally we adapt  _`partialObservationAction()`_. Also this parital observation is the default observation function by __DRQN__---.
![](/README_fig/pad-act.png)


## stacked observation
```
observation2 <- state[m:n]
stack <- [observation1,observation2]
```
![](/README_fig/stack.png)