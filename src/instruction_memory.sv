import risc_v_32_i_pkg::*;


module instruction_memory #(parameter [8*256-1:0] INIT_FILE="") (
  output logic [31:0] instruction_data_o,
  input logic [31:0] instruction_address_i
  );
  logic [31:0] instruction_mem [64];
  initial begin
    `ifndef SYNTHESIS
      if (INIT_FILE != "") begin
        $readmemh(INIT_FILE,instruction_mem);
      end
    `endif
  end

  always_comb begin
    instruction_data_o = instruction_mem[instruction_address_i[31:2]]; // ignore 2bit LSB
  end
  endmodule
