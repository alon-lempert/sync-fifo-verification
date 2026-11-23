//------------------------------------------------------------
// File        : fifo_generator.sv
// Description : Generator class. Creates randomized
//               transactions and sends them to the driver
//               through a mailbox.
//------------------------------------------------------------

class fifo_generator #(parameter int WIDTH = 8);
  mailbox #(fifo_transaction #(WIDTH)) mbx;
  int num_trans;

  // constructor: receives the shared mailbox from outside
  function new(mailbox #(fifo_transaction #(WIDTH)) mbx, int num_trans = 10);
    this.mbx       = mbx;
    this.num_trans = num_trans;
  endfunction

  task run();
    fifo_transaction #(WIDTH) trn;
    for (int i = 0; i < num_trans; i++) begin
      trn = new();
      if (!trn.randomize()) $fatal(1, "Randomization failed");
      trn.display("GEN");
      mbx.put(trn);
    end
  endtask
endclass
