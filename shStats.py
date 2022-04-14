#!/usr/bin/env python3
# vim: set ts=4 foldmethod=marker:

import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
from scipy.stats import norm, stats, shapiro

import researchpy as rp

import statsmodels.api as sm
from statsmodels.formula.api import ols
import pingouin as pg

class shStats():
	def __init__(self, 
				 shFile,
				 graphName           = None,
				 timeScale           = 97,
				 numberOfFunctionals = 400,
				 shMean              = False,
				 shMean_samples      = 40,
				 max_dist_inflection = 5):

		self.__max_dist_inflection  = max_dist_inflection
		self.__numberOfFunctionals  = numberOfFunctionals

		self.__shFunctionals        = np.loadtxt(shFile,
									             delimiter=' ',
										         max_rows=numberOfFunctionals)

		self.__xrangeOfFunctionals  = (self.__shFunctionals).shape[1]

		if shMean == True:
			self.__numberOfFunctionals  = int(numberOfFunctionals / shMean_samples)

			self.__shFunctionals = self.__shFunctionals.reshape(self.__numberOfFunctionals,
															    shMean_samples,
															    self.__xrangeOfFunctionals).mean(axis=1)

		self.__graphName            = graphName
		self.__pMax                 = None
		self.__pInflection          = None
		self.__area                 = None
		self.__timeScale            = timeScale

		self.run_calculations()


	def set_pInflection(self, pInflection):
		self.__pInflection = pInflection
	
	def set_pMax(self, pMax):
		self.__pMax = pMax

	def set_area(self, area):
		self.__area = area

	def get_max_dist_inflection(self):
		return self.__max_dist_inflection

	def get_area(self, normalized=False):
		#{{{1
		if normalized == False:
			return self.__area
		else:
			tmp = self.get_shFunctionals().max(axis=1)

			shLenght = np.zeros(self.get_numberOfFunctionals())

			for i in range(self.get_numberOfFunctionals()):
				j = - 1
				while self.get_shFunctionals()[i,j] < 0.001:
					j -= 1
				shLenght[i] = self.get_xrangeOfFunctionals() + j


			tmpArea = tmp * shLenght * self.get_timeScale()

			return self.__area / tmpArea
		#1}}}

	def get_pInflection_pMax_stat(self, normalized=False):
		#{{{1
		if normalized == True:
			return (self.get_pInflection() - self.get_pMax()) / self.get_pInflection()
		else:
			return self.get_pInflection() - self.get_pMax()
        #1}}}

	def get_pMax(self):
		return self.__pMax

	def get_shFunctionals(self):
		return self.__shFunctionals

	def get_numberOfFunctionals(self):
		return self.__numberOfFunctionals

	def get_xrangeOfFunctionals(self):
		return self.__xrangeOfFunctionals

	def get_pInflection(self):
		return self.__pInflection 

	def get_timeScale(self):
		return self.__timeScale
	
	def get_graphName(self):
		return self.__graphName

	def calc_pMax(self):
		self.set_pMax(self.get_shFunctionals().argmax(axis=1))
	
	def calc_pInflection_v0(self):
		# {{{1
		pInflection  = np.zeros(self.get_numberOfFunctionals(), dtype=int)

		for j in range(self.get_numberOfFunctionals()):

			dp2 = np.diff(self.get_shFunctionals()[j], n=2)
			dp2 = dp2[self.get_pMax()[j] : ]

			tmp = (dp2 > 0).nonzero()

			pInflection[j] = self.get_pMax()[j] + tmp[0][0]

		self.set_pInflection(pInflection)
		# 1}}}

	def calc_pInflection_v1(self):
		# {{{1
		pInflection  = np.zeros(self.get_numberOfFunctionals(), dtype=int)

		for j in range(self.get_numberOfFunctionals()):

			dp2 = np.diff(self.get_shFunctionals()[j], n=2)
			dp2 = dp2[self.get_pMax()[j] : ]

			tmp = dp2.argmax()

			pInflection[j] = self.get_pMax()[j] + tmp

		self.set_pInflection(pInflection)
		# 1}}}

	def calc_pInflection_v2(self):
		# {{{1
		pInflection  = np.zeros(self.get_numberOfFunctionals(), dtype=int)

		for j in range(self.get_numberOfFunctionals()):

			
			dp1 = np.gradient(self.get_shFunctionals()[j]) 
			dp2 = np.gradient( np.gradient(self.get_shFunctionals()[j]) )

			pInflection[j] = dp2.argmax()

		self.set_pInflection(pInflection)
		# 1}}}

	def calc_pInflection_v3(self):
		# {{{1
		MAX_DIST = self.get_max_dist_inflection()

		pInflection  = np.zeros(self.get_numberOfFunctionals(), dtype=int)

		for j in range(self.get_numberOfFunctionals()):

			dp1  = np.gradient(self.get_shFunctionals()[j]) 
			pmin = dp1.argmin()

			tmp = [pmin]
			for i in np.arange(pmin + 1, self.get_xrangeOfFunctionals() - 1):
				if (dp1[i - 1] >= dp1[i] <= dp1[i + 1]) or (dp1[i - 1] <= dp1[i] >= dp1[i + 1]):
					tmp.append(i)

			tmp2 = [pmin]
			for i in range(len(tmp) - 1):
				if tmp[i + 1] - tmp[i] < MAX_DIST:
					tmp2.append(tmp[i])
				else:
					break

			#print(tmp2)
			pInflection[j] = max(tmp2)

		self.set_pInflection(pInflection)
		# 1}}}

	def calc_area(self):
		#{{{1
		area = np.zeros(self.get_numberOfFunctionals(), dtype=float)

		i = 0
		for shFunctional in self.get_shFunctionals():
			for j in range(self.get_xrangeOfFunctionals() - 1):

				sh_min = shFunctional[j] if shFunctional[j] < shFunctional[j+1] else shFunctional[j+1]
				sh_max = shFunctional[j] if shFunctional[j] > shFunctional[j+1] else shFunctional[j+1]
				area[i] += sh_min * self.get_timeScale() 
				area[i] += self.get_timeScale() * (sh_max - sh_min) / 2.0 

			i += 1

		self.set_area(area)
		#1}}}

	def plot_functionals(self, axes=plt, plotFunctionals=True, plotInflection=True, saveFile=False):
		#{{{1
		if plotFunctionals == True:
			for shFunctional in self.get_shFunctionals():
				axes.plot(np.arange(self.get_xrangeOfFunctionals()) * self.get_timeScale(),
						 shFunctional)

		if plotInflection == True:
			xindex = np.arange(self.get_numberOfFunctionals())
			yindex = self.get_pMax()

			xvalue = self.get_pMax() * self.get_timeScale()
			yvalue = self.get_shFunctionals()[(xindex, yindex)]

			axes.plot(xvalue, yvalue, color='red', marker='o', linestyle='None', label='pMax')

			yindex = self.get_pInflection()

			xvalue = self.get_pInflection() * self.get_timeScale()
			yvalue = self.get_shFunctionals()[(xindex, yindex)]

			axes.plot(xvalue, yvalue, color='black', marker='o',linestyle='None', label='pInflection')

			axes.xlabel('time (s)')
			axes.ylabel('time (s)')
			axes.title('Persistence Silhouette Functions - Graph: ' + self.get_graphName())
			axes.legend()

		if saveFile == True:
			axes.savefig(self.get_graphName() + '_sh_dim0.pdf')
			axes.close()
		#1}}}

	def plot_meanFunctionals(self, pcolor):
		#{{{1
		sh = self.get_shFunctionals().mean(axis=0)
		plt.plot(np.arange(self.get_xrangeOfFunctionals()) * self.get_timeScale(),
				  sh,
				  color=pcolor,
				  linewidth=2,
				  label=self.get_graphName())

		#1}}}

	def plot_inflection(self, axes=None, plotNormalized=False):
		#{{{1
		tmp = self.get_pInflection_pMax_stat(normalized = plotNormalized)

		axes.hist(tmp, density=True, label=self.get_graphName())

		#mean = tmp.mean()
		#sd   = tmp.std()
		#points = np.linspace(mean - 3 * sd, mean + 3 * sd, 1000)

		#axes.plot(points, norm.pdf(points, mean, sd))


		#axes.set_ylabel(self.get_graphName())

		#axes.set_xlim([0, 1])
		axes.legend(loc='upper left', framealpha=0.0)

		if self.get_graphName() == 'f1':
			axes.set_title('Histogramas da medida: (pInflection - pMax) / pInflection.    Laranja -> densidade da normal ajustada')
		#1}}}

	def plot_area(self, axes, plotNormalized=True):
		#{{{1
		area = self.get_area(normalized = plotNormalized) 

		axes.hist(area, bins=10,density=True, label=self.get_graphName())
		#axes.scatter(area, np.zeros_like(area), color='black', marker='o')

		mean = area.mean()
		sd   = area.std()
		points = np.linspace(mean - 3 * sd, mean + 3 * sd, 1000)

		axes.plot(points, norm.pdf(points, mean, sd))

		#axes.set_xlim([0, 1])
		if self.get_graphName() in ['f1', 'mariliaMendonca', 'futebol']:
			axes.legend(loc='upper right', framealpha=0.0)
		else:
			axes.legend(loc='upper left', framealpha=0.0)

		if self.get_graphName() == 'f1':
			axes.set_title('Histogramas da medida area / area maxima + pdf da normal ajustada')


		#axes.set_title(self.get_graphName())

		#axes.set_xlim([0, 1])
		#axes.set_xlabel('area normalized')
		#1}}}

	def plot_inflection_area(self, axes, pcolor):
		#{{{1
			inflection = self.get_pInflection_pMax_stat(normalized=False)
			
			area = self.get_area(normalized=False)

			axes.scatter(area, inflection, color=pcolor, marker='o', label=self.get_graphName())
		#1}}}

	def run_calculations(self):
		self.calc_pMax()
		self.calc_pInflection_v3()
		self.calc_area()

