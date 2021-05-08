#include <stdlib.h>
#include "basis_of_vector_space.h"

/*  getters and setters */
dim_vector_space get_dimVS_of_ith_base (collection_of_basis *B, dim_path dim_p) {
    base *B_dim_p = (B->basis) + dim_p;
    return (B_dim_p->dimension_of_the_vs_spanned_by_base);
}

void set_dim_path_of_ith_base (collection_of_basis *B, dim_path dim_p) {
    base *B_dim_p                          = (B->basis) + dim_p;
    B_dim_p->dimension_of_the_regular_path =  dim_p;
}

void set_dimVS_of_ith_base (collection_of_basis *B, dim_path dim_p, dim_vector_space dimVS) {
    base *B_dim_p                                = (B->basis) + dim_p;
    B_dim_p->dimension_of_the_vs_spanned_by_base =  dimVS;
}

regular_path get_path_of_base_i_index_j (collection_of_basis *B, dim_path dim_i, base_index j) {

    base *base_i = B->basis + dim_i;

    return (base_i->base_matrix + j)->ith_base;
}

boolean is_path_of_dimPath_p_index_j_marked (collection_of_basis *B, dim_path path_dim, base_index index) {
    return ((B->basis + path_dim)->marks)[index];
}

/*  main functions */
collection_of_basis *alloc_all_basis (unsigned int number_of_basis_to_allocate_minus_one,
                                      unsigned int network_set_size,
                                      double **network_weight) {
    
	/* since the index for arrays start from 0, number_of_basis_to_allocate_minus_one
	 * represents properly the amount of basis we want to calculate. Just remember
	 * to stop looping when <= number_of_basis_to_allocate_minus_one
	 */

    collection_of_basis       *B = malloc (sizeof (collection_of_basis));
    base_index                i;
    tuple_regular_path_double ith_tuple;

    /* Don't worry, the value (number_of_basis_to_allocate_minus_one + 1) is correct */
    B->basis        = malloc( (number_of_basis_to_allocate_minus_one + 1) * sizeof(base) );
    B->max_of_basis = number_of_basis_to_allocate_minus_one;

    (B->basis)->base_matrix = malloc ( network_set_size * sizeof (tuple_regular_path_double) );

    (B->basis)->dimension_of_the_regular_path       = 0;
    (B->basis)->dimension_of_the_vs_spanned_by_base = network_set_size;

    for (i = 0; i < network_set_size; ++i) {
        /*Base referent to regular paths of dimension 0*/
        ith_tuple             = ((B->basis)->base_matrix)[i];
        ith_tuple.ith_base    = malloc ( sizeof (vertex_index) );
        ith_tuple.ith_base[0] = i;
        ith_tuple.allow_time  = 0.0;
    }

    for (i = 1; i <= number_of_basis_to_allocate_minus_one; ++i) {
        /*Base referent to regular paths of dimension > 0*/
        generating_all_regular_paths_dim_p (B, i, network_set_size, network_weight);
    }

    return B;
} /*  Tested Ok */

void generating_all_regular_paths_dim_p (collection_of_basis *B,
                                         dim_path dim_p,
                                         unsigned int network_set_size,
                                         double **network_weight){

    base *B_dim_p           = (B->basis) + dim_p;
    base *B_dim_p_minus_one = (B->basis) + (dim_p - 1);

    tuple_regular_path_double *temp_dim_p, *temp_dim_p_minus_one;

    unsigned int i, j, k, l;

    set_dim_path_of_ith_base (B, dim_p);
    set_dimVS_of_ith_base (B, dim_p, get_dimVS_of_ith_base (B, dim_p - 1) * (network_set_size - 1));

    B_dim_p->base_matrix = malloc ( get_dimVS_of_ith_base (B, dim_p) * sizeof (tuple_regular_path_double) );

    l = 0;
    for (i = 0; i < get_dimVS_of_ith_base (B, dim_p - 1); ++i) {
        /*  continue here */
        temp_dim_p_minus_one = B_dim_p_minus_one->base_matrix + i;
        temp_dim_p           = B_dim_p->base_matrix + l;

        for (j = 0; j < network_set_size; ++j) {
            temp_dim_p->ith_base = malloc( (dim_p + 1) * sizeof(vertex_index) );

            if ( temp_dim_p_minus_one->ith_base[dim_p - 1] != j ) {
                for (k = 0; k <= dim_p - 1; ++k) temp_dim_p->ith_base[k] = temp_dim_p_minus_one->ith_base[k];
                temp_dim_p->ith_base[k] = j;
                ++l;
            }
            /*now calculate the allow time of such regular path*/
            temp_dim_p->allow_time = allow_time_regular_path (network_weight, temp_dim_p->ith_base, dim_p);
        }
    }
} /*  Tested Ok */


void initialize_Marking_basis_vectors (collection_of_basis *B) {

    dim_path i;
    unsigned int j;


    for (i = 0; i <= B->max_of_basis; ++i) {

        (B->basis + i)->marks = malloc ( get_dimVS_of_ith_base (B, i) * sizeof (boolean) );

        for (j = 0; j < get_dimVS_of_ith_base (B, i); ++j){
            ((B->basis + i)->marks)[j] = NOT_MARKED;
        }
    }

    /*  Marking all regular paths of dimension 0 */

    for (j = 0; j < get_dimVS_of_ith_base (B, 0); ++j)
        (B->basis)->marks[j] = MARKED;

} /*  Teste ok */


void marking_vector_basis (collection_of_basis *B, dim_path dim_p, base_index vector_index) {
    ((B->basis + dim_p)->marks) [vector_index] = MARKED;
}


void sorting_the_basis_by_their_allow_times (collection_of_basis *B) {

    dim_path i;

    for (i = 1; i <= B->max_of_basis; ++i)
        qsort ((B->basis + i)->base_matrix, get_dimVS_of_ith_base (B, i),
               sizeof (tuple_regular_path_double), compareTuple);
} /*  Tested Ok */


double allow_time_regular_path (double **network_weight, regular_path path, dim_path path_dim) {
    /* Calculates the allow time of a regular path. It will be used to sort our basis */

    unsigned int j;
    vertex_index i, i_plus_one;
    double distance = 0.0;

    for (j = 0; j < path_dim; ++j) {
        i = path[j];
        i_plus_one = path[j + 1];
        distance = distance < network_weight[i][i_plus_one] ? network_weight[i][i_plus_one] : distance;
    }

    return distance;
} /*  Tested Ok */


int compareTuple (const void *p1, const void *p2) {
    double p1_value, p2_value;

    p1_value = ((tuple_regular_path_double*) p1)->allow_time;
    p2_value = ((tuple_regular_path_double*) p2)->allow_time;

    if      (p1_value <  p2_value) return -1;
    else if (p1_value == p2_value) return 0;
    else               return 1;
} /*  Ok*/
