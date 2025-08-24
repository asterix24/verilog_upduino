`timescale 1ns/1ps
`default_nettype none

module top(
  //input  wire clk,
  //input wire rst,
  output reg  RGB0,
  output reg  RGB1,
  output reg  RGB2
);

wire clk;

SB_LFOSC losc (
  .CLKLFEN(1'b1),
  .CLKLFPU(1'b1),
  .CLKLF(clk)
);

blink u_core (
    .clk (clk),
    .RGB0(RGB0),
    .RGB1(RGB1),
    .RGB2(RGB2)
);

endmodule

`default_nettype wire
