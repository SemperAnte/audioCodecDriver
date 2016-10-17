//--------------------------------------------------------------------------------
// File Name:     audioCodec.c
// Project:       i2cMaster
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    21.08.2016 - created
//    17.10.2016 - added wm8731 support
//--------------------------------------------------------------------------------
// NIOS example
// initialization audio codec SSM2603 on SoCKit  board via I2C
// initialization audio codec WM8731  on DE1-SoC board via I2C
//--------------------------------------------------------------------------------
#include "audioCodec.h"

// fully initialization ssm2603 via I2C ( write, read, compare )
alt_u8 ssm2603I2cInit( alt_u32 baseAdr,       // base module address
                       alt_u8  devAdr,        // device address
                       alt_u8  infoLevel )    // info level ( 0, 1 - additional debug info )
{
   printf( "Initialization SSM2603 via I2C ... " );
   if ( infoLevel )
      printf( "\n" );

   // i2c commands
   struct {
      alt_u8  regAdr;
      alt_u16 regData;                // 9 bits used
   } cmdData[] = { { 0x0f, 0x000 },   // 0_0000_0000, software reset                                    
                   { 0x06, 0x010 },   // 0_0001_0000, power on everything except out
                   { 0x00, 0x017 },   // 0_0001_0111, left-channel  ADC input volume
                   { 0x01, 0x017 },   // 0_0001_0111, right-channel ADC input volume
                   { 0x02, 0x079 },   // 0_0111_1001, left-channel DAC volume
                   { 0x03, 0x079 },   // 0_0111_1001, right-channel DAC volume
                   { 0x04, 0x010 },   // 0_0001_0000, analog audio path
                   { 0x05, 0x001 },   // 0_0000_0001, digital audio path
                   { 0x07, 0x009 },   // 0_0000_1001, digital audio I/F
                   { 0x08, 0x01C },   // 0_0001_1100, sampling rate ( MCLK = 12.288 MHz, BCLK = MCLK/2, Fs = 96 kHz )
                                      // pause 40 ms                                                      
                   { 0x09, 0x001 },   // 0_0000_0001, activate digital core 
                   { 0x06, 0x000 } }; // 0_0000_0000, power on everithing

   alt_u8  err;
   alt_u16 readData;
   
   int attNum; // attempt number, for loop
   int cmdNum; // command number, for loop
   for ( attNum = 0; attNum < 3; attNum++ ) { // set max number of attempts
      if ( infoLevel )
         printf( "\tattempt N %i\n", attNum + 1 );
      
      IOWR_8DIRECT( baseAdr, 0, 0x01 ); // soft reset to default
      IOWR_8DIRECT( baseAdr, 0, 0x80 ); // i2c module is enabled, interrupt is disabled
      
      for ( cmdNum = 0; cmdNum < sizeof( cmdData ) / sizeof( cmdData[ 0 ] ); cmdNum++ ) {
         // pause 40 ms to charge the VMID decoupling capacitor
         if ( cmdNum == sizeof( cmdData ) / sizeof( cmdData[ 0 ] ) - 2 ) // before register R9
            usleep( 40000 );
         
         // write data
         if( infoLevel )
            printf( "\twrite to register 0x%02X data 0x%03X : ", cmdData[ cmdNum ].regAdr, cmdData[ cmdNum ].regData );
         err = codecI2cWrite( baseAdr, devAdr, cmdData[ cmdNum ].regAdr, cmdData[ cmdNum ].regData );
         if ( !err ) {
            if ( infoLevel )
               printf( "ok\n" );
         } else {
            if ( infoLevel )
               printf( "error 0x%02X\n", err );
            break; // next attempt
         }

         // read data
         if ( infoLevel )
            printf( "\tread from register 0x%02X : ", cmdData[ cmdNum ].regAdr );
         err = codecI2cRead( baseAdr, devAdr, cmdData[ cmdNum ].regAdr, &readData );
         if ( !err ) {
            if ( infoLevel )
               printf( "data 0x%03X\n", readData );
         } else {
            if ( infoLevel )
               printf( "error 0x%02X\n", err );
            break; // next attempt 
         }
         
         // compare data
         if ( infoLevel )
            printf( "\tcompare write/read data : " );
         if ( cmdData[ cmdNum ].regData == readData ) {
            if ( infoLevel )
               printf( "ok\n" );
            err = 0x00;
         } else {   
            if ( infoLevel )
               printf( "error\n" );
            err = 0x03;
            break; // next attempt
         }
         
      } // for cmdNum
      
      if ( !err ) break; // no errors 
      
   } // for attNum

   if ( !err )
      printf( "done\n" );
   else
      printf( "failed\n" );
   
   return err;
}

