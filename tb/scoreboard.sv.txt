class scoreboard extends uvm_scoreboard;

`uvm_component_utils(scoreboard)

tb_config tb_cfg;

//uvm_tlm_analysis_fifo #(trans) mfifo[];
//uvm_tlm_analysis_fifo #(trans) sfifo[];

uvm_tlm_analysis_fifo #(trans) AWfifo[];
uvm_tlm_analysis_fifo #(trans) Wfifo[];
uvm_tlm_analysis_fifo #(trans) Rfifo[];
uvm_tlm_analysis_fifo #(trans) ARfifo[];
uvm_tlm_analysis_fifo #(trans) RWfifo[];

uvm_tlm_analysis_fifo #(trans) slave_AWfifo[];
uvm_tlm_analysis_fifo #(trans) slave_Wfifo[];
uvm_tlm_analysis_fifo #(trans) slave_Rfifo[];
uvm_tlm_analysis_fifo #(trans) slave_ARfifo[];
uvm_tlm_analysis_fifo #(trans) slave_RWfifo[];

trans xtn;
trans sxtn; 
trans r_xtn;
trans sr_xtn;

trans axi_write_cov;
trans axi_read_cov;

covergroup axi_write_coverage with function sample(int i);
   option.per_instance=1;  

       awaddr: coverpoint axi_write_cov.AWaddr
                 { bins low={[1:250]};
                   bins high={[251:500]}; }


       awlen: coverpoint axi_write_cov.AWlen
                 { bins low={[0:1]};
                   bins mid1={[2:3]};
                   bins mid2={[4:7]};
                   bins high={[8:15]}; }

       awsize: coverpoint axi_write_cov.AWsize
                 { bins low={[0:1]};
                   bins high={[2:7]}; }

       awburst: coverpoint axi_write_cov.AWburst
                 { bins low={[0:1]};
                   bins high={[2:3]}; }    

       wdata: coverpoint axi_write_cov.Wdata[i]
                 { bins low={[0:65536]};
                   bins mid1={[65536:16777215]};  
                   bins high={[16777216:2147483648]}; }

        wstrb: coverpoint axi_write_cov.Wstrb[i]
                 { bins low={[0:4]};
                   bins mid={[5:10]};
                   bins high={[11:15]};}
  
endgroup

covergroup axi_read_coverage with function sample(int i);

   option.per_instance=1;  

       araddr: coverpoint axi_read_cov.ARaddr
                 { bins low={[1:250]};
                   bins high={[251:500]}; }


       arlen: coverpoint axi_read_cov.ARlen
                 { bins low={[0:1]};
                   bins mid1={[2:3]};
                   bins mid2={[4:7]};
                   bins high={[8:15]}; }

       arsize: coverpoint axi_read_cov.ARsize
                 { bins low={[0:1]};
                   bins high={[2:7]}; }

       arburst: coverpoint axi_write_cov.ARburst
                 { bins low={[0:1]};
                   bins high={[2:3]}; }      

       rdata: coverpoint axi_write_cov.Rdata[i]
                 { bins low={[0:65535]};
                   bins mid={[65536:16777215]};  
                   bins high={[16777216:2147483648]}; }


endgroup

extern function new(string name="sb",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern function void check_data_write(trans xtn,trans sxtn);
extern function void check_data_read(trans r_xtn,trans sr_xtn);
endclass

function scoreboard::new(string name="sb",uvm_component parent);
	super.new(name,parent);
	axi_write_coverage = new();
	axi_read_coverage = new();
endfunction

function void scoreboard::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db #(tb_config)::get(this,"","tb_config",tb_cfg))
		`uvm_fatal("FATAL","cannot get in scoreboard")	
	
	AWfifo = new[tb_cfg.no_of_masters];
        Wfifo = new[tb_cfg.no_of_masters];
        Rfifo = new[tb_cfg.no_of_masters];
        ARfifo = new[tb_cfg.no_of_masters];
        RWfifo = new[tb_cfg.no_of_masters];


	slave_AWfifo = new[tb_cfg.no_of_slaves];
	slave_Wfifo= new[tb_cfg.no_of_slaves];
	slave_Rfifo= new[tb_cfg.no_of_slaves];
	slave_ARfifo= new[tb_cfg.no_of_slaves];
	slave_RWfifo= new[tb_cfg.no_of_slaves];
	
	foreach(AWfifo[i])
	AWfifo[i] = new($sformatf("AWfifo[%0d]",i),this);
	foreach(Wfifo[i])
	Wfifo[i] = new($sformatf("Wfifo[%0d]",i),this);
	foreach(Rfifo[i])
	Rfifo[i] = new($sformatf("Rfifo[%0d]",i),this);
	foreach(ARfifo[i])
	ARfifo[i] = new($sformatf("ARfifo[%0d]",i),this);
	foreach(RWfifo[i])
	RWfifo[i] = new($sformatf("RWfifo[%0d]",i),this);

	foreach(slave_AWfifo[i])
	slave_AWfifo[i] = new($sformatf("slave_AWfifo[%0d]",i),this);
	foreach(slave_Wfifo[i])
	slave_Wfifo[i] = new($sformatf("slave_Wfifo[%0d]",i),this);
	foreach(slave_Rfifo[i])
	slave_Rfifo[i] = new($sformatf("slave_Rfifo[%0d]",i),this);
	foreach(slave_ARfifo[i])
	slave_ARfifo[i] = new($sformatf("slave_ARfifo[%0d]",i),this);
	foreach(slave_AWfifo[i])
	slave_RWfifo[i] = new($sformatf("slave_RWfifo[%0d]",i),this);


