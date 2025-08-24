`timescale 1ns/1ps
`default_nettype none

module blink(
  input  wire clk,
  //input wire rst,
  output reg  RGB0,
  output reg  RGB1,
  output reg  RGB2
);

localparam integer COUNTER_WIDTH = 32;
reg [COUNTER_WIDTH-1:0] ctr;

initial ctr = '0;
initial RGB0 = 1'b1;
initial RGB1 = 1'b1;
initial RGB2 = 1'b1;

always @(posedge clk) begin
  //if (!rst) begin
  //  ctr <= {COUNTER_WIDTH{1'b0}};
  //  RGB0 <= 1'b1;
  //  RGB1 <= 1'b1;
  //  RGB2 <= 1'b1;
  //end else begin
    ctr <= ctr + 1;
    if (ctr == 32'd9999) begin
      RGB0 <= 1'b0;
      ctr <= {COUNTER_WIDTH{1'b0}};
    end else begin
      RGB0 <= 1'b1;
    end
  end

endmodule

`default_nettype wire

