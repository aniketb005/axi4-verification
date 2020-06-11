class axi_test extends uvm_test;

`uvm_component_utils(axi_test);

tb_config tb_cfg;
axi_tb envh;
agent_cfg m_cfg[];
agent_cfg s_cfg[];



int no_of_masters = 1;
int no_of_slaves = 1;

extern function new (string name="axi_test",uvm_component parent);
extern function void build_phase(uvm_phase phase);
endclass

function axi_test::new(string name="axi_test",uvm_component parent);
	super.new(name,parent);
endfunction

	
function void axi_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
	
	tb_cfg = tb_config::type_id::create("tb_cfg");

	m_cfg = new[no_of_masters];
 	tb_cfg.m_cfg = new[no_of_masters]; 
tb_cfg.s_cfg = new[no_of_masters]; 


	foreach(m_cfg[i])
	begin
	  m_cfg[i] = agent_cfg::type_id::create($sformatf("m_cfg[%0d]",i));
          // $display("-------------------------------------------------------------------%0d",m_cfg[i]);
	  if(!uvm_config_db #(virtual axi_if)::get(this,"","vif",m_cfg[i].vif))
		`uvm_fatal("FATAL","cannot get static interface from top ?? have you set it properly?")
	
	        m_cfg[i].is_active = UVM_ACTIVE;
           //$display("-------------------------------------------------------------------%0p",m_cfg[i]);

		tb_cfg.no_of_masters = no_of_masters;
		
	  tb_cfg.m_cfg[i] = m_cfg[i];
//$display("ahahahahahahahvagafvffffffffffff");
 $display("-------------------------------------------------------------------%0p", tb_cfg.m_cfg[i] );


	end

	s_cfg = new[no_of_slaves];
	foreach(s_cfg[i])
	begin
	  s_cfg[i] = agent_cfg::type_id::create($sformatf("s_cfg[%0d]",i));

	  if(!uvm_config_db #(virtual axi_if)::get(this,"","vif",s_cfg[i].vif))
		`uvm_fatal("FATAL","cannot get static interface from top ?? have you set it properly?")
	
	        s_cfg[i].is_active = UVM_ACTIVE;
		tb_cfg.no_of_slaves = no_of_slaves;
		
	  	tb_cfg.s_cfg[i] = s_cfg[i];
	end


   	uvm_config_db #(tb_config)::set(this,"*","tb_config",tb_cfg);

	envh = axi_tb::type_id::create("envh",this);

endfunction


class m_test extends axi_test;
	
`uvm_component_utils(m_test)

first_vseq vseqh;


extern function new(string name="m_test",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
endclass

function m_test:: new(string name="m_test",uvm_component parent);
	super.new(name,parent);
endfunction

function void m_test::build_phase(uvm_phase phase);
	super.build_phase(phase);
endfunction

task m_test::run_phase(uvm_phase phase);
	begin
	$display("TTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTTT %p",vseqh);

	phase.raise_objection(this);
	$display("##############AAAAAAAAAAAAAAAAAAAAAAAAAAAA################################################");	 
	vseqh = first_vseq::type_id::create("vseqh");

	vseqh.start(envh.vseqrh);
             #1000000;
	phase.drop_objection(this);
	end
endtask
