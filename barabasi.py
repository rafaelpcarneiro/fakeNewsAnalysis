#!/usr/bin/env python3
# vim: set ts=4 foldmethod=marker:

import numpy as np
import networkx as nx
from datetime import datetime

if __name__ == "__main__":
	NODES                = 10
	CONNECTIONS_PER_NODE = 2

	seed            = abs(hash(datetime.today())) & 2**32 -1
	randomVariable  = np.random.RandomState(seed)


	for i in range(6):
		g = nx.barabasi_albert_graph(NODES, CONNECTIONS_PER_NODE, i)

		flip_edges = []

		for edge in g.edges(): 
			prob = randomVariable.random()

			if prob > 0.5:
				flip_edges.append( (edge[1], edge[0]) )
			else:
				flip_edges.append( edge )

		edges = np.array(
			flip_edges,
			dtype = int
		)

		fname="barabasi_{}.dat".format(i)
		np.savetxt(fname, edges, fmt="%d ")


