#
#Copyright 1986-2021 Xilinx, Inc. All Rights Reserved.
#
set_param checkpoint.writeSynthRtdsInDcp 1
set_param messaging.defaultLimit 1000000
set_param power.BramSDPPropagationFix 1
set_param general.maxThreads 8
set_param general.maxBackupLogs 0
set_param power.enableUnconnectedCarry8PinPower 1
set_param synth.enableIncremental 0
set_param synth.incremental.totalBlackboxInstancesCount 1
set_param power.enableCarry8RouteBelPower 1
set_param power.enableLutRouteBelPower 1
set_param synth.incrementalSynthesisCache C:/git/aes_engine/aes_offload/imp/vivado_2021.2/build/.Xil/Vivado-18284-EUL10-797V3J3/incrSyn
debug::add_scope -scope route
debug::set_visibility -level 5
set_param chipscope.flow 0
set part xczu9eg-ffvb1156-2-e
set board_part_repo_paths {}
set board_part {}
set board_connections {}
set tool_flow Vivado
set ip_vlnv xilinx.com:ip:xsdbm:3.0
set ip_module_name dbg_hub
set params {{{PARAM_VALUE.C_BSCAN_MODE} {false} {PARAM_VALUE.C_BSCAN_MODE_WITH_CORE} {false} {PARAM_VALUE.C_CLK_INPUT_FREQ_HZ} {300000000} {PARAM_VALUE.C_ENABLE_CLK_DIVIDER} {false} {PARAM_VALUE.C_EN_BSCANID_VEC} {false} {PARAM_VALUE.C_NUM_BSCAN_MASTER_PORTS} {0} {PARAM_VALUE.C_TWO_PRIM_MODE} {false} {PARAM_VALUE.C_USER_SCAN_CHAIN} {1} {PARAM_VALUE.C_USE_EXT_BSCAN} {false} {PARAM_VALUE.C_XSDB_NUM_SLAVES} {1}}}
set intf_params {}
set connectivity {}
set output_xci c:/git/aes_engine/aes_offload/imp/vivado_2021.2/build/.Xil/Vivado-18284-EUL10-797V3J3/dbg_hub_CV.0/out/result.xci
set output_dcp c:/git/aes_engine/aes_offload/imp/vivado_2021.2/build/.Xil/Vivado-18284-EUL10-797V3J3/dbg_hub_CV.0/out/result.dcp
set output_dir c:/git/aes_engine/aes_offload/imp/vivado_2021.2/build/.Xil/Vivado-18284-EUL10-797V3J3/dbg_hub_CV.0/out
set ip_repo_paths {}
set ip_output_repo ./.cache/ip
set ip_cache_permissions {read write}

set oopbus_ip_repo_paths [get_param chipscope.oopbus_ip_repo_paths]

set synth_opts {}
set xdc_files {}