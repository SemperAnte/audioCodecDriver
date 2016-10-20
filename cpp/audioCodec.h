//--------------------------------------------------------------------------------
// File Name:     audioCodec.h
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
#include <io.h>
#include <alt_types.h>
#include <stdio.h>
#include <unistd.h>

// fully initialization ssm2603 via I2C ( write, read, compare )
alt_u8 ssm2603I2cInit( alt_u32 baseAdr,      // base module address
                       alt_u8  devAdr,       // device address
                       alt_u8  infoLevel);   // info level ( 0, 1 - additional debug info )

// fully initialization wm8731 via I2C ( only write )
alt_u8 wm8731I2cInit ( alt_u32 baseAdr,      // base module address
                       alt_u8  devAdr,       // device address
                       alt_u8  infoLevel);   // info level ( 0, 1 - additional debug info )

// write data to ssm2603/wm8731 via I2C
alt_u8 codecI2cWrite  ( alt_u32 baseAdr,     // base module address
                        alt_u8  devAdr,      // device address
                        alt_u8  regAdr,      // register address
                        alt_u16 regData );   // register data, 9 bits

// read data from ssm2603 via I2C
alt_u8 codecI2cRead  ( alt_u32  baseAdr,     // base module address
                       alt_u8   devAdr,      // device address
                       alt_u8   regAdr,      // register address
                       alt_u16* regData );   // read data here, 9 bits

// wait for interrupt bit after end of transfer
alt_u8 codecI2cWaitIrq( alt_u32 baseAdr );   // base module address

// configuration audio codec ssm2603/wm8731
alt_u8 audioCodecConfig( alt_u32 baseAdr,      // base module address
                         alt_u8  dacSourceL,   // source type data for dac, left
                         alt_u8  dacSourceR,   // source type data for dac, right
                         alt_u16 dacFrqL,      // frequency for saw/sine mode, left
                         alt_u16 dacFrqR,      // frequency for saw/sine mode, right
                         float   Fs,           // sampling frequency
                         alt_u8  infoLevel );  // info level ( 0, 1 - additional debug info )
