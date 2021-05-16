/* vim: set ts=4 expandtab sw=4: foldmethod=marker: */
#include <stdio.h>
#include <stdlib.h>

#define TRUE 1
#define FALSE 0

typedef char boolean;
typedef struct {
	unsigned int a_path[3];
}path;

boolean check_if_path_i_is_a_repetition (path *regular_paths, unsigned int i, unsigned int dim) {

    unsigned int j;
    if (dim == 2)
        for (j = 0; j < i; ++j) {
            if ( ((regular_paths+j)->a_path[0] == (regular_paths+i)->a_path[0]) &&
                 ((regular_paths+j)->a_path[1] == (regular_paths+i)->a_path[1]) ) {

                 return TRUE;
            }
        }
    else
        for (j = 0; j < i; ++j) {
            if ( ((regular_paths+j)->a_path[0] == (regular_paths+i)->a_path[0]) &&
                 ((regular_paths+j)->a_path[1] == (regular_paths+i)->a_path[1]) &&
                 ((regular_paths+j)->a_path[2] == (regular_paths+i)->a_path[2]) ) {

                 return TRUE;
            }
        }

    return FALSE;
}

int main () {

	path *regular_paths;
	unsigned int size, i;
    boolean check;

	FILE *fh_read_dim2, *fh_read_dim3, *fh_write_dim2, *fh_write_dim3;

	fh_read_dim2 = fopen ("all_regular_paths_dimension_2.txt", "r");

	if (fh_read_dim2 == NULL) printf ("Problems to read all_regular_paths_dimension_2.txt\n\n");

	fscanf (fh_read_dim2, "%u", &size);
	regular_paths = malloc (size * sizeof (path));

	for (i = 0; i < size; ++i) 
        fscanf (fh_read_dim2, "%u %u", (regular_paths+i)->a_path, (regular_paths+i)->a_path + 1);
    fclose (fh_read_dim2);

    fh_write_dim2 = fopen ("all_regular_paths_dimension_2_w_rep.txt", "w"); 
	if (fh_write_dim2 == NULL) printf ("Problems to write all_regular_paths_dimension_2_w_rep.txt\n\n");

    /*fprintf (fh_write_dim2, "%u\n", size);*/
    fprintf (fh_write_dim2, "%u %u\n", regular_paths->a_path[0], regular_paths->a_path[1]);

    for (i = 1; i < size; ++i) {
        check = check_if_path_i_is_a_repetition (regular_paths, i, 2);
        if (check == FALSE )
            fprintf (fh_write_dim2, "%u %u\n", (regular_paths+i)->a_path[0], (regular_paths+i)->a_path[1]);
    }
    fclose (fh_write_dim2);
    free (regular_paths);
    

	fh_read_dim3 = fopen ("all_regular_paths_dimension_3.txt", "r");

	if (fh_read_dim3 == NULL) printf ("Problems to read all_regular_paths_dimension_3.txt\n\n");

	fscanf (fh_read_dim3, "%u", &size);
	regular_paths = malloc (size * sizeof (path));

	for (i = 0; i < size; ++i) 
        fscanf (fh_read_dim3, "%u %u %u", (regular_paths+i)->a_path, 
                                          (regular_paths+i)->a_path + 1,
                                          (regular_paths+i)->a_path + 2);
    fclose (fh_read_dim3);

    fh_write_dim3 = fopen ("all_regular_paths_dimension_3_w_rep.txt", "w"); 
	if (fh_write_dim3 == NULL) printf ("Problems to write all_regular_paths_dimension_3_w_rep.txt\n\n");

    /*fprintf (fh_write_dim3, "%u\n", size);*/
    fprintf (fh_write_dim3, "%u %u %u\n", regular_paths->a_path[0],
                                          regular_paths->a_path[1],
                                          regular_paths->a_path[2]);

    for (i = 1; i < size; ++i) {
        check = check_if_path_i_is_a_repetition (regular_paths,  i, 3);
        if (check == FALSE )
            fprintf (fh_write_dim3, "%u %u %u\n", (regular_paths+i)->a_path[0],
                                               (regular_paths+i)->a_path[1],
                                               (regular_paths+i)->a_path[2]);
    }
    fclose (fh_write_dim3);

    return 0;
}
