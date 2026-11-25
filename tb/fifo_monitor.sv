//------------------------------------------------------------
// File        : fifo_monitor.sv
// Description : Passive monitor class. Every clock cycle,
//               samples all interface signals into a new
//               transaction and sends it to the scoreboard
//               via a mailbox.
//------------------------------------------------------------

class fifo_monitor #(parameter int WIDTH = 8);
  mailbox #(fifo_transaction #(WIDTH)) mbx;
  virtual fifo_if #(WIDTH)             vif;
  
  function new(mailbox #(fifo_transaction #(WIDTH)) mbx,
               virtual fifo_if #(WIDTH) vif); 
    this.mbx = mbx;  
    this.vif = vif;
  endfunction
  
  task run();
    fifo_transaction #(WIDTH) trn;
    forever begin
      @(posedge vif.clk);
      trn = new();              // new object for every sample
      trn.wr_en   = vif.wr_en;
      trn.rd_en   = vif.rd_en;
      trn.wr_data = vif.wr_data;
      trn.rd_data = vif.rd_data;
      trn.full    = vif.full;
      trn.empty   = vif.empty;
      trn.display("MON");
      mbx.put(trn);             // sends to mailbox
    end
  endtask
  
endclass
