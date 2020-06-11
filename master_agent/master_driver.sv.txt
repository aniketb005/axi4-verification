class master_driver extends uvm_driver #(trans);

`uvm_component_utils(master_driver)

virtual axi_if.MDR_MP vif;

agent_cfg m_cfg;

trans addr_queue[$];
trans data_queue[$];
trans resp_queue[$];
trans rd_addr_queue[$];
trans rd_data_queue[$];

bit [31:0]rd_data_val_queue[$];
bit [7:0]data= 8'd0;

semaphore sem1,sem2,sem3,sem_rd_data,sem_addr,sem_data,sem_resp;


extern function new(string name = "master_driver",uvm_component parent);
extern function void build_phase(uvm_phase phase);
extern function void connect_phase(uvm_phase phase);
extern task addr_drive(trans axtn);
extern task data_drive(trans dxtn);
extern task resp_drive(trans rxtn);
extern task rd_addr_drive(trans axtn);
extern task rd_data_drive(trans xtn);
extern task run_phase(uvm_phase phase);
endclass

function master_driver::new(string name = "master_driver",uvm_component parent);
	super.new(name,parent);
	sem1 = new();
	sem2 = new();
	sem3 = new();
	sem_rd_data = new(1);
	sem_data = new(1);
	sem_addr = new(1);
	sem_resp = new(1);
endfunction

function void master_driver::build_phase(uvm_phase phase);
	super.build_phase(phase);

	if(!uvm_config_db #(agent_cfg)::get(this,"","agent_cfg",m_cfg))
		`uvm_fatal("FATAL","cannot get config in driver")

endfunction

function void master_driver::connect_phase(uvm_phase phase);
	vif = m_cfg.vif;
endfunction

///////////////////////////////////////////////////////////WRITE DRIVE TASK//////////////////////////////////////////////////////////////////////////////

task master_driver::addr_drive(trans axtn);

begin
	vif.mdr_cb.AWvalid <= 1'b1;
	vif.mdr_cb.AWaddr <= axtn.AWaddr;
	vif.mdr_cb.AWsize <= axtn.AWsize;
	vif.mdr_cb.AWlen <= axtn.AWlen;
	vif.mdr_cb.AWburst <= axtn.AWburst;
	vif.mdr_cb.AWid <= axtn.AWid;		
	
	@(vif.mdr_cb);
	wait(vif.mdr_cb.AWready)

	 vif.mdr_cb.AWvalid <= 1'b0;

	repeat(axtn.no_of_cycle_addr)
	@(vif.mdr_cb);	
 end	

endtask


task master_driver::data_drive(trans dxtn);
  begin
    for(int i=0;i<dxtn.AWlen+1;i++)
      begin   
	@(vif.mdr_cb);

	  vif.mdr_cb.Wvalid <= 1'b1;

	  vif.mdr_cb.Wstrb <= dxtn.Wstrb[i];
	   case(dxtn.Wstrb[i])
	      4'b0001 : vif.mdr_cb.Wdata <= {data,data,data,dxtn.Wdata[i][7:0]};
	      4'b0010 : vif.mdr_cb.Wdata <= {data,data,dxtn.Wdata[i][15:8],data};
	      4'b0100 : vif.mdr_cb.Wdata <= {data,dxtn.Wdata[i][23:16],data,data};
	      4'b1000 : vif.mdr_cb.Wdata <= {dxtn.Wdata[i][31:24],data,data,data};
	      4'b0011 : vif.mdr_cb.Wdata <= {data,data,dxtn.Wdata[i][15:0]};
	      4'b1100 : vif.mdr_cb.Wdata <= {dxtn.Wdata[i][31:16],data,data};
	      4'b1111 : vif.mdr_cb.Wdata <= {dxtn.Wdata[i][31:0]};
	   endcase
    	
       	   if(i == (dxtn.Wstrb.size-1))
	     begin
	       vif.mdr_cb.Wlast <= 1'b1;
	     end
	   else 
	     begin
	       vif.mdr_cb.Wlast <= 1'b0;
	     end

 
	 wait(vif.mdr_cb.Wready)
	  @(vif.mdr_cb);	
	  vif.mdr_cb.Wvalid <= 0;
         vif.mdr_cb.Wlast <= 0;

   end 
