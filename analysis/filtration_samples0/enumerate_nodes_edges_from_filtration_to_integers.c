/* vim: foldmethod=marker: set ts=4: set expandtab: */

#include <stdio.h>
#include <stdlib.h>

#define NODES_FILE               "nodes.txt"
#define EDGES_FILE               "edges.txt"
#define PATHDIM2_FILE            "pathDim2.txt"

#define NODES_ENUMERATED_FILE    "nodes_enumerated.txt"
#define EDGES_ENUMERATED_FILE    "edges_enumerated.txt"
        
#define PATHDIM1_ENUMERATED_FILE "all_regular_paths_dimension_1.txt"
#define PATHDIM2_ENUMERATED_FILE "all_regular_paths_dimension_2.txt"

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

/* Progress Bar */
void progressBar_PPH (void) {
    static unsigned int percentagePPH = 1;

    if (percentagePPH <= 100){
        printf("█%2d%%", percentagePPH);
        fflush(stdout);
        printf("\b\b\b");
    }

    ++percentagePPH;
}

int main() {
    
    /* Variable Declaration */
    FILE               *file_nodes, *file_edges;

    FILE               *file_nodes_enumerated,
                       *file_edges_enumerated,
                       *file_pathDim1_enumerated;

    vertex_generation  *nodes;
    edge_generation    *edges;

    size               MAX_NODES, MAX_EDGES;

    iterator           i, from, to;

    node               node_tmp, from_node_A, to_node_B;
    double             weight;

    unsigned int       maxIterations, onePercentageIter;

    /* Reading all nodes and edges 2*/
    file_nodes    = fopen (NODES_FILE,    "r");
    file_edges    = fopen (EDGES_FILE,    "r");

    if (file_nodes == NULL || file_edges == NULL ) 
        printf("Problems to open the files\n");

    fscanf (file_nodes,    "%lu", &MAX_NODES);
    fscanf (file_edges,    "%lu", &MAX_EDGES);

    maxIterations     = 2 * (MAX_NODES + MAX_EDGES);
    onePercentageIter = (unsigned int) (0.01 * (double) maxIterations);

    nodes     = malloc (MAX_NODES    * sizeof (vertex_generation));
    edges     = malloc (MAX_EDGES    * sizeof (edge_generation));

    printf("Indexing all vertex by the natural numbers\n");
    printf("Progress: ");
    /* reading nodes */
    i = 0;
    while (fscanf (file_nodes, "%lu", &node_tmp) != EOF) {
        (nodes + i)->vertex = node_tmp;
        ++i;
        if (i % onePercentageIter == 0) progressBar_PPH ();
    }
    fclose (file_nodes);

    /* reading edges */
    i = 0;
    while (fscanf (file_edges, "%lu %lu %lf", &from_node_A, &to_node_B, &weight) != EOF) {
        (edges + i)->from     = from_node_A;
        (edges + i)->to       = to_node_B;
        (edges + i)->weight   = weight;

        ++i;
        if (i % onePercentageIter == 0) progressBar_PPH ();
    }
    fclose (file_edges);


    /* Writing all nodes and edges 2*/
    file_nodes_enumerated = fopen (NODES_ENUMERATED_FILE, "w");
    file_edges_enumerated = fopen (EDGES_ENUMERATED_FILE, "w");

    file_pathDim1_enumerated = fopen (PATHDIM1_ENUMERATED_FILE, "w");

    if (file_nodes_enumerated == NULL || file_edges_enumerated == NULL )
        printf("Problems to write the files\n");

    /* writing nodes indexed by Z >= 0 */
    fprintf (file_nodes_enumerated, "%lu\n", MAX_NODES);
    for (i = 0; i < MAX_NODES; ++i) {
        fprintf (file_nodes_enumerated, "%lu\n", i);

        if (i % onePercentageIter == 0) progressBar_PPH ();
    }

    fclose (file_nodes_enumerated);


    /* writing edges indexed by Z >= 0*/
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

        if (i % onePercentageIter == 0) progressBar_PPH ();
    }
    fclose (file_edges_enumerated);
    fclose (file_pathDim1_enumerated);

    return 0;
}