if __name__ == "__main__":
	#fig, ax = plt.subplots(nrows=1, ncols=1)

	f1              = shStats('data/f1_sh_curve.txt',
	                          'f1',
							  shMean = True,
							  max_dist_inflection = 50)

	mariliaMendonca = shStats('data/mariliaMendonca_sh_curve.txt',
	                          'mariliaMendonca',
							  shMean = True,
							  max_dist_inflection = 50)

	football        = shStats('data/football_sh_curve.txt',
	                          'futebol',
							  shMean = True,
							  max_dist_inflection = 10)

	onu             = shStats('data/onu_sh_curve.txt',
	                          'onu',
							  shMean = True,
							  max_dist_inflection = 50)

	mitoVisitaPutin = shStats('data/mitoVisitaPutin_sh_curve.txt',
	                          'mitoVisitaPutin',
							  shMean = True,
							  max_dist_inflection = 50)

	politcsAR       = shStats('data/politcsAR_sh_curve.txt',
							  'politcaAR',
							  shMean = True,
							  max_dist_inflection = 50)

	######################## Silhouette Functions ##############################
	# {{{1
	##### Silhouette Functions - each graph
	#f1.plot_functionals(saveFile=True)
	#mariliaMendonca.plot_functionals(saveFile=True)
	#football.plot_functionals(saveFile=True)

	#onu.plot_functionals(saveFile=True)
	#mitoVisitaPutin.plot_functionals(saveFile=True)
	#politcsAR.plot_functionals(saveFile=True)

	####### Mean Silhouette Functions
	#f1.plot_meanFunctionals( 'red')
	#mariliaMendonca.plot_meanFunctionals( 'blue')
	#football.plot_meanFunctionals( 'gold')

	#onu.plot_meanFunctionals( 'darkgreen')
	#mitoVisitaPutin.plot_meanFunctionals( 'purple')
	#politcsAR.plot_meanFunctionals( 'chocolate')

	#plt.xlabel('time (s)')
	#plt.ylabel('time (s)')
	#plt.title('Persistence Silhouette Functions' )
	#plt.legend()
	#plt.grid(linewidth=0.8, linestyle='--')

	#plt.savefig('sh_means.pdf')
    #1}}}

	########################## Statistics PLots ################################

	############## Box plots
	#{{{1
	#### Box plots - Inflection
	#myboxplots = [f1.get_pInflection_pMax_stat(),
	#			  mariliaMendonca.get_pInflection_pMax_stat(),
	#			  football.get_pInflection_pMax_stat(),
	#			  onu.get_pInflection_pMax_stat(),
	#			  mitoVisitaPutin.get_pInflection_pMax_stat(),
	#			  politcsAR.get_pInflection_pMax_stat()]

	#mylabels=[f1.get_graphName(),
	#		  mariliaMendonca.get_graphName(),
	#		  football.get_graphName(),
	#		  onu.get_graphName(),
	#		  mitoVisitaPutin.get_graphName(),
	#		  politcsAR.get_graphName()]

	##plt.axes().set_facecolor(color='royalblue')
	#bp = plt.boxplot( myboxplots, labels = mylabels, patch_artist=True)
	#bp['boxes'][0].set(facecolor='red')
	#bp['boxes'][1].set(facecolor='blue')
	#bp['boxes'][2].set(facecolor='gold')

	#bp['boxes'][3].set(facecolor='darkgreen')
	#bp['boxes'][4].set(facecolor='purple')
	#bp['boxes'][5].set(facecolor='chocolate')

	#plt.title('pInflection - pMax')
	#plt.grid(linewidth=0.8, linestyle='--')
	#plt.xticks(rotation=15)
	#plt.savefig('inflection_boxplot.pdf')

	##### Box plots - Area
	#myboxplots = [f1.get_area(normalized=False),
	#			  mariliaMendonca.get_area(normalized=False),
	#			  football.get_area(normalized=False),
	#			  onu.get_area(normalized=False),
	#			  mitoVisitaPutin.get_area(normalized=False),
	#			  politcsAR.get_area(normalized=False)]

	#mylabels=[f1.get_graphName(),
	#		  mariliaMendonca.get_graphName(),
	#		  football.get_graphName(),
	#		  onu.get_graphName(),
	#		  mitoVisitaPutin.get_graphName(),
	#		  politcsAR.get_graphName()]

	##plt.axes().set_facecolor(color='royalblue')
	#bp = plt.boxplot( myboxplots, labels = mylabels, patch_artist=True)
	#bp['boxes'][0].set(facecolor='red')
	#bp['boxes'][1].set(facecolor='blue')
	#bp['boxes'][2].set(facecolor='gold')

	#bp['boxes'][3].set(facecolor='darkgreen')
	#bp['boxes'][4].set(facecolor='purple')
	#bp['boxes'][5].set(facecolor='chocolate')

	#plt.title('area da curva / area maxima')
	#plt.grid(linewidth=0.8, linestyle='--')
	#plt.xticks(rotation=15)
	#plt.savefig('area_boxplot.pdf')
	#1}}}

	############## Histograms
	#{{{1
	### Histograms - Inflection
	#fig, ax = plt.subplots(nrows=6, ncols=1, sharex='col')
	##plt.title('Histogramas da medida (pInflection - pMax) / pInflection')

	#f1.plot_inflection(ax[0])
	#mariliaMendonca.plot_inflection(ax[1])
	#football.plot_inflection(ax[2])

	#onu.plot_inflection(ax[3])
	#mitoVisitaPutin.plot_inflection(ax[4])
	#politcsAR.plot_inflection(ax[5])

	##plt.tight_layout()
	##plt.legend()
	#plt.savefig('inflection_histograms.pdf')

	##### Histograms - Area
	#fig, ax = plt.subplots(nrows=6, ncols=1, sharex='col')
	##plt.title('Histogramas da medida (pInflection - pMax) / pInflection')

	#f1.plot_area(ax[0], plotNormalized=True)
	#mariliaMendonca.plot_area(ax[1], plotNormalized=True)
	#football.plot_area(ax[2], plotNormalized=True)

	#onu.plot_area(ax[3], plotNormalized=True)
	#mitoVisitaPutin.plot_area(ax[4], plotNormalized=True)
	#politcsAR.plot_area(ax[5], plotNormalized=True)

	##plt.tight_layout()
	##plt.legend()
	#plt.savefig('area_histograms_normalized.pdf')
	#1}}}

	############## QQplot
	#{{{1
	#sm.qqplot(f1.get_pInflection_pMax_stat(),
	#		  line ='45',
	#		  loc=f1.get_pInflection_pMax_stat().mean(),
	#		  scale=f1.get_pInflection_pMax_stat().std())

	#plt.savefig('f1_qqplot.pdf')

	#sm.qqplot(mariliaMendonca.get_pInflection_pMax_stat(),
	#		  line ='45',
	#		  loc=mariliaMendonca.get_pInflection_pMax_stat().mean(),
	#		  scale=mariliaMendonca.get_pInflection_pMax_stat().std())

	#plt.savefig('mariliaMendonca_qqplot.pdf')

	#sm.qqplot(football.get_pInflection_pMax_stat(),
	#		  line ='45',
	#		  loc=football.get_pInflection_pMax_stat().mean(),
	#		  scale=football.get_pInflection_pMax_stat().std())

	#plt.savefig('football_qqplot.pdf')

	#sm.qqplot(onu.get_pInflection_pMax_stat(),
	#		  line ='45',
	#		  loc=onu.get_pInflection_pMax_stat().mean(),
	#		  scale=onu.get_pInflection_pMax_stat().std())

	#plt.savefig('onu_qqplot.pdf')

	#sm.qqplot(mitoVisitaPutin.get_pInflection_pMax_stat(),
	#		  line ='45',
	#		  loc=mitoVisitaPutin.get_pInflection_pMax_stat().mean(),
	#		  scale=mitoVisitaPutin.get_pInflection_pMax_stat().std())

	#plt.savefig('mitoVisitaPutin_qqplot.pdf')

	#sm.qqplot(politcsAR.get_pInflection_pMax_stat(),
	#		  line ='45',
	#		  loc=politcsAR.get_pInflection_pMax_stat().mean(),
	#		  scale=politcsAR.get_pInflection_pMax_stat().std())

	#plt.savefig('politcsAR_qqplot.pdf')
	#1}}}

	############## Inflection + area
	#{{{1
	fig, ax = plt.subplots(nrows=1, ncols=1)
	ax.set_xlabel('area')
	ax.set_ylabel('pInflection - pMax')

	f1.plot_inflection_area(ax, 'red')
	mariliaMendonca.plot_inflection_area(ax, 'blue')
	football.plot_inflection_area(ax, 'gold')

	onu.plot_inflection_area(ax, 'darkgreen')
	mitoVisitaPutin.plot_inflection_area(ax, 'purple')
	politcsAR.plot_inflection_area(ax, 'chocolate')

	plt.grid(linewidth=0.2, linestyle='--', color='lightgray')

	plt.legend()
	plt.savefig('inflection_area.pdf')
	#1}}}

	############## Checking variance
	#{{{1
	#varCheck = np.concatenate(
	#	(f1.get_pInflection_pMax_stat(),
	#	mariliaMendonca.get_pInflection_pMax_stat(),
	#	football.get_pInflection_pMax_stat(),
	#	onu.get_pInflection_pMax_stat(),
	#	mitoVisitaPutin.get_pInflection_pMax_stat(),
	#	politcsAR.get_pInflection_pMax_stat())
	#)

	#plt.plot(varCheck)
	#plt.show()
	#1}}}

	########################## ANOVA ################################
	#{{{1
	inflection = np.concatenate(
		(f1.get_pInflection_pMax_stat(normalized=False),
		mariliaMendonca.get_pInflection_pMax_stat(normalized=False),
		football.get_pInflection_pMax_stat(normalized=False),
		onu.get_pInflection_pMax_stat(normalized=False),
		mitoVisitaPutin.get_pInflection_pMax_stat(normalized=False),
		politcsAR.get_pInflection_pMax_stat(normalized=False))
	)

	#area = np.concatenate(
	#	(f1.get_area(normalized=True),
	#	mariliaMendonca.get_area(normalized=True),
	#	football.get_area(normalized=True),
	#	onu.get_area(normalized=True),
	#	mitoVisitaPutin.get_area(normalized=True),
	#	politcsAR.get_area(normalized=True))
	#)

	graph_type = np.repeat( ['organico', 'nao_organico'], 
	                        3 * f1.get_numberOfFunctionals() )

	graph_order = np.repeat( ['graph0', 'graph1', 'graph2', 'graph0', 'graph1', 'graph2' ], 
	                         f1.get_numberOfFunctionals())


	df = pd.DataFrame({'graph_type':  graph_type,
	                   'inflection':  inflection,
					   'graph_order': graph_order})


	model = ols('inflection ~ C(graph_type) / C(graph_order) ', data=df).fit()
	#print( model.summary() )

	aov_table = sm.stats.anova_lm(model, typ=2)
	print(aov_table)

	print(shapiro(model.resid))

	#pg.qqplot(model.resid, dist='norm', sparams = (0, model.resid.values.std()))
	pg.qqplot(model.resid, dist='norm', confidence=0.95)
	#plt.scatter(np.arange(model.resid.size), model.resid)
	plt.savefig('normalidade_residuos.pdf')
	#plt.show()
	#df.to_csv('model.csv', sep=',')
	#1}}}




