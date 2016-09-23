// external interface
// emalutes external codec chip
// read data from audDacData
// write exAdcData to audAdcData
`timescale 1 ns / 100 ps

module exInterface
   #( parameter string INTERFACE_TYPE,    // "LEFT-JUSTIFIED", "RIGHT-JUSTIFIED", "I2S"
                int    DATA_WDT,          // width of adc/dac data, 16, 20, 24, 32
                int    BCLK_DIVIDER,      // relative to mclk, 1, 2, 4, 6, ... or greater even number
                int    LRCK_DIVIDER )     // relative to mclk, must be even
    ( input  logic                             clk,      
      input  logic                             reset,

      input  logic                             audBclk,
      input  logic                             audAdcLrck,
      output logic                             audAdcData,
      input  logic                             audDacLrck,
      input  logic                             audDacData,      
      
      // adc/dac audio interface
      input  logic signed [ DATA_WDT - 1 : 0 ] exAdcDataL,     // adc data, left channel
      input  logic signed [ DATA_WDT - 1 : 0 ] exAdcDataR,     // adc data, right channel
      output logic signed [ DATA_WDT - 1 : 0 ] exDacDataL,     // dac data, left channel
      output logic signed [ DATA_WDT - 1 : 0 ] exDacDataR );   // dac data, right channel

   localparam realtime T = 10;   
   
   // external interface audDacData, read from dac
   always_ff @( posedge reset, posedge audBclk ) begin
      logic [ DATA_WDT - 1 : 0 ] shiftL, shiftR;
      logic                      lrckPrev;
      int                        i;
   
      if ( reset ) begin
         exDacDataL <= '0;
         exDacDataR <= '0;
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
                  exDacDataL <= shiftL;
            end;
            
            // right
            if ( lrckPrev & ~audDacLrck ) begin
               shiftR = '0;
               i      =  0;
            end
            if ( ~audDacLrck && i < DATA_WDT ) begin
               shiftR = { shiftR[ DATA_WDT - 2 : 0 ], audDacData };
               if ( i == DATA_WDT - 1 )
                  exDacDataR <= shiftR;
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
                  exDacDataL <= shiftL;
            end;
            
            // right
            if ( lrckPrev & ~audDacLrck ) begin
               shiftR = '0;
               i      =  0;
            end
            if ( ~audDacLrck && i > LRCK_DIVIDER / BCLK_DIVIDER / 2 - DATA_WDT - 1 && i < LRCK_DIVIDER / BCLK_DIVIDER / 2  ) begin
               shiftR = { shiftR[ DATA_WDT - 2 : 0 ], audDacData };
               if ( i == LRCK_DIVIDER / BCLK_DIVIDER / 2 - 1 )
                  exDacDataR <= shiftR;
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
                  exDacDataL <= shiftL;;
            end;
            
            // right
            if ( ~lrckPrev & audDacLrck ) begin
               shiftR = '0;
               i      =  0;
            end
            if ( audDacLrck && i > 0 && i < DATA_WDT + 1 ) begin
               shiftR = { shiftR[ DATA_WDT - 2 : 0 ], audDacData };
               if ( i == DATA_WDT )
                  exDacDataR <= shiftR;
            end
            i++;
            
         end         
      end
   end
   
   logic audBclkDelay;
   assign #1 audBclkDelay = audBclk;
   
  // external interface audAdcData, write to adc
   always_ff @( posedge reset, negedge audBclkDelay ) begin
      logic [ DATA_WDT - 1 : 0 ] shiftL, shiftR;
      logic [ DATA_WDT - 1 : 0 ] dataL, dataR;
      logic                      lrckPrev;
      int                        i;
      
      if ( reset ) begin
         audAdcData  = 1'b0;
         shiftL      = '0;
         shiftR      = '0;
         dataL       = '0;
         dataR       = '0;
         lrckPrev   <= 1'b0;
         i           = 0;
      end else begin
         lrckPrev   <= audAdcLrck;
         if ( i >= DATA_WDT )
            audAdcData  = 1'b0; // default
         
         if ( INTERFACE_TYPE == "LEFT-JUSTIFIED" ) begin
         
            // left
            if ( ~lrckPrev & audAdcLrck ) begin
               dataL      = exAdcDataL;
               dataR      = exAdcDataR;
               shiftL     = dataL;
               shiftR     = dataR;
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
            end
            i++;
         
         end else if ( INTERFACE_TYPE == "RIGHT-JUSTIFIED" ) begin
            
            // left
            if ( ~lrckPrev & audAdcLrck ) begin
               dataL      = exAdcDataL;
               dataR      = exAdcDataR;
               shiftL     = dataL;
               shiftR     = dataR;
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
            end
            i++;
         
         end else if ( INTERFACE_TYPE == "I2S" ) begin
         
            // left
            if ( lrckPrev & ~audAdcLrck ) begin
               dataL      = exAdcDataL;
               dataR      = exAdcDataR;
               shiftL     = dataL;
               shiftR     = dataR;
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
            end
            i++;
            
         end
      end
   end
   
endmodule