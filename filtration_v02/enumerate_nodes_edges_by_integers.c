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

typedef struct {
    node         vertex;

} vertex_generation;

typedef struct {
    node         from;
    node         to;
    unsigned int weight;

    char         flag;

} edge_generation;

typedef struct {
    node         a0;
    node         a1;
    node         a2;

} pathDim2;
/* END Data Types 1}}} */

/*|--- MAIN {{{1*/
int main() {
    
    /*|--- Variable Declaration {{{2*/
    FILE                      *file_nodes, *file_edges, *file_pathDim2;

    FILE                      *file_nodes_enumerated,
                              *file_edges_enumerated,
                              *file_pathDim1_enumerated,
                              *file_pathDim2_enumerated;

    vertex_generation         *nodes;
    edge_generation           *edges;
    pathDim2                  *pathsDim2;

    size                      MAX_NODES, MAX_EDGES, MAX_PATHDIM2;

    iterator                  i, from, to, b0, b1, b2;

    node                      node_tmp, from_node_A, to_node_B, a0, a1, a2;
    unsigned long int         weight;
    
    /*END Variable Declaration 2}}}*/

    /*|--- Reading all nodes and edges {{{2*/
    file_nodes = fopen ("nodes.txt", "r");
    file_edges = fopen ("edges.txt", "r");

    file_pathDim2 = fopen ("pathDim2.txt", "r");

    if (file_nodes == NULL || file_edges == NULL || file_pathDim2 == NULL ) 
        printf("Problems to open the files\n");

    fscanf (file_nodes, "%lu", &MAX_NODES);
    nodes = malloc (MAX_NODES * sizeof (vertex_generation));

    i = 0;
    while (fscanf (file_nodes, "%lu", &node_tmp) != EOF) {
        (nodes + i)->vertex      = node_tmp;

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


    fscanf (file_pathDim2, "%lu", &MAX_PATHDIM2);
    pathsDim2 = malloc (MAX_PATHDIM2 * sizeof (pathDim2));

    i = 0;
    while (fscanf (file_pathDim2, "%lu %lu %lu", &a0, &a1, &a2) != EOF) {
        (pathsDim2 + i)->a0   = a0;
        (pathsDim2 + i)->a1   = a1;
        (pathsDim2 + i)->a2   = a2;

        ++i;
    }
    fclose (file_pathDim2);
    /*END Reading all nodes and edges 2}}}*/

    /*|--- Writing all nodes and edges {{{2*/
    file_nodes_enumerated = fopen ("nodes_enumerated.txt", "w");
    file_edges_enumerated = fopen ("edges_enumerated.txt", "w");

    file_pathDim1_enumerated = fopen ("pathDim1_enumerated.txt", "w");
    file_pathDim2_enumerated = fopen ("pathDim2_enumerated.txt", "w");

    if (file_nodes_enumerated == NULL || file_edges_enumerated == NULL ) printf("Problems to write the files\n");

    fprintf (file_nodes_enumerated, "%lu\n", MAX_NODES);
    for (i = 0; i < MAX_NODES; ++i)
        fprintf (file_nodes_enumerated, "%lu\n", i);

    fclose (file_nodes_enumerated);


    fprintf (file_edges_enumerated,    "%lu\n", MAX_EDGES);
    fprintf (file_pathDim1_enumerated, "%lu\n", MAX_EDGES);
    for (i = 0; i < MAX_EDGES; ++i) {
        for (from = 0; from < MAX_NODES; ++from)
            if ((edges+i)->from == (nodes+from)->vertex) break;

        for (to = 0; to < MAX_NODES; ++to)
            if ((edges+i)->to == (nodes+to)->vertex) break;
        
        fprintf (file_edges_enumerated,
                 "%lu\t%lu\t%lu\n",
                 from, to, (edges+i)->weight);

        fprintf (file_pathDim1_enumerated,
                 "%lu\t%lu\n",
                 from, to);
    }
    fclose (file_edges_enumerated);
    fclose (file_pathDim1_enumerated);


    fprintf (file_pathDim2_enumerated, "%lu\n", MAX_PATHDIM2);
    for (i = 0; i < MAX_PATHDIM2; ++i) {
        for (b0 = 0; b0 < MAX_NODES; ++b0)
            if ((pathsDim2+i)->a0 == (nodes+b0)->vertex) break;

        for (b1 = 0; b1 < MAX_NODES; ++b1)
            if ((pathsDim2+i)->a1 == (nodes+b1)->vertex) break;

        for (b2 = 0; b2 < MAX_NODES; ++b2)
            if ((pathsDim2+i)->a2 == (nodes+b2)->vertex) break;
        
        fprintf (file_pathDim1_enumerated,
                 "%lu\t%lu\t%lu\n",
                 b0, b1, b2);
    }
    fclose (file_pathDim2_enumerated);

    /*END writing all nodes and edges 2}}}*/

    return 0;
}
/*END MAIN 1}}}*/
