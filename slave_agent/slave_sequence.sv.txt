class base_slave_sequence extends uvm_sequence;

`uvm_object_utils(base_slave_sequence); 

extern function new (string name = "base_sequence");
endclass

function base_slave_sequence::new(string name = "base_sequence");
	super.new(name);
endfunction

class first_slseq extends base_slave_sequence;

`uvm_object_utils(first_slseq)

extern function new(string name="first_slseq");
extern task body();
endclass

function first_slseq::new(string name = "first_slseq");
	super.new(name);
endfunction

task first_slseq::body();
repeat(30)

	begin
	trans xtn;
	xtn = trans::type_id::create("xtn");
	
	begin
	start_item(xtn);
	assert(xtn.randomize);
	finish_item(xtn);
	end
	end
endtask
