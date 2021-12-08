module disp_mask_core (
   input logic clk, reset,
   // frame counter
   input  logic [10:0] x, y,
   // video slot interface
   input  logic cs,      
   input  logic write,  
   input  logic [13:0] addr,    
   input  logic [31:0] wr_data,
   // stream interface
   input  logic [11:0] si_rgb,
   output logic [11:0] so_rgb
  );
   logic [11:0] masked_rgb;
   logic [3:0] si_r, si_g, si_b;
   logic [11:0] border_rgb [0:1];
   assign border_rgb[1] = {3'b1,si_r[3],3'b1,si_g[3],3'b1,si_b[3]};
   assign border_rgb[0] = 12'hfff;

   // mask generator
   always_comb
   begin
      if (|x[9:8]) masked_rgb = 'h000;
      else if (x[4:1] == 'h0) masked_rgb = border_rgb[x[0]]; // first
      else if (x[4:1] == 'hf) masked_rgb = border_rgb[~x[0]]; // last
      else masked_rgb = si_rgb;
   end

   assign so_rgb = masked_rgb;
endmodule