syntax case match

" KEYWORDS
syntax keyword myConditionals if else
syntax keyword myReturn       return
syntax keyword myLoop         while for do
syntax keyword myTypes	      boolean vertex_index vectorBasis_index 
syntax keyword myTypes	      dim_path dim_base regular_path vector
syntax keyword myTypes	      vector_index dim_vector_space 
syntax keyword myTypes	      tuple_regular_path_double base collection_of_basis
syntax keyword myTypes 	      T_p_tuple T_p_tuple_collection T_p vector_indexes
syntax keyword myTypes	      Pers_interval_p root Pers

syntax keyword myFunc1        are_these_regular_paths_the_same 
syntax keyword myFunc1        is_this_path_a_regular_path
syntax keyword myFunc1        is_this_vector_zero
syntax keyword myFunc1        sum_these_vectors 

syntax keyword myFunc2	      alloc_all_basis 
syntax keyword myFunc2	      generating_all_regular_paths_dim_p 
syntax keyword myFunc2	      generating_all_regular_paths_dim_p_version2
syntax keyword myFunc2	      Basis_of_the_vector_spaces_spanned_by_regular_paths
syntax keyword myFunc2	      initialize_Marking_basis_vectors
syntax keyword myFunc2	      sorting_the_basis_by_their_allow_times
syntax keyword myFunc2	      marking_vector_basis
syntax keyword myFunc2	      allow_time_regular_path
syntax keyword myFunc2	      compareTuple
syntax keyword myFunc2	      get_dimVS_of_ith_base
syntax keyword myFunc2	      set_dim_path_of_ith_base
syntax keyword myFunc2	      set_dimVS_of_ith_base
syntax keyword myFunc2	      get_path_of_base_i_index_j
syntax keyword myFunc2	      is_path_of_dimPath_p_index_j_marked

syntax keyword myFunc3	      alloc_T_p
syntax keyword myFunc3	      set_T_p_pathDim_i_vector_j 
syntax keyword myFunc3	      is_T_p_pathDim_i_vector_j_empty 
syntax keyword myFunc3	      get_Tp_vector_of_pathDim_i_index_j 
syntax keyword myFunc3	      get_Tp_et_of_pathDim_i_index_j 


syntax keyword myFunc4	      alloc_Pers 
syntax keyword myFunc4	      add_interval_of_pathDim_p 
syntax keyword myFunc4	      print_all_persistent_diagrams 
syntax keyword myFunc4	      allow_time_vector 
syntax keyword myFunc4	      entry_time_vector 
syntax keyword myFunc4	      BasisChange 
syntax keyword myFunc4	      ComputePPH


syntax keyword myWarnings     DANGER

syntax keyword myValues       TRUE FALSE MARKED NOT_MARKED EMPTY NOT_EMPTY SORTED NOT_SORTED 



" COLORS
hi myConditionals cterm=italic,bold ctermfg=darkyellow
hi myReturn	      cterm=bold        ctermfg=red
hi myLoop  	      cterm=bold,italic ctermfg=magenta
hi myTypes 	      cterm=bold        ctermfg=cyan
hi myFunc1 	      cterm=italic
hi myFunc2 	      cterm=italic
hi myFunc3 	      cterm=italic
hi myFunc4 	      cterm=italic
hi myValues	                        ctermfg=darkgray
hi myWarnings     cterm=bold        ctermfg=black	    ctermbg=yellow

hi Comment        cterm=bold        ctermfg=Green
hi Constant                         ctermfg=darkgray
hi cRepeat        cterm=bold        ctermfg=brown
hi cType          cterm=bold        ctermfg=cyan
