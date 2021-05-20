/* vim: set ts=4 expandtab sw=4: */
#include <stdio.h>
#include <stdlib.h>
#include "../headers/persistent_path_homology.h"
#include "../headers/basis_of_vector_space.h"
#include "../headers/Tp.h"
#include "../headers/network_weight.h"
#include "../headers/definitions.h"

int main () {

    Pers  *PPH; 

    PPH =  ComputePPH(1, 11);

    print_all_persistent_diagrams (PPH); 

	return 0;
}
