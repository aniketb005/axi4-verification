class master_monitor extends uvm_monitor ;

`uvm_component_utils(master_monitor)

virtual axi_if.MMON_MP vif;

agent_cfg m_cfg;
bit [3:0]d;
bit [3:0]rd_len;

semaphore sem1,sem2,sem3,sem_rd_data,sem_data,sem_resp;

trans mon_addr_queue[$];
trans mon_data_queue[$];
trans mon_resp_queue[$];

bit [3:0]len_queue[$];
bit [3:0]rd_len_qu[$];

uvm_analysis_port #(trans) AWport;
uvm_analysis_port #(trans) Wport;
uvm_analysis_port #(trans) Rport;
uvm_analysis_port #(trans) ARport;
uvm_analysis_port #(trans) RWport;

extern function new(string name="master_monitor",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task run_phase(uvm_phase phase);

extern task addr_collect(trans axtn);
extern task data_collect(trans dxtn);
extern task resp_collect(trans rxtn);
extern task rd_addr_collect(trans xtn);
extern task rd_data_collect(trans xtn);
endclass

function master_monitor::new(string name="master_monitor",uvm_component parent);
	super.new(name,parent);
//	mport = new("mport",this);

	AWport = new("AWport",this);
	Wport = new("Wport",this);
	Rport = new("Rport",this);
	ARport = new("ARport",this);
	RWport = new("RWport",this);

	sem1 = new();
	sem2 = new();
	sem3 = new();
	sem_rd_data = new(1);
	sem_data = new(1);
	sem_resp = new(1);
endfunction

function void master_monitor::build_phase(uvm_phase phase);
	super.build_phase(phase);
	if(!uvm_config_db #(agent_cfg)::get(this,"","agent_cfg",m_cfg))
	   `uvm_fatal("FATAL","cannot get config in monitor")

endfunction

function void master_monitor::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction

task master_monitor::addr_collect(trans axtn);
 begin
	@(vif.mmon_cb);
	wait(vif.mmon_cb.AWvalid && vif.mmon_cb.AWready)
	begin
	axtn.AWaddr = vif.mmon_cb.AWaddr;
	axtn.AWsize = vif.mmon_cb.AWsize;
	axtn.AWlen = vif.mmon_cb.AWlen;
	axtn.AWburst = vif.mmon_cb.AWburst;
	axtn.AWid = vif.mmon_cb.AWid;
	 
	len_queue.push_back(vif.mmon_cb.AWlen);
	mon_addr_queue.push_back(axtn);
	end
 end
	AWport.write(axtn);

endtask

task master_monitor::data_collect(trans dxtn);

       d=len_queue.pop_front();


for(int i=0;i<=d;i++)
   begin

	begin
       wait(vif.mmon_cb.Wvalid && vif.mmon_cb.Wready)
	 @(vif.mmon_cb);

	 dxtn.Wdata[i] = vif.mmon_cb.Wdata;
	 dxtn.Wstrb[i] = vif.mmon_cb.Wstrb;
	end
   end
Wport.write(dxtn);
`uvm_info("Data WRITE MONITOR DRIVE", $sformatf("printing from MONITOROOROROROROROROR \n %s", dxtn.sprint()),UVM_LOW)	
endtask

task master_monitor::resp_collect(trans rxtn);
    if(vif.mmon_cb.Bvalid==1)
       rxtn.Bresp = vif.mmon_cb.Bresp;
//       rxtn.Bid = vif.mmon_cb.Bid;
Rport.write(rxtn);
endtask

//////////////////////////////////////////////////////////READ COLLECT TASKKKK////////////////////////////////////////////////////////////////////////////
task master_monitor::rd_addr_collect(trans xtn);
    @(vif.mmon_cb);
      wait(vif.mmon_cb.ARready && vif.mmon_cb.ARvalid)
	
      xtn.ARaddr = vif.mmon_cb.ARaddr; 	
      xtn.ARsize = vif.mmon_cb.ARsize;
      xtn.ARlen = vif.mmon_cb.ARlen ;	 
      xtn.ARburst = vif.mmon_cb.ARburst;
      xtn.ARid = vif.mmon_cb.ARid;

      rd_len_qu.push_back(vif.mmon_cb.ARlen);
ARport.write(xtn);
endtask

task master_monitor::rd_data_collect(trans xtn);
rd_len = rd_len_qu.pop_front();

for(int i=0;i<=rd_len;i++)
   begin

	begin
          wait(vif.mmon_cb.Rvalid && vif.mmon_cb.Rready)
	   @(vif.mmon_cb);
	    xtn.Rdata[i] = vif.mmon_cb.Rdata;
	end
   end
RWport.write(xtn);
//`uvm_info("Data MASTER READ MON", $sformatf("printing from READ TASK MONITOROOROROROROROROR \n %s", xtn.sprint()),UVM_LOW)	
endtask


/////////////////////////////////////////////////////////RUN PHASE/////////////////////////////////////////////////////////////////////////////////////////
task master_monitor::run_phase(uvm_phase phase);

forever
	 begin
	      trans mxtn;
              mxtn = trans::type_id::create("mxtn");

		  fork
		     begin
	    		addr_collect(mxtn);
	    		sem1.put(1);
	  	     end

	  	     begin
	    		sem1.get(1);
	    		sem_data.get(1);
	    		data_collect(mxtn);
	    		sem_data.put(1);
	    		sem2.put(1);
	  	     end

	  	     begin
	    		sem2.get(1);
	    		sem_resp.get(1);
	    		resp_collect(mxtn);
	    		sem_resp.put(1);
	             end

	  	  begin
	    	        rd_addr_collect(mxtn);
	    		sem3.put(1);
	          end

		  begin
	    		sem3.get(1);
	    		sem_rd_data.get(1);
	    		rd_data_collect(mxtn);
	    		sem_rd_data.put(1);
	  	  end


		  join_any

	   end


endtask

