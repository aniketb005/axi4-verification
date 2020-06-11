class base_master_sequence extends uvm_sequence;

`uvm_object_utils(base_master_sequence); 

extern function new (string name = "base_sequence");
endclass

function base_master_sequence::new(string name = "base_sequence");
	super.new(name);
endfunction

class first_seq extends base_master_sequence;

`uvm_object_utils(first_seq)

extern function new(string name="first_seq");
extern task body();
endclass

function first_seq::new(string name = "first_seq");
	super.new(name);
endfunction

task first_seq::body();
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
