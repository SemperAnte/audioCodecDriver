//--------------------------------------------------------------------------------
// File Name:     main.c
// Project:       i2cMaster
// Author:        Shustov Aleksey ( SemperAnte ), semte@semte.ru
// History:
//    21.08.2016 - created
//--------------------------------------------------------------------------------
// NIOS example
// initialization audio codec SSM2603 on SoCKit  board via I2C
// initialization audio codec WM8731  on DE1-SoC board via I2C
//--------------------------------------------------------------------------------
#include <system.h>
#include <sys/alt_timestamp.h>
#include "audioCodec.h"

#include <io.h>

int main()
{
   alt_u32 time0, time1;

   alt_timestamp_start();
   time0 = alt_timestamp();

   //ssm2603I2cInit( ACDRIVER_I2CAVS_BASE, 0x34, 1 ); // device adr - 0011_0100 ( 0x34 )
   wm8731I2cInit( ACDRIVER_I2CAVS_BASE, 0x34, 0 );    // device adr - 0011_0100 ( 0x34 )
   // configuration audio codec
   enum { DAC_ZERO = 0, DAC_INTERFACE = 1, DAC_ADC = 2, DAC_SAW = 3, DAC_SINE = 4 };
   audioCodecConfig( ACDRIVER_ACAVS_BASE, DAC_INTERFACE, DAC_INTERFACE, 1000, 2500 );

   time1 = alt_timestamp();
   printf( "ticks spent = %u\n", ( unsigned int ) ( time1 - time0 ) );

   return 0;
}
