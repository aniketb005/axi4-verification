class tb_config extends uvm_object;

`uvm_object_utils(tb_config)

agent_cfg m_cfg[];
agent_cfg s_cfg[];

bit has_master = 1;
bit has_slave  = 1;
bit has_virtual_seqr =1;
bit has_scoreboard =1 ;
int no_of_masters = 1;
int no_of_slaves = 1;

extern function new(string name="tb_config");

endclass

function tb_config::new(string name= "tb_config");
	super.new(name);
endfunction