endfunction

task scoreboard::run_phase(uvm_phase phase);


	forever
	   begin
		fork
			begin
				AWfifo[0].get(xtn);
				Wfifo[0].get(xtn);
				Rfifo[0].get(xtn);
			end

			begin
				ARfifo[0].get(r_xtn);
				RWfifo[0].get(r_xtn);
			end
			begin
				slave_AWfifo[0].get(sxtn);
				slave_Wfifo[0].get(sxtn);
				slave_Rfifo[0].get(sxtn);
			end

			begin
				slave_ARfifo[0].get(sr_xtn);
				slave_RWfifo[0].get(sr_xtn);
			end
		join

			check_data_write(xtn,sxtn);
			check_data_read(r_xtn,sr_xtn);
			
			axi_write_cov = xtn;
			axi_read_cov = sr_xtn;

			for(int i=0;i<xtn.AWlen+1;i++)
			axi_write_coverage.sample(i);

			for(int i=0;i<r_xtn.ARlen+1;i++)
			axi_read_coverage.sample(i);


	end

endtask

function void scoreboard::check_data_write(trans xtn,trans sxtn);

$display("*****************************************WRITEEE ADDRR********************************************************");
	if(xtn.AWaddr == sxtn.AWaddr)
		begin
		`uvm_info("SCOREBOARD","WRITE addr COMPARED",UVM_LOW)
		$display("Master %0d \n  slave %0d",xtn.AWaddr,sxtn.AWaddr);
		end
	else
		begin
		`uvm_info("SCOREBOARD","NOT CORRECT",UVM_LOW)
		$display("Master %0d \n  slave %0d",xtn.AWaddr,sxtn.AWaddr);
		end
$display("*********************************************************************************************************\n");

$display("*****************************************WRITEEE LEN********************************************************");
	if(xtn.AWlen == sxtn.AWlen)
		begin
		`uvm_info("SCOREBOARD","Write Length COMPARED",UVM_LOW)
		$display("Master %0d \n  slave %0d",xtn.AWlen,sxtn.AWlen);
		end	
	else
		begin
		`uvm_info("SCOREBOARD","NOT CORRECT",UVM_LOW)
		$display("Master %0d \n  slave %0d",xtn.AWlen,sxtn.AWlen);
		end
$display("********************************************************************************************************* \n");

$display("*****************************************WRITEEE SIZE********************************************************");
	if(xtn.AWsize == sxtn.AWsize)
	   begin
		`uvm_info("SCOREBOARD","WRITE size COMPARED",UVM_LOW)
		$display("Master %0d \n  slave %0d",xtn.AWsize,sxtn.AWsize);
	   end
	else
		begin
		`uvm_info("SCOREBOARD","NOT CORRECT",UVM_LOW)
		$display("Master %0d \n  slave %0d",xtn.AWsize,sxtn.AWsize);
		end
$display("*********************************************************************************************************\n");

$display("*****************************************WRITEEE Burst********************************************************");
	if(xtn.AWburst == sxtn.AWburst)
		begin
		`uvm_info("SCOREBOARD","WRITE Burst COMPARED",UVM_LOW)
		$display("Master %0d \n slave %0d",xtn.AWburst,sxtn.AWburst);
		end
	else
		begin
		`uvm_info("SCOREBOARD","NOT CORRECT",UVM_LOW)
		$display("Master %0d \n slave %0d",xtn.AWburst,sxtn.AWburst);
		end
$display("*********************************************************************************************************\n");