// fully initialization ssm2603 via I2C ( only write )
alt_u8 wm8731I2cInit( alt_u32 baseAdr,       // base module address
                      alt_u8  devAdr,        // device address
                      alt_u8  infoLevel )    // info level ( 0, 1 - additional debug info )
{
   printf( "Initialization WM8731 via I2C ... " );
   if ( infoLevel )
      printf( "\n" );

   // i2c commands
   struct {
      alt_u8  regAdr;
      alt_u16 regData;                // 9 bits used
   } cmdData[] = { { 0x0f, 0x000 },   // 0_0000_0000, software reset
                   { 0x06, 0x010 },   // 0_0001_0000, power on everything except out
                   { 0x00, 0x017 },   // 0_0001_0111, left-channel  ADC input volume
                   { 0x01, 0x017 },   // 0_0001_0111, right-channel ADC input volume
                   { 0x02, 0x079 },   // 0_0111_1001, left-channel DAC volume
                   { 0x03, 0x079 },   // 0_0111_1001, right-channel DAC volume
                   { 0x04, 0x010 },   // 0_0001_0000, analog audio path
                   { 0x05, 0x001 },   // 0_0000_0001, digital audio path
                   { 0x07, 0x009 },   // 0_0000_1001, digital audio I/F
                   { 0x08, 0x01C },   // 0_0001_1100, sampling rate ( MCLK = 12.288 MHz, BCLK = MCLK/2, Fs = 96 kHz )
                                      // pause 40 ms
                   { 0x09, 0x001 },   // 0_0000_0001, activate digital core
                   { 0x06, 0x000 } }; // 0_0000_0000, power on everithing

   alt_u8  err;

   int attNum; // attempt number, for loop
   int cmdNum; // command number, for loop
   for ( attNum = 0; attNum < 3; attNum++ ) { // set max number of attempts
      if ( infoLevel )
         printf( "\tattempt N %i\n", attNum + 1 );

      IOWR_8DIRECT( baseAdr, 0, 0x01 ); // soft reset to default
      IOWR_8DIRECT( baseAdr, 0, 0x80 ); // i2c module is enabled, interrupt is disabled

      for ( cmdNum = 0; cmdNum < sizeof( cmdData ) / sizeof( cmdData[ 0 ] ); cmdNum++ ) {
         // pause 40 ms to charge the VMID decoupling capacitor
         if ( cmdNum == sizeof( cmdData ) / sizeof( cmdData[ 0 ] ) - 2 ) // before register R9
            usleep( 40000 );

         // write data
         if( infoLevel )
            printf( "\twrite to register 0x%02X data 0x%03X : ", cmdData[ cmdNum ].regAdr, cmdData[ cmdNum ].regData );
         err = codecI2cWrite( baseAdr, devAdr, cmdData[ cmdNum ].regAdr, cmdData[ cmdNum ].regData );
         if ( !err ) {
            if ( infoLevel )
               printf( "ok\n" );
         } else {
            if ( infoLevel )
               printf( "error 0x%02X\n", err );
            break; // next attempt
         }

      } // for cmdNum

      if ( !err ) break; // no errors

   } // for attNum

   if ( !err )
      printf( "done\n" );
   else
      printf( "failed\n" );

   return err;
}

// write data to ssm2603/wm8731 via I2C
alt_u8 codecI2cWrite( alt_u32 baseAdr,   // base module address
                      alt_u8  devAdr,    // device address
                      alt_u8  regAdr,    // register address
                      alt_u16 regData )  // register data, 9 bits
{
   alt_u8 err;

   // byte 1 - 7 bits of dev adr + write bit 0
   IOWR_8DIRECT( baseAdr, 2, devAdr ); 
   IOWR_8DIRECT( baseAdr, 3, 0xC0 );        // 1100_0000 - start + write + no ack m + no stop
   err = codecI2cWaitIrq( baseAdr );
   if ( err )
      return err;
   
   // byte 2 - 7 bits of reg adr + msb of reg data
   IOWR_8DIRECT( baseAdr, 2, ( regAdr << 1 ) | ( alt_u8 )( regData >> 8 ) );
   IOWR_8DIRECT( baseAdr, 3, 0x40 );       // 0100_0000 - no start + write + no ack m + no stop
   err = codecI2cWaitIrq( baseAdr );
   if ( err )
      return err;
      
   // byte 3 - 8 lsb of reg data
   IOWR_8DIRECT( baseAdr, 2, ( alt_u8 ) regData );
   IOWR_8DIRECT( baseAdr, 3, 0x50 );       // 0101_0000 - no start + write + no ack m + stop
   err = codecI2cWaitIrq( baseAdr );
   return err;
}

