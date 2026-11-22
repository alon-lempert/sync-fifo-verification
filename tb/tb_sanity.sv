`timescale 1ns/1ps
`include "fifo_if.sv"
`include "fifo_transaction.sv"

module tb;
  localparam int WIDTH = 8;
  localparam int DEPTH = 4;
  logic clk;

  // interface instance
  fifo_if #(.WIDTH(WIDTH)) fif (.clk(clk));

  // DUT instance
  sync_fifo #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut (
    .clk     (clk),
    .rst_n   (fif.rst_n),
    .wr_en   (fif.wr_en),
    .wr_data (fif.wr_data),
    .rd_en   (fif.rd_en),
    .rd_data (fif.rd_data),
    .full    (fif.full),
    .empty   (fif.empty)
  );
  
  
  initial clk=0;
  always #5 clk = ~clk;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  initial begin
    fif.wr_en = 0;
    fif.wr_data = 0;
    fif.rd_en = 0;
    fif.rst_n = 0;
    
    repeat(2) @(negedge clk);
    fif.rst_n = 1;
    
    // write 4 entries
    for (int i = 1; i <= 4; i++) begin
      fif.wr_en = 1;
      fif.wr_data = 8'hA0+i;
      @(negedge clk);
    end
    fif.wr_en = 0;
    
    // read 4 entries
    fif.rd_en = 1;
    repeat(4) @(negedge clk);
    fif.rd_en = 0;
        
    
    repeat(2) @(negedge clk);
    $finish();
    
  end
  
endmodule
