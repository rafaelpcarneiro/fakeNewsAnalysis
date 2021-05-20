/* vim: set ts=4 expandtab: */
#include <stdlib.h>
#include "~/fakeNewsAnalysis/pph_in_C/headers/Tp.h"


/*  main functions */

T_p *alloc_T_p (collection_of_basis *B) {

    T_p                  *Tp = malloc (sizeof (T_p));
    T_p_tuple_collection *Tp_i;
    T_p_tuple            *Tp_i_j;

    unsigned int i, j, k;
	
    /* I will loook for diagrams of dimension 0 and 1. Thus, I just need the
     * T_p structure of dimension 0 and 1. The code will have this changes in mind
     */
    /*Tp->all_Tp    = malloc (B->max_of_basis * sizeof (T_p_tuple_collection));*/
    /*Tp->max_of_Tp = B->max_of_basis;*/
    Tp->all_Tp    = malloc (2 * sizeof (T_p_tuple_collection));
    Tp->max_of_Tp = 1;

    for (i = 0; i <= Tp->max_of_Tp; ++i) {
        Tp_i = Tp->all_Tp + i;

        Tp_i->array_of_T_p_tuple = malloc (get_dimVS_of_ith_base (B, i) * sizeof (T_p_tuple));
        Tp_i->size               = get_dimVS_of_ith_base (B, i);

        for (j = 0; j < Tp_i->size; ++j) {
            Tp_i_j              = Tp_i->array_of_T_p_tuple + j;
            Tp_i_j->path_vector = malloc (Tp_i->size * sizeof (boolean)); /* DANGER TOO BIG */
            Tp_i_j->is_empty    = EMPTY;
        }
    }
    return Tp;
}


/*  Setters and getters */

boolean is_T_p_pathDim_i_vector_j_empty (T_p * Tp,
                                         dim_path dim,
                                         vector_index index) {
    return ((Tp->all_Tp + dim)->array_of_T_p_tuple + index)->is_empty; /*returns EMPTY or NOT_EMPTY*/
}


void set_T_p_pathDim_i_vector_j (T_p *Tp,
                                 dim_path dim,
                                 vector_index index,
                                 vector u,
                                 double et) {

    ((Tp->all_Tp + dim)->array_of_T_p_tuple + index)->path_vector = u;
    ((Tp->all_Tp + dim)->array_of_T_p_tuple + index)->entry_time  = et;
    ((Tp->all_Tp + dim)->array_of_T_p_tuple + index)->is_empty    = NOT_EMPTY;

}

vector get_Tp_vector_of_pathDim_i_index_j (T_p *Tp, dim_path dim_i, vector_index index_j) {
    return ((Tp->all_Tp + dim_i)->array_of_T_p_tuple + index_j)->path_vector;
}

double get_Tp_et_of_pathDim_i_index_j (T_p *Tp, dim_path dim_i, vector_index index_j) {
    return ((Tp->all_Tp + dim_i)->array_of_T_p_tuple + index_j)->entry_time;
}
