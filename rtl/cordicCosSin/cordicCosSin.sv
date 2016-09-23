//--------------------------------------------------------------------------------
// File Name:     cordicCosSin.sv
// Project:       cordic
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    11.05.2016 - 0.1, verified with Modelsim and Matlab
//    13.05.2016 - 0.2, add SV LUT tables for atan, coefd
//    03.06.2016 - 1.0, release
//--------------------------------------------------------------------------------
// calc cosine and sine of input angle phi by CORDIC algorithm
// architecture: serial   - requires N + 2 clocks
//               parallel - pipelined for N + 2 clocks
// input angle: unsigned fi [   0(0000..) ... 2*pi(1111..) ) or
//                signed fi [ -pi(1000..) ...   pi(0111..) )
// see Matlab bit accurate model
//--------------------------------------------------------------------------------
module cordicCosSin
   #( parameter string CORDIC_TYPE = "PARALLEL",   // "PARALLEL" or "SERIAL"
                int    N           = 13,           // number of iterations for CORDIC algorithm
                int    PHI_WDT     = 18 )          // width of input angle phi (outputs is same width)                
    ( input  logic                            clk,
      input  logic                            reset,   // async reset
      input  logic                            sclr,    // sync clear
      input  logic                            en,      // clock enable
      
      input  logic                            st,      // start calc
      input  logic        [ PHI_WDT - 1 : 0 ] phi,     // input angle
            
      output logic                            rdy,     // result is ready
      output logic signed [ PHI_WDT - 1 : 0 ] cos,
      output logic signed [ PHI_WDT - 1 : 0 ] sin );   
 
   generate
      if ( CORDIC_TYPE == "PARALLEL" ) // parallel architecture
         cordicCosSinParallel
            #( .N       ( N       ),
               .PHI_WDT ( PHI_WDT ) )
         cordicCosSinParallelInst
             ( .clk   ( clk   ),
               .reset ( reset ),
               .sclr  ( sclr  ),
               .en    ( en    ),
               .st    ( st    ),
               .phi   ( phi   ),
               .rdy   ( rdy   ),
               .cos   ( cos   ),
               .sin   ( sin   ) );
      else if ( CORDIC_TYPE == "SERIAL" ) // serial architecture
         cordicCosSinSerial
            #( .N       ( N       ),
               .PHI_WDT ( PHI_WDT ) )
         cordicCosSinSerialInst
             ( .clk   ( clk   ),
               .reset ( reset ),
               .sclr  ( sclr  ),
               .en    ( en    ),
               .st    ( st    ),
               .phi   ( phi   ),
               .rdy   ( rdy   ),
               .cos   ( cos   ),
               .sin   ( sin   ) );
      else
         initial begin
            $error( "Not correct parameter CORDIC_TYPE" );
            $stop;
         end
   endgenerate
     
endmodule