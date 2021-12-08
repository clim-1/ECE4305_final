module scrolling_core (
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
  localparam ADDR_WIDTH = 9;  // number of address bits
  localparam         CD = 12;   // color depth
  localparam CNTR_WIDTH = 32;
  localparam LANE_WIDTH = 2;  // color code width not how many px
  localparam DVSR_WIDTH = 8;
  localparam        MAX = 400;
  localparam LANE_COUNT = 8;

  // delaration
  logic wr_en, wr_lane, wr_dvsr, wr_byps, wr_down;
  logic [LANE_WIDTH-1:0] lane_in [LANE_COUNT-1:0];
  logic [LANE_WIDTH-1:0] lane_out [LANE_COUNT-1:0];
  logic bypass_reg;
  logic down_reg;
  logic [DVSR_WIDTH-1:0] dvsr_reg;
  logic [CD-1:0] lane_rgb;
  logic [CD-1:0] chrom_rgb;
  logic [10:0] ram_y;
  logic [11:0] coded_color [3:0];
  logic [$clog2(LANE_COUNT)-1:0]lane_now;

  // 8 32 px lanes with 
  // adj_x bits:
  //----------------------------------
  //|XX|XX|XX| lane # |  x inside    |
  //|10|09|08|07    05|04          00|
  //----------------------------------

  always_comb // lane determination logic
  begin
    if (~&x[9:8]) lane_rgb = coded_color[lane_out[x[7:5]]];
    else lane_rgb = si_rgb;
  end

  assign coded_color[0] = 'h222; // kinda gray
  assign coded_color[1] = 'he34; // kinda red
  assign coded_color[2] = 'hadd; // kinda cyan
  assign coded_color[3] = 'hffe; // kinda white
  assign ram_y = (down_reg)? MAX - 1 - y: y; // flip vertically

    genvar i;
    generate 
      for (i = 0; i < LANE_COUNT; i++)
      begin
      // instantiate lane scrolling ram (shift register, kinda)
      scrolling_ram #(
        .ADDR_WIDTH(ADDR_WIDTH),  // number of address bits
        .DATA_WIDTH(LANE_WIDTH),   // color depth
        .DVSR_WIDTH(DVSR_WIDTH),
        .MAX(MAX)
      ) scrl_ram (
        .addr_r(ram_y),
        .din(lane_in[i]),
        .dout(lane_out[i]),
        .dvsr(dvsr_reg),
        .*
        );

        always_ff @(posedge clk, posedge reset)
        begin
          if (reset)
          begin
            lane_in[i] <= 0;
          end
          else
          begin
            if (wr_lane)
              lane_in[i] <= wr_data[(LANE_WIDTH*(i+1))-1:LANE_WIDTH*i];
          end              
        end
      end
    endgenerate

  // register
  always_ff @(posedge clk, posedge reset)
    if (reset)
    begin
      bypass_reg <= 0;
      down_reg <= 0;
    end
    else
    begin
      if (wr_dvsr)
        dvsr_reg <= wr_data[10:0];
      if (wr_byps)
        bypass_reg <= wr_data[0];
      if (wr_down)
        down_reg <= wr_data[0];
    end
  // decoding
  assign wr_en = write & cs;
  assign wr_lane = wr_en && (addr[1:0]==2'b00);
  assign wr_dvsr = wr_en && (addr[1:0]==2'b01);
  assign wr_byps = wr_en && (addr[1:0]==2'b10);
  assign wr_down = wr_en && (addr[1:0]==2'b11);
  assign so_rgb = (bypass_reg) ? si_rgb : lane_rgb;
endmodule
