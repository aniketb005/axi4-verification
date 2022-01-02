class virtual_sequencer extends uvm_sequencer #(uvm_sequence_item);

`uvm_component_utils(virtual_sequencer)

master_seqr mseqr[];
slave_seqr sseqr[];
tb_config tb_cfg;

extern function new(string name="virtual_sequencer",uvm_component parent);
extern function void build_phase(uvm_phase phase);
endclass

function virtual_sequencer::new(string name="virtual_sequencer",uvm_component parent);
	super.new(name,parent);
endfunction

function void virtual_sequencer::build_phase(uvm_phase phase);
	if(!uvm_config_db #(tb_config)::get(this,"","tb_config",tb_cfg))
		`uvm_fatal("FATAL","cannot get config in virtual seqr")

	mseqr = new[tb_cfg.no_of_masters];
	sseqr = new[tb_cfg.no_of_slaves];	
	
endfunction
