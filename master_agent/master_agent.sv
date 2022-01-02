class master_agent extends uvm_agent;

`uvm_component_utils(master_agent)

agent_cfg m_cfg;
master_monitor monh;
master_driver drivh;
master_seqr seqrh;

extern function new(string name= "master_agent",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);


endclass

function master_agent::new(string name="master_agent",uvm_component parent);
	super.new(name,parent);
endfunction

function void master_agent::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db #(agent_cfg)::get(this,"","agent_cfg",m_cfg))
		`uvm_fatal("FATAL","cannot get config in agent")
	
           monh = master_monitor::type_id::create("monh",this);
	
	if(m_cfg.is_active == UVM_ACTIVE)
	begin
	   drivh = master_driver::type_id::create("drivh",this);
	   seqrh = master_seqr::type_id::create("seqrh",this);
	end

endfunction

function void master_agent::connect_phase(uvm_phase phase);

	if(m_cfg.is_active == UVM_ACTIVE)
		drivh.seq_item_port.connect(seqrh.seq_item_export);

endfunction	  		
