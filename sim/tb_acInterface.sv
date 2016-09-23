// external interface
// emalutes external codec chip
// read data from audDacData
// write data to 
`timescale 1 ns / 100 ps

module tb_acInterface ();

   localparam realtime T = 10;
   
   localparam string INTERFACE_TYPE = "I2S"; // "LEFT-JUSTIFIED", "RIGHT-JUSTIFIED", "I2S"
   
   localparam int DATA_WDT     = 24,
                  BCLK_DIVIDER = 2, 
                  LRCK_DIVIDER = 128;
                  
   logic                      clk; 
   logic                      reset;         
   logic                      audMclk;
   logic                      audBclk;
   logic                      audAdcLrck;
   logic                      audAdcData;
   logic                      audDacLrck;
   logic                      audDacData;
   logic                      cmdModEn;  
   logic                      tick;
   logic [ DATA_WDT - 1 : 0 ] adcDataL;
   logic [ DATA_WDT - 1 : 0 ] adcDataR;
   logic [ DATA_WDT - 1 : 0 ] genDataL;
   logic [ DATA_WDT - 1 : 0 ] genDataR;

   
   acInterface
     #( .INTERFACE_TYPE ( INTERFACE_TYPE ),
        .DATA_WDT       ( DATA_WDT       ),
        .BCLK_DIVIDER   ( BCLK_DIVIDER   ),
        .LRCK_DIVIDER   ( LRCK_DIVIDER   ) )
   uutAcInterface
      ( .clk        ( clk        ),
        .reset      ( reset      ),
        .audMclk    ( audMclk    ),
        .audBclk    ( audBclk    ),        
        .audAdcLrck ( audAdcLrck ),        
        .audAdcData ( audAdcData ),        
        .audDacLrck ( audDacLrck ),        
        .audDacData ( audDacData ),   
        .cmdModEn   ( cmdModEn   ),
        .tick       ( tick       ),
        .adcDataL   ( adcDataL   ),
        .adcDataR   ( adcDataR   ),
        .genDataL   ( genDataL   ),
        .genDataR   ( genDataR   ) );
        
   always begin   
      clk = 1'b1;
      #( T / 2 );
      clk = 1'b0;
      #( T / 2 );
   end
   
   // cmdModEn control
   initial begin      
      reset = 1'b1;
      cmdModEn = 1'b0;
      # ( 10 * T + T / 2 );
      reset = 1'b0;
      # ( 5 * T );
      cmdModEn = 1'b1;  
      # ( 700 * T );
      cmdModEn = 1'b0;
      # ( 50 * T );
      cmdModEn = 1'b1;
   end
   
   logic [ DATA_WDT - 1 : 0 ] wrDacDataL, wrDacDataR; // write data to dac
   logic [ DATA_WDT - 1 : 0 ] rdAdcDataL, rdAdcDataR; // read data from adc
   
   // internal interface, write data to dac, read data from adc
   always_ff @( posedge reset, negedge cmdModEn, posedge clk ) begin
      logic [ DATA_WDT - 1 : 0 ] randL, randR;
      logic                      st;
   
      if ( reset | ~cmdModEn ) begin
         genDataL   <= '0;
         genDataR   <= '0;
         wrDacDataL <= '0;
         wrDacDataR <= '0;
         st         <= 1'b0;
      end else if ( tick ) begin
         // dac left
         randL       = $urandom;
         genDataL   <= randL;
         wrDacDataL <= genDataL; // previous value
         // dac right
         randR       = $urandom;
         genDataR   <= randR;
         wrDacDataR <= genDataR;
         
         if ( ~st ) // first launch, no data from adc
            st <= 1'b1;
         else begin
            if ( rdAdcDataL != adcDataL )
               $warning( "adc data left  : not equal read / write : %b / %b", rdAdcDataL, adcDataL );
            else
               $display( "adc data left  : correct" );
            if ( rdAdcDataR != adcDataR )
               $warning( "adc data right : not equal read / write : %b / %b", rdAdcDataR, adcDataR );
            else
               $display( "adc data right : correct" );
         end            
      end
   end
  
   // external interface audDacData, read from dac
   always_ff @( posedge reset, negedge cmdModEn, posedge audBclk ) begin
      logic [ DATA_WDT - 1 : 0 ] shiftL, shiftR;
      logic                      lrckPrev;
      int                        i;
   
      if ( reset | ~cmdModEn ) begin
         shiftL   = '0;
         shiftR   = '0;
         lrckPrev = 1'b0;
         i        = 0;
      end else begin    
         lrckPrev <= audDacLrck;
         
         if ( INTERFACE_TYPE == "LEFT-JUSTIFIED" ) begin
            
            // left
            if ( ~lrckPrev & audDacLrck ) begin
               shiftL = '0;
               i      =  0;            
            end         
            if ( audDacLrck && i < DATA_WDT ) begin
               shiftL = { shiftL[ DATA_WDT - 2 : 0 ], audDacData };
               if ( i == DATA_WDT - 1 )
                  if ( shiftL != wrDacDataL )
                     $warning( "dac data left  : not equal read / write : %b / %b", shiftL, wrDacDataL );
                  else
                     $display( "dac data left  : correct" );
            end;
            
            // right
            if ( lrckPrev & ~audDacLrck ) begin
               shiftR = '0;
               i      =  0;
            end
            if ( ~audDacLrck && i < DATA_WDT ) begin
               shiftR = { shiftR[ DATA_WDT - 2 : 0 ], audDacData };
               if ( i == DATA_WDT - 1 )
                  if ( shiftR != wrDacDataR )
                     $warning( "dac data right : not equal read / write : %b / %b", shiftR, wrDacDataR );
                  else
                     $display( "dac data right : correct" );
            end
            i++;
            
         end else if ( INTERFACE_TYPE == "RIGHT-JUSTIFIED" ) begin
            
            
            // left
            if ( ~lrckPrev & audDacLrck ) begin
               shiftL = '0;
               i      =  0;                   
            end         
            if ( audDacLrck && i > LRCK_DIVIDER / BCLK_DIVIDER / 2 - DATA_WDT - 1 && i < LRCK_DIVIDER / BCLK_DIVIDER / 2 ) begin
               shiftL = { shiftL[ DATA_WDT - 2 : 0 ], audDacData };
               if ( i == LRCK_DIVIDER / BCLK_DIVIDER / 2 - 1 )
                  if ( shiftL != wrDacDataL )
                     $warning( "dac data left  : not equal read / write : %b / %b", shiftL, wrDacDataL );
                  else
                     $display( "dac data left  : correct" );
            end;
            
            // right
            if ( lrckPrev & ~audDacLrck ) begin
               shiftR = '0;
               i      =  0;
            end
            if ( ~audDacLrck && i > LRCK_DIVIDER / BCLK_DIVIDER / 2 - DATA_WDT - 1 && i < LRCK_DIVIDER / BCLK_DIVIDER / 2  ) begin
               shiftR = { shiftR[ DATA_WDT - 2 : 0 ], audDacData };
               if ( i == LRCK_DIVIDER / BCLK_DIVIDER / 2 - 1 )
                  if ( shiftR != wrDacDataR )
                     $warning( "dac data right : not equal read / write : %b / %b", shiftR, wrDacDataR );
                  else
                     $display( "dac data right : correct" );
            end
            i++;
            
         end else if ( INTERFACE_TYPE == "I2S" ) begin
            
            // left
            if ( lrckPrev & ~audDacLrck ) begin            
               shiftL = '0;
               i      =  0;            
            end         
            if ( ~audDacLrck && i > 0 && i < DATA_WDT + 1 ) begin
               shiftL = { shiftL[ DATA_WDT - 2 : 0 ], audDacData };
               if ( i == DATA_WDT )
                  if ( shiftL != wrDacDataL )
                     $warning( "dac data left  : not equal read / write : %b / %b", shiftL, wrDacDataL );
                  else
                     $display( "dac data left  : correct" );
            end;
            
            // right
            if ( ~lrckPrev & audDacLrck ) begin
               shiftR = '0;
               i      =  0;
            end
            if ( audDacLrck && i > 0 && i < DATA_WDT + 1 ) begin
               shiftR = { shiftR[ DATA_WDT - 2 : 0 ], audDacData };
               if ( i == DATA_WDT )
                  if ( shiftR != wrDacDataR )
                     $warning( "dac data right : not equal read / write : %b / %b", shiftR, wrDacDataR );
                  else
                     $display( "dac data right : correct" );
            end
            i++;
            
         end         
      end
   end
   
   logic audBclkDelay;
   assign #1 audBclkDelay = audBclk;
   
  // external interface audAdcData, write to adc
   always_ff @( posedge reset, negedge cmdModEn, negedge audBclkDelay ) begin
      logic [ DATA_WDT - 1 : 0 ] shiftL, shiftR;
      logic [ DATA_WDT - 1 : 0 ] randL, randR;
      logic                      lrckPrev;
      int                        i;
      
      if ( reset | ~cmdModEn ) begin
         audAdcData  = 1'b0;
         rdAdcDataL <= '0;
         rdAdcDataR <= '0;
         shiftL      = '0;
         shiftR      = '0;
         randL       = '0;
         randR       = '0;
         lrckPrev   <= 1'b0;
         i           = 0;
      end else begin
         lrckPrev   <= audAdcLrck;
         if ( i >= DATA_WDT )
            audAdcData  = 1'b0; // default
         
         if ( INTERFACE_TYPE == "LEFT-JUSTIFIED" ) begin
         
            // left
            if ( ~lrckPrev & audAdcLrck ) begin
               randL      = $urandom;
               randR      = $urandom;
               shiftL     = randL;
               shiftR     = randR;
               i          = 0;
            end
            if ( audAdcLrck && i < DATA_WDT ) begin
               audAdcData = shiftL[ DATA_WDT - 1 ];
               shiftL = { shiftL[ DATA_WDT - 2 : 0 ], 1'b0 };
            end
            
            // right
            if ( lrckPrev & ~audAdcLrck )
               i = 0;
            if ( ~audAdcLrck && i < DATA_WDT ) begin
               audAdcData = shiftR[ DATA_WDT - 1 ];
               shiftR = { shiftR[ DATA_WDT - 2 : 0 ], 1'b0 };
               if ( i == DATA_WDT - 1 ) begin
                  rdAdcDataL <= randL;
                  rdAdcDataR <= randR;
               end
            end
            i++;
         
         end else if ( INTERFACE_TYPE == "RIGHT-JUSTIFIED" ) begin
            
            // left
            if ( ~lrckPrev & audAdcLrck ) begin
               randL      = $urandom;
               randR      = $urandom;
               shiftL     = randL;
               shiftR     = randR;
               i          = 0;
            end
            if ( audAdcLrck && i > LRCK_DIVIDER / BCLK_DIVIDER / 2 - DATA_WDT - 1 && i < LRCK_DIVIDER / BCLK_DIVIDER / 2 ) begin
               audAdcData = shiftL[ DATA_WDT - 1 ];
               shiftL = { shiftL[ DATA_WDT - 2 : 0 ], 1'b0 };
            end
            
            // right
            if ( lrckPrev & ~audAdcLrck )
               i = 0;
            if ( ~audAdcLrck && i > LRCK_DIVIDER / BCLK_DIVIDER / 2 - DATA_WDT - 1 && i < LRCK_DIVIDER / BCLK_DIVIDER / 2 ) begin
               audAdcData = shiftR[ DATA_WDT - 1 ];
               shiftR = { shiftR[ DATA_WDT - 2 : 0 ], 1'b0 };
               if ( i == LRCK_DIVIDER / BCLK_DIVIDER / 2 - 1 ) begin
                  rdAdcDataL <= randL;
                  rdAdcDataR <= randR;
               end
            end
            i++;
         
         end else if ( INTERFACE_TYPE == "I2S" ) begin
         
            // left
            if ( lrckPrev & ~audAdcLrck ) begin
               randL      = $urandom;
               randR      = $urandom;
               shiftL     = randL;
               shiftR     = randR;
               i          = 0;
            end
            if ( ~audAdcLrck && i > 0 && i < DATA_WDT + 1 ) begin
               audAdcData = shiftL[ DATA_WDT - 1 ];
               shiftL = { shiftL[ DATA_WDT - 2 : 0 ], 1'b0 };
            end
            
            // right
            if ( ~lrckPrev & audAdcLrck )
               i = 0;
            if ( audAdcLrck && i > 0 && i < DATA_WDT + 1 ) begin
               audAdcData = shiftR[ DATA_WDT - 1 ];
               shiftR = { shiftR[ DATA_WDT - 2 : 0 ], 1'b0 };
               if ( i == DATA_WDT ) begin
                  rdAdcDataL <= randL;
                  rdAdcDataR <= randR;
               end
            end
            i++;
            
         end
      end
   end
   
endmodule