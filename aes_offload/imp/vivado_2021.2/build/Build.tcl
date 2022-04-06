
# Build script
# -------------------------------------------------------------------------------------
# Build a design running synthesis, placement, routing and bitstream in Vivado in
# non-project mode
# 


#
# For help, see the procedure 'help'
# ======================================================================================


# -------------------------------------------------------------------------------------
# Help
# -------------------------------------------------------------------------------------

proc help {} {
  puts ""
  puts " To build the design, type 'build' "
  puts " ---------------------------------"
  puts ""
  puts ""
  puts " Procedures available in this file:"
  puts ""
  puts "   build"
  puts "      Runs the design build"
  puts ""  
  puts "      Optional parameters (to pass more than one parameter use '{}'):"
  puts "       -no_synth:     Does not run the synthesis."
  puts "       -no_impl:      Does not run the implementation (place and route)."
  puts "       -no_bits:      Does not run the bitstream generation."
  puts "       -elaborate:    Generates the elaborated RTL and opens the GUI, ending the script."
  puts "       -debug:        Generates the debug probes .ltx file."
  puts "       -ins_ila:      Inserts the ILA based on the RTL attributes, without using the GUI. E.g. 'build -ins_ila' or 'build {-ins_ila -no_synth}' if synthesis has been run previously."
  puts "       -no_id_update: Do not update the ID block."
  puts ""  
  puts "   prog_dev"
  puts "      Program the device through JTAG."
  puts ""  
  puts "   help"
  puts "      This help"
  puts ""  
  puts "   viado_help"
  puts "      Lists Vivado useful commands"
  puts ""
}

proc help_vivado {} {
  puts " Useful Vivado commands:                                                            "
  puts "                                                                                    "
  puts "  * Clean previously read files and build information:                              "
  puts "     % close_project                                                                "
  puts "                                                                                    "
  puts "  * Open the design in the Vivado GUI after running the build procedure             "
  puts "     % start_gui                                                                    "
  puts "                                                                                    "
  puts "  * Open a checkpoint in the Vivado GUI without having an open project              "
  puts "     % open_checkpoint ../checkpoints/post_synth.dcp -part xcku040-ffva1156-2-e     "
  puts "     % open_checkpoint ../checkpoints/post_route.dcp -part xcku040-ffva1156-2-e     "
  puts "     % start_gui                                                                    "
}

# ============================================================================================
# Variables
# ============================================================================================
# Directories
set checkpoints_dir ../checkpoints
set reports_dir ../reports
set outputs_dir ../outputs
set archive_dir ../archive


