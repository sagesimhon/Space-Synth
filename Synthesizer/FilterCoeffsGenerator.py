# -*- coding: utf-8 -*-
"""
Created on Fri Nov  6 15:27:57 2020

@author: Praj
"""

import scipy.signal as signal
f = open('filter_coeffs.txt', 'w')

min_freqency = 100
max_frequency = 5000
sampling_frequency = 48000

nyquist = sampling_frequency/2
stepsize = (max_frequency-min_freqency)/256

for i in range (256):
    cutoff_frequency = i*stepsize+min_freqency
    frequency_ratio = cutoff_frequency/nyquist
    b,a = signal.iirfilter(1,frequency_ratio,btype='lowpass')
    f.write("8'd{}: begin".format(i))
    f.write("\n")
    f.write("        ")
    f.write("b0_out <= 16'sd{};".format(int(round(b[0]*2**14))))
    f.write("\n")
    f.write("        ")
    f.write("a1_out <= 16'sd{};".format(int(abs(round(a[1]*2**14)))))
    f.write("\n")
    f.write("      end")
    f.write("\n")
    f.write("\n")

f.close()