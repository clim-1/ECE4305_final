module chu_ddfs_core
   #(parameter PW=30)   // # DDFS bits
   (
    input  logic clk,
    input  logic reset,
    // slot interface
    input  logic cs,
    input  logic read,
    input  logic write,
    input  logic [4:0] addr,
    input  logic [31:0] wr_data,
    output logic [31:0] rd_data,
    // external signals 
    input  logic [PW-1:0] focw_ext, pha_ext,
    input  logic [15:0] env_ext,
    output logic digital_out,
    output logic pdm_out,
    output logic [15:0] pcm_out
   );

   // declaration
   logic [PW-1:0] pha_reg, fccw_reg, focw_reg;
   logic [PW-1:0] fccw0,fccw1,fccw2,fccw3;
   logic [PW-1:0] focw, pha;
   logic [15:0] env_reg;
   logic [15:0] env;
   logic [2:0] ctrl_reg;
   logic [1:0] track_reg;
   logic wr_en, wr_fccw, wr_focw, wr_pha, wr_env, wr_ctrl;
   logic digital_out0,digital_out1,digital_out2,digital_out3;
   logic [15:0] pcm; 
   logic [15:0] pcm0,pcm1,pcm2,pcm3;
   logic pdm0,pdm1,pdm2,pdm3;
   logic [3:0] enable;
   logic [1:0] counter;
   
   
always @(posedge clk)
begin
    case (track_reg)
    2'b00: begin
    enable = 4'b0001;
    fccw0 = fccw_reg;
    end
    2'b01: begin
    enable = 4'b0010;
    fccw1 = fccw_reg;
    end
    2'b10: begin 
    enable = 4'b0100;
    fccw2 = fccw_reg;
    end
    2'b11: begin
    enable = 4'b1000;
    fccw3 = fccw_reg;
    end
    endcase
end

   // instantiate ddfs
   ddfs #(.PW(PW)) ddfs_unit0
      (.*, .fccw(fccw0), .pcm_out(pcm0), .pulse_out(digital_out0));
      
   ddfs #(.PW(PW)) ddfs_unit1
      (.*, .fccw(fccw1), .pcm_out(pcm1), .pulse_out(digital_out1));
      
   ddfs #(.PW(PW)) ddfs_unit2
      (.*, .fccw(fccw2), .pcm_out(pcm2), .pulse_out(digital_out2));
      
   ddfs #(.PW(PW)) ddfs_unit3
      (.*, .fccw(fccw3), .pcm_out(pcm3), .pulse_out(digital_out3));  

   // instantiate 1-bit dac
   ds_1bit_dac #(.W(16)) dac_unit0 
      (.*, .pcm_in(pcm0),.pdm_out(pdm0));
      
   ds_1bit_dac #(.W(16)) dac_unit1 
      (.*, .pcm_in(pcm1),.pdm_out(pdm1));
      
   ds_1bit_dac #(.W(16)) dac_unit2 
      (.*, .pcm_in(pcm2),.pdm_out(pdm2));
      
   ds_1bit_dac #(.W(16)) dac_unit3 
      (.*, .pcm_in(pcm3),.pdm_out(pdm3));
  // assign pcm_out = pcm;
   
   // mux for pdmout
   always_ff @(posedge clk)
   begin
   if (counter == 2'b00) begin
   pdm_out <= pdm0;
   pcm_out <= pcm0;
   end
   if (counter == 2'b01) begin
   pdm_out <= pdm1;
   pcm_out <= pcm1;
   end
   if (counter == 2'b10) begin
   pdm_out <= pdm2;
   pcm_out <= pcm2;
   end
   if (counter == 2'b11) begin
   pdm_out <= pdm3;
   pcm_out <= pcm3;
   end
   counter <= counter + 1;
   end
   
   // registers
   always_ff @(posedge clk, posedge reset)
      if (reset) begin
         fccw_reg <= 0;
         focw_reg <= 0;
         pha_reg <= 0;
         env_reg <= 16'h4000;    // 1.00
         ctrl_reg <= 0;
         counter <= 0;
      end 
      else begin
         if (wr_fccw)
            fccw_reg <= wr_data[PW-1:0];
         if (wr_focw)
            focw_reg <= wr_data[PW-1:0];
         if (wr_pha)
            pha_reg <= wr_data[PW-1:0];
         if (wr_env)
            env_reg <= wr_data[15:0];
         if (wr_ctrl)
            ctrl_reg <= wr_data[2:0];
         if (wr_track)
            track_reg <= wr_data[1:0];
       end

       // decoding
       assign wr_en = write & cs;
   assign wr_fccw = (addr[2:0]==3'b000) & wr_en;
   assign wr_focw = (addr[2:0]==3'b001) & wr_en;
   assign wr_pha  = (addr[2:0]==3'b010) & wr_en;
   assign wr_env  = (addr[2:0]==3'b011) & wr_en;
   assign wr_ctrl = (addr[2:0]==3'b100) & wr_en;
   assign wr_track= (addr[2:0]==3'b101) & wr_en;
   // input signal routing 
   assign env  =(ctrl_reg[0]) ? env_ext : env_reg;
   assign focw =(ctrl_reg[1]) ? focw_ext : focw_reg;
   assign pha  =(ctrl_reg[2]) ? pha_ext : pha_reg;
   // read out
   assign rd_data = {16'h0000, pcm};
endmodule     


