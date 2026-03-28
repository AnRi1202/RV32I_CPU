import risc_v_32_i_pkg::*;


module data_memory#(
  parameter int XLEN=32,
  parameter [8*256-1:0] INIT_FILE=""
)(
  input logic clk_i,
  input logic [31:0] data_address_i,
  input logic [XLEN-1:0] write_data_i,
  input logic write_enable_i,
  input logic [3:0] write_strobe_i,
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
      if (write_strobe_i[0]) data_mem[data_address_i[31:2]][7:0] <= write_data_i[7:0];
      if (write_strobe_i[1]) data_mem[data_address_i[31:2]][15:8] <= write_data_i[15:8];
      if (write_strobe_i[2]) data_mem[data_address_i[31:2]][23:16] <= write_data_i[23:16];
      if (write_strobe_i[3]) data_mem[data_address_i[31:2]][31:24] <= write_data_i[31:24];
    end
  end

  endmodule
