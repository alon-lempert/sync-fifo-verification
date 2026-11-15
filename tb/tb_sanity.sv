`timescale 1ns/1ps

module tb;
  
  localparam int WIDTH=8;
  localparam int DEPTH=4;
  logic clk;
  logic rst_n;
  logic wr_en;
  logic [WIDTH-1:0] wr_data;
  logic rd_en;
  logic [WIDTH-1:0] rd_data;
  logic full;
  logic empty;
  
  sync_fifo #(.WIDTH(WIDTH), .DEPTH(DEPTH)) dut (
    .clk(clk),
    .rst_n(rst_n),
    .wr_en(wr_en),
    .wr_data(wr_data),
    .rd_en(rd_en),
    .rd_data(rd_data),
    .full(full),
    .empty(empty)
  );
  
  initial clk=0;
  always #5 clk= ~clk;
  
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end
  
  initial begin
    wr_en=0;
    wr_data=0;
    rd_en=0;
    rst_n=0;
    
    repeat(2) @(negedge clk);
    rst_n=1;
    
    // write 4 entries
    for (int i=1; i<=4; i++) begin
      wr_en=1;
      wr_data=8'hA0+i;
      @(negedge clk);
    end
    wr_en=0;
    
    // read 4 entries
    rd_en=1;
    repeat(4) @(negedge clk);
    rd_en=0;
        
    
    repeat(2) @(negedge clk);
    $finish();
    
  end
  
endmodule
