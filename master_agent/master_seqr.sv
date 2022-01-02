class master_seqr extends uvm_sequencer #(trans);

`uvm_component_utils(master_seqr)

extern function new(string name = "master_seqr", uvm_component parent);
extern function void build_phase(uvm_phase phase);

endclass 

function master_seqr::new(string name = "master_seqr", uvm_component parent );
	super.new(name,parent);
endfunction

function void master_seqr::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction
