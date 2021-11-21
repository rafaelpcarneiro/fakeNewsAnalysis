/* vim: foldmethod=marker: set ts=4: set expandtab: */

#include <stdio.h>
#include <stdlib.h>

#define NODES_FILE    "nodes.txt"
#define EDGES_FILE    "edges.txt"
#define PATHDIM2_FILE "pathDim2.txt"

#define NODES_ENUMERATED_FILE    "nodes_enumerated.txt"
#define EDGES_ENUMERATED_FILE    "edges_enumerated.txt"
        
#define PATHDIM1_ENUMERATED_FILE "pathDim1_enumerated.txt"
#define PATHDIM2_ENUMERATED_FILE "pathDim2_enumerated.txt"

/* Data Types  */
typedef unsigned long int node;
typedef unsigned long int size;
typedef unsigned long int iterator;

typedef struct {
    node   vertex;

} vertex_generation;

typedef struct {
    node   from;
    node   to;
    double weight;
    char   flag;

} edge_generation;

typedef struct {
    node   a0;
    node   a1;
    node   a2;

} pathDim2;

int main() {
    
    /* Variable Declaration */
    FILE               *file_nodes, *file_edges, *file_pathDim2;

    FILE               *file_nodes_enumerated,
                       *file_edges_enumerated,
                       *file_pathDim1_enumerated,
                       *file_pathDim2_enumerated;

    vertex_generation  *nodes;
    edge_generation    *edges;
    pathDim2           *pathsDim2;

    size               MAX_NODES, MAX_EDGES, MAX_PATHDIM2;

    iterator           i, from, to, b0, b1, b2;

    node               node_tmp, from_node_A, to_node_B, a0, a1, a2;
    double             weight;
    

    /* Reading all nodes and edges 2*/
    file_nodes = fopen (NODES_FILE, "r");
    file_edges = fopen (EDGES_FILE, "r");

    file_pathDim2 = fopen (PATHDIM2_FILE, "r");

    if (file_nodes == NULL || file_edges == NULL || file_pathDim2 == NULL ) 
        printf("Problems to open the files\n");

    fscanf (file_nodes, "%lu", &MAX_NODES);
    nodes = malloc (MAX_NODES * sizeof (vertex_generation));

    i = 0;
    while (fscanf (file_nodes, "%lu", &node_tmp) != EOF) {
        (nodes + i)->vertex = node_tmp;
        ++i;
    }
    fclose (file_nodes);

    fscanf (file_edges, "%lu", &MAX_EDGES);
    edges = malloc (MAX_EDGES * sizeof (edge_generation));

    i = 0;
    while (fscanf (file_edges, "%lu %lu %lf", &from_node_A, &to_node_B, &weight) != EOF) {
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

    /* Writing all nodes and edges 2*/
    file_nodes_enumerated = fopen (NODES_ENUMERATED_FILE, "w");
    file_edges_enumerated = fopen (EDGES_ENUMERATED_FILE, "w");

    file_pathDim1_enumerated = fopen (PATHDIM1_ENUMERATED_FILE, "w");
    file_pathDim2_enumerated = fopen (PATHDIM2_ENUMERATED_FILE, "w");

    if (file_nodes_enumerated == NULL || file_edges_enumerated == NULL )
        printf("Problems to write the files\n");

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
                 "%lu\t%lu\t%f\n",
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
        
        fprintf (file_pathDim2_enumerated,
                 "%lu\t%lu\t%lu\n",
                 b0, b1, b2);
    }
    fclose (file_pathDim2_enumerated);

    return 0;
}
