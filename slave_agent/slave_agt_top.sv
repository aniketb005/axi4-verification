class slave_agt_top extends uvm_agent;

`uvm_component_utils(slave_agt_top)

tb_config tb_cfg;
slave_agent sagenth[];
agent_cfg s_cfg[];

extern function new(string name="slave_agt_top",uvm_component parent);
extern function void build_phase(uvm_phase phase);
endclass

function slave_agt_top::new(string name="slave_agt_top",uvm_component parent);
	super.new(name,parent);
endfunction

function void slave_agt_top::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db #(tb_config)::get(this,"","tb_config",tb_cfg))
	`uvm_fatal("FATAL","cannot get config in slave agent top")

	sagenth = new[tb_cfg.no_of_slaves];
	
	foreach(sagenth[i])
	  sagenth[i]= slave_agent::type_id::create($sformatf("sagenth[%0d]",i),this);

	foreach(sagenth[i])
	  uvm_config_db #(agent_cfg)::set(this,$sformatf("sagenth[%0d]*",i),"agent_cfg",tb_cfg.s_cfg[i]);

endfunction
