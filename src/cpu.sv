module cpu #(parameter int XLEN=32) (
  input logic clk_i, rst_i,
  input logic [XLEN-1:0] write_data_i,
  input logic [31:0] data_address_i,
  output logic write_enable_o
  );
  // for imem
  logic [31:0] instruction_address;
  logic [31:0] instruction_data;
  // for dmem
  logic write_enable;
  logic [XLEN-1:0] read_data;

  instruction_memory imem(
    .instruction_address_i(instruction_address),
    .instruction_data_o(instruction_data)
  );
  data_memory dmem(
    .address_i(data_address_i),
    .write_data_i(write_data_i),
    .clk_i(clk_i),
    .write_enable_i(write_enable),
    .read_data_o(read_data)
    );
endmodule