# ############################################################################################
# BUILD procedure
# ############################################################################################
proc build {{parameters no_parameteres}} {

  global checkpoints_dir
  global outputs_dir
  global reports_dir
  global archive_dir
  global project_name
  global device_pn
  global top_entity
  global synthesis_parameters
  global placement_parameters
  global ila_depth

  # Store start time
  set t0 [clock clicks -millisec]
  set t0_seconds [clock seconds]
  
  # Check if the parameters are valid
  if {$parameters != "no_parameteres"} {
    foreach parameter $parameters {
      set is_valid 0
      foreach valid_param {-no_synth -no_impl -no_bits -debug -no_id_update -elaborate- -ins_ila} {
        if {$parameter == $valid_param} {
          set is_valid 1
        }
      }
      if {$is_valid == 0} {
        puts "Invalid parameter"
        return
      }
    }
  }  
 
  # Store the length of the original vivado.log file to start login
  set fp [open "vivado.log" r]
  set file_data [read $fp]
  set current_length [string length $file_data]
  close $fp
  
  # ------------------------------------------
  # Read design settings
  # ------------------------------------------
  source design_settings.tcl -notrace


  if {![check_parameters $parameters -no_synth]} {
    # Removes information from a previous build
    # First tests is there is any previous project
    if {[catch {current_project } result ]} { 
      puts "No previous project opened."
    } else {
      puts "Cleaning previous project information."
      close_project
    }

    puts "\nRemoving Vivado temporary directories"
    recursive_delete ./.Xil
    recursive_delete ./.srcs
    #file delete -force -- ./.Xil
    #file delete -force -- ./.srcs
  }

  # ============================================================================================
  # Settings
  # ============================================================================================
  # General parameters
  set_param general.maxBackupLogs 0
  set_param messaging.defaultLimit 1000000
  
  exec attrib -r $reports_dir/*.*
  exec attrib -r $checkpoints_dir/*.*
  exec attrib -r $outputs_dir/*.*
  exec attrib -r $archive_dir/*.*

  if {![check_parameters $parameters -no_synth] || [check_parameters $parameters -elaborate]} {create_project -part $device_pn -in memory}

  # ============================================================================================
  # Synthesis
  # ============================================================================================
  if {![check_parameters $parameters -no_synth] || [check_parameters $parameters -elaborate]} {
    # STEP#1: setup design sources and constraints
    puts "\n=========================================="
    puts " Reading source files"
    puts "=========================================="
    source project.tcl

    # Updating version information
    if {[check_parameters $parameters -no_id_update]||[check_parameters $parameters -elaborate]} {
      puts "\nNOT updating version information."
    } else {
      puts "\nUpdating version."
      set result [version_info]
      set version      [lindex $result 0]
      set vendor       [lindex $result 1]
      set vendorinfo   [lindex $result 2]
      set path         [lindex $result 3]
      set package_file [lindex $result 4]
      source ../scripts/id.tcl -notrace
      set result [getinfo $path $package_file $vendor $vendorinfo $version]
      set date_info       [lindex $result 0]
      set vendor_hex      [lindex $result 1]
      set vendorinfo_hex  [lindex $result 2]
      set version_hex     [lindex $result 3]
      set date_hex        [lindex $result 4]
      generate_vhdl $path $package_file $vendor $vendorinfo $version $date_info $vendor_hex $vendorinfo_hex $version_hex $date_hex
    }
  }
  
  if {[check_parameters $parameters -elaborate]} {
    puts "\n=========================================="
    puts " Starting Elaborated RTL"
    puts "=========================================="
    set_property top $top_entity [current_fileset]
    synth_design -rtl -name $project_name
    
    puts "\n=========================================="
    puts " Elaborated RTL complete"
    puts "=========================================="
    # Print elapsed time
    set seconds [expr {([clock clicks -millisec]-$t0)/1000.}]
    puts [format "\nStarted in: %s" [clock format $t0_seconds -format "%Y-%m-%d %H:%M:%S"]]
    puts [format "\nElapsed time: %.1f seconds (%.2f minutes)." $seconds [expr $seconds/60]]
    puts [format "\nHostname: %s" [info hostname]]
    
    set current_length [save_log $current_length "$reports_dir/elaborate.log"]
    puts "\n\nOpening the GUI."
    puts "To close the GUI and return to this console type 'stop_gui' in the Tcl Console of the GUI.\n"
    start_gui
    return
  }
  
  if {![check_parameters $parameters -no_synth]} {
    puts "\nArchiving previous build files into the 'archive' folder."
    file delete -force -- $archive_dir
    while {[file exists "$archive_dir"]} {
      after 100 ms
    }
    file mkdir $archive_dir
    if {[file exists "$checkpoints_dir"]} {file copy -force -- $checkpoints_dir   $archive_dir}
    if {[file exists "$reports_dir"    ]} {file copy -force -- $reports_dir       $archive_dir}
    if {[file exists "$outputs_dir"    ]} {file copy -force -- $outputs_dir       $archive_dir}
    
    puts "\nRemoving existing output directories"
    file delete -force -- $checkpoints_dir
    file delete -force -- $reports_dir
    file delete -force -- $outputs_dir
    
    puts "Creating output directory"
    file mkdir $checkpoints_dir
    file mkdir $reports_dir
    file mkdir $outputs_dir
    
    report_ip -file $reports_dir/report_ip.rpt
    
    # STEP#2: run synthesis, report utilization and timing estimates, write checkpoint design
    #
    puts "\n=========================================="
    puts " Starting synthesis"
    puts "=========================================="
    read_xdc ../constraints/${project_name}_synth.xdc
    eval "synth_design -top $top_entity -part $device_pn $synthesis_parameters"


    puts "\n=========================================="
    puts " Writing reports"
    puts "=========================================="
    write_checkpoint -force $checkpoints_dir/post_synth
    report_timing_summary -file $reports_dir/post_synth_timing_summary.rpt
    # report_power -file $reports_dir/post_synth_power.rpt
    report_utilization -file $reports_dir/post_synth_util.rpt
    set current_length [save_log $current_length "$reports_dir/synthesis.log"]
    ips_properties
    set current_length [save_log $current_length "$reports_dir/ips_properties.rpt"]
  }

  if {![check_parameters $parameters -no_impl]} {
    if {[check_parameters $parameters -ins_ila]} {
      puts "Adding the ILA.\n"
      source ../scripts/batch_insert_ila.tcl -notrace
      batch_insert_ila $ila_depth
      set current_length [save_log $current_length "$reports_dir/insert_ila.rpt"]
    }  
      
    # ============================================================================================
    # Placement
    # ============================================================================================
    # STEP#3: run placement and logic optimization, report timing estimates, write checkpoint design
    puts "\n=========================================="
    puts " Starting optimization"
    puts "=========================================="
    read_xdc ../constraints/${project_name}_imp.xdc
    opt_design
    set current_length [save_log $current_length "$reports_dir/optimization.log"]
    puts "\n=========================================="
    puts " Starting placement"
    puts "=========================================="
    eval "place_design $placement_parameters"
    
    set current_length [save_log $current_length "$reports_dir/place.log"]
    # puts "\n=========================================="
    # puts " Optimise Placement"
    # puts "=========================================="
    # phys_opt_design
    # puts "\n=========================================="
    # puts " Writing reports"
    # puts "=========================================="
    # write_checkpoint -force $checkpoints_dir/post_place
    # report_timing_summary -file $reports_dir/post_place_timing_summary.rpt
    # set current_length [save_log $current_length "$reports_dir/opt_after_place.log"]


    # ============================================================================================
    # Routing
    # ============================================================================================
    # STEP#4: run router, report actual utilization and timing, write checkpoint design, run drc, write verilog and xdc out
    puts "\n=========================================="
    puts " Starting route"
    puts "=========================================="
    route_design
    # set current_length [save_log $current_length "$reports_dir/route.log"]
    # puts "\n=========================================="
    # puts " Physical optimization"
    # puts "=========================================="
    # phys_opt_design
    puts "\n=========================================="
    puts " Writing reports"
    puts "=========================================="
    write_checkpoint -force $checkpoints_dir/post_route
    report_timing_summary -file $reports_dir/post_route_timing_summary.rpt
    report_timing -sort_by group -max_paths 100 -path_type summary -file $reports_dir/post_route_timing.rpt
    report_datasheet -file $reports_dir/timing_datasheet.rpt -show_oe_timing
    report_bus_skew -file $reports_dir/bus_skew.rpt
    report_methodology -file $reports_dir/methodology.rpt
    report_route_status -file $reports_dir/route_status.rpt
    report_clock_utilization -file $reports_dir/clock_util.rpt
    report_cdc -details -file $reports_dir/cdc_timing.rpt
    report_clocks -file $reports_dir/clocks.rpt
    report_utilization -file $reports_dir/post_route_util.rpt
    report_utilization -hierarchical -hierarchical_depth 10 -file $reports_dir/post_route_util_hierarch.rpt
    # report_power -file $reports_dir/post_route_power.rpt
    report_drc -file $reports_dir/post_imp_drc.rpt
    report_io -file $reports_dir/post_route_io.rpt
    write_csv -force $reports_dir/post_route_io.csv
    
    puts "Generating gt_attributes.rpt"
    set outList(1) "create_global_array"
    source ../scripts/gt_Attributes_100.tcl -notrace
    gt_attributes $reports_dir/gt_attributes.rpt
    
    # report_design_analysis -logic_level_distribution -of_timing_paths [get_timing_paths -max_paths 10000 -slack_lesser_than 1000e-9] -file $reports_dir/post_route_vios.rpt
    write_xdc -no_fixed_only -force $reports_dir/top_impl.xdc
    # Generates the IBIS model
    # write_ibis -allmodels -truncate 0 -component_name $device_pn $outputs_dir/$device_pn.ibs

    # set current_length [save_log $current_length "$reports_dir/post_route_phys_opt.log"]
    set current_length [save_log $current_length "$reports_dir/route.log"]
  }
  
  # ============================================================================================
  # Bitstream
  # ============================================================================================
  if {![check_parameters $parameters -no_bits]} {
    # STEP#5: generate a bitstream
    # 
    puts "\n=========================================="
    puts " Starting bitstream generation"
    puts "=========================================="
    write_bitstream -force $outputs_dir/$project_name.bit -verbose -bin_file
    puts "\n=========================================="
    puts " Checksum generation"
    puts "=========================================="
    write_cfgmem -force -format MCS -size 32 -interface SPIx1 -checksum -loadbit "up 0x0 $outputs_dir/$project_name.bit" $outputs_dir/$project_name.mcs  
    if {[check_parameters $parameters -debug]||[check_parameters $parameters -ins_ila]} {write_debug_probes -force $outputs_dir/$project_name.ltx}
    set current_length [save_log $current_length "$reports_dir/bitstream.log"]
  }

  puts "\n=========================================="
  puts " Build complete"
  puts "=========================================="
  # Print elapsed time
  set seconds [expr {([clock clicks -millisec]-$t0)/1000.}]
  puts [format "\nStarted in: %s" [clock format $t0_seconds -format "%Y-%m-%d %H:%M:%S"]]
  puts [format "\nBuild time (synthesis and implementation): %.1f seconds (%.2f minutes)." $seconds [expr $seconds/60]]
  puts [format "\nHostname: %s" [info hostname]]

  # Check timing constraints
  if {![check_parameters $parameters -no_impl]} {
    set fp [open "$reports_dir/post_route_timing_summary.rpt" r]
    set filecontent [read $fp]
    close $fp
    if {[string first "All user specified timing constraints are met" $filecontent 1] == -1} {
      puts "\nERROR!!! The timing constraints are NOT met."
    } else {
      puts "\nThe timing constraints are met."
    }
  }
  
  set current_length [save_log $current_length "$reports_dir/build_info.log"]
  puts "\nTo open implemented design in Vivado type start_gui."

}


# Program the device with the bitstream available in outputs_dir
proc prog_dev {} {
  global outputs_dir
  global project_name
  open_hw
  connect_hw_server -quiet
  open_hw_target
  current_hw_device [get_hw_devices xcku040_0]
  if {[file exists "$outputs_dir/$project_name.ltx"]} {
    puts "Including debug .ltx file."
    set_property PROBES.FILE      "$outputs_dir/$project_name.ltx" [get_hw_devices xcku040_0]
    set_property FULL_PROBES.FILE "$outputs_dir/$project_name.ltx" [get_hw_devices xcku040_0]
  } else {
    set_property PROBES.FILE      {} [get_hw_devices xcku040_0]
    set_property FULL_PROBES.FILE {} [get_hw_devices xcku040_0]
  }
  set_property PROGRAM.FILE "$outputs_dir/$project_name.bit" [get_hw_devices xcku040_0]
  puts "\nStarting device programming."
  program_hw_devices [get_hw_devices xcku040_0]
  puts "\nDone.\n"
  
  refresh_hw_device [lindex [get_hw_devices xcku040_0] 0]

}


# ---------------------------------------------------
# Auxiliary procedures
# ---------------------------------------------------
# Extracts the log file of a step from the vivado.log
proc save_log {prev_length output_file} {
   set fp [open "vivado.log" r]
   set current_file [read $fp]
   close $fp

   set filename $output_file
   set fp [open $filename w]
   puts $fp [string replace $current_file 0 [expr {$prev_length - 1}] ""]
   close $fp
   return [string length $current_file]
}

# Lists the properties of the IPs
proc ips_properties {} {
  puts "\nIPs properties report"
  puts "====================="
  foreach IPfile [get_ips] {
    puts "\n-------------------------------"
    puts " $IPfile";
    puts "-------------------------------"
    foreach prop [list_property [get_ips $IPfile] -regexp {^CONFIG\.\w+$}] {
      if {[get_property $prop\.value_src [get_ips $IPfile]]=="user"} {
        puts "* $prop = [get_property $prop [get_ips $IPfile]] *"
      } else {
        puts "  $prop = [get_property $prop [get_ips $IPfile]]"
      }
    }
  }
  puts "\n-------------------------------------"
  puts "* = Non-default value (user defined).\n"
}

# Checks if a specific parameter was passed to the build procedure
proc check_parameters {parameters param_to_search} {
  set result 0
  foreach parameter $parameters {
    if {$parameter == $param_to_search} {
      set result 1
    }
  }
  return $result
}


proc recursive_delete {files_path} {
  foreach dir [glob -type d -nocomplain $files_path] {
    #puts "Dir $dir"
    recursive_delete $dir/*
  }
  foreach file [glob -type f -nocomplain $files_path] {
    puts "File $file"
    if {[catch {file delete -force -- $file}]} {
      puts "Could not delete and skipping file $file"
    }
  }
  foreach dir [glob -type d -nocomplain $files_path] {
    puts "Dir  $dir"
    if {[catch {file delete -force -- $dir}]} {
      puts "Could not delete and skipping directory $dir"
    }
  }
}


# #####################################################
# Main execution
# #####################################################
help