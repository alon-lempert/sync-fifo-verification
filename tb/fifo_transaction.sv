//------------------------------------------------------------
// File        : fifo_transaction.sv
// Description : Transaction class representing one FIFO
//               cycle: randomized stimulus (wr_en, rd_en,
//               wr_data) and observed outputs (rd_data,
//               full, empty).
//------------------------------------------------------------

class fifo_transaction #(parameter int WIDTH = 8);
  // stimulus (randomized)
  rand bit             wr_en;
  rand bit             rd_en;
  rand bit [WIDTH-1:0] wr_data;
  // observed (sampled from DUT)
  logic [WIDTH-1:0]    rd_data;
  logic                full;
  logic                empty;

  function void display(string tag = "");
    $display("[%0t][%s] : wr_en=%0b, rd_en=%0b, wr_data=%0h | rd_data=%0h, full=%0b, empty=%0b",
             $time, tag, wr_en, rd_en, wr_data, rd_data, full, empty);
  endfunction
endclass
