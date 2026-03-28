module cpu_with_memory #(
  parameter int XLEN=32,
  parameter int REG_ADDR_WIDTH=5,
  parameter [8*256-1:0] IMEM_FILE="",
  parameter [8*256-1:0] DMEM_FILE=""
  )(
  input logic clk_i, rst_n_i
  );


  logic [31:0] instruction_data;
  logic [31:0] instruction_address;

  logic [31:0] data_address;
  logic [31:0] write_data;
  logic write_enable;
  logic [3:0] write_strobe;
  logic [XLEN-1:0] read_data;

  cpu #(.XLEN(XLEN), .REG_ADDR_WIDTH(REG_ADDR_WIDTH)) cpu(
    .clk_i(clk_i),
    .rst_n_i(rst_n_i),
    .read_data_i(read_data),
    .write_data_o(write_data),
    .data_address_o(data_address),
    .write_enable_o(write_enable),
    .write_strobe_o(write_strobe),
    .instruction_data_i(instruction_data),
    .instruction_address_o(instruction_address)
    );
  instruction_memory #(.INIT_FILE(IMEM_FILE)) imem(
    .instruction_data_o(instruction_data),
    .instruction_address_i(instruction_address)
    );
  data_memory #(.XLEN(XLEN), .INIT_FILE(DMEM_FILE)) dmem(
    .clk_i(clk_i),
    .data_address_i(data_address),
    .write_data_i(write_data),
    .write_enable_i(write_enable),
    .write_strobe_i(write_strobe),
    .read_data_o(read_data)
    );
  endmodule
