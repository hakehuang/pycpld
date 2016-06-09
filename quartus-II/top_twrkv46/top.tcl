# Copyright (C) 1991-2014 Altera Corporation. All rights reserved.
# Your use of Altera Corporation's design tools, logic functions 
# and other software and tools, and its AMPP partner logic 
# functions, and any output files from any of the foregoing 
# (including device programming or simulation files), and any 
# associated documentation or information are expressly subject 
# to the terms and conditions of the Altera Program License 
# Subscription Agreement, the Altera Quartus II License Agreement,
# the Altera MegaCore Function License Agreement, or other 
# applicable license agreement, including, without limitation, 
# that your use is for the sole purpose of programming logic 
# devices manufactured by Altera and sold by Altera or its 
# authorized distributors.  Please refer to the applicable 
# agreement for further details.

# Quartus II: Generate Tcl File for Project
# File: my_uart_top.tcl
# Generated on: Thu Jan 29 13:04:19 2015

# Load Quartus II Tcl Project package
package require ::quartus::project

set need_to_close_project 0
set make_assignments 1

# Check that the right project is open
if {[is_project_open]} {
	if {[string compare $quartus(project) "top"]} {
		puts "Project top is not open"
		set make_assignments 0
	}
} else {
	# Only open if not already open
	if {[project_exists top]} {
		project_open -revision top top
	} else {
		project_new -revision top top
	}
	set need_to_close_project 1
}

# Make assignments
if {$make_assignments} {
	#project properties
	set_global_assignment -name FAMILY "MAX II"
	set_global_assignment -name DEVICE EPM570T100C5
	set_global_assignment -name ORIGINAL_QUARTUS_VERSION "9.0 SP2"
	set_global_assignment -name PROJECT_CREATION_TIME_DATE "20:55:40  SEPTEMBER 02, 2013"
	set_global_assignment -name LAST_QUARTUS_VERSION 14.0
	set_global_assignment -name USE_GENERATED_PHYSICAL_CONSTRAINTS OFF -section_id eda_blast_fpga
	set_global_assignment -name DEVICE_FILTER_PIN_COUNT 100
	set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
	set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
	set_global_assignment -name POWER_EXT_SUPPLY_VOLTAGE_TO_REGULATOR 3.3V
	set_global_assignment -name STRATIX_DEVICE_IO_STANDARD "3.3-V LVTTL"
	set_global_assignment -name AUTO_RESTART_CONFIGURATION OFF
	set_global_assignment -name USE_CONFIGURATION_DEVICE ON
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS "AS INPUT TRI-STATED"
	set_global_assignment -name RESERVE_ALL_UNUSED_PINS_NO_OUTPUT_GND "AS INPUT TRI-STATED"
	set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (Verilog)"
	set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
	set_global_assignment -name POWER_PRESET_COOLING_SOLUTION "NO HEAT SINK WITH STILL AIR"
	set_global_assignment -name VERILOG_FILE top.v
	set_global_assignment -name VERILOG_FILE enc.v
set_global_assignment -name VERILOG_FILE speed_select.v
set_global_assignment -name VERILOG_FILE uart_rx.v
set_global_assignment -name VERILOG_FILE uart_tx.v

	set_global_assignment -name SIGNALTAP_FILE stp1.stp
	set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
	set_global_assignment -name LL_ROOT_REGION ON -section_id "Root Region"
	set_global_assignment -name LL_MEMBER_STATE LOCKED -section_id "Root Region"

	#default configurations
	set_location_assignment PIN_12 -to clk
	set_location_assignment PIN_1 -to rst_n
	set_location_assignment PIN_6 -to rs232_rx
	set_location_assignment PIN_7 -to led

	######################
	#pin assignments part
	
	set_location_assignment PIN_98 -to BusB[98]
set_location_assignment PIN_57 -to BusA[57]
set_location_assignment PIN_56 -to BusA[56]


	
	######################
	
	# Commit assignments
	export_assignments

	# Close project
	if {$need_to_close_project} {
		project_close
	}
}
