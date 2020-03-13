
function(___output_debug_target bin_name )

    file(TO_CMAKE_PATH "${CMAKE_CURRENT_SOURCE_DIR}" cm_build_dir)
    if( "${bin_name}" STREQUAL "_" )
    	set(debug_file "dbg_project_args" )
    else()
        set(debug_file "dbg_${bin_name}" )
    endif()
	set(flash_debug_file "${CMAKE_BINARY_DIR}/flash_${debug_file}" )
	set(debug_file "${CMAKE_BINARY_DIR}/${debug_file}")
			    
    set(flash_args_file "${cm_build_dir}/flash_project_args"  )
    set(line_prefix "mon program_esp32 ${cm_build_dir}/"  )
    
	file(READ ${flash_args_file} flash_args)


	list(APPEND dbg_cmds "mon reset halt")
	list(APPEND dbg_cmds "flushregs")
	list(APPEND dbg_cmds "set remote hardware-watchpoint-limit 2")

	STRING(REGEX REPLACE "\n" ";" SPLIT "${flash_args}")
	


	foreach(flash_arg_line ${SPLIT})
		string(REGEX MATCH "^(0[xX][^ ]*)[ ]*([^ ]*)" out_matches "${flash_arg_line}")
	   
	  	if( ${CMAKE_MATCH_COUNT} GREATER 0  )
	  		set(found_offset "${CMAKE_MATCH_1}")
	  		set(found_bin "${CMAKE_MATCH_2}")
	  		if( ( "${bin_name}" MATCHES "${found_bin}" ) OR ( "${bin_name}" STREQUAL "_" ) )
			  	list(APPEND flash_dbg_cmds "${line_prefix}${found_bin} ${found_offset}")
	  		endif()
			if( ( "${bin_name}" MATCHES "recovery" ) AND ( "${found_bin}" MATCHES "ota_data_initial" ) )
				# reset OTADATA to force reloading recovery
			  	list(APPEND flash_dbg_cmds "${line_prefix}${found_bin} ${found_offset}")
	  		endif()	  		
	  		
			if( ( "${bin_name}" MATCHES "${found_bin}" ) )
			   list(APPEND dbg_cmds "mon esp32 appoffset ${found_offset}") 	  
			endif()
	  endif()
	endforeach()

	list(APPEND dbg_cmds_end "mon reset halt")
	list(APPEND dbg_cmds_end "flushregs")

	list(APPEND full_dbg_cmds "${dbg_cmds}")
	list(APPEND full_dbg_cmds "${dbg_cmds_end}")

	list(APPEND full_flash_dbg_cmds "${dbg_cmds}")
	list(APPEND full_flash_dbg_cmds "${flash_dbg_cmds}")
	list(APPEND full_flash_dbg_cmds "${dbg_cmds_end}")
	STRING(REGEX REPLACE  ";" "\n" dbg_cmds_end "${dbg_cmds_end}")
	STRING(REGEX REPLACE  ";" "\n" full_dbg_cmds "${full_dbg_cmds}")
	STRING(REGEX REPLACE  ";" "\n" full_flash_dbg_cmds "${full_flash_dbg_cmds}")

	message("Writing: ${debug_file} with ${full_dbg_cmds}")
	file(GENERATE OUTPUT "${debug_file}" CONTENT "${full_dbg_cmds}")
	message("Writing: ${flash_debug_file} with : ${full_flash_dbg_cmds}")
	file(GENERATE OUTPUT "${flash_debug_file}" CONTENT "${full_flash_dbg_cmds}")
  

endfunction()
message("Generating debug script files") 
___output_debug_target("_")
___output_debug_target("squeezelite")
___output_debug_target("recovery")
	
