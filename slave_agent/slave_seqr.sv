class slave_seqr extends uvm_sequencer #(trans);

`uvm_component_utils(slave_seqr)

extern function new(string name = "slave_seqr", uvm_component parent);
extern function void build_phase(uvm_phase phase);

endclass 

function slave_seqr::new(string name = "slave_seqr", uvm_component parent );
	super.new(name,parent);
endfunction

function void slave_seqr::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction
