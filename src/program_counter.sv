module program_counter(
  input logic clk_i,
  input logic rst_n_i,
  input logic [31:0] next_pc_i,
  input logic enable_i,
  output logic [31:0] pc_o
  );
  always_ff @(posedge clk_i or negedge rst_n_i) begin
    if (!rst_n_i) pc_o <= 32'b0;
    else if(enable_i) pc_o <= next_pc_i;
  end

endmodule
