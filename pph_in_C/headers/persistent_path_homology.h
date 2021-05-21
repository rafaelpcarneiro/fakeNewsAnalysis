#ifndef __PERSISTENT_PATH_HOMOLOGY_H_
#define __PERSISTENT_PATH_HOMOLOGY_H_

#include "definitions.h"
#include "Tp.h"
#include "basis_of_vector_space.h"
#include <stdlib.h>

/*================================================================
 * DOCUMENTATION> please read the file doc.pdf (inside the folder
 * pph_in_C), it explains everething that you will find here.
 *
 * ---------------------------------------------------------------
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


double allow_time_vector (collection_of_basis*, vector, dim_path, dim_vector_space);


double entry_time_vector (collection_of_basis*, vector, unsigned int, unsigned int);

vector apply_border_operator_and_take_out_unmarked_points (collection_of_basis*, vector, dim_path);

void print_vec_nicely (vector, dim_vector_space, char*);


vector BasisChange (collection_of_basis *B,
		    T_p	*Tp,
		    vector path_vector,
		    dim_path path_dim,
                    double *return_et,
		    unsigned int *return_max_index);


Pers *ComputePPH(unsigned int pph_dim,
                 unsigned int network_set_size);

#endif /* __PERSISTENT_PATH_HOMOLOGY_H_ */
