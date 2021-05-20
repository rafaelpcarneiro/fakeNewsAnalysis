/* vim: set ts=4 expandtab sw=4: */

#include "~/fakeNewsAnalysis/pph_in_C/headers/network_weight.h"
#include "~/fakeNewsAnalysis/pph_in_C/headers/definitions.h"
#include <stdlib.h>
/*================================================================
 * DOCUMENTATION> please read the file doc.pdf (inside the folder
 * pph_in_C), it explains everething that you will find here.
 *
 * ---------------------------------------------------------------
 *================================================================*/

double network_weight (vertex_index x, vertex_index y) {

    FILE *fh;
    unsigned int i, size;
    vertex_index a, b;
    unsigned int gen_a, gen_b;

    fh = fopen ("~/fakeNewsAnalysis/pph_in_C/data/edges.txt", "r");

    if (fh == NULL) printf ("Problems with the file data/edges.txt\n\n");

    fscanf (fh, "%u", &size);

    for ( fscanf (fh, "%u %u %u %u", &a, &b, &gen_a, &gen_b) != EOF ) 
        if ( (a == x) && (b == y) )
            return (double) (gen_b - gen_a);


    return 0;
}
