`timescale 1ns / 1ns

////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer:
//
// Create Date:   17:47:18 11/15/2016
// Design Name:   coder_ham
// Module Name:   D:/Git/FPGA/Xilinx/hamming/src/coder_ham_tb.v
// Project Name:  hamming
// Target Device:  
// Tool versions:  
// Description: 
//
// Verilog Test Fixture created by ISE for module: coder_ham
//
// Dependencies:
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
////////////////////////////////////////////////////////////////////////////////

module coder_decoder_ham_tb;
   
	// Inputs
	reg clk_i;
	reg rst_i;
	reg [15:0] dat_i;
	reg vld_i;
	reg rdy_i;

	// Outputs
	wire rdy_d1, rdy_o; // decoder and coder outputs
	wire [15:0] dat_o;
	wire vld_d1, vld_o; // decoder and coder outputs
   
   // TB regs and wires
   reg [15:0] dat_i_d1, dat_i_d2; // conveyor input data to compare with decoded data
   wire [20:0] dat, dat_err;      // coder output and channel with 1-bit errors
      
   // TB other
   integer log; // log file descriptor
   integer err_num;  // errors counter
   
	// Instantiate the Units Under Test (UUT)
	coder_ham uut_c (
		.clk_i(clk_i), 
		.rst_i(rst_i), 
		.dat_i(dat_i), 
		.vld_i(vld_i), 
		.rdy_o(rdy_o), 
		.dat_o(dat), 
		.vld_o(vld_d1), 
		.rdy_i(rdy_d1)
	);
   
   decoder_ham uut_d (
		.clk_i(clk_i), 
		.rst_i(rst_i), 
		.dat_i(dat_err), 
		.vld_i(vld_d1), 
		.rdy_o(rdy_d1), 
		.dat_o(dat_o), 
		.vld_o(vld_o), 
		.rdy_i(rdy_i)
	);

	initial begin
		// Initialize regs
		clk_i = 0;
		rst_i = 1;
		dat_i = 0;
		vld_i = 0;
		rdy_i = 1;
      dat_i_d1 = 0;
      dat_i_d2 = 0;
      
      err_num  = 0;

		// Wait 60 ns for global reset to finish
		#60;
      rst_i = 0;
		// Add stimulus here
      
	end
   
   // clock generation
   always begin
      #10;
      clk_i <= ~clk_i;
   end
   
   always @(posedge clk_i)
      if(rst_i) begin
         dat_i <= 0;
         vld_i <= 0;
         rdy_i <= 1;
      end else begin
         if(rdy_o) begin // if coder is ready, external input data changing is enable
            dat_i <= dat_i + 1; // from 0 to FFFF, full trivial test
            vld_i <= $random % 2;
         end
         
         if(vld_o || !rdy_i)
            rdy_i <= $random % 2; // after data reading from decoder, external reader can be not ready
      end                         // for next data (probably)
      
   
   // input data bypass conveyor (we need it to compare with decoder output after errors correcting
   always @(posedge clk_i)
      if(rst_i) begin
         dat_i_d1 <= 0;
         dat_i_d2 <= 0;
      end else begin 
         if(rdy_d1)
            dat_i_d1 <= dat_i;
            
         if(rdy_i)
            dat_i_d2 <= dat_i_d1;
      end
   
   assign dat_err = dat ^ (1 << ($random % 22)); // channel with 1-bit errors
                                                 // 22 (not 21) is to simulate the probabilistic
                                                 // nature of errors (it can occur or not)
   
   // test case
   // matching input data with decoded data after error
   always @(posedge clk_i)
      if(dat_o != dat_i_d2) begin
         if(!err_num)
            log = $fopen("log.txt", "w"); // if it occurs some errors, they are logging
         
         // end of test condition
         // design contains over 5 errors
         if(err_num >= 5) begin
            $fwrite(log, "Design contains over 5 errors\nSimulation stopped\n");
            $display("DESIGN CONTAINS OVER 5 ERRORS\nSIMULATION STOPPED\n");
            $fclose(log);
            $stop;
         end else
            err_num <= err_num + 1;
         $fwrite(log, "Expected: 0x%X\nGot:      0x%X\n\n", dat_i_d2, dat_o);
      end
   
   // end of test condition
   // all possible input data is checked
   always @(posedge clk_i)
      if(dat_i_d2 == (2**16 - 1)) begin
         if(!err_num)
            $display("TEST PASSED\nDESIGN HAVES NO ERRORS\n");
         else
            $display("DESIGN CONTAINS %d ERRORS, CHECK THE LOG PLEASE\n", err_num);
         $fclose(log);
         $stop;
      end

endmodule
