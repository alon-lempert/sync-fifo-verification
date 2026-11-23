//------------------------------------------------------------
// File        : fifo_driver.sv
// Description : Driver class. Applies reset, then every cycle
//               gets a transaction from the generator mailbox
//               and drives it into the DUT interface.
//               Drives idle when no transaction is available.
//------------------------------------------------------------

class fifo_driver #(parameter int WIDTH = 8);
  mailbox #(fifo_transaction #(WIDTH)) mbx;
  virtual fifo_if #(WIDTH)             vif;
  int num_driven = 0;   // transactions driven so far

  function new(mailbox #(fifo_transaction #(WIDTH)) mbx,
               virtual fifo_if #(WIDTH) vif);
    this.mbx = mbx;
    this.vif = vif;
  endfunction

  // drive inputs to idle and apply reset for 2 cycles
  task reset();
    vif.wr_en   = 0;
    vif.rd_en   = 0;
    vif.wr_data = 0;
    vif.rst_n   = 0;
    repeat (2) @(negedge vif.clk);
    vif.rst_n   = 1;
  endtask

  task run();
    fifo_transaction #(WIDTH) trn;
    forever begin
      @(negedge vif.clk);
      if (mbx.try_get(trn)) begin // drive a transaction
        vif.wr_en   = trn.wr_en;
        vif.rd_en   = trn.rd_en;
        vif.wr_data = trn.wr_data;
        trn.display("DRV");
        num_driven++;
      end else begin              // idle
        vif.wr_en = 0;
        vif.rd_en = 0;
      end
    end
  endtask
endclass
