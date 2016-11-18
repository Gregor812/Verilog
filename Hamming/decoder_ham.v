`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date:    21:10:04 11/13/2016 
// Design Name: 
// Module Name:    decoder_ham 
// Project Name: 
// Target Devices: 
// Tool versions: 
// Description: 
//
// Dependencies: 
//
// Revision: 
// Revision 0.01 - File Created
// Additional Comments: 
//
//////////////////////////////////////////////////////////////////////////////////
module decoder_ham
(
    input   wire  clk_i,
    input   wire  rst_i,
    
    input   wire [20:0] dat_i,
    input   wire        vld_i,
    output  reg         rdy_o,
    
    output  wire [15:0] dat_o,
    output  reg         vld_o,
    input   wire        rdy_i
);

   reg [4:0] syndrome;
   reg [20:0] dat; // register with corrected errors
   
   assign dat_o = {dat[20:16], dat[14:8], dat[6:4], dat[2]}; // control bits removing
   
   always @(*)
   begin
      syndrome[0] = dat_i[0]  ^ dat_i[2]  ^ dat_i[4]  ^
                    dat_i[6]  ^ dat_i[8]  ^ dat_i[10] ^
                    dat_i[12] ^ dat_i[14] ^ dat_i[16] ^
                    dat_i[18] ^ dat_i[20];
      syndrome[1] = dat_i[1]  ^ dat_i[2]  ^ dat_i[5]  ^
                    dat_i[6]  ^ dat_i[9]  ^ dat_i[10] ^
                    dat_i[13] ^ dat_i[14] ^ dat_i[17] ^
                    dat_i[18];
      syndrome[2] = dat_i[3]  ^ dat_i[4]  ^ dat_i[5]  ^
                    dat_i[6]  ^ dat_i[11] ^ dat_i[12] ^
                    dat_i[13] ^ dat_i[14] ^ dat_i[19] ^
                    dat_i[20];
      syndrome[3] = dat_i[7]  ^ dat_i[8]  ^ dat_i[9]  ^
                    dat_i[10] ^ dat_i[11] ^ dat_i[12] ^
                    dat_i[13] ^ dat_i[14];
      syndrome[4] = dat_i[15] ^ dat_i[16] ^ dat_i[17] ^
                    dat_i[18] ^ dat_i[19] ^ dat_i[20];
   end
   
   always @(posedge clk_i)
      if(rst_i)
      begin
         rdy_o <= 0;
         dat   <= 0;
         vld_o <= 0;
      end
      else
      begin
         rdy_o <= rdy_i;
         if(rdy_i) begin
            dat   <= syndrome ? (dat_i ^ (1 << (syndrome - 5'b1))) : dat_i; // error correcting
            vld_o <= vld_i;
         end
      end
      
endmodule
