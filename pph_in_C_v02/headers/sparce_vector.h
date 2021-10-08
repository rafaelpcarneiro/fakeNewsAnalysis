#ifndef __SPARCE_VECTOR_H_
#define __SPARCE_VECTOR_H_

/* Library responsible to deal with the sparce vectors */

/* Remember that the field acting on the vector space is
 * Z_2
 */

typedef struct _vector_index {
    unsigned long int     pos; /* index which the vector is not zero */
    struct _vector_index *next;
}vector_index;

typedef struct {
   vector_index     *root; 
   dim_vector_space dim; /* dim of the vector space which the vector is
                          * element
                          */
}vector;

vector *alloc_vec (dim_vector_space);

void add_index_to_vector (vector*, unsigned long int);

void remove_index_to_vector (vector*, unsigned long int);

boolean is_this_vector_zero (vector*);

void sum_these_vectors (vector*, vector*);

vector *I_k (void); /* vector with 1 on position k and 0 otherwise */

void print_vec_nicely (vector*, char*);

void free_vector (vector*);

#endif
