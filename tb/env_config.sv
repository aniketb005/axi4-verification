class env_config extends uvm_object'

`uvm_object_utils(env_config)

agent_cfg m_cfg[];

bit has_master = 1;
bit has_slave  = 1;
bit has_virtual_seqr =1;
bit has_scoreboard =1 ;
int no_of_masters = 1;
int no_of_slaves = 1;

extern function new(string name="env_config");

endclass

function env_config::new(string name= "env_config");
	super.new(name);
endfunction
