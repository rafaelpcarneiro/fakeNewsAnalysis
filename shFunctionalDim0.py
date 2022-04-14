#!/usr/bin/env python3
# vim: set noexpandtab foldmethod=marker:

import gudhi as gd
import numpy as np
import gudhi.representations


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

class shFunctionalDim0():

	def __init__(self, 
				 graphName,
				 number_pph0Samples,
				 sh_resolution0 = 1_000,
				 sh_max0        = 97_000):

		self.__graphName           = graphName
		self.__sh_resolution0      = sh_resolution0
		self.__sh_max0             = sh_max0
		self.__number_pph0Samples  = number_pph0Samples
		self.__shFunctionals       = None

		self.calcFunctionals()
	
	def set_shFunctionals(self, shFunctionals):
		self.__shFunctionals = shFunctionals

	def get_shFunctionals(self):
		return self.__shFunctionals

	def get_sh_resolution0(self):
		return self.__sh_resolution0

	def get_sh_max0(self):
		return self.__sh_max0

	def get_graphName(self):
		return self.__graphName

	def get_number_pph0Samples(self):
		return self.__number_pph0Samples 

	def calcFunctionals(self):
		##### Dimension 0 

		pph0_sample : list = []

		for i in range(self.get_number_pph0Samples()):
			dir_str = self.get_graphName() + "/sample_" + str(i) + "/pph0.txt"
			sample  = np.loadtxt (dir_str, dtype=float)
			sample  = sample[ sample[:,1] != -1 ] 
			
			pph0_sample.append (sample)


		SH = gd.representations.Silhouette (resolution = self.get_sh_resolution0(),
											weight=lambda x: 1.0, 
											sample_range = [0,self.get_sh_max0()])

		sh = SH.fit_transform (pph0_sample)

		self.set_shFunctionals(sh)

		pph0_sample = []

	def saveFunctionals(self, directory='data'):
		np.savetxt (directory + '/' + self.get_graphName() + '_sh_curve.txt', 
					self.get_shFunctionals(),
					delimiter=' ',
					fmt='%.4f')

if __name__ == '__main__':
	mitoVisitaPutin = shFunctionalDim0('mitoVisitaPutin', number_pph0Samples = 400)
	mitoVisitaPutin.saveFunctionals()

	onu = shFunctionalDim0('onu', number_pph0Samples = 400)
	onu.saveFunctionals()

	politcsAR = shFunctionalDim0('politcsAR', number_pph0Samples = 400)
	politcsAR.saveFunctionals()
