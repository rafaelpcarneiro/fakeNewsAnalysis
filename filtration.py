#!/usr/bin/env python3
# vim: set ts=4 foldmethod=marker:

import numpy as np
import pandas as pd
import networkx as nx

#-------------------------------------------------------------------------------
#                             Exception Classes
#-------------------------------------------------------------------------------
#{{{1 Exception Classes
class PathsConflict(Exception):
	def __init__(self):
		pass

	def __str__(self):
		return (
			"Cannot happen at same time neither new_paths and existing_paths to  "
			"be None nor new_paths and existing_paths to be not None\n"
		)

class PathsStepError(Exception):
	def __init__(self):
		pass

	def __str__(self):
		return (
			"Be sure that self.paths['distance'] == step - 1 is not empty!!!\n"
		)

class PathsEmpty(Exception):
	def __init__(self):
		pass

	def __str__(self):
		return (
			"The collection of paths is empty"
		)

class PathsColumnMissMatch(Exception):
	def __init__(self):
		pass

	def __str__(self):
		return (
			"DataFrame doesn't have the proper column names"
		)

#1}}}

#-------------------------------------------------------------------------------
#                             Auxiliary functions
#-------------------------------------------------------------------------------
#{{{1 Auxiliary functions
def print_data(filename:str, data, header=False):
	"""
		Function to be used to print all relevant data inside the method
		performFiltration from BarabasiSample.

		Atributes::
		----------
		  + filename: wich file should I write the data;
		  + data: the data itself;
		  + header: should the first line be the total amount of lines in data
	"""
	if header:
		with open(filename, "w") as fh:
			fh.write(f"{data.shape[0]}\n")
	
	if isinstance(data, pd.DataFrame):
		data.to_csv(
			filename,
			sep    = " ",
			header = False,
			index  = False
		)
	elif isinstance(data, np.ndarray): 
		np.savetxt(
			filename,
			data,
			fmt = "%d "
		)
	else:
		print(f"Error, data type not known: {type(data)}")
#1}}}


class Paths:
	"""
		Consider a finite set of oriented paths

			P = { (x_0, x_1), (x_2, x_3), ... },

		where P will be pandas Dataframe.

		This class aims to deal with paths operations such as 
		difference, concatenation, and walking on connected paths

		Class Atributes
		---------------
		+ columns (private)::
		   Column names of the DataFrame regarding the paths
		+ paths  (public)::
		   The pandas DataFrame containing all paths
	"""

	#{{{1 Paths Attributes
	def __init__(self, new_paths=None, existing_paths=None):
		"""
			Parameters
			----------
			+ new paths::
			   is a numpy array of shape == (N, 2) where
			   the first column represents the starting point of a path and
			   the second column represents the ending point of a path.
			+ existing_paths::
			   a pandas DataFrame with columns
			   ["from", "fromID", "to", "toID", "distance"]
		"""
		self.__columns = ["from", "fromID", "to", "toID", "distance"]
		self.paths = {'new_paths': new_paths, 'existing_paths': existing_paths}

	@property
	def paths(self):
		return self.__collection_of_paths

	@paths.setter
	def paths(self, kwargs: dict):
		"""
			kwargs.keys() == ['new_paths', 'existing_paths']
		"""
		new_paths      = kwargs['new_paths']
		existing_paths = kwargs['existing_paths']

		if (new_paths is not None and existing_paths is None):
			if not new_paths.size:
				raise PathsEmpty()

			self.__collection_of_paths = pd.DataFrame( {
				"from"    : new_paths[ : , 0],

				"to"      : new_paths[ : , 1],

				"fromID"  : np.arange(new_paths.shape[0]),
				 
				"toID"    : np.arange(new_paths.shape[0], 
									  2*new_paths.shape[0]),

				"distance": np.ones(new_paths.shape[0], dtype=int)
			})

		elif (new_paths is None and existing_paths is not None):
			if not existing_paths.size:
				raise PathsEmpty()

			if set(existing_paths.columns.to_list()) != set(self.__columns):
				raise PathsColumnMissMatch()

			self.__collection_of_paths = existing_paths

		else:
			raise PathsConflict()
	#1}}}

	#{{{1 Paths Methods
	def __add__(self, other):
		"""
			This will concatenate two Paths instances
		"""
		new_df = pd.concat([self.paths, other.paths], ignore_index=True)
		return Paths(
			existing_paths = new_df
		)

	def __sub__(self, other):
		"""
			This will take the difference between sets:
			         self.paths ╲ other.paths
		"""
		indexSelf = pd.MultiIndex.from_arrays([
			self.paths[col] 
			for col in self.__columns
			if col != "distance"
		])

		indexOther = pd.MultiIndex.from_arrays([
			other.paths[col] 
			for col in other.__columns
			if col != "distance"
		])

		result = self.paths.loc[~indexSelf.isin(indexOther)]

		if result.size:
			return Paths(existing_paths = result)
		else:
			raise PathsEmpty()
		
	def __rshift__(self, step: int):
		"""
			Given the inputs
				+ instance of Paths (self);
				+ and a step 

			this method will return a Path P' where:

				P' = { (x,y); exist a graph path w = [a_0, a_1, ..., a_N]
				              where a_0 == x, a_N == y, N == step
							  and (a_0, a_1), (a_1,a_2), ... are edges
							  of the graph }

			Note that
				+ If step == 1 then the method doesn't do anything and return 
				  self

				+ If self.paths['distance'] == step - 1 is empty then the method
				  raises the Error PathStepError
				
			In order to walk an amount of N steps you must do something like
				a = a + a >> 2 (walk one step and join the results)
				a = a + a >> 3 (walk two steps and join the results)
				a = a + a >> 4 (walk three steps and join the results)
				      .
				      .
				      .
				a = a + a >> N-1 (walk N-1 steps and join the results)
				a = a + a >> N   (walk N steps and join the results)

			Return:
				The method returns P' if P' is not empty and None otherwise.
		"""
		if (~self.paths['distance'] == step -1).sum():
			raise PathsStepError()

		tmp = pd.merge(
			self.paths[self.paths['distance'] == step - 1],
			self.paths[self.paths['distance'] == 1],
			left_on  = "to",
			right_on = "from"
		)

		if not tmp.size:
			raise PathsEmpty()

		columns_to_rename  = {
			"from_x"     : "from",
			"fromID_x"   : "fromID",
			"to_y"       : "to",
			"toID_y"     : "toID",
			"distance_x" : "distance"
		}

		tmp = tmp.rename(columns = columns_to_rename)
		tmp = tmp[tmp["from"] != tmp["to"]]  # exclude loops

		tmp['distance'] = step

		try:
			result = Paths(existing_paths=tmp[self.__columns])

			result = result - self

			return result

		except PathsEmpty:
			raise PathsEmpty()
	#1}}}


