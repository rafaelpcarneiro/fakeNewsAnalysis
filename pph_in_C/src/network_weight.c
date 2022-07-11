/* vim: set ts=4 expandtab sw=4: */

/*================================================================
 * DOCUMENTATION> please read the file doc.pdf (inside the folder
 * pph_in_C), it explains everething that you will find here.
 *
 * ---------------------------------------------------------------
 *================================================================*/

#include "../headers/network_weight.h"
#include "../headers/definitions.h"
#include <stdlib.h>
#include <stdio.h>

graphWeightList *alloc_graphWeightMatrix (void) {
    FILE         *fh;
    unsigned long long int i;
    vertex_index a, b;
    unsigned long long int weight_matrix_size;
    double       weight_tmp;

    graphWeightList  *weight  = malloc (sizeof (graphWeightList));


    fh = fopen (FILE_EDGES, "r");

    if (fh == NULL) 
        printf ("Problems reading the file with the matix of the weights\n\n");

    fscanf (fh, "%llu", &weight_matrix_size);

    weight->thegraphWeight = malloc (weight_matrix_size * sizeof(graphWeight));
    weight->size           = weight_matrix_size;

    i = 0;
    while ( fscanf (fh, "%llu %llu %lf", &a, &b, &weight_tmp) != EOF ) {
        (weight->thegraphWeight + i)->from       = a;
        (weight->thegraphWeight + i)->to         = b;
        (weight->thegraphWeight + i)->weightEdge = weight_tmp;
        ++i;
    }
    fclose (fh);

    return weight;
}

double network_weight (vertex_index x, vertex_index y, graphWeightList *W) {

    unsigned long long int    i;
    double          weight_to_return = 0.0; 
    /* unsigned int test; */

    for (i = 0; i < W->size; ++i) {
        if ( ((W->thegraphWeight + i)->from == x) && ((W->thegraphWeight + i)->to == y)) {
         
            weight_to_return = (W->thegraphWeight + i)->weightEdge;
            break;
        }
    }

    /* printf ("netw = %u\n", test); */ 
    /* return (double) (test); */
    return weight_to_return;
}
