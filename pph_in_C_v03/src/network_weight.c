/* vim: set ts=4 expandtab sw=4: */

#include "../headers/network_weight.h"
#include "../headers/definitions.h"
#include <stdlib.h>
#include <stdio.h>
/*================================================================
 * DOCUMENTATION> please read the file doc.pdf (inside the folder
 * pph_in_C), it explains everething that you will find here.
 *
 * ---------------------------------------------------------------
 *================================================================*/

double network_weight (vertex_index x, vertex_index y) {

    FILE *fh;
    unsigned int size;
    vertex_index a, b;
    unsigned int weight;
    /* unsigned int test; */

    fh = fopen ("data/edges.txt", "r");

    if (fh == NULL) printf ("Problems with the file data/edges.txt\n\n");

    fscanf (fh, "%u", &size);
    /* printf ("size %u\n", size); */ 

    while ( fscanf (fh, "%u %u %u", &a, &b, &weight) != EOF ) 
        if ( (a == x) && (b == y) ) break;

    /*
    while ( fscanf (fh, "%u %u %u", &a, &b, &test) != EOF ) 
        if ( (a == x) && (b == y) ) break;
    */

    fclose (fh);
    /* printf ("netw = %u\n", test); */ 
    /* return (double) (test); */
    return (double) (weight);
}
