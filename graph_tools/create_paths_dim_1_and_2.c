/* vim: set ts=4 expandtab sw=4: foldmethod=marker: */
#include <stdio.h>
#include <stdlib.h>

typedef unsigned int size;
typedef unsigned int iterator;
typedef unsigned int node;

/* Print all subsets from branch of cardinality p.
 * Here, p must be 2 or 3
 */
void print_comb (unsigned int N, unsigned int p, node *a_branch) {

    iterator i, j, k;

    if (p == 1) 
        for (i = 0; i < N; ++i) 
            for (j = i+1; j < N; ++j)
                printf ("%u  %u\n", a_branch[i], a_branch[j]);

    if (p == 2) 
        for (i = 0; i < N; ++i) 
            for (j = i+1; j < N; ++j)
                for (k = j+1; k < N; ++k)
                    printf ("%u  %u  %u\n", a_branch[i], a_branch[j], a_branch[k]);
}

int main (int argc, char **argv) {

    size     MAX_BRANCHES, branch_size;
    node     branch[15];
    iterator i, j;
    FILE     *fh;
    unsigned int p ;

    if (argc == 2) p = atoi (argv[1]);
    else printf ("Must have as argument an integer value to calculate all combinations\n\n");

    fh = fopen ("all_branches.txt", "r");

    if (fh == NULL ) printf ("Problems to open all_branches.txt !!!\n\n\n");

    fscanf (fh, "%u\n", &MAX_BRANCHES);

    for (i = 0; i < MAX_BRANCHES; ++i) {

        /* Reading branches that looks like [ 0 2 1 4 ] */
        fscanf (fh, "%*s"); 
        for (j = 0; fscanf (fh, "%u", branch+j) == 1; ++j);
        fscanf (fh, "%*s"); 

        branch_size = j;

        print_comb (branch_size, p, branch);

    }
    return 0;
}
