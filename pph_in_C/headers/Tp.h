#ifndef __TP_H_
#define __TP_H_

#include "definitions.h"
#include "basis_of_vector_space.h"

/*================================================================
 * DOCUMENTATION> please read the file doc.pdf (inside the folder
 * pph_in_C), it explains everething that you will find here.
 *
 * ---------------------------------------------------------------
 *================================================================*/
typedef struct{
    vector  path_vector;
    double  entry_time;
    boolean is_empty;

} T_p_tuple;

typedef struct{
    T_p_tuple        *array_of_T_p_tuple;
    dim_vector_space size;

} T_p_tuple_collection;

typedef struct{
    T_p_tuple_collection *all_Tp;
    dim_path             max_of_Tp;

} T_p;

/*  Functions acting into these types */
T_p *alloc_T_p (collection_of_basis*);

/*  setters and getters */
void set_T_p_pathDim_i_vector_j (T_p*, dim_path, vector_index, vector, double);


boolean is_T_p_pathDim_i_vector_j_empty (T_p*, dim_path, vector_index);


vector get_Tp_vector_of_pathDim_i_index_j (T_p*, dim_path, vector_index);


double get_Tp_et_of_pathDim_i_index_j (T_p*, dim_path, vector_index);

#endif // __TP_H_
