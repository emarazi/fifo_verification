`include "fifo_interface.sv"
module synchronous_fifo #(parameter DEPTH=8, DATA_WIDTH=8) (
  fifo_interface fif
);

  reg [$clog2(DEPTH)-1:0] w_ptr, r_ptr;
  reg [DATA_WIDTH-1:0] fifo[DEPTH];
  reg [$clog2(DEPTH)-1:0] count;

  // Set Default values on reset.
  always @(posedge fif.clk or negedge fif.rst_n) begin
    if (!fif.rst_n) begin
      w_ptr <= 0;
      r_ptr <= 0;
      fif.data_out <= 0;
      count <= 0;
    end else begin
      case ({fif.w_en, fif.r_en})
        2'b00, 2'b11: count <= count;
        2'b01: count <= count - 1'b1;
        2'b10: count <= count + 1'b1;
      endcase
    end
  end

  // To write data to FIFO
  always @(posedge fif.clk) begin
    if (fif.w_en & !fif.full) begin
      fifo[w_ptr] <= fif.data_in;
      w_ptr <= w_ptr + 1;
    end
  end

  // To read data from FIFO
  always @(posedge fif.clk) begin
    if (fif.r_en & !fif.empty) begin
      fif.data_out <= fifo[r_ptr];
      r_ptr <= r_ptr + 1;
    end
  end

  assign fif.full = (count == DEPTH);
  assign fif.empty = (count == 0);

endmodule
