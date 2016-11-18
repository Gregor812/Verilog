`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: Grigorii Kuzmin
// 
// Create Date:    21:08:23 11/13/2016 
// Design Name:    hamming
// Module Name:    coder_ham 
// Project Name:   Test task 1
// Target Devices: XC4VFX60
// Tool versions:  ISE 14.7
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module coder_ham (
   input   wire   clk_i,
   input   wire   rst_i,
 
   input   wire [15:0] dat_i,
   input   wire        vld_i,
   output  reg         rdy_o,
 
   output  reg  [20:0] dat_o,
   output  reg         vld_o,
   input   wire        rdy_i
);
   
   reg [4:0] ctrl_bits;
   
   always @(*) begin
      ctrl_bits[0] = dat_i[0]  ^ dat_i[1]  ^ dat_i[3]  ^
                     dat_i[4]  ^ dat_i[6]  ^ dat_i[8]  ^
                     dat_i[10] ^ dat_i[11] ^ dat_i[13] ^
                     dat_i[15];
      ctrl_bits[1] = dat_i[0]  ^ dat_i[2]  ^ dat_i[3] ^
                     dat_i[5]  ^ dat_i[6]  ^ dat_i[9] ^
                     dat_i[10] ^ dat_i[12] ^ dat_i[13];
      ctrl_bits[2] = dat_i[1]  ^ dat_i[2]  ^ dat_i[3] ^
                     dat_i[7]  ^ dat_i[8]  ^ dat_i[9] ^
                     dat_i[10] ^ dat_i[14] ^ dat_i[15];
      ctrl_bits[3] = dat_i[4]  ^ dat_i[5]  ^ dat_i[6] ^
                     dat_i[7]  ^ dat_i[8]  ^ dat_i[9] ^
                     dat_i[10];
      ctrl_bits[4] = dat_i[11] ^ dat_i[12] ^ dat_i[13] ^
                     dat_i[14] ^ dat_i[15];
   end
   
   always @(posedge clk_i)
      if(rst_i) begin
         rdy_o <= 0;
         dat_o <= 0;
         vld_o <= 0;
      end else begin
         rdy_o <= rdy_i;
         if(rdy_i) begin
            dat_o <= {dat_i[15:11], ctrl_bits[4],        //  \ 
                      dat_i[10:4],  ctrl_bits[3],        //   |  control bits including
                      dat_i[3:1],   ctrl_bits[2],        //   |
                      dat_i[0],     ctrl_bits[1:0]};     //  /
            vld_o <= vld_i;
         end
      end
   
endmodule
