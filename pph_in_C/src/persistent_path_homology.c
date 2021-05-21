/* vim: set ts=4 expandtab sw=4: */
#include <stdio.h>
#include <stdlib.h>
#include "../headers/persistent_path_homology.h"
#include "../headers/basis_of_vector_space.h"
#include "../headers/Tp.h"
#include "../headers/network_weight.h"
#include "../headers/definitions.h"

#define INFINITE -1

Pers *alloc_Pers (dim_path pph_max) {
    dim_path i;

    Pers *P         = malloc (sizeof (Pers));
    P->PPH_Diagrams = malloc ((pph_max + 1) * sizeof (root));

    for (i = 0; i <= pph_max; ++i)
        (P->PPH_Diagrams + i)->stack = NULL;

    P->pph_max = pph_max;
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
    FILE *fh;
    Pers_interval_p *interval;
    dim_path        p;

    fh = fopen ("data/pph_diagrams.txt", "w");
    if (fh == NULL) printf ("Problems to write pph_diagrams.txt\n");

    for (p = 0; p <= P->pph_max; ++p) {
        fprintf (fh, "Persistent Path Diagrams of dimension %u:\n", p);
        interval = (P->PPH_Diagrams + p)->stack;

        while (interval != NULL) {
            fprintf (fh, "[%6.2f,%6.2f]\n", (interval->PPH_interval_dim_p)[0], (interval->PPH_interval_dim_p)[1]);
            interval = interval->next;
        }
    }
    fclose (fh);
}


double allow_time_vector (collection_of_basis *B,
                          vector path_vector,
			  dim_path path_dim,
			  dim_vector_space base_dim) {

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

                distance = distance < network_weight (vertex, vertex_next)
                           ? network_weight (vertex, vertex_next) : distance;
            }
        }
    }
    return distance;
} /*  Tested Ok */


double entry_time_vector (collection_of_basis *B,
                          vector path_vector,
			  dim_path path_dim,
			  dim_vector_space base_dim) {

    base_index i;
    double distance = 0.0;
    unsigned int j, k, l;
    regular_path boundary, temp;

    if (path_dim == 0) return 0.0;

    else if (path_dim == 1) return allow_time_vector (B, path_vector, path_dim, base_dim);

    else {
        distance = allow_time_vector (B, path_vector, path_dim, base_dim);

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

                    distance = distance < allow_time_regular_path (boundary, path_dim - 1) ?
                        allow_time_regular_path (boundary, path_dim - 1) : distance;
                }
            }
        }
        free (boundary);
        return distance;
    }
}

double entry_time_regular_path (collection_of_basis *B,
                                dim_path path_dim,
				base_index index) {

    double distance = 0.0;
    unsigned int j, k, l;
    regular_path boundary, temp;

    if (path_dim == 0) return 0.0;

    else if (path_dim == 1) return allow_time_regular_path (get_path_of_base_i_index_j (B, path_dim, index),
                                                            path_dim);

    else {
        distance = allow_time_regular_path (get_path_of_base_i_index_j (B, path_dim, index),
                                            path_dim);

        /*Now we will have to calculate the boudary operator of the path_vector
         * then we will take its allow times */
        boundary = malloc ((path_dim) * sizeof (vertex_index));
        /*for (i = 0; i < get_dimVS_of_ith_base (B, path_dim); ++i) {*/

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

	    distance = distance < allow_time_regular_path (boundary, path_dim - 1) ?
		allow_time_regular_path (boundary, path_dim - 1) : distance;
	}
    /*}*/
    free (boundary);
    return distance;
    }
}

vector apply_border_operator_and_take_out_unmarked_points (collection_of_basis *B,
                                                           vector path_vector,
                                                           dim_path path_dim) {

    vector u;
    unsigned int i, j, l, k;
    regular_path boundary_of_path_vector, temp;

    boundary_of_path_vector = malloc (path_dim * sizeof (vertex_index));

    u = malloc (get_dimVS_of_ith_base (B, path_dim - 1) * sizeof (boolean));

    for (i = 0; i < get_dimVS_of_ith_base (B, path_dim - 1); ++i) u[i] = 0;


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
			            break;
                    }
                }
            }
        }
    } /*finished calculating the border*/

    free (boundary_of_path_vector);


    return u;
}


