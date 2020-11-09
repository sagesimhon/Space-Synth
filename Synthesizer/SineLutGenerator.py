# -*- coding: utf-8 -*-
"""
Created on Thu Nov  5 16:13:17 2020

@author: Praj
"""

import math

numbits = 8

numSteps = 2**numbits
stepSize = 2*math.pi/numSteps

currentStep = 0;

for i in range(numSteps):
    
    currentRads = currentStep * stepSize
    val = round(math.sin(currentRads)*127)+127
    line = "8'd{}: amp_out<=8'd{};".format(currentStep,val)
    print(line)
    currentStep = currentStep + 1