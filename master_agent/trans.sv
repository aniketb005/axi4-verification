class trans extends uvm_sequence_item;

`uvm_object_utils(trans);

rand bit [31:0]ARaddr;
rand bit [31:0]AWaddr;
rand bit [31:0]Wdata[$];
rand bit [3:0]Wstrb[$];
rand bit [31:0]Rdata[$];
rand bit [2:0]AWsize;
rand bit [2:0]ARsize;
rand bit [1:0]AWburst;
rand bit [1:0]ARburst;
rand bit [3:0]AWlen;
rand bit [3:0]ARlen;
rand bit [3:0]AWid;
rand bit [3:0]ARid;
bit [3:0]Bid;
bit [3:0]Rid;
rand int no_of_cycle_addr;

bit AWvalid;
bit [1:0]Bresp;
bit Wlast;
bit [31:0]Start_address;
int Number_bytes;
int Data_bus_bytes;
bit [31:0] Aligned_address;
int Burst_length;
bit [31:0]Address[];
bit [31:0] Wrap_boundary;
bit [31:0]Lower_byte_lane;
bit [31:0]Upper_byte_lane;
bit [3:0]wstrb[];

constraint data { Wdata.size == AWlen+1'b1;
		  Wstrb.size == AWlen+1'b1;
		  Rdata.size == ARlen+1'b1;}

constraint Size { AWsize inside {[0:2]};
		  ARsize inside {[0:2]};}

 constraint awadd{AWaddr inside {[1:500]};}
 constraint aradd{ARaddr inside {[1:500]};}

constraint bursttt { AWburst!=3; ARburst != 3;}

constraint Wburst { if(AWburst == 2)
			AWlen inside {1,3,7,15};}

constraint Rburst { if(ARburst == 2)
			ARlen inside {1,3,7,15};}

constraint Awaddrr {if(AWburst == 2)
			AWaddr%(2**AWsize) == 0 ;}

constraint Araddrr {if(ARburst == 2)
			ARaddr%(2**ARsize) == 0 ;}

constraint no_of_cyc {no_of_cycle_addr inside{[2:5]};}

extern function new (string name = "trans") ;
extern function void do_print(uvm_printer printer);
extern function void next_addr_logic();
extern function void next_strb_logic();

extern function void post_randomize();
endclass


function trans::new(string name = "trans");
	super.new(name);
endfunction

function void trans::do_print(uvm_printer printer);
	super.do_print(printer);
    //                   srting name   		bitstream value     size       radix for printing
//    printer.print_field( "AWvalid", 		this.AWvalid,        1,         UVM_DEC		);
    printer.print_field( "AWaddr", 		this.AWaddr, 	     32,	         UVM_DEC		);
    printer.print_field( "AWsize", 		this.AWsize, 	     3,		 UVM_DEC		);
    printer.print_field( "AWlen",           	this.AWlen, 	     4,	   	 UVM_DEC		);
    printer.print_field( "AWburst",             this.AWburst,        2,		 UVM_DEC		);
//    printer.print_field( "AWvalid", 		this.AWvalid,	     1,          UVM_DEC		);
    foreach(Wdata[i])
    printer.print_field( $sformatf("Wdata[%0d]",i),		this.Wdata[i],	     32, 	 UVM_DEC		);
    foreach(Wstrb[i])	
    printer.print_field( $sformatf("Wstrb[%0d]",i),		this.Wstrb[i],	     4,		 UVM_DEC	 	);
 //   printer.print_field( "Wlast",		this.Wlast,	     1, 	 UVM_DEC		);	
//    printer.print_field( "Bresp",		this.Bresp,	     2, 	 UVM_DEC		);
    printer.print_field( "ARaddr", 		this.ARaddr, 	     32,	         UVM_DEC		);
    printer.print_field( "ARsize", 		this.ARsize, 	     3,		 UVM_DEC		);
    printer.print_field( "ARlen",           	this.ARlen, 	     4,	   	 UVM_DEC		);
    printer.print_field( "ARburst",             this.ARburst,        2,		 UVM_DEC		);
    foreach(Rdata[i])
    printer.print_field( $sformatf("Rdata[%0d]",i),		this.Rdata[i],	     32, 	 UVM_DEC		);


    

endfunction



function void trans::next_addr_logic();

	Data_bus_bytes = 4;
	Start_address = AWaddr;
	Number_bytes = 2 ** AWsize;
	Burst_length = AWlen+1'b1;
//	$display("Number of Bytes %0d",Number_bytes);
//	$display("AWaddr %0d",AWaddr);
	Address = new[Burst_length];

///FIXEDD////////////////////////////////////////////////////////////////////////////////
    if(AWburst == 2'd0)
       begin
	 for(int i=0;i<Burst_length;i++)
	   begin
	    Address[i] = Start_address;
//	    $display("Fixedddddddd %0d %0d",Address[i],i);
       	   end
	end  	   

/////Aligned ADDRESS//////////////////////////////////////////////////////////
        Aligned_address = (int'(Start_address/Number_bytes))*(Number_bytes);
//	$display("aligneed %0d",Aligned_address);
	    	
////Increment//////////////////////////////////////////////////////////////////////////////
     if(AWburst == 2'd1)
       begin
	  //First Transfer 
	  Address[0] = Start_address;
	 // $display("address during increment %0p",Address);

	 for(int i = 1;i<Burst_length;i++)
	  begin	
	  //TO Determine addr of any transfer after 1st transfer
 	  Address[i] = Aligned_address  + (i*Number_bytes);	
//	  $display("address during increment %0p",Address);
	end
       end


////WRAP BURST//////////////////////////////////////////////////////////////////////////////
     if(AWburst  == 2'd2)
        begin
	   Address[0] = Start_address;

//		$display("during wrap Address[0] %0d",Address[0]);
//		$display("during wrap start Address %0d",Start_address);

	   Wrap_boundary = (int'(Start_address/(Number_bytes*Burst_length)))*(Number_bytes*Burst_length);
//		$display("Wrap Boundary %0d",Wrap_boundary);

	for(int i = 1; i<Burst_length; i++)
	  begin
	 	Address[i] = Aligned_address  + (i*Number_bytes);
//		$display("address during wrap  %0d %0d",Address[i],i);

	     if(Address[i] == Wrap_boundary + (Number_bytes * Burst_length))
		begin
//		$display("HIGHER ADDRESS for wrap %0d",Wrap_boundary + (Number_bytes * Burst_length));
		Address[i] = Wrap_boundary;
//		$display("addresss changed to wrap boundary  %0d %0d",Address[i],i);

		for(int k=i+1;k<Burst_length; k++)
		  begin
		     Address[k] = Start_address + (((k)*Number_bytes)-(Number_bytes*Burst_length));
//		     $display("address after wrap boundary  %0p %0d",Address[k],k);

		  end
		break;
	        end
	    end
	  end

endfunction

function void trans::next_strb_logic();
	
	Data_bus_bytes = 4;
	Start_address = AWaddr;
	Number_bytes = 2** AWsize;
	Burst_length = AWlen+1'b1;
//	Wstrb = new[Burst_length];
	
	foreach(Wstrb[j])
	  begin
	  Wstrb[j] = 0;
	
	    if(j==0)
		begin
		    Lower_byte_lane = Start_address - (int'(Start_address/Data_bus_bytes))*Data_bus_bytes;

		    Upper_byte_lane = Aligned_address + (Number_bytes -1) - (int'(Start_address/Data_bus_bytes))*Data_bus_bytes;

//		    $display("WHEN J IS ZERO LBL %0d UBL %0d",Lower_byte_lane,Upper_byte_lane );
		end

	    else
		begin
			Lower_byte_lane = Address[j] - (int'(Address[j]/Data_bus_bytes))*Data_bus_bytes;

			Upper_byte_lane = Lower_byte_lane + Number_bytes-1;

//			$display("WHEN J IS %0d LBL %0d UBL %0d",j,Lower_byte_lane,Upper_byte_lane );
		
		end


			for(int i = Lower_byte_lane ; i<=Upper_byte_lane;i++)
			   begin
			     Wstrb[j][i] = 1'b1;

//			   	 $display("strobeeee %b",Wstrb[j]);
				end
	 end

endfunction

function void trans::post_randomize();
	next_addr_logic();	
	next_strb_logic();
endfunction

