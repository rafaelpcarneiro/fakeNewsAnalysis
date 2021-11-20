/* vim: set ts=4 expandtab sw=4: */
#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <pthread.h>
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
            fprintf (fh, "%6.2f,%6.2f\n",
                     (interval->PPH_interval_dim_p)[0],
                     (interval->PPH_interval_dim_p)[1]
            );
            interval = interval->next;
        }
    }
    fclose (fh);
}


double allow_time_vector (collection_of_basis *B,
                          vector *path_vector,
                          dim_path path_dim,
                          graphWeightList *W) {

    unsigned int j;
    double       distance = 0.0;
    regular_path temp_path;
    vertex_index vertex, vertex_next;
    vector_index *tmp;
    boolean      test;


    if (path_dim == 0) return 0.0;

    test = is_this_vector_zero (path_vector);
    if (test == TRUE) return 0.0;

    tmp = path_vector->root;
    while (tmp != NULL) {
        temp_path = get_path_of_base_i_index_j (B, path_dim, tmp->pos);

        for (j = 0; j < path_dim; ++j) {
            vertex      = temp_path[j];
            vertex_next = temp_path[j + 1];

            distance = distance < network_weight (vertex, vertex_next, W)
                       ? network_weight (vertex, vertex_next, W) : distance;
        }
        
        tmp = tmp->next;
    }
    return distance;
} /*  Tested Ok */


double entry_time_vector (collection_of_basis *B,
                          vector *path_vector,
                          dim_path path_dim,
                          graphWeightList *W) {

    double distance = 0.0;
    unsigned int j, k, l;
    regular_path boundary, temp;
    boolean test;
    vector_index *tmp_index;

    if (path_dim == 0) return 0.0;

    else if (path_dim == 1) return allow_time_vector (B, path_vector, path_dim, W);

    else {
        distance = allow_time_vector (B, path_vector, path_dim, W);

        /*Now we will have to calculate the boudary operator of the path_vector
         * then we will take its allow times */
        boundary = malloc ((path_dim) * sizeof (vertex_index));

        test = is_this_vector_zero (path_vector);
        if (test == TRUE) return 0.0;

        tmp_index = path_vector->root;
        while (tmp_index != NULL)  {

            temp = get_path_of_base_i_index_j (B, path_dim, tmp_index->pos);

            for (j = 0; j <= path_dim; ++j) {
                l = 0;
                for (k = 0; k <= path_dim; ++k) {
                    if (k != j) {
                        boundary[l] = temp[k];
                        ++l;
                    }
                }
                if (is_this_path_a_regular_path (boundary, path_dim - 1) == FALSE) continue;

                distance = distance < allow_time_regular_path (boundary, path_dim - 1, W) ?
                    allow_time_regular_path (boundary, path_dim - 1, W) : distance;
            }

            tmp_index = tmp_index->next;
        }
        free (boundary);
        return distance;
    }
}

double entry_time_regular_path (collection_of_basis *B,
                                dim_path path_dim,
                                vectorBasis_index index,
                                graphWeightList *W) {

    double distance = 0.0;
    unsigned int j, k, l;
    regular_path boundary, temp;

    if (path_dim == 0) return 0.0;

    else if (path_dim == 1)
        return allow_time_regular_path (get_path_of_base_i_index_j (B, path_dim, index),
                                        path_dim,
                                        W);

    else {
        distance = allow_time_regular_path (get_path_of_base_i_index_j (B, path_dim, index),
                                            path_dim,
                                            W);

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

            distance = distance < allow_time_regular_path (boundary, path_dim - 1, W) ?
                allow_time_regular_path (boundary, path_dim - 1, W) : distance;
        }
        /*}*/
        free (boundary);
        return distance;
        }
}

vector *apply_border_operator_and_take_out_unmarked_points (collection_of_basis *B,
                                                            vector *path_vector,
                                                            dim_path path_dim) {

    vector *u;
    unsigned int j, l, k;
    regular_path boundary_of_path_vector, temp;
    vector_index *tmp_index;

    boundary_of_path_vector = malloc (path_dim * sizeof (vertex_index));

    u = alloc_vec ();

    /*
    u = malloc (get_dimVS_of_ith_base (B, path_dim - 1) * sizeof (boolean));
    for (i = 0; i < get_dimVS_of_ith_base (B, path_dim - 1); ++i) u[i] = 0;
    */


    tmp_index = path_vector->root;
    while (tmp_index != NULL ) {

        /*apply the boundary operator*/
        temp = get_path_of_base_i_index_j (B, path_dim, tmp_index->pos);

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
                    &&
                    is_path_of_dimPath_p_index_j_marked (B, path_dim - 1, k) == TRUE) {

                    add_index_to_vector (u, k);
                    /* u[k] = (u[k] + 1) % 2; */
                    break;
                }
            }
        }
         
        tmp_index = tmp_index->next;
    } /*finished calculating the border*/

    free (boundary_of_path_vector);


    return u;
}


