#!/usr/bin/env python3
# vim: set ts=4 foldmethod=marker:

import numpy as np
import networkx as nx

if __name__ == "__main__":
	NODES                = 5
	CONNECTIONS_PER_NODE = 2


	for seed in range(6):
		g = nx.barabasi_albert_graph(NODES, CONNECTIONS_PER_NODE, seed)

		edges = np.array(
			g.edges(),
			dtype = int
		)

		edges.savetxt(f"barabasi_{seed}.dat", fmt="%d ")


