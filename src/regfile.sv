module regfile#(
  parameter int XLEN=32,
  parameter int REG_ADDR_WIDTH=5)
  (
  input logic clk_i,
  input logic reg_we_i,
  input logic [XLEN-1:0] write_data_i,
  input logic [REG_ADDR_WIDTH-1:0] write_address_i,
  input logic [REG_ADDR_WIDTH-1:0] read_address_1_i,
  input logic [REG_ADDR_WIDTH-1:0] read_address_2_i,
  output logic [XLEN-1:0] read_data_1_o,
  output logic [XLEN-1:0] read_data_2_o
  );
  logic [XLEN-1:0] register [REG_ADDR_WIDTH];
  always_comb begin
    read_data_1_o = (read_address_1_i == 0) ? 0: register[read_address_1_i];
    read_data_2_o = (read_address_2_i == 0) ? 0: register[read_address_2_i];
  end

  always_ff @(posedge clk_i) begin
    if (reg_we_i && write_address_i !==0) begin
      register[write_address_i] <= write_data_i;
    end
  end

endmodule
