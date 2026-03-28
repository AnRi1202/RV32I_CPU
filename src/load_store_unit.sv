//TODO: not support XLEN=64. need to fix data_memory ([3:0])
// not supoort hardware exception
module load_store_unit #(parameter int XLEN=32)( // align rw data
  // load
  input load_store_type_t load_store_sel_i,
  input logic [XLEN-1:0] read_data_i,
  output logic [XLEN-1:0] aligned_read_data_o,
  input logic [31:0] data_address_i,
  // store
  input logic [XLEN-1:0] write_data_i,
  output logic [XLEN-1:0] aligned_write_data_o,
  output logic [3:0] write_strobe_o
  );
  logic [XLEN-1:0] read_data_shifted;
  assign read_data_shifted = read_data_i >> (data_address_i[1:0] *8);
  // e.g., acess 03 -> shift right 24 bit.
  always_comb begin
    // aligned_read_data
    aligned_read_data_o = '0;
    unique0 case(load_store_sel_i)
      L_B: aligned_read_data_o = {{(XLEN-8){read_data_shifted[7]}},read_data_shifted[7:0]};
      L_H: aligned_read_data_o =  {{(XLEN-16){read_data_shifted[15]}},read_data_shifted[15:0]};
      L_W: aligned_read_data_o = {{(XLEN-32){read_data_shifted[31]}},read_data_shifted[31:0]};
      L_BU: aligned_read_data_o = {{(XLEN-8){1'b0}},read_data_shifted[7:0]};
      L_HU: aligned_read_data_o =  {{(XLEN-16){1'b0}},read_data_shifted[15:0]};
      LS_N_A: aligned_read_data_o = '0;
    endcase
    // aligned_write_data_o
    aligned_write_data_o = '0;
    write_strobe_o = '0;
    unique0 case(load_store_sel_i)
    S_B: begin
      aligned_write_data_o = {4{write_data_i[7:0]}};
      write_strobe_o = 4'b0001 << data_address_i[1:0];
    end
    S_H: begin
      aligned_write_data_o = {2{write_data_i[15:0]}};
      unique case(data_address_i[1:0])
        2'b00: write_strobe_o = 4'b0011;
        2'b01: write_strobe_o = 4'b0110;
        2'b10: write_strobe_o = 4'b1100;
        default: write_strobe_o = 4'b0000; // not handling misaligned
      endcase
    end
    S_W: begin
      aligned_write_data_o = write_data_i;
      write_strobe_o = 4'b1111;
    end
    default: write_strobe_o =4'b0000;
    endcase
  end
endmodule
