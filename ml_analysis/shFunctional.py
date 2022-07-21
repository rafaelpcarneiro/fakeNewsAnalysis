#!/usr/bin/env python3
# vim: set noexpandtab foldmethod=marker:

import gudhi as gd
import numpy as np
import gudhi.representations
import glob

############################## CONSTANTS #############################
## GRAPHS folders
##GRAPHS = [ 'mariliaMendonca', 'football', 'f1' ]
##		   #'onu', 'mitoVisitaPutin', 'politicsAR' ]
##
##GROUPS_PER_GRAPH   : int = 16
##SAMPLE_PER_GROUP   : int = 30
##SAMPLE_SIZE        : int = GROUPS_PER_GRAPH * SAMPLE_PER_GROUP # == 480
###SAMPLE_SIZE        : int = 5
##SH_RESOLUTION0     : int = 1_000 
##SH_MAX_0           : int = 97_000

class shFunctionalDim0_1():

	def __init__(self, 
				 graphName,
				 number_pph0Samples,
				 number_pph1Samples,
				 sh_resolution0 = 1_000,
				 sh_resolution1 = 1_000,
				 sh_max0        = 97_000,
				 sh_max1        = 97_000):

		self.__graphName           = graphName

		self.__sh_resolution0      = sh_resolution0
		self.__sh_max0             = sh_max0
		self.__number_pph0Samples  = number_pph0Samples

		self.__sh_resolution1      = sh_resolution1
		self.__sh_max1             = sh_max1
		self.__number_pph1Samples  = number_pph1Samples

		self.__shFunctionals       = None

		self.calcFunctionals()
	
	def set_shFunctionals(self, shFunctionals):
		self.__shFunctionals = { 
			"dim0" : shFunctionals[0],
			"dim1" : shFunctionals[1]
		}

	#def get_shFunctionals(self):
	#	return self.__shFunctionals

	def get_sh_resolution0(self):
		return self.__sh_resolution0

	def get_sh_max0(self):
		return self.__sh_max0

	def get_sh_resolution1(self):
		return self.__sh_resolution1

	def get_sh_max1(self):
		return self.__sh_max1

	def get_graphName(self):
		return self.__graphName

	def get_number_pph0Samples(self):
		return self.__number_pph0Samples 

	def get_number_pph1Samples(self):
		return self.__number_pph1Samples 

	def calcFunctionals(self):
		##### Dimension 0 
		sh0 = {
			"all_samples_30perc": None,
			"all_samples_35perc": None,
			"all_samples_40perc": None
		}
		sh1 = {
			"all_samples_30perc": None,
			"all_samples_35perc": None,
			"all_samples_40perc": None
		}

		list_all_samples = [
			"all_samples_30perc",
			"all_samples_35perc",
			"all_samples_40perc"
		]

		for samplePerc in list_all_samples:
			pph0_sample : list = []
			pph1_sample : list = []

			dir_ls    = self.get_graphName() + "/" + samplePerc + "/" + "/sample_*"
			dir_files = glob.glob(dir_ls)

			for file in dir_files:
				pph0File = file + "/pph0.txt"
				pph1File = file + "/pph1.txt"
				
				# dim == 0
				sample  = np.loadtxt (pph0File, dtype=float)
				sample  = sample[ sample[:,1] != -1 ] 
				
				pph0_sample.append (sample)

				# dim == 1
				sample  = np.loadtxt (pph1File, dtype=float)
				sample  = sample[ sample[:,1] != -1 ] 
				
				pph1_sample.append (sample)


			SH0 = gd.representations.Silhouette (
				resolution = self.get_sh_resolution0(),
				weight=lambda x: 1.0, 
				sample_range = [0,self.get_sh_max0()]
			)
			SH1 = gd.representations.Silhouette (
				resolution = self.get_sh_resolution1(),
				weight=lambda x: 1.0, 
				sample_range = [0,self.get_sh_max1()]
			)

			sh0[samplePerc] = SH0.fit_transform (
				pph0_sample[ : self.get_number_pph0Samples()]
			)
			sh1[samplePerc] = SH1.fit_transform (
				pph1_sample[ : self.get_number_pph1Samples()]
			)

		self.set_shFunctionals([sh0, sh1])

	def saveFunctionals(self, directory='data'):
		list_all_samples = [
			"all_samples_30perc",
			"all_samples_35perc",
			"all_samples_40perc"
		]

		for samplePerc in list_all_samples:
			np.savetxt (
				directory + '/' + self.get_graphName() + '_' + samplePerc + '_sh_curve_dim0.txt', 
				self.__shFunctionals['dim0'][samplePerc],
				delimiter=' ',
				fmt='%.4f'
			)
			np.savetxt (
				directory + '/' + self.get_graphName() + '_' + samplePerc + '_sh_curve_dim1.txt', 
				self.__shFunctionals['dim1'][samplePerc],
				delimiter=' ',
				fmt='%.4f'
			)

if __name__ == '__main__':
	## GRAPHS folders
	GRAPHS = [ 
		'graph_mariliaMendonca',
		'graph_football',
		'graph_f1',
		'graph_onu',
		'graph_mitoVisitaPutin', 
		'graph_politicsAR'
	]
	
	##GROUPS_PER_GRAPH   : int = 16
	##SAMPLE_PER_GROUP   : int = 30
	##SAMPLE_SIZE        : int = GROUPS_PER_GRAPH * SAMPLE_PER_GROUP # == 480
	###SAMPLE_SIZE        : int = 5
	##SH_RESOLUTION0     : int = 1_000 
	##SH_MAX_0           : int = 97_000
	NUMBER_PPH0SAMPLES : int = 10
	NUMBER_PPH1SAMPLES : int = 10,
	SH_RESOLUTION0     : int = 1_000,
	SH_RESOLUTION1     : int = 1_000,
	SH_MAX0            : int = 97_000,
	SH_MAX1            : int = 97_000
	
	obj = None
	for graph in GRAPHS:
		obj  = shFunctionalDim0_1(
			graph,
			NUMBER_PPH0SAMPLES,
			NUMBER_PPH1SAMPLES,
			SH_RESOLUTION0,
			SH_RESOLUTION1,
			SH_MAX_0,
			SH_MAX1
		)

		obj.saveFunctionals()
   
	#mitoVisitaPutin = shFunctionalDim0('mitoVisitaPutin', number_pph0Samples = 400)
	#mitoVisitaPutin.saveFunctionals()

	#onu = shFunctionalDim0('onu', number_pph0Samples = 400)
	#onu.saveFunctionals()

	#politcsAR = shFunctionalDim0('politcsAR', number_pph0Samples = 400)
	#politcsAR.saveFunctionals()
