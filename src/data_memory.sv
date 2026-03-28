import risc_v_32_i_pkg::*;


module data_memory#(
  parameter int XLEN=32,
  parameter [8*256-1:0] INIT_FILE=""
)(
  input logic [31:0] data_address_i,
  input logic [XLEN-1:0] write_data_i,
  input logic clk_i,
  input logic write_enable_i,
  output logic [XLEN-1:0] read_data_o
  );
  logic [XLEN-1:0] data_mem[64];
  `ifndef SYNTHESIS
  initial begin
    if (INIT_FILE !="") begin
      $readmemh(INIT_FILE, data_mem);
    end
  end
  `endif

  always_comb begin
    read_data_o = data_mem[data_address_i[31:2]]; // 4word
  end
  always_ff @(posedge clk_i) begin
    if (write_enable_i) begin
      data_mem[data_address_i[31:2]] <= write_data_i;
    end
  end

  endmodule
