/* vim: foldmethod=marker: set ts=4: set expandtab:
 */

/*|--- Includes and defines {{{1*/
#include <stdio.h>
#include <stdlib.h>

#define STOP 	  -1
#define CONTINUES 1

#define TAIL_MARKED     0
#define TAIL_NOT_MARKED 1
/*END Includes and defines 1}}}*/

/*|--- Data Types {{{1 */
typedef unsigned int node;
typedef unsigned int size;
typedef unsigned int iterators;
typedef unsigned int generation;

typedef structure {
	node         vertex;
	generation   gen;
	unsigned int amount_sons;

} vertex_generation_amount_sons;

typedef structure {
	node 	     from;
	node 	     to;
	generation   from_gen;
	generation   to_gen;

	char         flag;

} edge_generation;

typedef structure {
	node 	     a_branch[15];
	int 	     flag;

} branch;

/* END Data Types 1}}} */

/*|--- FUNCTIONS {{{1 */
iterator add_all_branches (branch 	                 *_branches,
		               vertex_generation_amount_sons *_nodes,
		               edge_generation 		         *_edges,
		               iterator 		             from_node,
					   iterator						 from_edge,
		               iterator 		             start_branch,
					   size							 max_nodes) {

	iterator count_sons, ret;
	iterator k, j;

	if ((_nodes + from)->amount_sons == 0  ) {

		if ((_edges + from_edge)->flag == TAIL_NOT_MARKED) {

			(_branches + start_branch)->a_branch[ (_nodes + from_node)->gen ] = (_nodes + from_node)->vertex;
				
			(-edges + from_edge)->flag = TAIL_MARKED;
			return ++start_branch;
		}

		else return start_branch;

	}
	else {

		for (count_sons = 0, k = 0; count_sons < (_nodes + from)->amount_sons; ++k) {
			if ((_edges + k)->from == (_nodes + from)->vertex ){
				for (j = 0; j < max_nodes; ++j)  
					if ((_nodes +j)->vertex == (_edges + k)->to) break;

				ret = add_all_branches (_branches, _nodes, _edges, j, k, start_branch, MAX_NODES);

				if (ret - start_branch == 1 && (_nodes + j)->gen > 1) {
					(_branches + *start_branch)->a_branch[ (_nodes + from)->gen ] = (_nodes + from)->vertex;
					return ret;
				}
				else if (ret - start_branch == 1 && (_nodes + j)->gen == 1) {
					(_branches + *start_branch)->a_branch[ (_nodes + j)->gen ]    = (_nodes + j)->vertex;
					(_branches + *start_branch)->a_branch[ (_nodes + from)->gen ] = (_nodes + from)->vertex;
					++count_sons;
					++start_branch;
					k = 0;
				}
				else {
					++count_sons;
				}
			}
		}

	} /*END OF ELSE */
	return start_branch;
}
/*|--- END FUNCTIONS 1}}} */

/*|--- MAIN {{{1*/
int main() {
	
	/*|--- Variable Declaration {{{2*/
	FILE              	      *file_nodes, *file_edges;

	vertex_generation_amount_sons *nodes;
	edge_generation	  	      *edges
	branch            	      *branches;

	size              	      MAX_BRANCHES, MAX_NODES, MAX_EDGES;

	iterators         	      i, j;

	node	          	      node_tmp, from_node_A, to_node_B;
	generation        	      generation_tmp, from_gen_X, to_gen_Y;
	
	unsigned int 		      amount_of_sons;

	/*END Variable Declaration 2}}}*/

	/*|--- Reading all nodes and edges {{{2*/
	file_nodes = fopen ("nodes.txt", "r");
	file_edges = fopen ("edges.txt", "r");

	if (file_nodes == NULL || file_edges == NULL ) printf("Problems to open the files\n");

	fscanf (file_nodes, "%d", &MAX_NODES);
	nodes = malloc (MAX_NODES * sizeof (vertex_generation));

	i = 0;
	while (fscanf (file_nodes, "%d %d %d", &node_tmp, &generation_tmp, &amount_of_sons)) {
		(nodes + i)->vertex      = node_tmp;
		(nodes + i)->gen         = generation_tmp;
		(nodes + i)->amount_sons = amount_of_sons;

		++i;
	}
	fclose (file_nodes);

	fscanf (file_edges, "%d", &MAX_EDGES);
	edges = malloc (MAX_EDGES * sizeof (edge_generation));

	i = 0;
	while (fscanf (file_edges, "%d %d %d %d", &from_node_A, &to_node_B, &from_gen_X, &to_gen_Y)) {
		(edges + i)->from     = from_node_A;
		(edges + i)->to       = to;
		(edges + i)->from_gen = from_gen_X;
		(edges + i)->to_gen   = to_gen_Y;

		++i;
	}
	fclose (file_edges);
	/*END Reading all nodes and edges 2}}}*/

	/*|--- Storing all branches {{{2*/
	MAX_BRANCHES   = MAX_NODES; /* worst scenario */
	branches       = malloc (MAX_BRANCHES * sizeof (branch));

	i              = 0;
	generation_tmp = 0;
	while ((nodes+i)->gen == 0) {
		if ((nodes+i)->amount_sons !=0) add_all_branches ();
		++i;
	}

	/*END Storing all branches 2}}}*/

}
/*END MAIN 1}}}*/