// read data from ssm2603 via I2C                          
alt_u8 codecI2cRead( alt_u32  baseAdr,    // base module address
                     alt_u8   devAdr,     // device address
                     alt_u8   regAdr,     // register address
                     alt_u16* regData )   // read data here, 9 bits
{
   alt_u8 err;

   // byte 1 - 7 bits of dev adr + write bit 0
   IOWR_8DIRECT( baseAdr, 2, devAdr ); 
   IOWR_8DIRECT( baseAdr, 3, 0xC0 );        // 1100_0000 - start + write + no ack m + no stop
   err = codecI2cWaitIrq( baseAdr );
   if ( err )
      return err;

   // byte 2 - 7 bits of reg adr + bit 0
   IOWR_8DIRECT( baseAdr, 2, regAdr << 1 );
   IOWR_8DIRECT( baseAdr, 3, 0x40 );       // 0100_0000 - no start + write + no ack m + no stop
   err = codecI2cWaitIrq( baseAdr );
   if ( err )
      return err;
      
   // byte 3 - 7 bits of dev adr + read bit 1
   IOWR_8DIRECT( baseAdr, 2, devAdr | 0x01 );
   IOWR_8DIRECT( baseAdr, 3, 0xC0 );       // 1100_0000 - rep start + write + no ack m + no stop
   err = codecI2cWaitIrq( baseAdr );
   if ( err )
      return err;
      
   // byte 4 - read 7 lsb of reg data
   IOWR_8DIRECT( baseAdr, 3, 0x20 );       // 0010_0000 - no start + read + ack m + no stop
   err = codecI2cWaitIrq( baseAdr );
   if ( err )
      return err;
   *regData = IORD_8DIRECT( baseAdr, 2 ) & 0x00ff;
   
   // byte 5 - read msb of reg data
   IOWR_8DIRECT( baseAdr, 3, 0x10 );       // 0001_0000 - no start + read + no ack m + stop
   err = codecI2cWaitIrq( baseAdr );
   if ( err )
      *regData = 0;
   else
      *regData = ( IORD_8DIRECT( baseAdr, 2 ) << 8 ) | ( *regData );
   return err;
}

// wait for interrupt bit after end of transfer
alt_u8 codecI2cWaitIrq( alt_u32 baseAdr ) // base module address
{
   alt_u16 cnt = 500;   // guard counter ~400 us

   while ( ( ( IORD_8DIRECT( baseAdr, 1 ) & 0x01 ) != 0x01 ) && --cnt ); // wait for interrupt bit with guard counter
   if ( !cnt )
      return 0x02; // error - time limit exceeded
   else {
      IOWR_8DIRECT( baseAdr, 1, 0x00 );   // clear interrupt bit
      return ( IORD_8DIRECT( baseAdr, 3 ) & 0x03 );
   }
}

// configuration audio codec ssm2603/wm8731
alt_u8 audioCodecConfig( alt_u32 baseAdr,      // base module address
                         alt_u8  dacSourceL,   // source type data for dac, left
                         alt_u8  dacSourceR,   // source type data for dac, right
                         alt_u16 dacFrqL,      // frequency for saw/sine mode, left
                         alt_u16 dacFrqR )     // frequency for saw/sine mode, right
{
   printf( "Configuration audio codec ... " );

   // soft reset to default
   IOWR_16DIRECT( baseAdr, 0, 0x0001 );
   // module is enabled, interrupt is disabled
   IOWR_16DIRECT( baseAdr, 0, 0x8000 );
   // source type
   IOWR_16DIRECT( baseAdr, 2, ( dacSourceR << 4 ) | dacSourceL  );
   // frq L
   IOWR_16DIRECT( baseAdr, 4, ( alt_u16 ) ( ( float ) dacFrqL / 96000.0 * 65536.0 ) );
   // frq R
   IOWR_16DIRECT( baseAdr, 6, ( alt_u16 ) ( ( float ) dacFrqR / 96000.0 * 65536.0 ) );

   printf( "done\n" );

   return 0;
}
