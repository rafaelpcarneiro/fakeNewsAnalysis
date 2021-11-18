/* vim: set ts=4: set expandtab: */
#include <stdio.h>
#include <stdlib.h>
#include <pthread.h>
#include "../headers/basis_of_vector_space.h"
#include "../headers/network_weight.h"


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

regular_path get_path_of_base_i_index_j (collection_of_basis *B, dim_path dim_i, vectorBasis_index j) {

    base *base_i = B->basis + dim_i;

    return (base_i->base_matrix + j)->jth_vectorBase;
}

boolean is_path_of_dimPath_p_index_j_marked (collection_of_basis *B, dim_path path_dim, vectorBasis_index index) {
    return ((B->basis + path_dim)->marks)[index];
}

/*  main functions */
collection_of_basis *alloc_all_basis (unsigned int number_of_basis_to_allocate_minus_one,
                                      unsigned int network_set_size,
                                      graphWeightList *W) {
    
    /* since the index for arrays start from 0, number_of_basis_to_allocate_minus_one
     * represents properly the amount of basis we want to calculate. Just remember
     * to stop looping when <= number_of_basis_to_allocate_minus_one
     */

    collection_of_basis       *B = malloc (sizeof (collection_of_basis));
    vectorBasis_index         i;
    /* tuple_regular_path_double ith_tuple; */ 


    /* Don't worry, the value (number_of_basis_to_allocate_minus_one + 1) is correct */
    B->basis        = malloc( (number_of_basis_to_allocate_minus_one + 1) * sizeof(base) );
    B->max_of_basis = number_of_basis_to_allocate_minus_one; /* 0, 1, 2 */

    (B->basis)->base_matrix = malloc ( network_set_size * sizeof (tuple_regular_path_double) );

    (B->basis)->dimension_of_the_regular_path       = 0;
    (B->basis)->dimension_of_the_vs_spanned_by_base = network_set_size;

    for (i = 0; i < network_set_size; ++i) {
        ((B->basis)->base_matrix + i)->jth_vectorBase    = malloc ( sizeof (vertex_index) ); 
        ((B->basis)->base_matrix + i)->jth_vectorBase[0] = i; 
        ((B->basis)->base_matrix + i)->allow_time        = 0.0; 

    }

    /* Now Lets store all basis according to the dimensions 1 and 2*/
	storing_all_regular_paths_up_to_dim2 (B, W);

    return B;
} /*  Tested Ok */


void storing_all_regular_paths_up_to_dim2 (collection_of_basis *B, graphWeightList *W){

    /* This function was adapted to work with the two threads below */
    pthread_t dim1_threadID;
    pthread_t dim2_threadID;

    pthread_arguments myArgs;

    FILE         *paths_xy, *paths_xyz;
    unsigned int size1, size2;


    paths_xy  = fopen (FILE_REGULAR_PATHS_DIM_1, "r");
    if (paths_xy == NULL) {
        printf ("problems trying to open the file containing regular"
                "paths of dimension 1. STOP HERE");
    }
    fscanf (paths_xy, "%u", &size1);
    fclose (paths_xy);

    paths_xyz = fopen (FILE_REGULAR_PATHS_DIM_2, "r");
    if (paths_xyz == NULL) {
        printf ("problems trying to open the file containing regular"
                "paths of dimension 2. STOP HERE");
    }
    fscanf (paths_xyz, "%u", &size2);
    fclose (paths_xyz);


    myArgs.B                        = B;
    myArgs.size_dim1_plus_size_dim2 = size1 + size2;
    myArgs.W                        = W;


    printf("Setting up the filtration\n");
    printf("progress: ");
    fflush(stdout);

    /* Run the threads */
    pthread_create (&dim1_threadID,
                    NULL,
                    &pthread_storing_all_regular_paths_dim1,
                    &myArgs);

    pthread_create (&dim2_threadID,
                    NULL,
                    &pthread_storing_all_regular_paths_dim2,
                    &myArgs);

    pthread_join (dim1_threadID, NULL);
    pthread_join (dim2_threadID, NULL);

    printf("\n\n");
} /*  Tested Ok */

/* THREAD AUXILIARY FUNCTIONS TO IMPROVE SPEED 
 * --> To be used only with storing_all_regular_paths_up_to_dim2
 */
void *pthread_storing_all_regular_paths_dim1 (void *parameters) {
    /* This function is going to open a txt files containing all regular paths
     * of dimension 1 and is going to store them on the collection_of_basis,
     * according to its dimension.
     */

    pthread_arguments         *p  = (pthread_arguments*) parameters;
    collection_of_basis       *B  = p->B;
    graphWeightList           *W  = p->W;
    tuple_regular_path_double *temp_dim_p;
    unsigned int              x, y, i;
	dim_path                  dim_p;
    dim_vector_space          size;
    unsigned int              sizeTotal      = p->size_dim1_plus_size_dim2;
    unsigned int              one_percentage = (int) (0.01 * ( (float) sizeTotal));

    FILE *paths_xy;

	/* regular paths of dimension 1 */
	dim_p = 1;

    paths_xy = fopen (FILE_REGULAR_PATHS_DIM_1, "r");
    if (paths_xy == NULL) {
        printf ("problems trying to open the file containing regular"
                "paths of dimension 1. STOP HERE");
    }


    /* First line of paths_xy.txt is a description of how many regular
     * paths the file has.
     */
    fscanf (paths_xy, "%u", &size);
    ((B->basis) + dim_p)->base_matrix				          = malloc (size * sizeof (tuple_regular_path_double));
	((B->basis) + dim_p)->dimension_of_the_regular_path       = dim_p;
	((B->basis) + dim_p)->dimension_of_the_vs_spanned_by_base = size;

    i = 0;
    while (fscanf (paths_xy, "%u %u", &x, &y) != EOF) {
		temp_dim_p                 = ((((B->basis) + dim_p)->base_matrix) + i);
		temp_dim_p->jth_vectorBase = malloc (2 * sizeof (vertex_index));

		temp_dim_p->jth_vectorBase[0] = x;
		temp_dim_p->jth_vectorBase[1] = y;

		temp_dim_p->allow_time  = network_weight(x, y, W);

        if (i % one_percentage == 0 )  progressBar_reading_filtration ();
		++i;
    }
	fclose (paths_xy);

    return NULL;
}