vector *BasisChange (collection_of_basis *B,
                     T_p *Tp,
                     vector *path_vector,
                     dim_path path_dim,
                     double *return_et, 
                     vectorBasis_index *return_max_index,
                     graphWeightList *W) {

    vector_index *tmp_index;
    vector *u;

    vectorBasis_index max_index = 0;

    double et = 0.0;

    regular_path temp;

    u = apply_border_operator_and_take_out_unmarked_points (B, path_vector, path_dim);


    max_index = 0;
    tmp_index = u->root;
    while (tmp_index != NULL) {
        max_index = max_index <= tmp_index->pos ? tmp_index->pos : max_index;
        tmp_index = tmp_index->next;
    }

    while (max_index > 0) {
        temp = get_path_of_base_i_index_j (B, path_dim - 1, max_index);

        et = allow_time_vector (B, path_vector, path_dim, W)
            <
            allow_time_regular_path (temp, path_dim - 1, W )
            ?
            allow_time_regular_path (temp, path_dim - 1, W ) :
            allow_time_vector (B, path_vector, path_dim, W);

        if (is_T_p_pathDim_i_vector_j_empty (Tp, path_dim - 1, max_index) == EMPTY) break;

        sum_these_vectors (u,
                           get_Tp_vector_of_pathDim_i_index_j (Tp, path_dim - 1, max_index));


        /*now check again max_index*/
        max_index = 0;
        tmp_index = u->root;
        while (tmp_index != NULL) {
            max_index = max_index <= tmp_index->pos ? tmp_index->pos : max_index;
            tmp_index = tmp_index->next;
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
    graphWeightList     *W;

    unsigned int        j;

    pthread_t           thread_dim0_dim1;
    pthread_t           thread_dim0_dim0;
    pthread_t           thread_dim1_dim2;
    pthread_t           thread_dim1_dim1;

    pthread_loop_args   pthreadArgs;

    /*Setting the environment*/
    printf ("Allocating the Environment variables\n\n");
    PPH = alloc_Pers (pph_max_dim);

    /* initializing the network weight env */
    W = alloc_graphWeightMatrix ();
    
    B   = alloc_all_basis (pph_max_dim + 1, network_set_size, W);
    printf ("Info about all basis allocated:\n");
    printf ("===============================\n\n");

    for (j = 0; j < 3; ++j)
        printf ("The amount of regular paths of dimension %u is: %u\n",
                (B->basis+j)->dimension_of_the_regular_path,
                (B->basis+j)->dimension_of_the_vs_spanned_by_base
        );

    printf("\n\n");


    Tp  = alloc_T_p (B);

    initialize_Marking_basis_vectors       (B);
    sorting_the_basis_by_their_allow_times (B);

    /* storing all info into a pthread arg stucture */
    pthreadArgs.PPH = PPH;
    pthreadArgs.B   = B;
    pthreadArgs.Tp  = Tp;
    pthreadArgs.W   = W;
    
    /* printf_basis (B); */

    printf("Env variables summary      status:\n");
    printf("----------------------------------------------------\n");
    printf("Basis         (*B)         allocated in MEM     - OK\n");
    printf("Basis         (*B)         marked               - OK\n");
    printf("Basis         (*B)         sorted by allow time - OK\n");
    printf("PPH diagram   (*PPH)       allocated in MEM     - OK\n");
    printf("Weight Matrix (*W)         allocated in MEM     - OK\n");
    printf("T_p structure (*T_p)       allocated in MEM     - OK\n");
    printf("Thread Args   (*pthread)   allocated in MEM     - OK\n\n");

    sleep  (5);
    printf ("Now, we are ready to calculate the persistent path homology\n");
    printf ("\n\n");
    sleep  (1);

    /*Now lets start the algorithm*/
    printf("PPH diagrams\n");
    printf("progress: ");

    pthread_create (&thread_dim0_dim1, 
                    NULL, 
                    &pthread_loop_dim0_dim1, 
                    &pthreadArgs);

    pthread_create (&thread_dim1_dim2, 
                    NULL, 
                    &pthread_loop_dim1_dim2, 
                    &pthreadArgs);

    pthread_join (thread_dim0_dim1, NULL); 

    pthread_create (&thread_dim0_dim0, 
                    NULL, 
                    &pthread_loop_dim0_dim0, 
                    &pthreadArgs);

    pthread_join (thread_dim1_dim2, NULL); 
    pthread_join (thread_dim0_dim0, NULL); 

    pthread_create (&thread_dim1_dim1, 
                    NULL, 
                    &pthread_loop_dim1_dim1, 
                    &pthreadArgs);

    pthread_join (thread_dim1_dim1, NULL); 

    printf("\n\n");
    return PPH;
}

/* THREAD AUXILIARY FUNCTIONS */

/* Thread responsible for the loop j = 0, 1, 2, ..., dim (R_{0+1}) with p == 0 
 * (Here, R_{0+1} are the regular paths of dimensio 0+1)
 * --> First iteration of the LOOP
 */
void *pthread_loop_dim0_dim1 (void *myArgs) {
    /* pt = parameter thread */
    pthread_loop_args   *pt   = (pthread_loop_args*) myArgs;

    Pers                *PPH = pt->PPH; 
    collection_of_basis *B   = pt->B;
    T_p                 *Tp  = pt->Tp;
    graphWeightList     *W   = pt->W;

    unsigned int        maxNumberOfIterations, onePercentageProgress;
    unsigned int        j, p, max_index;
    vector              *u, *v_j;
    double              et, lower, upper;




    maxNumberOfIterations = get_dimVS_of_ith_base (B, 1) +
                             get_dimVS_of_ith_base (B, 0) +
                             get_dimVS_of_ith_base (B, 2) +
                             get_dimVS_of_ith_base (B, 1);

    onePercentageProgress = (int) (0.01 * (double) maxNumberOfIterations);

    /*Now lets start the algorithm*/
    p   = 0;            /* p == dimension */
    v_j = alloc_vec (); 

    for (j = 0; j < get_dimVS_of_ith_base (B, p + 1); ++j) {

        v_j = I_k (j);

        /*if (p == 1 && j == 12 ) print_Tp (Tp);*/
        u = BasisChange (B, Tp, v_j, p + 1, &et, &max_index, W);
        /*print_vec_nicely (u, get_dimVS_of_ith_base (B, p), "u");*/


        if (is_this_vector_zero (u) == TRUE) {
            marking_vector_basis (B, p + 1, j);
            free_vector (u);
        }
        else {
            set_T_p_pathDim_i_vector_j (Tp, p, max_index, u, et);
            lower = entry_time_regular_path (B, p, max_index, W);
            upper = et;
            add_interval_of_pathDim_p (PPH, p, lower, upper);
        }

        if (j % onePercentageProgress == 0 )  progressBar_PPH ();
    }
    free_vector (v_j);

    return NULL;
}

/* Thread responsible for the loop j = 0, 1, 2, ..., dim (R_{0}) with p == 0 
 * (Here, R_{0} are the regular paths of dimensio 0)
 * --> First iteration of the LOOP
 */
void *pthread_loop_dim0_dim0 (void *myArgs) {
    /* pt = parameter thread */
    pthread_loop_args   *pt   = (pthread_loop_args*) myArgs;

    Pers                *PPH = pt->PPH; 
    collection_of_basis *B   = pt->B;
    T_p                 *Tp  = pt->Tp;
    graphWeightList     *W   = pt->W;

    unsigned int        maxNumberOfIterations, onePercentageProgress;
    unsigned int        j, p;
    double              lower, upper;




    maxNumberOfIterations = get_dimVS_of_ith_base (B, 1) +
                             get_dimVS_of_ith_base (B, 0) +
                             get_dimVS_of_ith_base (B, 2) +
                             get_dimVS_of_ith_base (B, 1);

    onePercentageProgress = (int) (0.01 * (double) maxNumberOfIterations);

    /*Now lets start the algorithm*/
    p   = 0;            /* p == dimension */

    for (j = 0; j < get_dimVS_of_ith_base (B, p); ++j) {

        if (is_T_p_pathDim_i_vector_j_empty  (Tp, p, j)   == EMPTY 
            &&
            is_path_of_dimPath_p_index_j_marked (B, p, j) == MARKED )
        {
            lower = entry_time_regular_path (B, p, j, W);
            upper = INFINITE;
            add_interval_of_pathDim_p (PPH, p, lower, upper);
        }

        if (j % onePercentageProgress == 0 )  progressBar_PPH ();
    }

    return NULL;
}



/* Thread responsible for the loop j = 0, 1, 2, ..., dim (R_{1+1}) with p == 1
 * (Here, R_{1+1} are the regular paths of dimensio 1+1)
 * --> Second iteration of the LOOP
 */
void *pthread_loop_dim1_dim2 (void *myArgs) {
    /* pt = parameter thread */
    pthread_loop_args   *pt   = (pthread_loop_args*) myArgs;

    Pers                *PPH = pt->PPH; 
    collection_of_basis *B   = pt->B;
    T_p                 *Tp  = pt->Tp;
    graphWeightList     *W   = pt->W;

    unsigned int        maxNumberOfIterations, onePercentageProgress;
    unsigned int        j, p, max_index;
    vector              *u, *v_j;
    double              et, lower, upper;




    maxNumberOfIterations = get_dimVS_of_ith_base (B, 1) +
                             get_dimVS_of_ith_base (B, 0) +
                             get_dimVS_of_ith_base (B, 2) +
                             get_dimVS_of_ith_base (B, 1);

    onePercentageProgress = (int) (0.01 * (double) maxNumberOfIterations);

    /*Now lets start the algorithm*/
    p   = 1;            /* p == dimension */
    v_j = alloc_vec (); 

    for (j = 0; j < get_dimVS_of_ith_base (B, p + 1); ++j) {

        v_j = I_k (j);

        /*if (p == 1 && j == 12 ) print_Tp (Tp);*/
        u = BasisChange (B, Tp, v_j, p + 1, &et, &max_index, W);
        /*print_vec_nicely (u, get_dimVS_of_ith_base (B, p), "u");*/


        if (is_this_vector_zero (u) == TRUE) {
            marking_vector_basis (B, p + 1, j);
            free_vector (u);
        }
        else {
            set_T_p_pathDim_i_vector_j (Tp, p, max_index, u, et);
            lower = entry_time_regular_path (B, p, max_index, W);
            upper = et;
            add_interval_of_pathDim_p (PPH, p, lower, upper);
        }

        if (j % onePercentageProgress == 0 )  progressBar_PPH ();
    }
    free_vector (v_j);

    return NULL;
}

/* Thread responsible for the loop j = 0, 1, 2, ..., dim (R_{1}) with p == 1 
 * (Here, R_{1} are the regular paths of dimensio 1)
 * --> Second iteration of the LOOP
 */
void *pthread_loop_dim1_dim1 (void *myArgs) {
    /* pt = parameter thread */
    pthread_loop_args   *pt   = (pthread_loop_args*) myArgs;

    Pers                *PPH = pt->PPH; 
    collection_of_basis *B   = pt->B;
    T_p                 *Tp  = pt->Tp;
    graphWeightList     *W   = pt->W;

    unsigned int        maxNumberOfIterations, onePercentageProgress;
    unsigned int        j, p;
    double              lower, upper;




    maxNumberOfIterations = get_dimVS_of_ith_base (B, 1) +
                             get_dimVS_of_ith_base (B, 0) +
                             get_dimVS_of_ith_base (B, 2) +
                             get_dimVS_of_ith_base (B, 1);

    onePercentageProgress = (int) (0.01 * (double) maxNumberOfIterations);

    /*Now lets start the algorithm*/
    p   = 1;            /* p == dimension */

    for (j = 0; j < get_dimVS_of_ith_base (B, p); ++j) {

        if (is_T_p_pathDim_i_vector_j_empty  (Tp, p, j)   == EMPTY 
            &&
            is_path_of_dimPath_p_index_j_marked (B, p, j) == MARKED )
        {
            lower = entry_time_regular_path (B, p, j, W);
            upper = INFINITE;
            add_interval_of_pathDim_p (PPH, p, lower, upper);
        }

        if (j % onePercentageProgress == 0 )  progressBar_PPH ();
    }

    return NULL;
}

/* Progress Bar */
void progressBar_PPH (void) {
    static unsigned int percentagePPH = 1;

    if (percentagePPH <= 100){
        printf("█%2d%%", percentagePPH);
        fflush(stdout);
        printf("\b\b\b");
    }

    ++percentagePPH;
}
