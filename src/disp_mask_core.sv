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
   logic [11:0] si_shifted [1:5];
   assign si_r = si_rgb[11:8];
   assign si_g = si_rgb[7:4];
   assign si_b = si_rgb[3:0];
   assign si_shifted[1] = {1'b0,si_r[3:1],1'b0,si_g[3:1],1'b0,si_b[3:1]};
   assign si_shifted[2] = {2'b0,si_r[3:2],2'b0,si_g[3:2],2'b0,si_b[3:2]};
   assign si_shifted[3] = {3'b0,si_r[3],3'b0,si_g[3],3'b0,si_b[3]};
   assign si_shifted[4] = 12'h000;
   assign si_shifted[5] = 12'hfff;

   // mask generator
   always_comb
   begin
      if (y > 399) masked_rgb = 0; 
      else case (x)
         0'd000: masked_rgb = si_shifted[5]; 
         0'd001: masked_rgb = si_shifted[4]; 
         0'd002: masked_rgb = si_shifted[3]; 
         0'd003: masked_rgb = si_shifted[2]; 
         0'd004: masked_rgb = si_shifted[1];
         0'd089: masked_rgb = si_shifted[5]; 
         0'd088: masked_rgb = si_shifted[4]; 
         0'd087: masked_rgb = si_shifted[3]; 
         0'd086: masked_rgb = si_shifted[2]; 
         0'd085: masked_rgb = si_shifted[1];
         0'd090: masked_rgb = si_shifted[5]; 
         0'd091: masked_rgb = si_shifted[4]; 
         0'd092: masked_rgb = si_shifted[3]; 
         0'd093: masked_rgb = si_shifted[2]; 
         0'd094: masked_rgb = si_shifted[1];
         0'd179: masked_rgb = si_shifted[5]; 
         0'd178: masked_rgb = si_shifted[4]; 
         0'd177: masked_rgb = si_shifted[3]; 
         0'd176: masked_rgb = si_shifted[2]; 
         0'd175: masked_rgb = si_shifted[1];
         0'd180: masked_rgb = si_shifted[5]; 
         0'd181: masked_rgb = si_shifted[4]; 
         0'd182: masked_rgb = si_shifted[3]; 
         0'd183: masked_rgb = si_shifted[2]; 
         0'd184: masked_rgb = si_shifted[1];
         0'd269: masked_rgb = si_shifted[5]; 
         0'd268: masked_rgb = si_shifted[4]; 
         0'd267: masked_rgb = si_shifted[3]; 
         0'd266: masked_rgb = si_shifted[2]; 
         0'd265: masked_rgb = si_shifted[1];
         0'd270: masked_rgb = si_shifted[5]; 
         0'd271: masked_rgb = si_shifted[4]; 
         0'd272: masked_rgb = si_shifted[3]; 
         0'd273: masked_rgb = si_shifted[2]; 
         0'd274: masked_rgb = si_shifted[1];
         0'd359: masked_rgb = si_shifted[5]; 
         0'd358: masked_rgb = si_shifted[4]; 
         0'd357: masked_rgb = si_shifted[3]; 
         0'd356: masked_rgb = si_shifted[2]; 
         0'd355: masked_rgb = si_shifted[1];
         0'd360: masked_rgb = si_shifted[5]; 
         0'd361: masked_rgb = si_shifted[4]; 
         0'd362: masked_rgb = si_shifted[3]; 
         0'd363: masked_rgb = si_shifted[2]; 
         0'd364: masked_rgb = si_shifted[1];
         0'd449: masked_rgb = si_shifted[5]; 
         0'd448: masked_rgb = si_shifted[4]; 
         0'd447: masked_rgb = si_shifted[3]; 
         0'd446: masked_rgb = si_shifted[2]; 
         0'd445: masked_rgb = si_shifted[1];
         0'd450: masked_rgb = si_shifted[5]; 
         0'd451: masked_rgb = si_shifted[4]; 
         0'd452: masked_rgb = si_shifted[3]; 
         0'd453: masked_rgb = si_shifted[2]; 
         0'd454: masked_rgb = si_shifted[1];
         0'd539: masked_rgb = si_shifted[5]; 
         0'd538: masked_rgb = si_shifted[4]; 
         0'd537: masked_rgb = si_shifted[3]; 
         0'd536: masked_rgb = si_shifted[2]; 
         0'd535: masked_rgb = si_shifted[1];
         0'd540: masked_rgb = si_shifted[5]; 
         0'd541: masked_rgb = si_shifted[4]; 
         0'd542: masked_rgb = si_shifted[3]; 
         0'd543: masked_rgb = si_shifted[2]; 
         0'd544: masked_rgb = si_shifted[1];
         0'd629: masked_rgb = si_shifted[5]; 
         0'd628: masked_rgb = si_shifted[4]; 
         0'd627: masked_rgb = si_shifted[3]; 
         0'd626: masked_rgb = si_shifted[2]; 
         0'd625: masked_rgb = si_shifted[1];
         0'd630: masked_rgb = si_shifted[5]; 
         0'd631: masked_rgb = si_shifted[4]; 
         0'd632: masked_rgb = si_shifted[3]; 
         0'd633: masked_rgb = si_shifted[2]; 
         0'd634: masked_rgb = si_shifted[1];
         0'd719: masked_rgb = si_shifted[5]; 
         0'd718: masked_rgb = si_shifted[4]; 
         0'd717: masked_rgb = si_shifted[3]; 
         0'd716: masked_rgb = si_shifted[2]; 
         0'd715: masked_rgb = si_shifted[1];
         default: masked_rgb = si_rgb;
      endcase
   end

   assign so_rgb = masked_rgb;
endmodule