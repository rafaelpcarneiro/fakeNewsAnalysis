#ifndef __PERSISTENT_PATH_HOMOLOGY_H_
#define __PERSISTENT_PATH_HOMOLOGY_H_

#include "definitions.h"
#include "Tp.h"
#include "basis_of_vector_space.h"
#include <stdlib.h>

/*================================================================
 * SETTING THE DATA TYPE TO STORE THE PERSISTENT PATH HOMOLOGY
 * DIAGRAMS
 * ---------------------------------------------------------------
 *
 *================================================================
 *================================================================*/

/*  a stack is introduced down bellow  */
typedef struct _Pers_interval_p{
    double                  PPH_interval_dim_p[2];
    struct _Pers_interval_p *next;
} Pers_interval_p;

typedef struct {
    Pers_interval_p *stack;
} root;

typedef struct {
    root     *PPH_Diagrams;
    dim_path pph_max;
} Pers;


/*  Main Functions  */
Pers *alloc_Pers (dim_path);


void add_interval_of_pathDim_p (Pers*, dim_path, double, double);


void print_all_persistent_diagrams (Pers*);


double allow_time_vector (double**, collection_of_basis*,
                          vector, dim_path, dim_vector_space);


double entry_time_vector (double **network_weight, collection_of_basis *B,
                          vector path_vector, unsigned int path_dim, unsigned int base_dim);


vector BasisChange (collection_of_basis *B, T_p *Tp, double **network_weight, vector path_vector, unsigned int path_dim,
                    double *return_et, unsigned int *return_max_index);


Pers *ComputePPH(unsigned int pph_dim,
                 double **network_weight,
                 unsigned int network_set_size);

#endif /* __PERSISTENT_PATH_HOMOLOGY_H_ */
