module sync_fifo #(parameter int WIDTH=8, parameter int DEPTH=16) (
  input  logic clk,
  input  logic rst_n,
  // write side:
  input  logic wr_en,
  input  logic [WIDTH-1:0] wr_data,
  // read side:
  input  logic rd_en,
  output logic [WIDTH-1:0] rd_data,
  // FIFO status:
  output logic full,
  output logic empty
);
  localparam int ADDR_W = $clog2(DEPTH); // address width
  logic [ADDR_W:0] rd_ptr; //the MSB used as a wrap bit 
  logic [ADDR_W:0] wr_ptr; //the MSB used as a wrap bit
  logic [WIDTH-1:0] mem [DEPTH];

  // write logic:
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      wr_ptr<='0;
      end else if (wr_en && !full) begin
      mem[wr_ptr[ADDR_W-1:0]]<=wr_data;
      wr_ptr<=wr_ptr+1;
    end 
  end
  
  // read logic:
  always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
      rd_ptr<='0;
      rd_data<='0;
    end else if (rd_en && !empty) begin
      rd_data<=mem[rd_ptr[ADDR_W-1:0]];      
      rd_ptr<=rd_ptr+1;
    end
  end
  
  // full/empty flags:  
  assign empty=(wr_ptr==rd_ptr);
  assign full=((rd_ptr[ADDR_W]!= wr_ptr[ADDR_W]) && (rd_ptr[ADDR_W-1:0] == wr_ptr[ADDR_W-1:0]));

endmodule
