/* vim: set ts=4 expandtab sw=4: */
#include <stdio.h>
#include <stdlib.h>
#include "../headers/persistent_path_homology.h"
#include "../headers/basis_of_vector_space.h"
#include "../headers/Tp.h"
#include "../headers/network_weight.h"
#include "../headers/definitions.h"

int main () {

    Pers  *PPH; 
    FILE *nodes;
    unsigned int network_size;

    nodes = fopen ("data/nodes.txt", "r");
    if (nodes == NULL) printf ("Problems to read data/nodes.txt\n");

    fscanf (nodes, "%u", &network_size);
    fclose (nodes);

    PPH =  ComputePPH(1, network_size);

    print_all_persistent_diagrams (PPH); 

	return 0;
}
