#ifndef __TP_H_
#define __TP_H_

#include "definitions.h"
#include "basis_of_vector_space.h"

/*================================================================
 * SETTING THE DATA TYPE TO DEAL WITH THE T_P STRUCTURE
 * ---------------------------------------------------------------
 *
 * Explanation of each of these data types.
 *
 *================================================================
 * T_P_tuple := a struct storing the tuple (path_vector,
 *   |           entry_time, is_empty, dim).
 *   |
 *   --> path_vector:= an array of booleans representing a vactor
 *   |                  in a given base.
 *   |
 *   --> entry_time := the moment when a regular path w is feasible
 *   |              at the filtration.
 *   |
 *   --> is_empty   := checking if this tuple is empty or not;
 *   |
 *   |
 *   --> dim        := the dimension of the regular paths that span
 *                     the vector spach which path_vector is element
 *
 * T_p_tuple_collection := a struct with all T_p_tuple of same dim.
 *   |
 *   |
 *   --> array_of_T_p_tuple := an array with all tuples  sharing
 *   |                         the condition that path_vectors have
 *   |                         same dimension
 *   |
 *   --> size               := the size of the array above
 *
 * T_p := a struct which finnaly assembly all T_p ranging from all
 *   |    dimensions
 *   |
 *   --> all_Tp := an array containing all T_p_tuple_collection
 *   |
 *   |
 *   --> dim    := maximum number of T_p_tuple_collection to
 *                 store;
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
