#include <stdio.h>
#include <stdlib.h>
#include "persistent_path_homology.h"
#include "basis_of_vector_space.h"


Pers *alloc_Pers (dim_path pph_max) {
    dim_path i;

    Pers *P         = malloc (sizeof (Pers));
    P->PPH_Diagrams = malloc ((pph_max + 1) * sizeof (root));

    for (i = 0; i <= pph_max; ++i)
        P->PPH_Diagrams->stack = NULL;

    return P;
}


void add_interval_of_pathDim_p (Pers *P, dim_path p, double lower, double upper) {
    Pers_interval_p *interval;

    interval = malloc (sizeof (Pers_interval_p));

    interval->PPH_interval_dim_p[0] = lower;
    interval->PPH_interval_dim_p[1] = upper;
    interval->next                  = (P->PPH_Diagrams + p)->stack;
    (P->PPH_Diagrams + p)->stack    = interval;
}


void print_all_persistent_diagrams (Pers *P) {
    Pers_interval_p *interval;
    dim_path        p;

    for (p = 0; p <= P->pph_max; ++p) {
        printf ("Persistent Path Diagrams of dimension %u:\n", p);
        interval = (P->PPH_Diagrams + p)->stack;

        while (interval != NULL) {
            printf ("[%6.2f,%6.2f]\n", (interval->PPH_interval_dim_p)[0], (interval->PPH_interval_dim_p)[1]);
            interval = interval->next;
        }
    }
}


double allow_time_vector (double **network_weight, collection_of_basis *B,
                          vector path_vector, dim_path path_dim, dim_vector_space base_dim) {

    base_index   i;
    unsigned int j;
    double       distance = 0.0;
    regular_path temp_path;
    vertex_index vertex, vertex_next;

    if (path_dim == 0) return 0.0;

    for (i = 0; i < base_dim; ++i) {
        if (path_vector[i] == TRUE) {
            temp_path = get_path_of_base_i_index_j (B, path_dim, i);

            for (j = 0; j < path_dim; ++j) {
                vertex      = temp_path[j];
                vertex_next = temp_path[j + 1];

                distance = distance < network_weight[vertex][vertex_next]
                           ? network_weight [vertex][vertex_next] : distance;
            }
        }
    }
    return distance;
} /*  Tested Ok */


double entry_time_vector (double **network_weight, collection_of_basis *B,
                          vector path_vector, dim_path path_dim, dim_vector_space base_dim) {

    base_index i;
    double distance = 0.0;
    unsigned int j, k, l;
    regular_path boundary, temp;

    if (path_dim == 0) return 0.0;

    else if (path_dim == 1) return allow_time_vector (network_weight, B, path_vector, path_dim, base_dim);

    else {
        distance = allow_time_vector (network_weight, B, path_vector, path_dim, base_dim);

        /*Now we will have to calculate the boudary operator of the path_vector
         * then we will take its allow times */
        boundary = malloc ((path_dim) * sizeof (vertex_index));
        for (i = 0; i < base_dim; ++i) {

            if (path_vector[i] == TRUE) {
                temp = get_path_of_base_i_index_j (B, path_dim, i);

                for (j = 0; j <= path_dim; ++j) {
                    l = 0;
                    for (k = 0; k <= path_dim; ++k) {
                        if (k != j) {
                            boundary[l] = temp[k];
                            ++l;
                        }
                    }
                    if (is_this_path_a_regular_path (boundary, path_dim - 1) == FALSE) continue;

                    distance = distance < allow_time_regular_path (network_weight, boundary, path_dim - 1) ?
                        allow_time_regular_path (network_weight, boundary, path_dim - 1) : distance;
                }
            }
        }
        free (boundary);
        return distance;
    }
}

double entry_time_regular_path (double **network_weight, collection_of_basis *B,
                                dim_path path_dim, base_index index) {

    base_index i;
    double distance = 0.0;
    unsigned int j, k, l;
    regular_path boundary, temp;

    if (path_dim == 0) return 0.0;

    else if (path_dim == 1) return allow_time_regular_path (network_weight,
                                                            get_path_of_base_i_index_j (B, path_dim, index),
                                                            path_dim);

    else {
        distance = allow_time_regular_path (network_weight,
                                            get_path_of_base_i_index_j (B, path_dim, index),
                                            path_dim);

        /*Now we will have to calculate the boudary operator of the path_vector
         * then we will take its allow times */
        boundary = malloc ((path_dim) * sizeof (vertex_index));
        for (i = 0; i < get_dimVS_of_ith_base (B, path_dim); ++i) {

            temp = get_path_of_base_i_index_j (B, path_dim, index);

            for (j = 0; j <= path_dim; ++j) {
                l = 0;
                for (k = 0; k <= path_dim; ++k) {
                    if (k != j) {
                        boundary[l] = temp[k];
                        ++l;
                    }
                }
                if (is_this_path_a_regular_path (boundary, path_dim - 1) == FALSE) continue;

                distance = distance < allow_time_regular_path (network_weight, boundary, path_dim - 1) ?
                    allow_time_regular_path (network_weight, boundary, path_dim - 1) : distance;
            }
        }
        free (boundary);
        return distance;
    }
}

