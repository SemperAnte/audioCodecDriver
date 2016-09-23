//--------------------------------------------------------------------------------
// File Name:     i2cLine.sv
// Project:       i2cMaster
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    16.07.2016 - created
//--------------------------------------------------------------------------------
// i2c line sdat / sclk control
// control outputs, filter inputs
//--------------------------------------------------------------------------------
module i2cLine          
    ( input  logic clk,
      input  logic reset,       // async reset
      
      // reference tick
      input  logic tickX16,      
      // i2c outputs control
      input  logic sdatOut,
      input  logic sclkOut,      
      // i2c filtered inputs, comb logic
      output logic sdatFlt,
      output logic sclkFlt,      
      // i2c lines
      inout  wire  sdat,
      inout  wire  sclk );
   
   // sdat / sclk tri-state control
   logic  sdatIn;
   assign sdatIn = sdat;
   assign sdat = ( sdatOut ) ? 1'bz : 1'b0;
   logic  sclkIn;
   assign sclkIn = sclk;
   assign sclk = ( sclkOut ) ? 1'bz : 1'b0;
   
   // synchronizer to reduce metastability
   logic [ 1 : 0 ] sdatSyn, sclkSyn;
   
   always_ff @( posedge clk, posedge reset )
      if ( reset ) begin
         sdatSyn <= 2'b11;
         sclkSyn <= 2'b11;
      end else begin
         sdatSyn <= { sdatSyn[ 0 ], sdatIn };
         sclkSyn <= { sclkSyn[ 0 ], sclkIn };
      end 
      
   // delayed version of sdatSyn, sclkSyn with period of tickX16
   logic [ 2 : 0 ] sdatDly, sclkDly;
   
   always_ff @( posedge clk, posedge reset )
      if ( reset ) begin
         sdatDly <= 3'b111;
         sclkDly <= 3'b111;
      end else if ( tickX16 ) begin
         sdatDly <= { sdatDly[ 1 : 0 ], sdatSyn[ 1 ] };
         sclkDly <= { sclkDly[ 1 : 0 ], sclkSyn[ 1 ] };
      end
   
   // filter sdatDly, sclkDly to remove glitches   
   assign sdatFlt = ( sdatDly[ 2 ] & sdatDly[ 1 ] ) | ( sdatDly[ 1 ] & sdatDly[ 0 ] ) | ( sdatDly[ 2 ] & sdatDly[ 0 ] );
   assign sclkFlt = ( sclkDly[ 2 ] & sclkDly[ 1 ] ) | ( sclkDly[ 1 ] & sclkDly[ 0 ] ) | ( sclkDly[ 2 ] & sclkDly[ 0 ] );
   
endmodule