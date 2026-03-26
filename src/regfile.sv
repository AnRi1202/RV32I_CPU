module regfile#(
  parameter int XLEN=32,
  parameter int REG_ADDR_WIDTH=5)
  (
  input logic clk_i,
  input logic write_enable_i,
  input logic write_data_i,
  input logic [REG_ADDR_WIDTH-1:0] write_address_i,
  input logic [REG_ADDR_WIDTH-1:0] read_address_a_i,
  input logic [REG_ADDR_WIDTH-1:0] read_address_b_i,
  output logic [XLEN-1:0] read_data_a_o,
  output logic [XLEN-1:0] read_data_b_o
  );
  logic [XLEN-1:0] register [REG_ADDR_WIDTH];
  always_comb begin
    read_data_a_o = (read_address_a_i == 0) ? 0: register[read_address_a_i];
    read_data_b_o = (read_address_b_i == 0) ? 0: register[read_address_b_i];
  end

  always_ff @(posedge clk) begin
    if (write_enable_i && write_address_i !==0) begin
      register[write_address_i] <= write_data_i;
    end
  end

endmodule