$display("*****************************************WRITEEE DATATATA********************************************************");
	if(xtn.Wdata == sxtn.Wdata)
		begin
		`uvm_info("SCOREBOARD","WRITE Burst COMPARED",UVM_LOW)
		$display("Master %0p \n slave %0p",xtn.Wdata,sxtn.Wdata);
		end
	else
		begin
		`uvm_info("SCOREBOARD","NOT CORRECT",UVM_LOW)
		$display("Master %0p \n slave %0p",xtn.Wdata,sxtn.Wdata);
		end
$display("*********************************************************************************************************\n");

$display("*****************************************WRITEEE STROBEE********************************************************");
	if(xtn.Wstrb == sxtn.Wstrb)
		begin
		`uvm_info("SCOREBOARD","WRITE Burst COMPARED",UVM_LOW)
		$display("Master %0p \n slave %0p",xtn.Wstrb,sxtn.Wstrb);
		end
	else
		begin
		`uvm_info("SCOREBOARD","NOT CORRECT",UVM_LOW)
		$display("Master %0p \n slave %0p",xtn.Wstrb,sxtn.Wstrb);
		end
$display("*********************************************************************************************************\n");

$display("*****************************************WRITEEE IDDDDDD********************************************************");
	if(xtn.AWid == sxtn.Bid)
		begin
		`uvm_info("SCOREBOARD","WRITE IDDDD COMPARED",UVM_LOW)
		$display("Master %0p \n slave %0p",xtn.AWid,sxtn.Bid);
		end
	else
		begin
		`uvm_info("SCOREBOARD","NOT CORRECT",UVM_LOW)
		$display("Master %0p \n slave %0p",xtn.AWid,sxtn.Bid);
		end
$display("*********************************************************************************************************\n");


endfunction


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


function void scoreboard::check_data_read(trans r_xtn,trans sr_xtn);

$display("*****************************************READDDDD ADDR********************************************************");
	if(r_xtn.ARaddr == sr_xtn.ARaddr)
		begin
		`uvm_info("SCOREBOARD","READ ADDR COMPARED",UVM_LOW)
		$display("Master %0d \n slave %0d",xtn.ARaddr,sxtn.ARaddr);
		end
	else
		begin
		`uvm_info("SCOREBOARD","NOT CORRECT",UVM_LOW)
		$display("Master %0d \n slave %0d",xtn.ARaddr,sxtn.ARaddr);
		end
$display("*********************************************************************************************************");

$display("*****************************************READDDDD LENNN********************************************************");
	if(r_xtn.ARlen == sr_xtn.ARlen)
		begin
		`uvm_info("SCOREBOARD","READ LENN COMPARED",UVM_LOW)
		$display("Master %0d \n slave %0d",xtn.ARlen,sxtn.ARlen);
		end
	else
		begin
		`uvm_info("SCOREBOARD","NOT CORRECT",UVM_LOW)
		$display("Master %0d \n slave %0d",xtn.ARlen,sxtn.ARlen);
		end
$display("*********************************************************************************************************");

$display("*****************************************READDDDD BURST********************************************************");
	if(r_xtn.ARburst == sr_xtn.ARburst)
		begin
		`uvm_info("SCOREBOARD","READ BURST COMPARED",UVM_LOW)
		$display("Master %0d \n slave %0d",xtn.ARburst,sxtn.ARburst);
		end
	else
		begin
		`uvm_info("SCOREBOARD","NOT CORRECT",UVM_LOW)
		$display("Master %0d \n slave %0d",xtn.ARburst,sxtn.ARburst);
		end
$display("*********************************************************************************************************");

$display("*****************************************READDDDD DATA********************************************************");
	if(r_xtn.Rdata == sr_xtn.Rdata)
		begin
		`uvm_info("SCOREBOARD","READ DTATATA COMPARED",UVM_LOW)
		$display("Master %0p \n slave %0p",xtn.Rdata,sxtn.Rdata);
		end
	else
		begin
		`uvm_info("SCOREBOARD","NOT CORRECT",UVM_LOW)
		$display("Master %0p \n slave %0p",xtn.Rdata,sxtn.Rdata);
		end
$display("*********************************************************************************************************");

$display("*****************************************READ IDDDDDD********************************************************");
	if(r_xtn.ARid == sr_xtn.Rid)
		begin
		`uvm_info("SCOREBOARD","Read IDDDD COMPARED",UVM_LOW)
		$display("Master %0p \n slave %0p",r_xtn.ARid,sr_xtn.Rid);
		end
	else
		begin
		`uvm_info("SCOREBOARD","NOT CORRECT",UVM_LOW)
		$display("Master %0p \n slave %0p",r_xtn.ARid,sr_xtn.Rid);
		end
$display("*********************************************************************************************************\n");


endfunction