//$display("-*************************************--------- %d",vif.mdr_cb.Wdata);
//`uvm_info("Data DRIVE",$sformatf("printing from driver \n %s", dxtn.sprint()),UVM_LOW)		
end	
endtask

task master_driver::resp_drive(trans rxtn);
   begin
	vif.mdr_cb.Bready <= 1'b1;
	
	wait(vif.mdr_cb.Bvalid)
	  rxtn.Bresp <= vif.mdr_cb.Bresp;
	  @(vif.mdr_cb);
         vif.mdr_cb.Bready <= 1'b0;

   end	
endtask

/////////////////////////////////////////////////////////////FOR READ TASKK/////////////////////////////////////////////////////////////////////////

task master_driver::rd_addr_drive(trans axtn);
	vif.mdr_cb.ARvalid <= 1'b1;
	vif.mdr_cb.ARaddr <= axtn.ARaddr;
	vif.mdr_cb.ARsize <= axtn.ARsize;
	vif.mdr_cb.ARlen <= axtn.ARlen;
	vif.mdr_cb.ARburst <= axtn.ARburst;

	vif.mdr_cb.ARid <= axtn.ARid;		

	@(vif.mdr_cb);
	wait(vif.mdr_cb.ARready)
	 vif.mdr_cb.ARvalid <= 1'b0;

	repeat(axtn.no_of_cycle_addr)
	@(vif.mdr_cb);	
endtask

task master_driver::rd_data_drive(trans xtn);
	for(int i = 0;i<=xtn.ARlen;i++)
	  begin
	    wait(vif.mdr_cb.Rvalid ==1)
		vif.mdr_cb.Rready <= 1;
		@(vif.mdr_cb);
		rd_data_val_queue.push_back(xtn.Rdata[i]);
		vif.mdr_cb.Rready <= 0;

		repeat(xtn.no_of_cycle_addr)
		    @(vif.mdr_cb);
	  end
//`uvm_info("Data DRIVE",$sformatf("printing from driver \n %s", dxtn.sprint()),UVM_LOW)	

endtask

//////////////////////////////////////////////////////////////////RUN PHASEE FORK JOIN/////////////////////////////////////////////////////////////////////

task master_driver::run_phase(uvm_phase phase);
	trans xtn;
	xtn = trans::type_id::create("xtn");
	@(vif.mdr_cb);
	vif.mdr_cb.Aresetn <=0;
	@(vif.mdr_cb);
	vif.mdr_cb.Aresetn <= 1;

	forever
	   begin
	     seq_item_port.get_next_item(xtn);
	
		addr_queue.push_front(xtn);
     		data_queue.push_front(xtn);
		resp_queue.push_front(xtn);	
	        rd_addr_queue.push_front(xtn);
//	    	rd_data_queue.push_front(xtn);

		fork
		  begin
	    		addr_drive(addr_queue.pop_back());
	    		sem1.put(1);
	  	  end

	  	  begin
	    		sem1.get(1);
	    		sem_data.get(1);
	    		data_drive(data_queue.pop_back());
	    		sem_data.put(1);
	    		sem2.put(1);
	  	  end

	  	  begin
	    		sem2.get(1);
	    		sem_resp.get(1);
	    		resp_drive(resp_queue.pop_back());
	    		sem_resp.put(1);
	          end

	  	  begin
	    	        rd_addr_drive(rd_addr_queue.pop_back());
	    		sem3.put(1);
	          end

		  begin
	    		sem3.get(1);
	    		sem_rd_data.get(1);
	    		rd_data_drive(xtn);
	    		sem_rd_data.put(1);
	  	  end

		join_any

	     seq_item_port.item_done();

	   end
endtask	
