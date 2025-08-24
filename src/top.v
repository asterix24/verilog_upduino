//`timescale 1ns/1ps
//`default_nettype none
//
//module top #(
//    parameter WIDTH  = 8,
//    parameter THRESH = 100
//) (
//    input  wire clk,
//    input  wire rstn,
//    input  wire en,
//    output wire led
//);
//    // segnali interni per collegare i due moduli
//    wire [WIDTH-1:0] cnt;
//
//    // Istanza 1: contatore
//    counter #(.WIDTH(WIDTH)) u_cnt (
//        .clk  (clk),
//        .rstn (rstn),
//        .en   (en),
//        .q    (cnt)
//    );
//
//    counter #(.WIDTH(WIDTH)) u_cnt1 (
//        .clk  (clk),
//        .rstn (rstn),
//        .en   (en),
//        .q    (cnt)
//    );
//
//    // Istanza 2: comparatore
//    comparator #(.WIDTH(WIDTH), .THRESH(THRESH)) u_cmp (
//        .a         (cnt),
//        .ge_thresh (led)
//    );
//endmodule
//
//`default_nettype wire
//

`timescale 1ns/1ps
`default_nettype none

module top(
  //input  wire clk,
  //input wire rst,
  output reg  RGB0,
  output reg  RGB1,
  output reg  RGB2
);

// Se vuoi l'oscillatore interno iCE40 in HW, decommenta queste righe
// e rimuovi 'clk' dalla porta del modulo.
wire clk;
//SB_HFOSC inthosc (
//  .CLKHFPU(1'b1),
//  .CLKHFEN(1'b1),
//  .CLKHF(clk)
//);
SB_LFOSC losc (
  .CLKLFEN(1'b1),
  .CLKLFPU(1'b1),
  .CLKLF(clk)
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
    //if (ctr[12]) begin
    //  RGB0 <= 1'b0;
    //  RGB1 <= 1'b1;
    //  RGB2 <= 1'b1;
    //end else if (ctr[24]) begin
    //  RGB0 <= 1'b1;
    //  RGB1 <= 1'b0;
    //  RGB2 <= 1'b1;
    //end else if (ctr[30]) begin
    //  ctr <= {COUNTER_WIDTH{1'b0}};
    //  RGB0 <= 1'b1;
    //  RGB1 <= 1'b1;
    //  RGB2 <= 1'b1;
    //end
  end
//end

endmodule

`default_nettype wire
