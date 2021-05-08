syntax case match

" KEYWORDS
syntax keyword myConditionals if else
syntax keyword myReturn       return
syntax keyword myLoop         while for do
syntax keyword myTypes	      boolean vertex_index base_index dim_path dim_base regular_path vector
syntax keyword myTypes	      vector_index dim_vector_space
syntax keyword myTypes	      tuple_regular_path_double base collection_of_basis

syntax keyword myFunc1        are_these_regular_paths_the_same 
syntax keyword myFunc1        is_this_path_a_regular_path
syntax keyword myFunc1        is_this_vector_zero
syntax keyword myFunc1        sum_these_vectors 

syntax keyword myValues       TRUE FALSE MARKED NOT_MARKED EMPTY NOT_EMPTY SORTED NOT_SORTED 



" COLORS
hi myConditionals cterm=italic,bold ctermfg=darkyellow
hi myReturn	  cterm=bold        ctermfg=red
hi myLoop  	  cterm=bold,italic ctermfg=magenta
hi myTypes 	  cterm=bold        ctermfg=cyan
hi myFunc1 	  cterm=italic
hi myValues	                    ctermfg=darkgray

hi Comment cterm=bold ctermfg=Green
hi Constant ctermfg=darkgray
hi cRepeat cterm=bold ctermfg=brown
hi cType cterm=bold ctermfg=cyan
