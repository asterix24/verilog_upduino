`timescale 1ns/1ps
`default_nettype none

module tb_top;

  // Clock generato dal TB
  reg clk = 1'b0;
  reg rst = 1'b0;

  // Uscite del DUT
  wire RGB0, RGB1, RGB2;

  // Istanza del DUT
  top dut (
    .clk (clk),
    .rst (rst),
    .RGB0(RGB0),
    .RGB1(RGB1),
    .RGB2(RGB2)
  );

  // Clock 100 MHz (periodo 10 ns)
  always #5 clk = ~clk;

  initial begin
    $dumpfile("tb_top.vcd");
    $dumpvars(0, tb_top);

    repeat (4) @(posedge clk);
    rst = 1'b1;
    repeat (2000) @(posedge clk);
    $finish;
  end

endmodule

`default_nettype wire

