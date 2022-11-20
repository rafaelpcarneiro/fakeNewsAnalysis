/* vim: set ts=4 expandtab sw=4: */
/*================================================================
 * DOCUMENTATION> please read the file doc.pdf (inside the folder
 * pph_in_C), it explains everething that you will find here.
 *
 * ---------------------------------------------------------------
 *================================================================*/

#ifndef __NETWORK_WEIGHT_H_
#define __NETWORK_WEIGHT_H_

#include "definitions.h"

#define FILE_EDGES "data/edges.txt"

typedef struct {
    vertex_index from;
    vertex_index to;
    double       weightEdge;
} graphWeight;

typedef struct {
    graphWeight  *thegraphWeight;
    unsigned long long int size;
} graphWeightList;

graphWeightList *alloc_graphWeightMatrix (void);

double          network_weight (vertex_index, vertex_index, graphWeightList*);

#endif /* __NETWORK_WEIGHT_H_ */