vector BasisChange (collection_of_basis *B, T_p *Tp, double **network_weight, vector path_vector, dim_path path_dim,
                    double *return_et, base_index *return_max_index) {

    vector u;

    regular_path boundary_of_path_vector, temp;


    base_index i, j, k, l, max_index = 0;

    double et = 0.0;

    boundary_of_path_vector = malloc (path_dim * sizeof (vertex_index));

    u = malloc (get_dimVS_of_ith_base (B, path_dim - 1) * sizeof (boolean));

    max_index = 0;

    for (i = 0; i < get_dimVS_of_ith_base (B, path_dim); ++i) {

        if (path_vector[i] == TRUE) {
            /*apply the boundary operator*/
            temp = get_path_of_base_i_index_j (B, path_dim, i);

            for (j = 0; j <= path_dim; ++j) {
                l = 0;
                for (k = 0; k <= path_dim; ++k) {
                    if (k != j) {
                        boundary_of_path_vector[l] = temp[k];
                        ++l;
                    }
                }
                if (is_this_path_a_regular_path (boundary_of_path_vector, path_dim - 1) == FALSE) continue;

                for (k = 0; k < get_dimVS_of_ith_base (B, path_dim - 1); ++k) {
                    if (are_these_regular_paths_the_same (get_path_of_base_i_index_j (B, path_dim - 1, k),
                                                          boundary_of_path_vector, path_dim - 1) == TRUE
                        && is_path_of_dimPath_p_index_j_marked (B, path_dim - 1, k) == TRUE) {

                        u[k] = (u[k] + 1) % 2;
                        if (u[k] != 0) max_index = max_index < k ? k : max_index;
                    }

                }
            }
        }
    } /*finished calcualting the border*/

    while (max_index > 0) {
        temp = get_path_of_base_i_index_j (B, path_dim - 1, max_index);

        et = allow_time_vector (network_weight, B, u, path_dim - 1, get_dimVS_of_ith_base (B, path_dim - 1))
            <
            allow_time_regular_path (network_weight, temp, path_dim - 1 )
            ?
            allow_time_regular_path (network_weight, temp, path_dim - 1 ) :
            allow_time_vector (network_weight, B, u, path_dim - 1, get_dimVS_of_ith_base (B, path_dim - 1));

        if (is_T_p_pathDim_i_vector_j_empty (Tp, path_dim - 1, max_index) == EMPTY) break;

        for (k = 0; k < get_dimVS_of_ith_base (B, path_dim - 1); ++k) {
            sum_these_vectors (u,
                               get_Tp_vector_of_pathDim_i_index_j (Tp, path_dim - 1, max_index),
                               get_dimVS_of_ith_base (B, path_dim - 1));
        }

        /*now check again max_index*/
        max_index = 0;
        for (k = 0; k < get_dimVS_of_ith_base (B, path_dim - 1); ++k) {
            if (u[k] != 0) max_index = k;
        }
    }

    /*returning the values*/
    /*return_vector = u;*/
    *return_et = et;
    *return_max_index = max_index;
    return u;
}


Pers *ComputePPH(unsigned int pph_dim, double **network_weight, unsigned int network_set_size) {

    Pers                *PPH = alloc_Pers (pph_dim);
    collection_of_basis *B   = alloc_all_basis (pph_dim + 1, network_set_size, network_weight);
    T_p                 *Tp  = alloc_T_p (B);

    unsigned int        j, k, p, max_index;
    vector              u, v_j;
    double              et, lower, upper;

    /*Setting the environment*/
    initialize_Marking_basis_vectors       (B);
    sorting_the_basis_by_their_allow_times (B);

    /*Now lets start the algorithm*/
    for (p = 0; p <= pph_dim; ++p) {

        u   = malloc (get_dimVS_of_ith_base (B, p) * sizeof (boolean));
        v_j = malloc (get_dimVS_of_ith_base (B, p + 1) * sizeof (boolean));

        for (j = 0; j < get_dimVS_of_ith_base (B, p + 1); ++j) {

            for (k = 0; k < get_dimVS_of_ith_base (B, p + 1); ++k) {
                if (k == j) v_j[k] = TRUE;
                else        v_j[k] = FALSE;
            }

            u = BasisChange (B, Tp, network_weight, v_j, p + 1, &et, &max_index);

            if (is_this_vector_zero (u, get_dimVS_of_ith_base (B, p)) == TRUE)
                marking_vector_basis (B, p + 1, j);
            else {
                set_T_p_pathDim_i_vector_j (Tp, p, max_index, u, et);

                lower = entry_time_regular_path (network_weight, B, p, max_index);
                upper = et;
                add_interval_of_pathDim_p (PPH, p, lower, upper);
            }
        }
        for (j = 0; j < get_dimVS_of_ith_base (B, p); ++j) {

            if (is_T_p_pathDim_i_vector_j_empty  (Tp, p, j) == EMPTY &&
                is_path_of_dimPath_p_index_j_marked (B, p, j) == MARKED ) {


                lower = entry_time_regular_path (network_weight, B, p, j);
                upper = -1.0;
                add_interval_of_pathDim_p (PPH, p, lower, upper);
            }
        }

        free (u);
    }

    return PPH;
}
