/*================================================================
 * DOCUMENTATION> please read the file doc.pdf (inside the folder
 * pph_in_C), it explains everething that you will find here.
 *
 * ---------------------------------------------------------------
 *================================================================*/

#ifndef __BASIS_OF_VECTOR_SPACE_H_
#define __BASIS_OF_VECTOR_SPACE_H_

#include "definitions.h"

#define FILE_REGULAR_PATHS_DIM_1 "data/all_regular_paths_dimension_1.txt" 
#define FILE_REGULAR_PATHS_DIM_2 "data/all_regular_paths_dimension_2.txt"

typedef struct {
    regular_path               jth_vectorBase;
    double                     allow_time;

} tuple_regular_path_double;

/*  Here 'vs' stands for vector space */
typedef struct{
    tuple_regular_path_double  *base_matrix;
    unsigned int               dimension_of_the_regular_path;
    unsigned int               dimension_of_the_vs_spanned_by_base;
    boolean                    *marks;

} base;

typedef struct{
    base                       *basis;
    unsigned int               max_of_basis;

} collection_of_basis;

/* A structure to be used with Threads */
typedef struct {
    collection_of_basis *B;
    unsigned int long   size_dim1_plus_size_dim2;
} pthread_arguments;

/*  FUNCTIONS OPERATING ON THESE STRUCTS  */
collection_of_basis *alloc_all_basis        (unsigned int,
                                             unsigned int);

void storing_all_regular_paths_up_to_dim2   (collection_of_basis*);

void initialize_Marking_basis_vectors       (collection_of_basis*);


void sorting_the_basis_by_their_allow_times (collection_of_basis*);

void marking_vector_basis                   (collection_of_basis*,
                                             dim_path,
                                             vectorBasis_index);

double allow_time_regular_path              (regular_path,
                                             dim_path);

int compareTuple                            (const void*,
                                             const void*);

void printf_basis                           (collection_of_basis*);

/*  setters and getters */
dim_vector_space get_dimVS_of_ith_base      (collection_of_basis*,
                                             dim_path);

void set_dim_path_of_ith_base               (collection_of_basis*,
                                             dim_path);

void set_dimVS_of_ith_base                  (collection_of_basis*,
                                             dim_path,
                                             dim_vector_space);

regular_path get_path_of_base_i_index_j     (collection_of_basis*,
                                             dim_path,
                                             vectorBasis_index);

boolean is_path_of_dimPath_p_index_j_marked (collection_of_basis*,
                                             dim_path,
                                             vectorBasis_index);

/* THREADS */
void *pthread_storing_all_regular_paths_dim1 (void*);

void *pthread_storing_all_regular_paths_dim2 (void*);

/* Progress Bar - Filtration */
void progressBar_reading_filtration (void);
#endif /* __BASIS_OF_VECTOR_SPACE_H_ */
