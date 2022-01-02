class slave_monitor extends uvm_monitor ;

`uvm_component_utils(slave_monitor)

virtual axi_if.SMON_MP vif;

agent_cfg m_cfg;

trans smon_addr_queue[$];
trans smon_data_queue[$];
trans smon_resp_queue[$];
//bit [3:0]rd_len_qu[$];

bit [3:0]rd_len;
bit [3:0]rd_len_qu[$];
bit [3:0]slen_queue[$];
bit [3:0]sd;
semaphore sem1,sem2,sem3,sem_rd_data,sem_data,sem_resp;

uvm_analysis_port #(trans) slave_AWport;
uvm_analysis_port #(trans) slave_Wport;
uvm_analysis_port #(trans) slave_Rport;
uvm_analysis_port #(trans) slave_ARport;
uvm_analysis_port #(trans) slave_RWport;

extern function new(string name="slave_monitor",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);
extern task addr_collect(trans axtn);
extern task data_collect(trans dxtn);
extern task resp_collect(trans rxtn);
extern task rd_addr_collect(trans xtn);
extern task rd_data_collect(trans xtn);

endclass

function slave_monitor::new(string name="slave_monitor",uvm_component parent);
	super.new(name,parent);
//	sport = new("sport",this);
	slave_AWport = new("slave_AWport",this);
	slave_Wport = new("slave_Wport",this);
	slave_Rport = new("slave_Rport",this);
	slave_ARport = new("slave_ARport",this);
	slave_RWport = new("slave_RWport",this);


	sem1 = new();
	sem2 = new();
	sem3 = new();
	sem_rd_data = new(1);
	sem_data = new(1);
	sem_resp = new(1);

endfunction

function void slave_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db #(agent_cfg)::get(this,"","agent_cfg",m_cfg))
		`uvm_fatal("FATAL","Cannot get agent_cfg in monitor")
endfunction

function void slave_monitor::connect_phase(uvm_phase phase);	
	vif = m_cfg.vif;
endfunction

task slave_monitor::addr_collect(trans axtn);
	@(vif.smon_cb);
	wait(vif.smon_cb.AWvalid && vif.smon_cb.AWready)
 	  begin

	  axtn.AWaddr = vif.smon_cb.AWaddr;
	  axtn.AWsize = vif.smon_cb.AWsize;
	  axtn.AWlen = vif.smon_cb.AWlen;
	  axtn.AWburst = vif.smon_cb.AWburst;
	  axtn.AWid = vif.smon_cb.AWid;
	 
	  slen_queue.push_back(vif.smon_cb.AWlen);

	  smon_addr_queue.push_back(axtn);
//	$display("slave addr monitorrrrrrrrrrrrrrrrrrrrr %p",axtn);
	end
	  slave_AWport.write(axtn);

endtask

task slave_monitor::data_collect(trans dxtn);
//@(vif.smon_cb);
sd = slen_queue.pop_front();

for(int i=0;i<=sd;i++)
   begin
	@(vif.smon_cb);
	begin
	 wait(vif.smon_cb.Wvalid && vif.smon_cb.Wready)
	 dxtn.Wdata[i] = vif.smon_cb.Wdata;
	 dxtn.Wstrb[i] = vif.smon_cb.Wstrb;
	end
   end
slave_Wport.write(dxtn);
`uvm_info("Data SLAVE MONITOR DRIVE",$sformatf("printing from SLAVE MONITOROOROROROROROROR \n %s", dxtn.sprint()),UVM_LOW)	

endtask

task slave_monitor::resp_collect(trans rxtn);

//$display("slave monitorrrrr");
//#10;
  if(vif.smon_cb.Bvalid==1)
       rxtn.Bresp = vif.smon_cb.Bresp;
       rxtn.Bid = vif.smon_cb.Bid;

slave_Rport.write(rxtn);
endtask

//////////////////////////////////////////////////////////////READ COLLECT TASKKKKKKKK/////////////////////////////////////////////////////////////////
task slave_monitor::rd_addr_collect(trans xtn);
    @(vif.smon_cb);
      wait(vif.smon_cb.ARready && vif.smon_cb.ARvalid)
	
      xtn.ARaddr = vif.smon_cb.ARaddr; 	
      xtn.ARsize = vif.smon_cb.ARsize;
      xtn.ARlen = vif.smon_cb.ARlen ;	 
      xtn.ARburst = vif.smon_cb.ARburst;
      xtn.ARid = vif.smon_cb.ARid;

      rd_len_qu.push_back(vif.smon_cb.ARlen);

slave_ARport.write(xtn);
endtask

task slave_monitor::rd_data_collect(trans xtn);
rd_len = rd_len_qu.pop_front();

for(int i=0;i<=rd_len;i++)
   begin

	begin
          wait(vif.smon_cb.Rvalid && vif.smon_cb.Rready)
	   @(vif.smon_cb);
	    xtn.Rdata[i] = vif.smon_cb.Rdata;
	end
   end

if(vif.smon_cb.Rlast == 1)
xtn.Rid = vif.smon_cb.Rid;

slave_RWport.write(xtn);
//`uvm_info("Data SLAVE READ MON", $sformatf("printing from READ TASK MONITOROOROROROROROROR \n %s", xtn.sprint()),UVM_LOW)	
endtask

/////////////////////////////////////////////////////////////RUN PHASE ///////////////////////////////////////////////////////////////////////////////

task slave_monitor::run_phase(uvm_phase phase);

	forever
	   begin
            trans sxtn;
	    sxtn = trans::type_id::create("mxtn");

		  fork
		     begin
	    		addr_collect(sxtn);
	    		sem1.put(1);
	  	     end

	  	     begin
	    		sem1.get(1);
	    		sem_data.get(1);
	    		data_collect(sxtn);
	    		sem_data.put(1);
	    		sem2.put(1);
	  	     end

	  	     begin
	    		sem2.get(1);
	    		sem_resp.get(1);
	    		resp_collect(sxtn);
	    		sem_resp.put(1);
	             end


	  	  begin
	    	        rd_addr_collect(sxtn);
	    		sem3.put(1);
	          end

		  begin
	    		sem3.get(1);
	    		sem_rd_data.get(1);
	    		rd_data_collect(sxtn);
	    		sem_rd_data.put(1);
	  	  end

	        join_any

	   end


endtask

