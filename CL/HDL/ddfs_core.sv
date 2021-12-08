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
   logic [PW-1:0] fccw0,fccw1,fccw2,fccw3,fccw4,fccw5,fccw6,fccw7;
   logic [PW-1:0] focw, pha;
   logic [15:0] env_reg;
   logic [15:0] env;
   logic [2:0] ctrl_reg;
   logic [2:0] track_reg;
   logic wr_en, wr_fccw, wr_focw, wr_pha, wr_env, wr_ctrl;
   logic dout0,dout1,dout2,dout3,dout4,dout5,dout6,dout7;
   logic [15:0] pcm; 
   logic [15:0] pcm0,pcm1,pcm2,pcm3,pcm4,pcm5,pcm6,pcm7;
   //logic pdm0,pdm1,pdm2,pdm3;
   //logic [3:0] enable;
   logic [2:0] counter;
   
   
always @(posedge clk)
begin
    case (track_reg)
    3'b000: begin
    fccw0 = fccw_reg;
    end
    3'b001: begin
    fccw1 = fccw_reg;
    end
    3'b010: begin 
    fccw2 = fccw_reg;
    end
    3'b011: begin
    fccw3 = fccw_reg;
    end
    3'b100: begin
    fccw4 = fccw_reg;
    end
    3'b101: begin
    fccw5 = fccw_reg;
    end
    3'b110: begin
    fccw6 = fccw_reg;
    end
    3'b111: begin
    fccw7 = fccw_reg;
    end
    
    endcase
end

   // instantiate ddfs
   ddfs #(.PW(PW)) ddfs_unit0
      (.*, .fccw(fccw0), .pcm_out(pcm0), .pulse_out(dout0));
      
   ddfs #(.PW(PW)) ddfs_unit1
      (.*, .fccw(fccw1), .pcm_out(pcm1), .pulse_out(dout1));
      
   ddfs #(.PW(PW)) ddfs_unit2
      (.*, .fccw(fccw2), .pcm_out(pcm2), .pulse_out(dout2));
      
   ddfs #(.PW(PW)) ddfs_unit3
      (.*, .fccw(fccw3), .pcm_out(pcm3), .pulse_out(dout3));  
      
   ddfs #(.PW(PW)) ddfs_unit4
      (.*, .fccw(fccw4), .pcm_out(pcm4), .pulse_out(dout4));  
        
   ddfs #(.PW(PW)) ddfs_unit5
      (.*, .fccw(fccw5), .pcm_out(pcm5), .pulse_out(dout5));
      
   ddfs #(.PW(PW)) ddfs_unit6
      (.*, .fccw(fccw6), .pcm_out(pcm6), .pulse_out(dout6));
              
   ddfs #(.PW(PW)) ddfs_unit7
      (.*, .fccw(fccw7), .pcm_out(pcm7), .pulse_out(dout7));       
   // instantiate 1-bit dac
   ds_1bit_dac #(.W(16)) dac_unit0 
      (.*, .pcm_in(pcm));
      
   
   // mux for pdmout
   always @(posedge clk)
   begin
   if (counter == 3'b000) begin
   pcm = pcm0;
   digital_out=dout0;
   end
   if (counter == 3'b001) begin
   pcm = pcm1;
   digital_out=dout1;
   end
   if (counter == 3'b010) begin
   pcm = pcm2;
   digital_out=dout2;
   end
   if (counter == 3'b011) begin
   pcm = pcm3;
   digital_out=dout3;
   end
   if (counter == 3'b100) begin
   pcm = pcm4;
   digital_out=dout4;
   end
   if (counter == 3'b101) begin
   pcm = pcm5;
   digital_out=dout5;
   end
   if (counter == 3'b110) begin
   pcm = pcm6;
   digital_out=dout6;
   end
   if (counter == 3'b111) begin
   pcm = pcm7;
   digital_out=dout7;
   end
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
         counter <= counter + 1;
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
            track_reg <= wr_data[2:0];
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


