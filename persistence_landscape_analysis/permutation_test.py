#!/usr/bin/env python3
# vim: set noexpandtab foldmethod=marker:

import gudhi as gd
import numpy as np
import matplotlib.pyplot as plt
import gudhi.representations
import argparse

# Here G, F are representations of graphs
# G => is a graph whose contents are related with politics
# F => is a graph whose contents are related with football

descr: str = "Perform the permutation test"

myHelp :str = 'Use the infty at the analysis or not. 1 == yes. 0 == no'

parser = argparse.ArgumentParser (description=descr)
parser.add_argument ("--infty", 
                     action='store',
                     dest = 'useINFTY',
                     type = int,
                     required = True,
                     help = myHelp)

myArgs : list  = parser.parse_args()

# CONSTANTS
INFTY          : int = 282667
SAMPLE_SIZE    : int = 3
SH_RESOLUTION1 : int = 4712
SH_MAX_1       : int = INFTY
SH_RESOLUTION0 : int = 4712
SH_MAX_0       : int = INFTY
PERM_TEST_ITER : int = 15
##### Dimension 0 
## {{{1

# From 0:SAMPLE_SIZE             we have all pph diagrams belonging to graph G
# From SAMPLE_SIZE:2*SAMPLE_SIZE we have all pph diagrams belonging to graph F
pph0_sample : list = []

for i in range(SAMPLE_SIZE):
	dir_str                = "politics/sample_" + str(i) + "/pph0.txt"
	sample                 = np.loadtxt (dir_str, dtype=float)
	if (myArgs.useINFTY == 1):
		sample[ sample == -1 ] = INFTY
	if (myArgs.useINFTY == 0):
		sample = sample[ sample[:,1] != -1 ] 
	
	pph0_sample.append (sample)

for i in range(SAMPLE_SIZE):
	dir_str                = "football/sample_" + str(i) + "/pph0.txt"
	sample                 = np.loadtxt (dir_str, dtype=float)
	if (myArgs.useINFTY == 1):
		sample[ sample == -1 ] = INFTY
	if (myArgs.useINFTY == 0):
		sample = sample[ sample[:,1] != -1 ] 
	
	pph0_sample.append (sample)

# Persistence Landscape
SH = gd.representations.Silhouette (resolution=SH_RESOLUTION0, \
									weight=lambda x: 1.0, \
									sample_range = [0,SH_MAX_0])

sh = SH.fit_transform (pph0_sample)

shG = sh[:SAMPLE_SIZE].mean (axis = 0)
shF = sh[SAMPLE_SIZE:].mean (axis = 0)

diff_value_to_compare = np.abs(shG - shF).max()

pph0_sample    = [] # free memory
pvalue : float = 0
for test_iter in range(PERM_TEST_ITER):
	
	# shuffle all persistence landscapes
	functional_indexes = np.arange (2*SAMPLE_SIZE)
	np.random.shuffle (functional_indexes)
	
	shG = sh[functional_indexes[:SAMPLE_SIZE]].mean (axis = 0)
	shF = sh[functional_indexes[SAMPLE_SIZE:]].mean (axis = 0)
	
	sh_diff = np.abs(shG - shF).max()
	if (sh_diff >= diff_value_to_compare):
		pvalue += 1.0 / PERM_TEST_ITER

# Print results
if (myArgs.useINFTY == 1):
	print ("Obs: Infty was included on the analysis")
else:
	print ("Obs: Infty was not included on the analysis")

print ("\n")
print ("Permutation test")
print ("================")
print (" Dim = 0 ----> p-value: {}".format(pvalue))

## 1}}}

##### Dimension 1
## {{{1

# From 0:SAMPLE_SIZE             we have all pph diagrams belonging to graph G
# From SAMPLE_SIZE:2*SAMPLE_SIZE we have all pph diagrams belonging to graph F
pph1_sample : list = []

for i in range(SAMPLE_SIZE):
	dir_str                = "politics/sample_" + str(i) + "/pph1.txt"
	sample                 = np.loadtxt (dir_str, dtype=float)
	if (myArgs.useINFTY == 1):
		sample[ sample == -1 ] = INFTY
	if (myArgs.useINFTY == 0):
		sample = sample[ sample[:,1] != -1 ] 
	
	pph1_sample.append (sample)

for i in range(SAMPLE_SIZE):
	dir_str                = "football/sample_" + str(i) + "/pph1.txt"
	sample                 = np.loadtxt (dir_str, dtype=float)
	if (myArgs.useINFTY == 1):
		sample[ sample == -1 ] = INFTY
	if (myArgs.useINFTY == 0):
		sample = sample[ sample[:,1] != -1 ] 
	
	pph1_sample.append (sample)

# Persistence Landscape
SH = gd.representations.Silhouette (resolution=SH_RESOLUTION1, \
									weight=lambda x: 1.0, \
									sample_range = [0,SH_MAX_1])

sh = SH.fit_transform (pph1_sample)

shG = sh[:SAMPLE_SIZE].mean (axis = 0)
shF = sh[SAMPLE_SIZE:].mean (axis = 0)

diff_value_to_compare = np.abs(shG - shF).max()

pph1_sample    = [] # free memory
pvalue : float = 0
for test_iter in range(PERM_TEST_ITER):
	
	# shuffle all persistence landscapes
	functional_indexes = np.arange (2*SAMPLE_SIZE)
	np.random.shuffle (functional_indexes)
	
	shG = sh[functional_indexes[:SAMPLE_SIZE]].mean (axis = 0)
	shF = sh[functional_indexes[SAMPLE_SIZE:]].mean (axis = 0)
	
	sh_diff = np.abs(shG - shF).max()
	if (sh_diff >= diff_value_to_compare):
		pvalue += 1.0 / PERM_TEST_ITER

# Print results
print (" Dim = 1 ----> p-value: {}\n".format(pvalue))

## 1}}}