void *pthread_storing_all_regular_paths_dim2 (void *parameters) {
    /* This function is going to open a txt files containing all regular paths
     * of dimension 2 and is going to store them on the collection_of_basis,
     * according to its dimension.
     */

    pthread_arguments         *p  = (pthread_arguments*) parameters;
    collection_of_basis       *B  = p->B;
    graphWeightList           *W  = p->W;
    tuple_regular_path_double *temp_dim_p;
    unsigned int              x, y, z, i;
	dim_path                  dim_p;
    dim_vector_space          size;
    unsigned int              sizeTotal      = p->size_dim1_plus_size_dim2;
    unsigned int              one_percentage = (int) (0.01 * ( (float) sizeTotal));

    FILE *paths_xyz;

	/* regular paths of dimension 2 */
	dim_p = 2;

    paths_xyz = fopen (FILE_REGULAR_PATHS_DIM_2, "r");
    if (paths_xyz == NULL) {
        printf ("problems opening the file containing all regular paths"
                "of dimension 2. STOP HERE");
    }


    /* First line of paths_xyz.txt is a description of how many regular
     * paths the file has.
     */
    fscanf (paths_xyz, "%u", &size);
    ((B->basis) + dim_p)->base_matrix				          = malloc (size * sizeof (tuple_regular_path_double));
	((B->basis) + dim_p)->dimension_of_the_regular_path       = dim_p;
	((B->basis) + dim_p)->dimension_of_the_vs_spanned_by_base = size;

	i = 0;
    while (fscanf (paths_xyz, "%u %u %u", &x, &y, &z) != EOF) {
		temp_dim_p           = ((((B->basis) + dim_p)->base_matrix) + i);
		temp_dim_p->jth_vectorBase = malloc (3 * sizeof (vertex_index));

		temp_dim_p->jth_vectorBase[0] = x;
		temp_dim_p->jth_vectorBase[1] = y;
		temp_dim_p->jth_vectorBase[2] = z;

		temp_dim_p->allow_time  = network_weight(x,y,W) < network_weight(y,z,W)
                                  ?  network_weight(y,z,W) : network_weight(x,y,W);
																			   

        if (i % one_percentage == 0 )  progressBar_reading_filtration ();
		++i;
    }
	fclose (paths_xyz);

    return NULL;
} /*  Tested Ok */

void progressBar_reading_filtration (void) {
    static unsigned int percentage = 1;

    if (percentage <= 100){
        printf("█%2d%%", percentage);
        fflush(stdout);
        printf("\b\b\b");
    }

    ++percentage;
}


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


void marking_vector_basis (collection_of_basis *B, dim_path dim_p, vectorBasis_index vector__index) {
    ((B->basis + dim_p)->marks) [vector__index] = MARKED;
}


void sorting_the_basis_by_their_allow_times (collection_of_basis *B) {

    dim_path i;

    for (i = 1; i <= B->max_of_basis; ++i)
        qsort ((B->basis + i)->base_matrix, get_dimVS_of_ith_base (B, i),
               sizeof (tuple_regular_path_double), compareTuple);
} /*  Tested Ok */


double allow_time_regular_path (regular_path path, dim_path path_dim, graphWeightList *W) {
    /* Calculates the allow time of a regular path. It will be used to sort our basis */

    unsigned int j;
    vertex_index i, i_plus_one;
    double distance = 0.0;

    for (j = 0; j < path_dim; ++j) {
        i = path[j];
        i_plus_one = path[j + 1];
        distance = distance < network_weight(i, i_plus_one, W) ? network_weight(i, i_plus_one, W) : distance;
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


void printf_basis (collection_of_basis *B) {
	
	FILE *fh;
	unsigned int i, j, k;

	fh = fopen ("data/basis.txt", "w");
	if (fh == NULL) printf ("Problems to write the basis\n");

	for (i = 0; i <= B->max_of_basis; ++i) {
		fprintf (fh,
				 "Regular paths of dimension %u\nVS dimension = %u\n\n",
			 	 (B->basis + i)->dimension_of_the_regular_path,
				 (B->basis + i)->dimension_of_the_vs_spanned_by_base);
		
		for (j = 0; j < (B->basis + i)->dimension_of_the_vs_spanned_by_base; ++j) {
			fprintf (fh, "[");
			for (k = 0; k <= (B->basis + i)->dimension_of_the_regular_path; ++k)
				fprintf (fh, "%u ", ((B->basis + i)->base_matrix + j)->jth_vectorBase[k]);
			fprintf (fh, "]\n");
		}
		fprintf (fh, "\n");
	}
}
