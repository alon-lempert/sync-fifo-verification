//------------------------------------------------------------
// File        : fifo_scoreboard.sv
// Description : Scoreboard class. Receives transactions from
//               the monitor and checks the DUT against a
//               queue-based reference model: data ordering,
//               read data, and full/empty flags.
//               Prints a PASS/FAIL summary at the end.
//------------------------------------------------------------

class fifo_scoreboard #(parameter int WIDTH = 8, parameter int DEPTH = 16);
  mailbox #(fifo_transaction #(WIDTH)) mon2scb;
  bit [WIDTH-1:0] model_q[$];      // reference model
  bit [WIDTH-1:0] expected;        // expected rd_data for next cycle
  bit             read_pending;    // 1 = check rd_data next cycle
  int             pass_count  = 0;
  int             error_count = 0;  
  
  function new(mailbox #(fifo_transaction #(WIDTH)) mon2scb); 
    this.mon2scb = mon2scb;
  endfunction  
  
  task run();
    fifo_transaction #(WIDTH) trn;
    bit exp_empty, exp_full;
    
    forever begin
      mon2scb.get(trn);
      
      // model's state at the start of this cycle
      exp_empty = (model_q.size() == 0);
      exp_full  = (model_q.size() == DEPTH);
      
      // flag checks
      if (trn.empty != exp_empty) begin     
        error_count++;
        $error("[SCB] : Empty mismatch- expected=%0b, actual=%0b", exp_empty, trn.empty);        
      end
      if (trn.full != exp_full) begin  
        error_count++;
        $error("[SCB] : full mismatch- expected=%0b, actual=%0b", exp_full, trn.full);       
      end
      
      // check data of the read accepted in the previous cycle
      if (read_pending) begin        
        if (trn.rd_data == expected) begin
          pass_count++;
        end else begin
          error_count++;
          $error("[SCB] : Data mismatch: expected=%0h, actual=%0h",expected, trn.rd_data);
        end
        read_pending = 0;
      end
      
      // Read at this cycle
      if (trn.rd_en && !exp_empty) begin
        expected     = model_q.pop_front();
        read_pending = 1;
      end
      
      // Write at this cycle
      if (trn.wr_en && !exp_full) begin
        model_q.push_back(trn.wr_data);
      end      
    end    
  endtask
  
  // Summary report 
    function void report();
      $display("[%0t][SCB]: Data checks- PASS=%0d, ERROR=%0d", $time, pass_count, error_count);
      if (error_count == 0 && pass_count > 0) 
        $display("[SCB]: TEST PASSED");
      else
        $display("[SCB]: TEST FAILED");
    endfunction
  
endclass
