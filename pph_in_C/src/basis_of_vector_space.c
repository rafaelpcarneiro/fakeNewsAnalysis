/* vim: set ts=4: set expandtab: */
#include <stdlib.h>
#include "~/fakeNewsAnalysis/pph_in_C/headers/basis_of_vector_space.h"
#include "~/fakeNewsAnalysis/pph_in_C/headers/network_weight.h"

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
                                      unsigned int network_set_size) {
    
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

	/*Base referent to regular paths of dimension > 0*/
	/* I won't use the loop below. Instead, I will make usage of the version 2
	 * of the function: generating_all_regular_paths_dim_p.
	 *
     * for (i = 1; i <= number_of_basis_to_allocate_minus_one; ++i) {
     *     generating_all_regular_paths_dim_p (B, i, network_set_size, network_weight);
     * }
	 */
	generating_all_regular_paths_dim_p_version2 (B);

    return B;
} /*  Tested Ok */


int generating_all_regular_paths_dim_p_version2 (collection_of_basis *B){

    /* This function is going to open a txt files containing all regular paths,
     * contrary to its ancestor which would build all possible combinations. 
     * The purpose of this function is to build bases of regular paths up to dimension 2.
     */
    tuple_regular_path_double *temp_dim_p;

    unsigned int x, y, z, i;

	dim_path dim_p;

    dim_vector_space size;

    FILE *paths_xy, *paths_xyz;

	/* regular paths of dimension 1 */
	dim_p = 1;

    paths_xy = fopen ("~/fakeNewsAnalysis/pph_in_C/data/paths_xy.txt", "r");
    if (paths_xy == NULL) {
        printf ("problems trying to open the file paths_xy.txt. STOP HERE")
    }


    /* First line of paths_xy.txt is a description of how many regular
     * paths the file has.
     */
    fscanf (paths_xy, "%u", &size);
    ((B->basis) + dim_p)->base_matrix				          = malloc (size * sizeof (tuple_regular_path_double));
	((B->basis) + dim_p)->dimension_of_the_regular_path       = dim_p;
	((B->basis) + dim_p)->dimension_of_the_vs_spanned_by_base = size;

    i = 0;
    while (fscanf (paths_xy, "%u ; %u", &x, &y) != EOF) {
		temp_dim_p           = ((((B->basis) + dim_p)->base_matrix) + i);
		temp_dim_p->ith_base = malloc (2 * sizeof (vertex_index));

		temp_dim_p->ith_base[0] = x;
		temp_dim_p->ith_base[1] = y;

		temp_dim_p->allow_time  = network_weight(x, y);

		++i;
    }
	fclose (paths_xy);

	/* regular paths of dimension 2 */
	dim_p = 2;

    paths_xyz = fopen ("~/fakeNewsAnalysis/pph_in_C/data/paths_xyz.txt", "r");
    if (paths_xyz == NULL) {
        printf ("problems opening the file paths_xyz.txt. STOP HERE")
    }


    /* First line of paths_xyz.txt is a description of how many regular
     * paths the file has.
     */
    fscanf (paths_xyz, "%u", &size);
    ((B->basis) + dim_p)->base_matrix				          = malloc (size * sizeof (tuple_regular_path_double));
	((B->basis) + dim_p)->dimension_of_the_regular_path       = dim_p;
	((B->basis) + dim_p)->dimension_of_the_vs_spanned_by_base = size;

	i = 0;
    while (fscanf (paths_xyz, "%u ; %u ; %u", &x, &y, &z)) {
		temp_dim_p           = ((((B->basis) + dim_p)->base_matrix) + i);
		temp_dim_p->ith_base = malloc (3 * sizeof (vertex_index));

		temp_dim_p->ith_base[0] = x;
		temp_dim_p->ith_base[1] = y;
		temp_dim_p->ith_base[2] = z;

		temp_dim_p->allow_time  = network_weight(x,y) < network_weight(y,z) ?  network_weight(y,z):
																			   network_weight(x,y);

		++i;
    }
	fclose (paths_xyz);
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


double allow_time_regular_path (regular_path path, dim_path path_dim) {
    /* Calculates the allow time of a regular path. It will be used to sort our basis */

    unsigned int j;
    vertex_index i, i_plus_one;
    double distance = 0.0;

    for (j = 0; j < path_dim; ++j) {
        i = path[j];
        i_plus_one = path[j + 1];
        distance = distance < network_weight(i, i_plus_one) ? network_weight(i, i_plus_one) : distance;
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
