module scrolling_ram
   #(
    parameter ADDR_WIDTH = 9,  // number of address bits
              DATA_WIDTH = 1,   // color depth
              DVSR_WIDTH = 18,
                     MAX = 480
   )
   (
    input  logic clk,
    input  logic reset,
    input  logic [ADDR_WIDTH-1:0] addr_r,
    input  logic [DATA_WIDTH-1:0] din,
    input  logic [DVSR_WIDTH-1:0] dvsr,
    output logic [DATA_WIDTH-1:0] dout
   );

   localparam CNTR_WIDTH = ADDR_WIDTH + 1 + DVSR_WIDTH;

   // signal declaration
   logic [DATA_WIDTH-1:0] ram [0:2**ADDR_WIDTH-1];
   logic [DATA_WIDTH-1:0] data_reg;
   logic [CNTR_WIDTH-1:0] counter;
   logic [ADDR_WIDTH-1:0] index; 
   logic [CNTR_WIDTH-1:0] cnt_max;

   assign index = counter[ADDR_WIDTH-1:0]; 
   assign cnt_max[ADDR_WIDTH-1:0] = 0;
   assign cnt_max[ADDR_WIDTH] = 1;
   assign cnt_max[CNTR_WIDTH-1:ADDR_WIDTH+1] = dvsr;

   genvar i;
   generate for (i = 0; i < MAX; i++) 
      begin
         always_ff @(posedge clk)
         begin
            if (reset)
               ram[i] <= 0;
            else
            begin
               if (counter == i)
                  ram[i] <= ram[i+1];
            end
         end
      end
   endgenerate

   // body
   always_ff @(posedge clk)
   begin
      if (reset)
      begin
         ram[MAX] <= 0;
         data_reg <= 0;
         counter <= 0;
      end
      else
      begin
         counter <= counter+1;
         if (counter == MAX)
            ram[MAX] <= din;
         if (counter > cnt_max)
            counter <= 0;
         data_reg <= ram[addr_r];
      end
   end
   assign dout = data_reg;
endmodule   
