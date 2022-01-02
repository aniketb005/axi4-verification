class axi_tb extends uvm_env;

`uvm_component_utils(axi_tb)

tb_config tb_cfg;

master_agt_top magent_top;
slave_agt_top sagent_top;
virtual_sequencer vseqrh;
scoreboard sb;

extern function new (string name = "axi_tb",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
endclass


function axi_tb::new(string name="axi_tb",uvm_component parent);
	super.new(name,parent);
endfunction

function void axi_tb::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db #(tb_config)::get(this,"","tb_config",tb_cfg))
		`uvm_fatal("FATAL","cannot get config in TB")
	
	if(tb_cfg.has_master)
		magent_top = master_agt_top::type_id::create("magent_top",this);
	
	if(tb_cfg.has_slave)
		sagent_top = slave_agt_top::type_id::create("sagent_top",this);

	if(tb_cfg.has_virtual_seqr)
		vseqrh = virtual_sequencer::type_id::create("vseqrh",this);
		
	if(tb_cfg.has_scoreboard)
		sb = scoreboard::type_id::create("sb",this);

endfunction

function void axi_tb::connect_phase(uvm_phase phase);
	if(tb_cfg.has_scoreboard)	
	  begin	
	//	foreach(magent_top.magenth[i])
		for(int i=0;i<tb_cfg.no_of_masters;i++)
		   begin
			magent_top.magenth[i].monh.AWport.connect(sb.AWfifo[i].analysis_export);
			magent_top.magenth[i].monh.Wport.connect(sb.Wfifo[i].analysis_export);
			magent_top.magenth[i].monh.Rport.connect(sb.Rfifo[i].analysis_export);
			magent_top.magenth[i].monh.ARport.connect(sb.ARfifo[i].analysis_export);
			magent_top.magenth[i].monh.RWport.connect(sb.RWfifo[i].analysis_export);
 		   end
	
		for(int j=0;j<tb_cfg.no_of_slaves;j++)
		   begin
			sagent_top.sagenth[j].monh.slave_AWport.connect(sb.slave_AWfifo[j].analysis_export);			
			sagent_top.sagenth[j].monh.slave_Wport.connect(sb.slave_Wfifo[j].analysis_export);
			sagent_top.sagenth[j].monh.slave_Rport.connect(sb.slave_Rfifo[j].analysis_export);
			sagent_top.sagenth[j].monh.slave_ARport.connect(sb.slave_ARfifo[j].analysis_export);
			sagent_top.sagenth[j].monh.slave_RWport.connect(sb.slave_RWfifo[j].analysis_export);
		   end
	  end


	if(tb_cfg.has_virtual_seqr)
	  begin
		foreach(magent_top.magenth[i])
			vseqrh.mseqr[i] = magent_top.magenth[i].seqrh; 

		foreach(sagent_top.sagenth[i])
	    		vseqrh.sseqr[i] = sagent_top.sagenth[i].seqrh;
	  end	
endfunction
