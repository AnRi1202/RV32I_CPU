module regfile#(
  parameter int XLEN=32,
  parameter int REG_ADDR_WIDTH=5)
  (
  input logic clk_i,
  input logic reg_we_i,
  input logic [XLEN-1:0] reg_data_i,
  input logic [4:0] write_address_i,
  input logic [4:0] read_address_1_i,
  input logic [4:0] read_address_2_i,
  output logic [XLEN-1:0] read_data_1_o,
  output logic [XLEN-1:0] read_data_2_o
  );
  localparam int REG_COUNT = (((1 << REG_ADDR_WIDTH) < 32) ? (1 << REG_ADDR_WIDTH) : 32);

  logic [XLEN-1:0] register [REG_COUNT-1:0];
  always_comb begin
    read_data_1_o = '0;
    read_data_2_o = '0;

    if ((read_address_1_i != 5'd0) && (read_address_1_i < REG_COUNT)) begin
      read_data_1_o = register[read_address_1_i];
    end

    if ((read_address_2_i != 5'd0) && (read_address_2_i < REG_COUNT)) begin
      read_data_2_o = register[read_address_2_i];
    end
  end

  always_ff @(posedge clk_i) begin
    if (reg_we_i && (write_address_i != 5'd0) && (write_address_i < REG_COUNT)) begin
      register[write_address_i] <= reg_data_i;
    end
  end

endmodule