vector BasisChange (collection_of_basis *B,
		    T_p *Tp,
		    vector path_vector,
		    dim_path path_dim,
                    double *return_et, 
		    base_index *return_max_index) {

    vector u;

    base_index i, k, max_index = 0;

    double et = 0.0;

    regular_path temp;

    u = apply_border_operator_and_take_out_unmarked_points (B, path_vector, path_dim);


    max_index = 0;
    for (i = 0; i < get_dimVS_of_ith_base (B, path_dim - 1); ++i)
    	if (u[i] != 0) max_index = i;

    while (max_index > 0) {
        temp = get_path_of_base_i_index_j (B, path_dim - 1, max_index);

        et = allow_time_vector (B, path_vector, path_dim, get_dimVS_of_ith_base (B, path_dim))
            <
            allow_time_regular_path (temp, path_dim - 1 )
            ?
            allow_time_regular_path (temp, path_dim - 1 ) :
            allow_time_vector (B, path_vector, path_dim, get_dimVS_of_ith_base (B, path_dim));

        if (is_T_p_pathDim_i_vector_j_empty (Tp, path_dim - 1, max_index) == EMPTY) break;

        sum_these_vectors (u,
                           get_Tp_vector_of_pathDim_i_index_j (Tp, path_dim - 1, max_index),
                           get_dimVS_of_ith_base (B, path_dim - 1));

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


Pers *ComputePPH(unsigned int pph_max_dim, unsigned int network_set_size) {

    Pers                *PPH; 
    collection_of_basis *B  ;
    T_p                 *Tp ;

    unsigned int        j, k, p, max_index;
    vector              u, v_j;
    double              et, lower, upper;

    /*Setting the environment*/
    printf ("Environment variables\n\n");
	PPH = alloc_Pers (pph_max_dim);

    B   = alloc_all_basis (pph_max_dim + 1, network_set_size);
    printf ("Info about all basis allocated:\n");
    printf ("===============================\n\n");

    for (j = 0; j < 3; ++j)
        printf ("The amount of regular paths of dimension %u is: %u\n",(B->basis+j)->dimension_of_the_regular_path,
                                                                       (B->basis+j)->dimension_of_the_vs_spanned_by_base);

    printf("\n\n");

    printf ("Basis -- DONE\n");


    Tp  = alloc_T_p (B);
    printf ("T_p -- DONE\n");

    initialize_Marking_basis_vectors       (B);
    sorting_the_basis_by_their_allow_times (B);
    
    printf ("Basis marked and ordered -- DONE\n\n");
    /*printf_basis (B); */

    printf ("===========================================\n");
    printf ("Calculating the path persistent homology   \n");
    printf ("===========================================\n");

    /*Now lets start the algorithm*/
    for (p = 0; p <= pph_max_dim; ++p) {

        /*u   = malloc (get_dimVS_of_ith_base (B, p) * sizeof (boolean));*/
        v_j = malloc (get_dimVS_of_ith_base (B, p + 1) * sizeof (boolean));

        for (j = 0; j < get_dimVS_of_ith_base (B, p + 1); ++j) {
            printf ("First Loop -- Path dim = %u, base index = %u\n", p, j);

            for (k = 0; k < get_dimVS_of_ith_base (B, p + 1); ++k) {
                if (k == j) v_j[k] = TRUE;
                else        v_j[k] = FALSE;
            }

            /*if (p == 1 && j == 12 ) print_Tp (Tp);*/
            u = BasisChange (B, Tp, v_j, p + 1, &et, &max_index);
            /*print_vec_nicely (u, get_dimVS_of_ith_base (B, p), "u");*/


            if (is_this_vector_zero (u, get_dimVS_of_ith_base (B, p)) == TRUE) {
                marking_vector_basis (B, p + 1, j);
                free (u);
            }
            else {
                set_T_p_pathDim_i_vector_j (Tp, p, max_index, u, et);
                lower = entry_time_regular_path (B, p, max_index);
                upper = et;
                add_interval_of_pathDim_p (PPH, p, lower, upper);
            }
        }
        free (v_j);
        for (j = 0; j < get_dimVS_of_ith_base (B, p); ++j) {
            printf ("Second Loop -- Path dim = %u, base index = %u\n", p, j);

            if (is_T_p_pathDim_i_vector_j_empty  (Tp, p, j) == EMPTY &&
                is_path_of_dimPath_p_index_j_marked (B, p, j) == MARKED ) {
                lower = entry_time_regular_path (B, p, j);
                upper = INFINITE;
                add_interval_of_pathDim_p (PPH, p, lower, upper);
            }
        }
    }

    return PPH;
}
