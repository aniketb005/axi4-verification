interface axi_if(input bit Aclk);

// bit Aclk;
bit Aresetn;


//write address signals
logic [3:0]AWid;
logic [31:0]AWaddr;
logic [3:0]AWlen;
logic [2:0]AWsize;
logic [1:0]AWburst;
bit AWvalid,AWready;

//write data
logic [3:0]Wid,Wstrb;
logic [31:0]Wdata;
logic Wlast;
logic Wvalid,Wready;

//write responce signals
logic [3:0]Bid;
logic [1:0]Bresp;
bit Bready,Bvalid;

//read address
logic [3:0]ARid;
logic [31:0]ARaddr;
logic [3:0]ARlen;
logic [2:0]ARsize;
logic [1:0]ARburst;
bit ARvalid,ARready;

// read data channel signals
logic [3:0]Rid;
logic [31:0]Rdata;
logic Rlast;
logic Rvalid,Rready;
logic [1:0]Rresp;


clocking mdr_cb @(posedge Aclk);
    default input #1 output #1;

//RESET
output Aresetn;

//Write addr signals
output AWid;
output AWaddr;
output AWlen;
output AWsize;
output AWburst;
output AWvalid;
input AWready;

//Write DATA Signals
output Wid;
output Wdata;
output Wstrb;
output Wlast;    
output Wvalid;
input Wready;

//Read Address
output ARid;
output ARaddr;
output ARlen;
output ARsize;
output ARburst;
output ARvalid;
input ARready;

//Read data
input Rid;
input Rdata;
input Rresp;
input Rlast;
input Rvalid;
output Rready;


//Write Resp signal
output Bready;
input Bvalid;
input Bid;
input Bresp;
endclocking


clocking mmon_cb @(negedge Aclk);
    default input #1 output #1;

//Write data signals
input Wid;
input Wdata;
input Wstrb;
input Wlast;    
input Wvalid;
input Wready;

//Write addr signal
input AWid;
input AWaddr;
input AWlen;
input AWsize;
input AWburst;
input AWvalid;
input AWready;

//Write resp signal
input Bid;
input Bresp;
input Bvalid;
input Bready;

//Read addr signal
input ARid; 
input ARaddr;
input ARlen;
input ARsize;
input ARburst;
input ARready;
input ARvalid;

//Read data
input Rid;
input Rdata;
input Rresp;
input Rlast;
input Rvalid;
input Rready;

endclocking


clocking sdr_cb @ (posedge Aclk);
    default input #1 output #1;

//Write addr signal
output AWready;
input AWid;
input AWaddr;
input AWlen;
input AWsize;
input AWburst;
input AWvalid;

//Write data signal
output Wready;
input Wid;
input Wdata;
input Wstrb;
input Wlast;    
input Wvalid;

//write resp signal
output Bid;
output Bresp;
output Bvalid;
input Bready;

//Read Addr
output ARready;
input ARid;
input ARaddr;
input ARlen;
input ARsize;
input ARburst;
input ARvalid;

//Read data
output Rid;
output Rdata;
output Rresp;
output Rlast;
output Rvalid;
input Rready;

endclocking

clocking smon_cb @(negedge Aclk);
    default input #1 output #1;
//Write data signals
input Wid;
input Wdata;
input Wstrb;
input Wlast;    
input Wvalid;
input Wready;

//Write addr signal
input AWid;
input AWaddr;
input AWlen;
input AWsize;
input AWburst;
input AWvalid;
input AWready;

//Write resp signal
input Bid;
input Bresp;
input Bvalid;
input Bready;

//Read addr signal
input ARid; 
input ARaddr;
input ARlen;
input ARsize;
input ARburst;
input ARready;
input ARvalid;

//Read data
input Rid;
input Rdata;
input Rresp;
input Rlast;
input Rvalid;
input Rready;

endclocking


modport MDR_MP (clocking mdr_cb);
  //Read OVC Driver MP
  modport SDR_MP (clocking sdr_cb);
  //Write OVC Monitor MP
  modport MMON_MP (clocking mmon_cb);
  //Read OVC Monitor MP
  modport SMON_MP (clocking smon_cb);
endinterface
