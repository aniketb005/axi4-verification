module top;

import uvm_pkg::*;
import axi_pkg::*;

bit clk;

always
begin
	#10 clk = ~clk;
end

axi_if a01(clk);

initial
  begin

    uvm_config_db #(virtual axi_if)::set(null,"*","vif",a01);
	
    run_test();
    //$finish;
  end

endmodule
