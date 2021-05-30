/* vim: foldmethod=marker: set ts=4: set expandtab:
 */

/*|--- Includes and defines {{{1*/
#include <stdio.h>
#include <stdlib.h>
/*END Includes and defines 1}}}*/

/*|--- Data Types {{{1 */
typedef unsigned long int node;
typedef unsigned long int size;
typedef unsigned long int iterator;
typedef unsigned long int generation;

typedef struct {
	node         vertex;
	generation   gen;
	unsigned long int amount_sons;

} vertex_generation;

typedef struct {
	node 	     from;
	node 	     to;
	unsigned int weight;

	char         flag;

} edge_generation;
/* END Data Types 1}}} */

/*|--- MAIN {{{1*/
int main() {
	
	/*|--- Variable Declaration {{{2*/
	FILE              	      *file_nodes, *file_edges;
	FILE              	      *file_nodes_enumerated, *file_edges_enumerated;

	vertex_generation 		  *nodes;
	edge_generation	  	      *edges;

	size              	      MAX_NODES, MAX_EDGES;

	iterator         	      i, from, to;

	node	          	      node_tmp, from_node_A, to_node_B;
	generation        	      generation_tmp, weight;
	
	unsigned long int 		  amount_of_sons;

	/*END Variable Declaration 2}}}*/

	/*|--- Reading all nodes and edges {{{2*/
	file_nodes = fopen ("nodes.txt", "r");
	file_edges = fopen ("edges.txt", "r");

	if (file_nodes == NULL || file_edges == NULL ) printf("Problems to open the files\n");

	fscanf (file_nodes, "%lu", &MAX_NODES);
	nodes = malloc (MAX_NODES * sizeof (vertex_generation));

	i = 0;
	while (fscanf (file_nodes, "%lu %lu %lu", &node_tmp, &generation_tmp, &amount_of_sons) != EOF) {
		(nodes + i)->vertex      = node_tmp;
		(nodes + i)->gen         = generation_tmp;
		(nodes + i)->amount_sons = amount_of_sons;

		++i;
	}
	fclose (file_nodes);

	fscanf (file_edges, "%lu", &MAX_EDGES);
	edges = malloc (MAX_EDGES * sizeof (edge_generation));

	i = 0;
	while (fscanf (file_edges, "%lu %lu %lu", &from_node_A, &to_node_B, &weight) != EOF) {
		(edges + i)->from     = from_node_A;
		(edges + i)->to       = to_node_B;
		(edges + i)->weight   = weight;

		++i;
	}
	fclose (file_edges);
	/*END Reading all nodes and edges 2}}}*/

	/*|--- Writing all nodes and edges {{{2*/
	file_nodes_enumerated = fopen ("nodes_enumerated.txt", "w");
	file_edges_enumerated = fopen ("edges_enumerated.txt", "w");

	if (file_nodes_enumerated == NULL || file_edges_enumerated == NULL ) printf("Problems to write the files\n");

	fprintf (file_nodes_enumerated, "%lu\n", MAX_NODES);
	for (i = 0; i < MAX_NODES; ++i)
		fprintf (file_nodes_enumerated, "%lu\t%lu\t%lu\n", i, (nodes+i)->gen, (nodes+i)->amount_sons);

	fclose (file_nodes_enumerated);


	fprintf (file_edges_enumerated, "%lu\n", MAX_EDGES);
	for (i = 0; i < MAX_EDGES; ++i) {
		for (from = 0; from < MAX_NODES; ++from)
			if ((edges+i)->from == (nodes+from)->vertex) break;

		for (to = 0; to < MAX_NODES; ++to)
			if ((edges+i)->to == (nodes+to)->vertex) break;
		
		fprintf (file_edges_enumerated, "%lu\t%lu\t%lu\n", from, to, (edges+i)->weight);
	}
	fclose (file_edges_enumerated);

	/*END writing all nodes and edges 2}}}*/

	return 0;
}
/*END MAIN 1}}}*/
