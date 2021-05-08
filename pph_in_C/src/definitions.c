#include "definitions.h"

boolean are_these_regular_paths_the_same (regular_path path1, regular_path path2, dim_path path_dim) {

    unsigned int i;
    for (i = 0; i <= path_dim; ++i)
        if ( path1[i] != path2[i] ) return FALSE;

    return TRUE;
}

boolean is_this_path_a_regular_path (regular_path path, dim_path path_dim) {
    unsigned int i;

    for (i = 0; i < path_dim; ++i)
        if( path[i] == path[i+1] ) return FALSE;

    return TRUE;
}

boolean is_this_vector_zero (vector x, dim_vector_space dimVS) {
    unsigned int i;

    for (i = 0; i < dimVS; ++i)
        if (x[i] != 0) return FALSE;
    return TRUE;
}

void sum_these_vectors (vector a, vector b, dim_vector_space dim) {
    /*the resulting sum will be stored at the pointer a*/
    /*Remember that we are working with the field Z/2Z*/
    unsigned int i;

    for (i = 0; i < dim; ++i)
        a[i] = (a[i] + b[i]) % 2;
}
