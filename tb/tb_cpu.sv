module tb_cpu;
 localparam int XLEN = 32;
 logic clk=0, rst=0;
 logic [XLEN-1:0] write_data;
 logic [31:0] data_address;
 logic write_enable;

 cpu dut(
   .clk_i(clk),
   .rst_i(rst),
   .write_data_i(write_data),
   .data_address_i(data_address),
   .write_enable_o(write_enable)
   );

  initial begin: create_clk
    forever clk = ~clk;
  end
endmodule
