import risc_v_32_i_pkg::*;

module comparator #(parameter int XLEN=32)(
  input logic [XLEN-1:0] comp_port_a_i,
  input logic [XLEN-1:0] comp_port_b_i,
  input comp_sel_t comp_op_sel_i,
  output logic comp_o
  );
  always_comb begin
    unique case(comp_op_sel_i)
    OP_BEQ: comp_o = comp_port_a_i == comp_port_b_i;
    OP_BNE: comp_o = comp_port_a_i != comp_port_b_i;
    OP_BLT, OP_SLT: comp_o = $signed(comp_port_a_i) < $signed(comp_port_b_i);
    OP_BGE: comp_o = $signed(comp_port_a_i) >= $signed(comp_port_b_i);
    OP_BLTU, OP_SLTU: comp_o = comp_port_a_i < comp_port_b_i;
    OP_BGEU: comp_o = comp_port_a_i >= comp_port_b_i;
    OP_NONE: comp_o = 1'b0;
    default: comp_o = 1'b0;
    endcase
  end

endmodule
