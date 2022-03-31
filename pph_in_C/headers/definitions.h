#ifndef __DEFINITIONS_H_
#define __DEFINITIONS_H_

/*================================================================
 * DOCUMENTATION> please read the file doc.pdf (inside the folder
 * pph_in_C), it explains everething that you will find here.
 *
 * ---------------------------------------------------------------
 *================================================================*/

#define TRUE       1
#define FALSE      0

#define MARKED     1
#define NOT_MARKED 0

#define EMPTY      1
#define NOT_EMPTY  0

#define SORTED     1
#define NOT_SORTED 0

typedef char         	boolean;

typedef unsigned int 	vertex_index;

typedef unsigned int 	vectorBasis_index;

typedef unsigned int 	dim_path;

typedef unsigned int 	dim_vector_space;

typedef vertex_index 	*regular_path;

typedef unsigned long int vector_indexes; /* To use in Tp.h for consistence */

/*  Some functions dealing with these data types */
boolean are_these_regular_paths_the_same (regular_path, regular_path, dim_path);

boolean is_this_path_a_regular_path      (regular_path, dim_path);
#endif /* __DEFINITIONS_H_ */
