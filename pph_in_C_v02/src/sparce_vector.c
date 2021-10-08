#include <stdio.h>                                                                  
#include <stdlib.h>                                                                 
#include "../headers/definitions.h" 
#include "../headers/sparce_vector.h" 

vector *alloc_vec (dim_vector_space dimVS) {
    vector *u = malloc (sizeof (vector));

    u->dim = dimVS;
    root   = NULL;

    return u;
}

void add_index_to_vector (vector *u, unsigned long int position) {
    /* In case of adding an index which already exists the index will
       be removed from the vector
       */

    vector_index *tmp, *prev, *nnext;
    boolean      flag = TRUE;

    if (u->root == NULL) {
        u->root = malloc (sizeof (vector_index));

        (u->root)->pos  = position;
        (u->root)->next = NULL;
    }
    else {
        prev = u;
        tmp  = u->root;
        while (tmp != NULL) {
            if (tmp->pos == position) {
                flag  = FALSE;
                nnext = tmp->next;
                if (prev == u) u->root    = nnext;
                else           prev->next = nnext;

                remove_index_from_vector (u, tmp->pos);
                break;
            }
            prev = tmp;
            tmp  = tmp->next;
        }

        if (flag == TRUE) {
            tmp = malloc (sizeof (vector_index));

            tmp->pos   = position;
            tmp->next  = NULL; 
            prev->next = tmp;
        }
    }
}

void remove_index_from_vector (vector *u, unsigned long int position) {
    unsigned long int i;
    boolean test;

    vector_index *prev_index, *next_index, *tmp_index;

    test = is_this_vector_zero (u);

    if (test != NULL) {

        if ((u->root)->pos == position) {
            tmp_index  = u->root;
            next_index = tmp_index->next;
            u->root    = next_index;

            free_vector_index (tmp_index);
        }
        else {
            prev_index = u->root;
            tmp_index  = prev_index->next;
            while (tmp_index != NULL) {
                if (tmp_index->pos == position) {
                    next_index       = tmp_index->next;
                    prev_index->next = next_index;

                    free_vector_index (tmp_index);
                }
                else {
                    prev_index = tmp_index;
                    tmp_index  = prev_index->next;
                }
            }
        }
    }
}

boolean is_this_vector_zero (vector *u) {
    boolean test;

    if (u->root == NULL) return TRUE;
    else                 return FALSE;
}

void sum_these_vectors (vector *a, vector *b) {
    /*the resulting sum will be stored at the pointer a*/
    /*Remember that we are working with the field Z/2Z*/

    boolean           testA, testB;
    unsigned long int indexB, i;
    vector_index      *tmp;

    testB = is_this_vector_zero (b);
    if (testB != TRUE ) {
        if (testA == TRUE) a->root = b->root;
        else {
            tmp = b->root;
            add_index_to_vector (a, tmp->pos);
            while (tmp->next != NULL) {
                add_index_to_vector (a, tmp->pos);
                tmp = tmp->index;
            }
        }
    }
}

void free_vector (vector *u){

}
