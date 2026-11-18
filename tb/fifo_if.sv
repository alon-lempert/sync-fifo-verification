`timescale 1ns/1ps

interface fifo_if #(parameter int WIDTH = 8) (input logic clk);
  logic 			rst_n;
  // write side
  logic 			wr_en;
  logic [WIDTH-1:0] wr_data;
  // read side
  logic 			rd_en;
  logic [WIDTH-1:0] rd_data;
  // status
  logic 			full;
  logic 			empty;
endinterface
