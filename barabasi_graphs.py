#!/usr/bin/env python3
# vim: set ts=4 foldmethod=marker:

import numpy as np
import pandas as pd
import networkx as nx

class Filtration:
	"""
		Apply the filtration over a Barabasi Graph
	"""
	
	def __init__(self, G):
		"""
			The graph G must be an instance of the networkx class
		"""
		self.graph = G
		

	@property
	def graph(self):
		return self.__graph

	@graph.setter
	def graph(self, G):
		self.__graph = G

	def createFiltration(self):

		df = pd.DataFrame(
			data = G.edges(),
			names = ["from", "to"]
		)
		df['fromID']   = np.arange(df.shape[0], dtype=int)
		df['toID']     = np.arange(df.shape[0], 2*df.shape[0], dtype=int)

		df_dist1       = df ## copy of df with distance == 1
		                    ## but without distance column

		df['distance'] = 1

		distance = 1
		columns_to_look_at = ["from", "fromID", "to", "toID"]
		columns_to_rename  = {
			"from_x"     : "from",
			"fromID_x"   : "fromID",
			"to_y"       : "to",
			"toID_y"     : "toID",
		}
			
		while True:
			tmp = pd.merge(
				df[df['distance'] == distance],
				df_dist1,
				left_on  = "to",
				right_on = "from"
			)

			tmp = tmp.rename(columns = columns_to_rename)

			tmp = tmp[columns_to_look_at]

			tmp = tmp[~tmp.isin(df_dist1).all(axis=1)]
			tmp = tmp[tmp["from"] != tmp["to"]]

			if tmp.size:
				distance += 1
				tmp['distance'] = distance

				df = pd.concat([df, tmp], ignore_index=True)
			else:
				break
			
		fitration_dim1 = df.groupby(['from', 'to']).agg( {"distance": min} )

