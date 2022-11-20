#ifndef __PERSISTENT_PATH_HOMOLOGY_H_
#define __PERSISTENT_PATH_HOMOLOGY_H_

#include "definitions.h"
#include "Tp.h"
#include "basis_of_vector_space.h"
#include "sparce_vector.h"
#include <stdlib.h>
#include "network_weight.h"

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

/* Thread structure */
typedef struct {
    Pers                *PPH;
    collection_of_basis *B  ;
    T_p                 *Tp ;
    graphWeightList     *W  ;

} pthread_loop_args;


/*  Main Functions  */
Pers *alloc_Pers                   (dim_path);

void add_interval_of_pathDim_p     (Pers*, dim_path, double, double);

void print_all_persistent_diagrams (Pers*);

double allow_time_vector           (collection_of_basis*, vector*, dim_path, graphWeightList*);

double entry_time_vector           (collection_of_basis*, vector*, unsigned long long int, graphWeightList*);

double entry_time_regular_path     (collection_of_basis*, dim_path, vectorBasis_index, graphWeightList*);
                                


vector *apply_border_operator_and_take_out_unmarked_points (collection_of_basis*, vector*, dim_path);

/*
void print_vec_nicely (vector*, dim_vector_space, char*);
*/


vector *BasisChange (collection_of_basis *B,
                     T_p *Tp,
                     vector *path_vector,
                     dim_path path_dim,
                     double *return_et,
                     unsigned long long int *return_max_index,
                     graphWeightList *W);


Pers *ComputePPH    (unsigned long long int pph_dim,
                     unsigned long long int network_set_size);

/* THREADS AUXILIARY FUNCTIONS */
void *pthread_loop_dim0_dim1 (void *);
void *pthread_loop_dim0_dim0 (void *);
void *pthread_loop_dim1_dim2 (void *);
void *pthread_loop_dim1_dim1 (void *);

/* Progress Bar */
void progressBar_PPH (void);
#endif /* __PERSISTENT_PATH_HOMOLOGY_H_ */
