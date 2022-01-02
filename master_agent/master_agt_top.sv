class master_agt_top extends uvm_agent;

`uvm_component_utils(master_agt_top)

tb_config tb_cfg;
master_agent magenth[];
agent_cfg m_cfg[];

extern function new(string name="master_agt_top",uvm_component parent);
extern function void build_phase(uvm_phase phase);
//extern task run_phase(uvm_phase phase);
endclass

function master_agt_top::new(string name="master_agt_top",uvm_component parent);
	super.new(name,parent);
endfunction

function void master_agt_top::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db #(tb_config)::get(this,"","tb_config",tb_cfg))
	`uvm_fatal("FATAL","cannot get config in master agent top")

	magenth = new[tb_cfg.no_of_masters];
	
	foreach(magenth[i])
	  	magenth[i] = master_agent::type_id::create($sformatf("magenth[%0d]",i),this);

	foreach(magenth[i])
		uvm_config_db #(agent_cfg)::set(this,$sformatf("magenth[%0d]*",i),"agent_cfg",tb_cfg.m_cfg[i]);
endfunction

//task master_agt_top::run_phase(uvm_phase phase);
//	uvm_top.print_topology;	

//endtask
