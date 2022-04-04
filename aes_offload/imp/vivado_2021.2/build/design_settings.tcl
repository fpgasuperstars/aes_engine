# ##################################
# Design settings
# ##################################

# General settings
set project_name aes_engine
set top_entity aes_engine_wrapper
set device_pn xczu9eg-ffvb1156-2-e

# Tools parameters
set_param general.maxThreads 8

set synthesis_parameters   \
  "-assert                 \
  -flatten_hierarchy none"
  # -resource_sharing off  \
  # -keep_equivalent_registers \
  # -retiming

set placement_parameters \
  "-directive ExtraTimingOpt"

# ILA
set ila_depth 32768


# Version information
proc version_info {} {

  set version       "00.01"
  set vendor        "Jack O'Keefe Entrust"
  set vendorinfo    "aes_engine"
  set path          "../../../imp/code/devlib/id/"
  set package_file  "id_pkg"

  return [list $version $vendor $vendorinfo $path $package_file]
  
}