class BarabasiSample(Paths):
	"""
		Class Atributes
		---------------
			+ a Barabasi subgraph (public)::
			   Column names of the DataFrame regarding the paths

			+ a Paths instance object  (public)::

		Class Methods
		-------------
			+ performFiltration
			   method responsible for performing the filtration of dimension
			   1 and 2
	"""

	#{{{1 Atributes {{{1
	def __init__(self, sample_from_a_Barabasi_graph):
		"""
			sample_from_a_Barabasi_graph: is an instance of Graph from networkx
		"""

		self.graph = sample_from_a_Barabasi_graph
		#nx.barabasi_albert_graph(
		#	nodes,
		#	edges_to_attach_per_node
		#)

		super().__init__( new_paths = np.array(self.graph.edges()) )
	#1}}}

	#{{{1 Methods
	def performFiltration(self):
		"""
			This method will firstly calculate all possible paths w = [a_0, a_1],
			regardless its distance.

			Once all paths are discovered, that is, the filtration is calculated,
			then the program will proceed printing the paths of dim 0,1,2 to
			the respective files so ppph.c can finish the job
		"""
		## Calculating the filtration
		distance = 2

		filtration = self
		while True:
			try:
				tmp = filtration >> distance

				filtration = filtration + tmp
				distance += 1

			except PathsEmpty:
				break

		self.paths = {'new_paths': None, 'existing_paths': filtration.paths}

		## Printing all files so pph.c can calculate the persistent diagrams
		print_data(
			'nodes.txt',
			np.array(self.graph.nodes()),
			header=True
		)
		print_data(
			'edges.txt',
			self.paths.groupby(['from', 'to']).agg( {'distance': min} )
			header=True
		)
		print_data(
			'pathdim1.txt',
			self.paths[['from', 'to']].drop_duplicates()
			header=True
		)



	# Nodes)

	#1}}}
	#fitration_dim1 = df.groupby(['from', 'to']).agg( {"distance": min} )

if __name__ == "__main__":
	
	NODES                = 5
	CONNECTIONS_PER_NODE = 2

	g = nx.barabasi_albert_graph(NODES, CONNECTIONS_PER_NODE)

	g_sample = BarabasiSample(g)
	with open("aaaa.txt", "w") as fh:
		fh.write(f"{len(g_sample.graph.edges())}\n")

	g_sample.paths.to_csv(
		'aaaa.txt',
		sep     = "\t",
		columns = ["from", "to"],
		index   = False,
		header  = False,
		mode    = "a"
	)

	g_sample.performFiltration()
	print(g_sample.paths.distance.max())
	

