/* vim: set ts=4 expandtab sw=4: */
#include <stdio.h>
#include "../headers/definitions.h"

boolean are_these_regular_paths_the_same (regular_path path1, regular_path path2, dim_path path_dim) {

    unsigned long long int i;
    for (i = 0; i <= path_dim; ++i)
        if ( path1[i] != path2[i] ) return FALSE;

    return TRUE;
}

boolean is_this_path_a_regular_path (regular_path path, dim_path path_dim) {
    unsigned long long int i;

    for (i = 0; i < path_dim; ++i)
        if( path[i] == path[i+1] ) return FALSE;

    return TRUE;
}
