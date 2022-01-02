package axi_pkg;

import uvm_pkg::*;

`include "uvm_macros.svh"

`include "trans.sv"
`include "agent_cfg.sv"
`include "tb_config.sv"

`include "master_driver.sv"
`include "master_monitor.sv"
`include "master_seqr.sv"
`include "master_agent.sv"
`include "master_agt_top.sv"
`include "master_sequence.sv"

`include "slave_driver.sv"
`include "slave_monitor.sv"
`include "slave_seqr.sv"
`include "slave_agent.sv"
`include "slave_agt_top.sv"
`include "slave_sequence.sv"

`include "virtual_sequencer.sv"
`include "virtual_seqs.sv"
`include "scoreboard.sv"

`include "axi_tb.sv"
`include "axi_test.sv"


endpackage

