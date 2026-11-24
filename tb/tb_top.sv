//------------------------------------------------------------
// File        : tb_top.sv
// Description : Top-level testbench for the class-based
//               verification environment. Instantiates the
//               DUT and interface, generates the clock, and
//               runs randomized transactions.
//------------------------------------------------------------

`timescale 1ns/1ps
`include "fifo_if.sv"
`include "fifo_transaction.sv" 
`include "fifo_generator.sv"
`include "fifo_driver.sv"
`include "fifo_monitor.sv"

module tb;
  localparam int WIDTH = 8;
  localparam int DEPTH = 4;
  logic clk;

  // Interface instance
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
  
  // Clock generation: 100 MHz (10 ns period)
  initial clk=0;
  always #5 clk = ~clk;
  
  // Waveform dump
  initial begin
    $dumpfile("dump.vcd");
    $dumpvars;
  end

  // Test: generator + driver + monitor
  initial begin
    mailbox #(fifo_transaction #(WIDTH)) gen2drv;
    mailbox #(fifo_transaction #(WIDTH)) mon2scb;
    fifo_generator #(WIDTH) gen;
    fifo_driver    #(WIDTH) drv;
    fifo_monitor   #(WIDTH) mon;
    
    gen2drv = new();
    mon2scb = new();
    gen = new(gen2drv, 10);
    drv = new(gen2drv, fif);
    mon = new(mon2scb, fif);

    drv.reset();
    fork
      gen.run();
      drv.run();
      mon.run();
    join_none

    wait (drv.num_driven == 10);
    repeat (2) @(negedge clk);
    $finish;
  end
  
endmodule
