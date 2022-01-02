class slave_agent extends uvm_agent;

`uvm_component_utils(slave_agent)

///CONFIG HANDLE HERE
agent_cfg s_cfg;
slave_monitor monh;
slave_driver drivh;
slave_seqr seqrh;

extern function new(string name= "slave_agent",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);


endclass

function slave_agent::new(string name="slave_agent",uvm_component parent);
	super.new(name,parent);
endfunction

function void slave_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db #(agent_cfg)::get(this,"","agent_cfg",s_cfg))
		`uvm_fatal("FATAL","cannot get config in agent")
	
	monh = slave_monitor::type_id::create("monh",this);
	
	if(s_cfg.is_active == UVM_ACTIVE)
	begin
	   drivh = slave_driver::type_id::create("drivh",this);
	   seqrh = slave_seqr::type_id::create("seqrh",this);
	end

endfunction

function void slave_agent::connect_phase(uvm_phase phase);
	super.connect_phase(phase);

	if(s_cfg.is_active == UVM_ACTIVE)
		drivh.seq_item_port.connect(seqrh.seq_item_export);

endfunction	  		
