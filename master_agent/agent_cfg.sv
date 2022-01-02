class agent_cfg extends uvm_object;

`uvm_object_utils(agent_cfg)

virtual axi_if vif;

uvm_active_passive_enum is_active = UVM_ACTIVE;

extern function new(string name="agent_cfg");
endclass

function agent_cfg::new(string name="agent_cfg");
	super.new(name);
endfunction
