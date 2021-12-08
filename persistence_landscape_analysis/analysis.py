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

descr: str = """\
Calculate the persistence landscape comparing the 
complete graph with its reduced form."""

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
##### Dimension 0 
## {{{1

graph_G_pph0_sample : list = []

for i in range(SAMPLE_SIZE):
	dir_str                = "politics/sample_" + str(i) + "/pph0.txt"
	sample                 = np.loadtxt (dir_str, dtype=float)
	if (myArgs.useINFTY == 1):
		sample[ sample == -1 ] = INFTY
	if (myArgs.useINFTY == 0):
		sample = sample[ sample[:,1] != -1 ] 
	
	graph_G_pph0_sample.append (sample)

# Persistence Landscape
SH = gd.representations.Silhouette (resolution=SH_RESOLUTION0, \
									weight=lambda x: 1.0, \
									sample_range = [0,SH_MAX_0])
sh = SH.fit_transform (graph_G_pph0_sample)

for i in range(SAMPLE_SIZE):
	plt.plot (sh[i])

#save mean and variance
graph_G_pph0_sh_mean = sh.mean (axis = 0)
graph_G_pph0_sh_var  = sh.var  (axis = 0) * SAMPLE_SIZE / (SAMPLE_SIZE - 1)

if (myArgs.useINFTY == 1):
	plt.savefig ('politics_pph0_sh_with_infty.png')
	plt.close()
	np.savetxt  ('politics_pph0_sh_with_infty.txt', \
                np.transpose ([graph_G_pph0_sh_mean, graph_G_pph0_sh_var]), \
                fmt='%.2f')

if (myArgs.useINFTY == 0):
	plt.savefig ('politics_pph0_sh_without_infty.png')
	plt.close()
	np.savetxt  ('politics_pph0_sh_without_infty.txt', \
                np.transpose ([graph_G_pph0_sh_mean, graph_G_pph0_sh_var]), \
                fmt='%.2f')


graph_F_pph0_sample : list = []

for i in range(SAMPLE_SIZE):
	dir_str                = "football/sample_" + str(i) + "/pph0.txt"
	sample                 = np.loadtxt (dir_str, dtype=float)
	if (myArgs.useINFTY == 1):
		sample[ sample == -1 ] = INFTY
	if (myArgs.useINFTY == 0):
		sample = sample[ sample[:,1] != -1 ] 

	graph_F_pph0_sample.append (sample)

# Persistence Landscape
SH = gd.representations.Silhouette (resolution=SH_RESOLUTION0, \
									weight=lambda x: 1.0, \
									sample_range = [0,SH_MAX_0])
sh = SH.fit_transform (graph_F_pph0_sample)

for i in range(SAMPLE_SIZE):
	plt.plot (sh[i])

#save mean and variance
graph_F_pph0_sh_mean = sh.mean (axis = 0)
graph_F_pph0_sh_var  = sh.var  (axis = 0) * SAMPLE_SIZE / (SAMPLE_SIZE - 1)

if (myArgs.useINFTY == 1):
	plt.savefig ('football_pph0_sh_with_infty.png')
	plt.close()
	np.savetxt  ('football_pph0_sh_with_infty.txt', \
				np.transpose ([graph_F_pph0_sh_mean, graph_F_pph0_sh_var]), \
				fmt='%.2f')

if (myArgs.useINFTY == 0):
	plt.savefig ('football_pph0_sh_without_infty.png')
	plt.close()
	np.savetxt  ('football_pph0_sh_without_infty.txt', \
				np.transpose ([graph_F_pph0_sh_mean, graph_F_pph0_sh_var]), \
				fmt='%.2f')
## 1}}}

##### Dimension 1
## {{{1

graph_G_pph1_sample : list = []

for i in range(SAMPLE_SIZE):
	dir_str                = "politics/sample_" + str(i) + "/pph1.txt"
	sample                 = np.loadtxt (dir_str, dtype=float)
	if (myArgs.useINFTY == 1):
		sample[ sample == -1 ] = INFTY
	if (myArgs.useINFTY == 0):
		sample = sample[ sample[:,1] != -1 ] 

	graph_G_pph1_sample.append (sample)

# Persistence Landscape
SH = gd.representations.Silhouette (resolution=SH_RESOLUTION1, \
									weight=lambda x: 1.0, \
									sample_range = [0,SH_MAX_1])
sh = SH.fit_transform (graph_G_pph1_sample)

for i in range(SAMPLE_SIZE):
	plt.plot (sh[i])

#save mean and variance
graph_G_pph1_sh_mean = sh.mean (axis = 0)
graph_G_pph1_sh_var  = sh.var  (axis = 0) * SAMPLE_SIZE / (SAMPLE_SIZE - 1)

if (myArgs.useINFTY == 1):
	plt.savefig ('politics_pph1_sh_with_infty.png')
	plt.close()
	np.savetxt  ('politics_pph1_sh_with_infty.txt', \
				np.transpose ([graph_G_pph1_sh_mean, graph_G_pph1_sh_var]), \
				fmt='%.2f')

if (myArgs.useINFTY == 0):
	plt.savefig ('politics_pph1_sh_without_infty.png')
	plt.close()
	np.savetxt  ('politics_pph1_sh_without_infty.txt', \
				np.transpose ([graph_G_pph1_sh_mean, graph_G_pph1_sh_var]), \
				fmt='%.2f')


graph_F_pph1_sample : list = []

for i in range(SAMPLE_SIZE):
	dir_str                = "football/sample_" + str(i) + "/pph1.txt"
	sample                 = np.loadtxt (dir_str, dtype=float)
	if (myArgs.useINFTY == 1):
		sample[ sample == -1 ] = INFTY
	if (myArgs.useINFTY == 0):
		sample = sample[ sample[:,1] != -1 ] 

	graph_F_pph1_sample.append (sample)

# Persistence Landscape
SH = gd.representations.Silhouette (resolution=SH_RESOLUTION1, \
									weight=lambda x: 1.0, \
									sample_range = [0,SH_MAX_1])
sh = SH.fit_transform (graph_F_pph1_sample)

for i in range(SAMPLE_SIZE):
	plt.plot (sh[i])

#save mean and variance
graph_F_pph1_sh_mean = sh.mean (axis = 0)
graph_F_pph1_sh_var  = sh.var  (axis = 0) * SAMPLE_SIZE / (SAMPLE_SIZE - 1)

if (myArgs.useINFTY == 1):
	plt.savefig ('football_pph1_sh_with_infty.png')
	plt.close()
	np.savetxt  ('football_pph1_sh_with_infty.txt', \
				np.transpose ([graph_F_pph1_sh_mean, graph_F_pph1_sh_var]), \
				fmt='%.2f')

if (myArgs.useINFTY == 0):
	plt.savefig ('football_pph1_sh_without_infty.png')
	plt.close()
	np.savetxt  ('football_pph1_sh_without_infty.txt', \
				np.transpose ([graph_F_pph1_sh_mean, graph_F_pph1_sh_var]), \
				fmt='%.2f')
## 1}}}
