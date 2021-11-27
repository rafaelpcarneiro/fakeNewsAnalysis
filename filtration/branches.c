/* vim: foldmethod=marker: set ts=4: set expandtab:
 */

#include <stdio.h>
#include <stdlib.h>
#include <sys/types.h>
#include <unistd.h>
#include <sys/wait.h>

/* EOF == end of ~~~ branch NOT NECESSARY ANY MORE */
/*#define EOB 	  0*/

/* Data Types {{{1  */
typedef unsigned int node;
typedef unsigned int size;
typedef unsigned int iterator;
typedef unsigned int generation;

typedef struct {
	node         vertex;
	generation   gen;
	unsigned int amount_sons;

} vertex_generation;

typedef struct {
	node 	     from;
	node 	     to;
	unsigned int weight;

} edge_generation;

typedef struct {
	node 	     a_branch[15];
	unsigned int end_of_branch;

} branch;
/* END Data Types 1}}}  */

/*================================ FUNCTIONS =================================*/

/* add_all_branches down bellow doens't handle the problem as I wanted. 
 * The version2 is better and solve it nicely
 */
/*|--- add_all_branches {{{1 */
/*
iterator add_all_branches (branch 	                 *_branches,
		               vertex_generation *_nodes,
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

	} 
	return start_branch;
}
*/
/* END add_all_branches 1}}} */

/*|--- add_all_branches_version2 {{{1 */
branch *add_all_branches_version2 (vertex_generation *look_at_these_nodes,
				          		   edge_generation   *look_at_these_edges,
						  		   iterator          from) {

	iterator count_sons;
	iterator k, j;

	pid_t child_pid;

	branch *branch_found;

	if ((look_at_these_nodes + from)->amount_sons == 0  ) {

		branch_found = malloc (sizeof (branch));

		branch_found->a_branch[ (look_at_these_nodes + from)->gen ]    = (look_at_these_nodes + from)->vertex;
		branch_found->end_of_branch                                    = (look_at_these_nodes + from)->gen;
			
		return branch_found;
	}
	else {
		for (j = 0, count_sons = 0; count_sons < (look_at_these_nodes + from)->amount_sons; ++j) {
			
			if ( (look_at_these_edges + j)->from == (look_at_these_nodes + from)->vertex ) {
				++count_sons;
				k = 0;
				while (1) {
					if ((look_at_these_edges + j)->to == (look_at_these_nodes + k)->vertex) break;
					++k;
				}
				
				child_pid = fork ();
				if (child_pid == 0) {
					branch_found = add_all_branches_version2 (look_at_these_nodes, look_at_these_edges, k);

					if (branch_found != NULL) {
						branch_found->a_branch[(look_at_these_nodes + from)->gen] = (look_at_these_nodes + from)->vertex;
					}
					return branch_found;
				}
				while (wait(NULL) > 0);
			}
		}
	}
	return NULL;
}
/* END add_all_branches_version2 1}}} */
 
/*|--- fprintf_branches {{{1*/
/* I AM NOT USING THIS FUNCTION
void fprintf_branches (branch *print_branch) {
	
	FILE     *file;
	char     file_name[50];
	pid_t    the_pid;
	iterator i;

	the_pid = getpid ();
	sprintf (file_name, "branches/%d.txt", (int) the_pid);

	file = fopen (file_name, "w");
	if (file == NULL) printf ("problems to write the branch in a txt file\n\n");

	for (i = 0; print_branch->a_branch[i] != EOB; ++i ) fprintf (file, "%u   ", print_branch->a_branch[i]);

	fclose (file);
}
*/
/* END fprintf_branches 1}}} */

/*|--- printf_branches {{{1*/
void printf_branches (branch *print_branch) {
	iterator i;
	printf("[  ");
	for (i = 0; i <= print_branch->end_of_branch; ++i ) printf ("%u  ", print_branch->a_branch[i]);
	printf("]\n");
	
}
/* END fprintf_branches 1}}} */
 

/*=================================== MAIN ===================================*/
int main() {
	
	/*|--- Variable Declaration {{{1*/
	FILE              	      *file_nodes, *file_edges;

	pid_t					  root_pid;

	vertex_generation 		  *nodes;
	edge_generation	  	      *edges;
	branch            	      *my_branch;

	size              	      MAX_NODES, MAX_EDGES;

	iterator         	      i;

	node	          	      node_tmp, from_node_A, to_node_B;
	generation        	      generation_tmp;
	
	unsigned int 		      amount_of_sons, weight;

	/*END Variable Declaration 1}}}*/

	/*|--- Reading all nodes and edges {{{1*/
	file_nodes = fopen ("nodes.txt", "r");
	file_edges = fopen ("edges.txt", "r");

	if (file_nodes == NULL || file_edges == NULL ) printf("Problems to open the files\n");

	fscanf (file_nodes, "%u", &MAX_NODES);
	nodes = malloc (MAX_NODES * sizeof (vertex_generation));

	i = 0;
	while (fscanf (file_nodes, "%u %u %u", &node_tmp, &generation_tmp, &amount_of_sons) != EOF) {
		(nodes + i)->vertex      = node_tmp;
		(nodes + i)->gen         = generation_tmp;
		(nodes + i)->amount_sons = amount_of_sons;

		++i;
	}
	fclose (file_nodes);

	fscanf (file_edges, "%u", &MAX_EDGES);
	edges = malloc (MAX_EDGES * sizeof (edge_generation));

	i = 0;
	while (fscanf (file_edges, "%u %u %u", &from_node_A, &to_node_B, &weight) != EOF) {
		(edges + i)->from     = from_node_A;
		(edges + i)->to       = to_node_B;
		(edges + i)->weight   = weight;

		++i;
	}
	fclose (file_edges);
	/*END Reading all nodes and edges 1}}}*/

	/*|--- Storing all branches {{{1*/
	i              = 0;
	root_pid	   = getpid ();
	while ((nodes+i)->gen == 0) {
		if ((nodes+i)->amount_sons !=0) {
			fork ();
			if (root_pid != getpid ()) {
				my_branch = add_all_branches_version2 (nodes, edges, i);
				if (my_branch != NULL ) printf_branches (my_branch);
				return 0;
			}
			while (wait(NULL) > 0);
		}
		++i;
	}
	/*END Storing all branches 1}}}*/

	return 0;
}
