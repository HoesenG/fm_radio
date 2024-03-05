
#ifndef __FM_RADIO_H__
#define __FM_RADIO_H__

#include <math.h>

#define _VC_

// quantization
#define BITS            10
#define QUANT_VAL       (1 << BITS)
#define QUANTIZE_F(f)   (int)(((float)(f) * (float)QUANT_VAL))
#define QUANTIZE_I(i)   (int)((int)(i) * (int)QUANT_VAL)
#define DEQUANTIZE(i)   (int)((int)(i) / (int)QUANT_VAL)

// constants
#define PI              3.1415926535897932384626433832795f
#define ADC_RATE        64000000 // 64 MS/s
#define USRP_DECIM      250
#define QUAD_RATE       (int)(ADC_RATE / USRP_DECIM) // 256 kS/s
#define AUDIO_DECIM     8
#define AUDIO_RATE      (int)(QUAD_RATE / AUDIO_DECIM) // 32 kHz
#define VOLUME_LEVEL    QUANTIZE_F(1.0f)
#define SAMPLES         65536*4
#define AUDIO_SAMPLES   (int)(SAMPLES / AUDIO_DECIM)
#define MAX_TAPS        32 
#define MAX_DEV         55000.0f
#define FM_DEMOD_GAIN   QUANTIZE_F( (float)QUAD_RATE / (2.0f * PI * MAX_DEV) )
#define TAU             0.000075f
#define W_PP            0.21140067f //tan( 1.0f / ((float)AUDIO_RATE*2.0f*TAU) )

void fm_radio_stereo( unsigned char *IQ, int *left_audio, int *right_audio );

void read_IQ( unsigned char *IQ, int *I, int *Q, int samples );

void demodulate_n( int *real, int *imag, int *real_prev, int *imag_prev, const int n_samples, const int gain, int *demod_out );

void demodulate( int real, int imag, int *real_prev, int *imag_prev, const int gain, int *demod_out );

void deemphasis_n( int *input, int *x, int *y, const int n_samples, int *output );

void iir_n( int *x_in, const int n_samples, const int *x_coeffs, const int *y_coeffs, int *x, int *y, const int taps, int decimation, int *y_out );

void iir( int *x_in, const int *x_coeffs, const int *y_coeffs, int *x, int *y, const int taps, const int decimation, int *y_out );

void fir_n( int *x_in, const int n_samples, const int *coeff, int *x, const int taps, const int decimation, int *y_out ); 

void fir( int *x_in, const int *coeff, int *x, const int taps, const int decimation, int *y_out ); 

void fir_cmplx_n( int *x_real_in, int *x_imag_in, const int n_samples, const int *h_real, const int *h_imag, int *x_real, int *x_imag,  
                  const int taps, const int decimation, int *y_real_out, int *y_imag_out );

void fir_cmplx( int *x_real_in, int *x_imag_in, const int *h_real, const int *h_imag, int *x_real, int *x_imag, 
                const int taps, const int decimation, int *y_real_out, int *y_imag_out );

void gain_n( int *input, const int n_samples, int gain, int *output );

int qarctan(int y, int x);

void multiply_n( int *x_in, int *y_in, const int n_samples, int *output );

void add_n( int *x_in, int *y_in, const int n_samples, int *output );

void sub_n( int *x_in, int *y_in, const int n_samples, int *output );


// Deemphasis IIR Filter Coefficients: 
static const int IIR_COEFF_TAPS = 2;
static const int IIR_Y_COEFFS[] = {QUANTIZE_F(0.0f), QUANTIZE_F((W_PP - 1.0f) / (W_PP + 1.0f))};
static const int IIR_X_COEFFS[] = {QUANTIZE_F(W_PP / (1.0f + W_PP)), QUANTIZE_F(W_PP / (1.0f + W_PP))};

// Channel low-pass complex filter coefficients @ 0kHz to 80kHz
static const int CHANNEL_COEFF_TAPS = 20;
static const int CHANNEL_COEFFS_REAL[] =
{
	(int) 0x00000001, (int) 0x00000008, (int) 0xfffffff3, (int) 0x00000009, (int) 0x0000000b, (int) 0xffffffd3, (int) 0x00000045, (int) 0xffffffd3, 
	(int) 0xffffffb1, (int) 0x00000257, (int) 0x00000257, (int) 0xffffffb1, (int) 0xffffffd3, (int) 0x00000045, (int) 0xffffffd3, (int) 0x0000000b, 
	(int) 0x00000009, (int) 0xfffffff3, (int) 0x00000008, (int) 0x00000001
};

static const int CHANNEL_COEFFS_IMAG[] =
{
	(int) 0x00000000, (int) 0x00000000, (int) 0x00000000, (int) 0x00000000, (int) 0x00000000, (int) 0x00000000, (int) 0x00000000, (int) 0x00000000, 
	(int) 0x00000000, (int) 0x00000000, (int) 0x00000000, (int) 0x00000000, (int) 0x00000000, (int) 0x00000000, (int) 0x00000000, (int) 0x00000000, 
	(int) 0x00000000, (int) 0x00000000, (int) 0x00000000, (int) 0x00000000
};

// L+R low-pass filter coefficients @ 15kHz
static const int AUDIO_LPR_COEFF_TAPS = 32;
static const int AUDIO_LPR_COEFFS[] =
{
	(int) 0xfffffffd, (int) 0xfffffffa, (int) 0xfffffff4, (int) 0xffffffed, (int) 0xffffffe5, (int) 0xffffffdf, (int) 0xffffffe2, (int) 0xfffffff3, 
	(int) 0x00000015, (int) 0x0000004e, (int) 0x0000009b, (int) 0x000000f9, (int) 0x0000015d, (int) 0x000001be, (int) 0x0000020e, (int) 0x00000243, 
	(int) 0x00000243, (int) 0x0000020e, (int) 0x000001be, (int) 0x0000015d, (int) 0x000000f9, (int) 0x0000009b, (int) 0x0000004e, (int) 0x00000015, 
	(int) 0xfffffff3, (int) 0xffffffe2, (int) 0xffffffdf, (int) 0xffffffe5, (int) 0xffffffed, (int) 0xfffffff4, (int) 0xfffffffa, (int) 0xfffffffd
};

// L-R low-pass filter coefficients @ 15kHz, gain = 60
static const int AUDIO_LMR_COEFF_TAPS = 32;
static const int AUDIO_LMR_COEFFS[] =
{
	(int) 0xfffffffd, (int) 0xfffffffa, (int) 0xfffffff4, (int) 0xffffffed, (int) 0xffffffe5, (int) 0xffffffdf, (int) 0xffffffe2, (int) 0xfffffff3, 
	(int) 0x00000015, (int) 0x0000004e, (int) 0x0000009b, (int) 0x000000f9, (int) 0x0000015d, (int) 0x000001be, (int) 0x0000020e, (int) 0x00000243, 
	(int) 0x00000243, (int) 0x0000020e, (int) 0x000001be, (int) 0x0000015d, (int) 0x000000f9, (int) 0x0000009b, (int) 0x0000004e, (int) 0x00000015, 
      (int) 0xfffffff3, (int) 0xffffffe2, (int) 0xffffffdf, (int) 0xffffffe5, (int) 0xffffffed, (int) 0xfffffff4, (int) 0xfffffffa, (int) 0xfffffffd
};

// Pilot tone band-pass filter @ 19kHz
static const int BP_PILOT_COEFF_TAPS = 32;
static const int BP_PILOT_COEFFS[] =
{
	(int) 0x0000000e, (int) 0x0000001f, (int) 0x00000034, (int) 0x00000048, (int) 0x0000004e, (int) 0x00000036, (int) 0xfffffff8, (int) 0xffffff98, 
	(int) 0xffffff2d, (int) 0xfffffeda, (int) 0xfffffec3, (int) 0xfffffefe, (int) 0xffffff8a, (int) 0x0000004a, (int) 0x0000010f, (int) 0x000001a1, 
	(int) 0x000001a1, (int) 0x0000010f, (int) 0x0000004a, (int) 0xffffff8a, (int) 0xfffffefe, (int) 0xfffffec3, (int) 0xfffffeda, (int) 0xffffff2d, 
	(int) 0xffffff98, (int) 0xfffffff8, (int) 0x00000036, (int) 0x0000004e, (int) 0x00000048, (int) 0x00000034, (int) 0x0000001f, (int) 0x0000000e
};

// L-R band-pass filter @ 23kHz to 53kHz
static const int BP_LMR_COEFF_TAPS = 32;
static const int BP_LMR_COEFFS[] =
{
	(int) 0x00000000, (int) 0x00000000, (int) 0xfffffffc, (int) 0xfffffff9, (int) 0xfffffffe, (int) 0x00000008, (int) 0x0000000c, (int) 0x00000002, 
	(int) 0x00000003, (int) 0x0000001e, (int) 0x00000030, (int) 0xfffffffc, (int) 0xffffff8c, (int) 0xffffff58, (int) 0xffffffc3, (int) 0x0000008a, 
	(int) 0x0000008a, (int) 0xffffffc3, (int) 0xffffff58, (int) 0xffffff8c, (int) 0xfffffffc, (int) 0x00000030, (int) 0x0000001e, (int) 0x00000003, 
	(int) 0x00000002, (int) 0x0000000c, (int) 0x00000008, (int) 0xfffffffe, (int) 0xfffffff9, (int) 0xfffffffc, (int) 0x00000000, (int) 0x00000000
};

// High pass filter @ 0Hz removes noise after pilot tone is squared
static const int HP_COEFF_TAPS = 32;
static const int HP_COEFFS[] =
{
	(int) 0xffffffff, (int) 0x00000000, (int) 0x00000000, (int) 0x00000002, (int) 0x00000004, (int) 0x00000008, (int) 0x0000000b, (int) 0x0000000c, 
	(int) 0x00000008, (int) 0xffffffff, (int) 0xffffffee, (int) 0xffffffd7, (int) 0xffffffbb, (int) 0xffffff9f, (int) 0xffffff87, (int) 0xffffff76, 
	(int) 0xffffff76, (int) 0xffffff87, (int) 0xffffff9f, (int) 0xffffffbb, (int) 0xffffffd7, (int) 0xffffffee, (int) 0xffffffff, (int) 0x00000008, 
	(int) 0x0000000c, (int) 0x0000000b, (int) 0x00000008, (int) 0x00000004, (int) 0x00000002, (int) 0x00000000, (int) 0x00000000, (int) 0xffffffff
};

static const int sin_lut[1024]=
{
	(int) 0x00000000, (int) 0x00000006, (int) 0x0000000C, (int) 0x00000012, (int) 0x00000019, (int) 0x0000001F, (int) 0x00000025, (int) 0x0000002B, 
	(int) 0x00000032, (int) 0x00000038, (int) 0x0000003E, (int) 0x00000045, (int) 0x0000004B, (int) 0x00000051, (int) 0x00000057, (int) 0x0000005E, 
	(int) 0x00000064, (int) 0x0000006A, (int) 0x00000070, (int) 0x00000077, (int) 0x0000007D, (int) 0x00000083, (int) 0x00000089, (int) 0x00000090, 
	(int) 0x00000096, (int) 0x0000009C, (int) 0x000000A2, (int) 0x000000A8, (int) 0x000000AF, (int) 0x000000B5, (int) 0x000000BB, (int) 0x000000C1, 
	(int) 0x000000C7, (int) 0x000000CD, (int) 0x000000D4, (int) 0x000000DA, (int) 0x000000E0, (int) 0x000000E6, (int) 0x000000EC, (int) 0x000000F2, 
	(int) 0x000000F8, (int) 0x000000FE, (int) 0x00000104, (int) 0x0000010B, (int) 0x00000111, (int) 0x00000117, (int) 0x0000011D, (int) 0x00000123, 
	(int) 0x00000129, (int) 0x0000012F, (int) 0x00000135, (int) 0x0000013B, (int) 0x00000141, (int) 0x00000147, (int) 0x0000014D, (int) 0x00000153, 
	(int) 0x00000158, (int) 0x0000015E, (int) 0x00000164, (int) 0x0000016A, (int) 0x00000170, (int) 0x00000176, (int) 0x0000017C, (int) 0x00000182, 
	(int) 0x00000187, (int) 0x0000018D, (int) 0x00000193, (int) 0x00000199, (int) 0x0000019E, (int) 0x000001A4, (int) 0x000001AA, (int) 0x000001B0, 
	(int) 0x000001B5, (int) 0x000001BB, (int) 0x000001C1, (int) 0x000001C6, (int) 0x000001CC, (int) 0x000001D2, (int) 0x000001D7, (int) 0x000001DD, 
	(int) 0x000001E2, (int) 0x000001E8, (int) 0x000001ED, (int) 0x000001F3, (int) 0x000001F8, (int) 0x000001FE, (int) 0x00000203, (int) 0x00000209, 
	(int) 0x0000020E, (int) 0x00000213, (int) 0x00000219, (int) 0x0000021E, (int) 0x00000223, (int) 0x00000229, (int) 0x0000022E, (int) 0x00000233, 
	(int) 0x00000238, (int) 0x0000023E, (int) 0x00000243, (int) 0x00000248, (int) 0x0000024D, (int) 0x00000252, (int) 0x00000257, (int) 0x0000025C, 
	(int) 0x00000261, (int) 0x00000267, (int) 0x0000026C, (int) 0x00000271, (int) 0x00000275, (int) 0x0000027A, (int) 0x0000027F, (int) 0x00000284, 
	(int) 0x00000289, (int) 0x0000028E, (int) 0x00000293, (int) 0x00000298, (int) 0x0000029C, (int) 0x000002A1, (int) 0x000002A6, (int) 0x000002AB, 
	(int) 0x000002AF, (int) 0x000002B4, (int) 0x000002B8, (int) 0x000002BD, (int) 0x000002C2, (int) 0x000002C6, (int) 0x000002CB, (int) 0x000002CF, 
	(int) 0x000002D4, (int) 0x000002D8, (int) 0x000002DC, (int) 0x000002E1, (int) 0x000002E5, (int) 0x000002E9, (int) 0x000002EE, (int) 0x000002F2, 
	(int) 0x000002F6, (int) 0x000002FA, (int) 0x000002FF, (int) 0x00000303, (int) 0x00000307, (int) 0x0000030B, (int) 0x0000030F, (int) 0x00000313, 
	(int) 0x00000317, (int) 0x0000031B, (int) 0x0000031F, (int) 0x00000323, (int) 0x00000327, (int) 0x0000032B, (int) 0x0000032E, (int) 0x00000332, 
	(int) 0x00000336, (int) 0x0000033A, (int) 0x0000033D, (int) 0x00000341, (int) 0x00000345, (int) 0x00000348, (int) 0x0000034C, (int) 0x0000034F, 
	(int) 0x00000353, (int) 0x00000356, (int) 0x0000035A, (int) 0x0000035D, (int) 0x00000361, (int) 0x00000364, (int) 0x00000367, (int) 0x0000036B, 
	(int) 0x0000036E, (int) 0x00000371, (int) 0x00000374, (int) 0x00000377, (int) 0x0000037A, (int) 0x0000037E, (int) 0x00000381, (int) 0x00000384, 
	(int) 0x00000387, (int) 0x0000038A, (int) 0x0000038C, (int) 0x0000038F, (int) 0x00000392, (int) 0x00000395, (int) 0x00000398, (int) 0x0000039A, 
	(int) 0x0000039D, (int) 0x000003A0, (int) 0x000003A2, (int) 0x000003A5, (int) 0x000003A8, (int) 0x000003AA, (int) 0x000003AD, (int) 0x000003AF, 
	(int) 0x000003B2, (int) 0x000003B4, (int) 0x000003B6, (int) 0x000003B9, (int) 0x000003BB, (int) 0x000003BD, (int) 0x000003BF, (int) 0x000003C2, 
	(int) 0x000003C4, (int) 0x000003C6, (int) 0x000003C8, (int) 0x000003CA, (int) 0x000003CC, (int) 0x000003CE, (int) 0x000003D0, (int) 0x000003D2, 
	(int) 0x000003D3, (int) 0x000003D5, (int) 0x000003D7, (int) 0x000003D9, (int) 0x000003DA, (int) 0x000003DC, (int) 0x000003DE, (int) 0x000003DF, 
	(int) 0x000003E1, (int) 0x000003E2, (int) 0x000003E4, (int) 0x000003E5, (int) 0x000003E7, (int) 0x000003E8, (int) 0x000003E9, (int) 0x000003EB, 
	(int) 0x000003EC, (int) 0x000003ED, (int) 0x000003EE, (int) 0x000003EF, (int) 0x000003F0, (int) 0x000003F1, (int) 0x000003F2, (int) 0x000003F3, 
	(int) 0x000003F4, (int) 0x000003F5, (int) 0x000003F6, (int) 0x000003F7, (int) 0x000003F8, (int) 0x000003F9, (int) 0x000003F9, (int) 0x000003FA, 
	(int) 0x000003FB, (int) 0x000003FB, (int) 0x000003FC, (int) 0x000003FC, (int) 0x000003FD, (int) 0x000003FD, (int) 0x000003FE, (int) 0x000003FE, 
	(int) 0x000003FE, (int) 0x000003FF, (int) 0x000003FF, (int) 0x000003FF, (int) 0x000003FF, (int) 0x000003FF, (int) 0x000003FF, (int) 0x000003FF, 
	(int) 0x000003FF, (int) 0x000003FF, (int) 0x000003FF, (int) 0x000003FF, (int) 0x000003FF, (int) 0x000003FF, (int) 0x000003FF, (int) 0x000003FF, 
	(int) 0x000003FE, (int) 0x000003FE, (int) 0x000003FE, (int) 0x000003FD, (int) 0x000003FD, (int) 0x000003FC, (int) 0x000003FC, (int) 0x000003FB, 
	(int) 0x000003FB, (int) 0x000003FA, (int) 0x000003F9, (int) 0x000003F9, (int) 0x000003F8, (int) 0x000003F7, (int) 0x000003F6, (int) 0x000003F5, 
	(int) 0x000003F4, (int) 0x000003F3, (int) 0x000003F2, (int) 0x000003F1, (int) 0x000003F0, (int) 0x000003EF, (int) 0x000003EE, (int) 0x000003ED, 
	(int) 0x000003EC, (int) 0x000003EB, (int) 0x000003E9, (int) 0x000003E8, (int) 0x000003E7, (int) 0x000003E5, (int) 0x000003E4, (int) 0x000003E2, 
	(int) 0x000003E1, (int) 0x000003DF, (int) 0x000003DE, (int) 0x000003DC, (int) 0x000003DA, (int) 0x000003D9, (int) 0x000003D7, (int) 0x000003D5, 
	(int) 0x000003D3, (int) 0x000003D2, (int) 0x000003D0, (int) 0x000003CE, (int) 0x000003CC, (int) 0x000003CA, (int) 0x000003C8, (int) 0x000003C6, 
	(int) 0x000003C4, (int) 0x000003C2, (int) 0x000003BF, (int) 0x000003BD, (int) 0x000003BB, (int) 0x000003B9, (int) 0x000003B6, (int) 0x000003B4, 
	(int) 0x000003B2, (int) 0x000003AF, (int) 0x000003AD, (int) 0x000003AA, (int) 0x000003A8, (int) 0x000003A5, (int) 0x000003A2, (int) 0x000003A0, 
	(int) 0x0000039D, (int) 0x0000039A, (int) 0x00000398, (int) 0x00000395, (int) 0x00000392, (int) 0x0000038F, (int) 0x0000038C, (int) 0x0000038A, 
	(int) 0x00000387, (int) 0x00000384, (int) 0x00000381, (int) 0x0000037E, (int) 0x0000037A, (int) 0x00000377, (int) 0x00000374, (int) 0x00000371, 
	(int) 0x0000036E, (int) 0x0000036B, (int) 0x00000367, (int) 0x00000364, (int) 0x00000361, (int) 0x0000035D, (int) 0x0000035A, (int) 0x00000356, 
	(int) 0x00000353, (int) 0x0000034F, (int) 0x0000034C, (int) 0x00000348, (int) 0x00000345, (int) 0x00000341, (int) 0x0000033D, (int) 0x0000033A, 
	(int) 0x00000336, (int) 0x00000332, (int) 0x0000032E, (int) 0x0000032B, (int) 0x00000327, (int) 0x00000323, (int) 0x0000031F, (int) 0x0000031B, 
	(int) 0x00000317, (int) 0x00000313, (int) 0x0000030F, (int) 0x0000030B, (int) 0x00000307, (int) 0x00000303, (int) 0x000002FF, (int) 0x000002FA, 
	(int) 0x000002F6, (int) 0x000002F2, (int) 0x000002EE, (int) 0x000002E9, (int) 0x000002E5, (int) 0x000002E1, (int) 0x000002DC, (int) 0x000002D8, 
	(int) 0x000002D4, (int) 0x000002CF, (int) 0x000002CB, (int) 0x000002C6, (int) 0x000002C2, (int) 0x000002BD, (int) 0x000002B8, (int) 0x000002B4, 
	(int) 0x000002AF, (int) 0x000002AB, (int) 0x000002A6, (int) 0x000002A1, (int) 0x0000029C, (int) 0x00000298, (int) 0x00000293, (int) 0x0000028E, 
	(int) 0x00000289, (int) 0x00000284, (int) 0x0000027F, (int) 0x0000027A, (int) 0x00000275, (int) 0x00000271, (int) 0x0000026C, (int) 0x00000267, 
	(int) 0x00000261, (int) 0x0000025C, (int) 0x00000257, (int) 0x00000252, (int) 0x0000024D, (int) 0x00000248, (int) 0x00000243, (int) 0x0000023E, 
	(int) 0x00000238, (int) 0x00000233, (int) 0x0000022E, (int) 0x00000229, (int) 0x00000223, (int) 0x0000021E, (int) 0x00000219, (int) 0x00000213, 
	(int) 0x0000020E, (int) 0x00000209, (int) 0x00000203, (int) 0x000001FE, (int) 0x000001F8, (int) 0x000001F3, (int) 0x000001ED, (int) 0x000001E8, 
	(int) 0x000001E2, (int) 0x000001DD, (int) 0x000001D7, (int) 0x000001D2, (int) 0x000001CC, (int) 0x000001C6, (int) 0x000001C1, (int) 0x000001BB, 
	(int) 0x000001B5, (int) 0x000001B0, (int) 0x000001AA, (int) 0x000001A4, (int) 0x0000019E, (int) 0x00000199, (int) 0x00000193, (int) 0x0000018D, 
	(int) 0x00000187, (int) 0x00000182, (int) 0x0000017C, (int) 0x00000176, (int) 0x00000170, (int) 0x0000016A, (int) 0x00000164, (int) 0x0000015E, 
	(int) 0x00000158, (int) 0x00000153, (int) 0x0000014D, (int) 0x00000147, (int) 0x00000141, (int) 0x0000013B, (int) 0x00000135, (int) 0x0000012F, 
	(int) 0x00000129, (int) 0x00000123, (int) 0x0000011D, (int) 0x00000117, (int) 0x00000111, (int) 0x0000010B, (int) 0x00000104, (int) 0x000000FE, 
	(int) 0x000000F8, (int) 0x000000F2, (int) 0x000000EC, (int) 0x000000E6, (int) 0x000000E0, (int) 0x000000DA, (int) 0x000000D4, (int) 0x000000CD, 
	(int) 0x000000C7, (int) 0x000000C1, (int) 0x000000BB, (int) 0x000000B5, (int) 0x000000AF, (int) 0x000000A8, (int) 0x000000A2, (int) 0x0000009C, 
	(int) 0x00000096, (int) 0x00000090, (int) 0x00000089, (int) 0x00000083, (int) 0x0000007D, (int) 0x00000077, (int) 0x00000070, (int) 0x0000006A, 
	(int) 0x00000064, (int) 0x0000005E, (int) 0x00000057, (int) 0x00000051, (int) 0x0000004B, (int) 0x00000045, (int) 0x0000003E, (int) 0x00000038, 
	(int) 0x00000032, (int) 0x0000002B, (int) 0x00000025, (int) 0x0000001F, (int) 0x00000019, (int) 0x00000012, (int) 0x0000000C, (int) 0x00000006, 
	(int) 0x00000000, (int) 0xFFFFFFFA, (int) 0xFFFFFFF4, (int) 0xFFFFFFEE, (int) 0xFFFFFFE7, (int) 0xFFFFFFE1, (int) 0xFFFFFFDB, (int) 0xFFFFFFD5, 
	(int) 0xFFFFFFCE, (int) 0xFFFFFFC8, (int) 0xFFFFFFC2, (int) 0xFFFFFFBB, (int) 0xFFFFFFB5, (int) 0xFFFFFFAF, (int) 0xFFFFFFA9, (int) 0xFFFFFFA2, 
	(int) 0xFFFFFF9C, (int) 0xFFFFFF96, (int) 0xFFFFFF90, (int) 0xFFFFFF89, (int) 0xFFFFFF83, (int) 0xFFFFFF7D, (int) 0xFFFFFF77, (int) 0xFFFFFF70, 
	(int) 0xFFFFFF6A, (int) 0xFFFFFF64, (int) 0xFFFFFF5E, (int) 0xFFFFFF58, (int) 0xFFFFFF51, (int) 0xFFFFFF4B, (int) 0xFFFFFF45, (int) 0xFFFFFF3F, 
	(int) 0xFFFFFF39, (int) 0xFFFFFF33, (int) 0xFFFFFF2C, (int) 0xFFFFFF26, (int) 0xFFFFFF20, (int) 0xFFFFFF1A, (int) 0xFFFFFF14, (int) 0xFFFFFF0E, 
	(int) 0xFFFFFF08, (int) 0xFFFFFF02, (int) 0xFFFFFEFC, (int) 0xFFFFFEF5, (int) 0xFFFFFEEF, (int) 0xFFFFFEE9, (int) 0xFFFFFEE3, (int) 0xFFFFFEDD, 
	(int) 0xFFFFFED7, (int) 0xFFFFFED1, (int) 0xFFFFFECB, (int) 0xFFFFFEC5, (int) 0xFFFFFEBF, (int) 0xFFFFFEB9, (int) 0xFFFFFEB3, (int) 0xFFFFFEAD, 
	(int) 0xFFFFFEA8, (int) 0xFFFFFEA2, (int) 0xFFFFFE9C, (int) 0xFFFFFE96, (int) 0xFFFFFE90, (int) 0xFFFFFE8A, (int) 0xFFFFFE84, (int) 0xFFFFFE7E, 
	(int) 0xFFFFFE79, (int) 0xFFFFFE73, (int) 0xFFFFFE6D, (int) 0xFFFFFE67, (int) 0xFFFFFE62, (int) 0xFFFFFE5C, (int) 0xFFFFFE56, (int) 0xFFFFFE50, 
	(int) 0xFFFFFE4B, (int) 0xFFFFFE45, (int) 0xFFFFFE3F, (int) 0xFFFFFE3A, (int) 0xFFFFFE34, (int) 0xFFFFFE2E, (int) 0xFFFFFE29, (int) 0xFFFFFE23, 
	(int) 0xFFFFFE1E, (int) 0xFFFFFE18, (int) 0xFFFFFE13, (int) 0xFFFFFE0D, (int) 0xFFFFFE08, (int) 0xFFFFFE02, (int) 0xFFFFFDFD, (int) 0xFFFFFDF7, 
	(int) 0xFFFFFDF2, (int) 0xFFFFFDED, (int) 0xFFFFFDE7, (int) 0xFFFFFDE2, (int) 0xFFFFFDDD, (int) 0xFFFFFDD7, (int) 0xFFFFFDD2, (int) 0xFFFFFDCD, 
	(int) 0xFFFFFDC8, (int) 0xFFFFFDC2, (int) 0xFFFFFDBD, (int) 0xFFFFFDB8, (int) 0xFFFFFDB3, (int) 0xFFFFFDAE, (int) 0xFFFFFDA9, (int) 0xFFFFFDA4, 
	(int) 0xFFFFFD9F, (int) 0xFFFFFD99, (int) 0xFFFFFD94, (int) 0xFFFFFD8F, (int) 0xFFFFFD8B, (int) 0xFFFFFD86, (int) 0xFFFFFD81, (int) 0xFFFFFD7C, 
	(int) 0xFFFFFD77, (int) 0xFFFFFD72, (int) 0xFFFFFD6D, (int) 0xFFFFFD68, (int) 0xFFFFFD64, (int) 0xFFFFFD5F, (int) 0xFFFFFD5A, (int) 0xFFFFFD55, 
	(int) 0xFFFFFD51, (int) 0xFFFFFD4C, (int) 0xFFFFFD48, (int) 0xFFFFFD43, (int) 0xFFFFFD3E, (int) 0xFFFFFD3A, (int) 0xFFFFFD35, (int) 0xFFFFFD31, 
	(int) 0xFFFFFD2C, (int) 0xFFFFFD28, (int) 0xFFFFFD24, (int) 0xFFFFFD1F, (int) 0xFFFFFD1B, (int) 0xFFFFFD17, (int) 0xFFFFFD12, (int) 0xFFFFFD0E, 
	(int) 0xFFFFFD0A, (int) 0xFFFFFD06, (int) 0xFFFFFD01, (int) 0xFFFFFCFD, (int) 0xFFFFFCF9, (int) 0xFFFFFCF5, (int) 0xFFFFFCF1, (int) 0xFFFFFCED, 
	(int) 0xFFFFFCE9, (int) 0xFFFFFCE5, (int) 0xFFFFFCE1, (int) 0xFFFFFCDD, (int) 0xFFFFFCD9, (int) 0xFFFFFCD5, (int) 0xFFFFFCD2, (int) 0xFFFFFCCE, 
	(int) 0xFFFFFCCA, (int) 0xFFFFFCC6, (int) 0xFFFFFCC3, (int) 0xFFFFFCBF, (int) 0xFFFFFCBB, (int) 0xFFFFFCB8, (int) 0xFFFFFCB4, (int) 0xFFFFFCB1, 
	(int) 0xFFFFFCAD, (int) 0xFFFFFCAA, (int) 0xFFFFFCA6, (int) 0xFFFFFCA3, (int) 0xFFFFFC9F, (int) 0xFFFFFC9C, (int) 0xFFFFFC99, (int) 0xFFFFFC95, 
	(int) 0xFFFFFC92, (int) 0xFFFFFC8F, (int) 0xFFFFFC8C, (int) 0xFFFFFC89, (int) 0xFFFFFC86, (int) 0xFFFFFC82, (int) 0xFFFFFC7F, (int) 0xFFFFFC7C, 
	(int) 0xFFFFFC79, (int) 0xFFFFFC76, (int) 0xFFFFFC74, (int) 0xFFFFFC71, (int) 0xFFFFFC6E, (int) 0xFFFFFC6B, (int) 0xFFFFFC68, (int) 0xFFFFFC66, 
	(int) 0xFFFFFC63, (int) 0xFFFFFC60, (int) 0xFFFFFC5E, (int) 0xFFFFFC5B, (int) 0xFFFFFC58, (int) 0xFFFFFC56, (int) 0xFFFFFC53, (int) 0xFFFFFC51, 
	(int) 0xFFFFFC4E, (int) 0xFFFFFC4C, (int) 0xFFFFFC4A, (int) 0xFFFFFC47, (int) 0xFFFFFC45, (int) 0xFFFFFC43, (int) 0xFFFFFC41, (int) 0xFFFFFC3E, 
	(int) 0xFFFFFC3C, (int) 0xFFFFFC3A, (int) 0xFFFFFC38, (int) 0xFFFFFC36, (int) 0xFFFFFC34, (int) 0xFFFFFC32, (int) 0xFFFFFC30, (int) 0xFFFFFC2E, 
	(int) 0xFFFFFC2D, (int) 0xFFFFFC2B, (int) 0xFFFFFC29, (int) 0xFFFFFC27, (int) 0xFFFFFC26, (int) 0xFFFFFC24, (int) 0xFFFFFC22, (int) 0xFFFFFC21, 
	(int) 0xFFFFFC1F, (int) 0xFFFFFC1E, (int) 0xFFFFFC1C, (int) 0xFFFFFC1B, (int) 0xFFFFFC19, (int) 0xFFFFFC18, (int) 0xFFFFFC17, (int) 0xFFFFFC15, 
	(int) 0xFFFFFC14, (int) 0xFFFFFC13, (int) 0xFFFFFC12, (int) 0xFFFFFC11, (int) 0xFFFFFC10, (int) 0xFFFFFC0F, (int) 0xFFFFFC0E, (int) 0xFFFFFC0D, 
	(int) 0xFFFFFC0C, (int) 0xFFFFFC0B, (int) 0xFFFFFC0A, (int) 0xFFFFFC09, (int) 0xFFFFFC08, (int) 0xFFFFFC07, (int) 0xFFFFFC07, (int) 0xFFFFFC06, 
	(int) 0xFFFFFC05, (int) 0xFFFFFC05, (int) 0xFFFFFC04, (int) 0xFFFFFC04, (int) 0xFFFFFC03, (int) 0xFFFFFC03, (int) 0xFFFFFC02, (int) 0xFFFFFC02, 
	(int) 0xFFFFFC02, (int) 0xFFFFFC01, (int) 0xFFFFFC01, (int) 0xFFFFFC01, (int) 0xFFFFFC01, (int) 0xFFFFFC01, (int) 0xFFFFFC01, (int) 0xFFFFFC01, 
	(int) 0xFFFFFC01, (int) 0xFFFFFC01, (int) 0xFFFFFC01, (int) 0xFFFFFC01, (int) 0xFFFFFC01, (int) 0xFFFFFC01, (int) 0xFFFFFC01, (int) 0xFFFFFC01, 
	(int) 0xFFFFFC02, (int) 0xFFFFFC02, (int) 0xFFFFFC02, (int) 0xFFFFFC03, (int) 0xFFFFFC03, (int) 0xFFFFFC04, (int) 0xFFFFFC04, (int) 0xFFFFFC05, 
	(int) 0xFFFFFC05, (int) 0xFFFFFC06, (int) 0xFFFFFC07, (int) 0xFFFFFC07, (int) 0xFFFFFC08, (int) 0xFFFFFC09, (int) 0xFFFFFC0A, (int) 0xFFFFFC0B, 
	(int) 0xFFFFFC0C, (int) 0xFFFFFC0D, (int) 0xFFFFFC0E, (int) 0xFFFFFC0F, (int) 0xFFFFFC10, (int) 0xFFFFFC11, (int) 0xFFFFFC12, (int) 0xFFFFFC13, 
	(int) 0xFFFFFC14, (int) 0xFFFFFC15, (int) 0xFFFFFC17, (int) 0xFFFFFC18, (int) 0xFFFFFC19, (int) 0xFFFFFC1B, (int) 0xFFFFFC1C, (int) 0xFFFFFC1E, 
	(int) 0xFFFFFC1F, (int) 0xFFFFFC21, (int) 0xFFFFFC22, (int) 0xFFFFFC24, (int) 0xFFFFFC26, (int) 0xFFFFFC27, (int) 0xFFFFFC29, (int) 0xFFFFFC2B, 
	(int) 0xFFFFFC2D, (int) 0xFFFFFC2E, (int) 0xFFFFFC30, (int) 0xFFFFFC32, (int) 0xFFFFFC34, (int) 0xFFFFFC36, (int) 0xFFFFFC38, (int) 0xFFFFFC3A, 
	(int) 0xFFFFFC3C, (int) 0xFFFFFC3E, (int) 0xFFFFFC41, (int) 0xFFFFFC43, (int) 0xFFFFFC45, (int) 0xFFFFFC47, (int) 0xFFFFFC4A, (int) 0xFFFFFC4C, 
	(int) 0xFFFFFC4E, (int) 0xFFFFFC51, (int) 0xFFFFFC53, (int) 0xFFFFFC56, (int) 0xFFFFFC58, (int) 0xFFFFFC5B, (int) 0xFFFFFC5E, (int) 0xFFFFFC60, 
	(int) 0xFFFFFC63, (int) 0xFFFFFC66, (int) 0xFFFFFC68, (int) 0xFFFFFC6B, (int) 0xFFFFFC6E, (int) 0xFFFFFC71, (int) 0xFFFFFC74, (int) 0xFFFFFC76, 
	(int) 0xFFFFFC79, (int) 0xFFFFFC7C, (int) 0xFFFFFC7F, (int) 0xFFFFFC82, (int) 0xFFFFFC86, (int) 0xFFFFFC89, (int) 0xFFFFFC8C, (int) 0xFFFFFC8F, 
	(int) 0xFFFFFC92, (int) 0xFFFFFC95, (int) 0xFFFFFC99, (int) 0xFFFFFC9C, (int) 0xFFFFFC9F, (int) 0xFFFFFCA3, (int) 0xFFFFFCA6, (int) 0xFFFFFCAA, 
	(int) 0xFFFFFCAD, (int) 0xFFFFFCB1, (int) 0xFFFFFCB4, (int) 0xFFFFFCB8, (int) 0xFFFFFCBB, (int) 0xFFFFFCBF, (int) 0xFFFFFCC3, (int) 0xFFFFFCC6, 
	(int) 0xFFFFFCCA, (int) 0xFFFFFCCE, (int) 0xFFFFFCD2, (int) 0xFFFFFCD5, (int) 0xFFFFFCD9, (int) 0xFFFFFCDD, (int) 0xFFFFFCE1, (int) 0xFFFFFCE5, 
	(int) 0xFFFFFCE9, (int) 0xFFFFFCED, (int) 0xFFFFFCF1, (int) 0xFFFFFCF5, (int) 0xFFFFFCF9, (int) 0xFFFFFCFD, (int) 0xFFFFFD01, (int) 0xFFFFFD06, 
	(int) 0xFFFFFD0A, (int) 0xFFFFFD0E, (int) 0xFFFFFD12, (int) 0xFFFFFD17, (int) 0xFFFFFD1B, (int) 0xFFFFFD1F, (int) 0xFFFFFD24, (int) 0xFFFFFD28, 
	(int) 0xFFFFFD2C, (int) 0xFFFFFD31, (int) 0xFFFFFD35, (int) 0xFFFFFD3A, (int) 0xFFFFFD3E, (int) 0xFFFFFD43, (int) 0xFFFFFD48, (int) 0xFFFFFD4C, 
	(int) 0xFFFFFD51, (int) 0xFFFFFD55, (int) 0xFFFFFD5A, (int) 0xFFFFFD5F, (int) 0xFFFFFD64, (int) 0xFFFFFD68, (int) 0xFFFFFD6D, (int) 0xFFFFFD72, 
	(int) 0xFFFFFD77, (int) 0xFFFFFD7C, (int) 0xFFFFFD81, (int) 0xFFFFFD86, (int) 0xFFFFFD8B, (int) 0xFFFFFD8F, (int) 0xFFFFFD94, (int) 0xFFFFFD99, 
	(int) 0xFFFFFD9F, (int) 0xFFFFFDA4, (int) 0xFFFFFDA9, (int) 0xFFFFFDAE, (int) 0xFFFFFDB3, (int) 0xFFFFFDB8, (int) 0xFFFFFDBD, (int) 0xFFFFFDC2, 
	(int) 0xFFFFFDC8, (int) 0xFFFFFDCD, (int) 0xFFFFFDD2, (int) 0xFFFFFDD7, (int) 0xFFFFFDDD, (int) 0xFFFFFDE2, (int) 0xFFFFFDE7, (int) 0xFFFFFDED, 
	(int) 0xFFFFFDF2, (int) 0xFFFFFDF7, (int) 0xFFFFFDFD, (int) 0xFFFFFE02, (int) 0xFFFFFE08, (int) 0xFFFFFE0D, (int) 0xFFFFFE13, (int) 0xFFFFFE18, 
	(int) 0xFFFFFE1E, (int) 0xFFFFFE23, (int) 0xFFFFFE29, (int) 0xFFFFFE2E, (int) 0xFFFFFE34, (int) 0xFFFFFE3A, (int) 0xFFFFFE3F, (int) 0xFFFFFE45, 
	(int) 0xFFFFFE4B, (int) 0xFFFFFE50, (int) 0xFFFFFE56, (int) 0xFFFFFE5C, (int) 0xFFFFFE62, (int) 0xFFFFFE67, (int) 0xFFFFFE6D, (int) 0xFFFFFE73, 
	(int) 0xFFFFFE79, (int) 0xFFFFFE7E, (int) 0xFFFFFE84, (int) 0xFFFFFE8A, (int) 0xFFFFFE90, (int) 0xFFFFFE96, (int) 0xFFFFFE9C, (int) 0xFFFFFEA2, 
	(int) 0xFFFFFEA8, (int) 0xFFFFFEAD, (int) 0xFFFFFEB3, (int) 0xFFFFFEB9, (int) 0xFFFFFEBF, (int) 0xFFFFFEC5, (int) 0xFFFFFECB, (int) 0xFFFFFED1, 
	(int) 0xFFFFFED7, (int) 0xFFFFFEDD, (int) 0xFFFFFEE3, (int) 0xFFFFFEE9, (int) 0xFFFFFEEF, (int) 0xFFFFFEF5, (int) 0xFFFFFEFC, (int) 0xFFFFFF02, 
	(int) 0xFFFFFF08, (int) 0xFFFFFF0E, (int) 0xFFFFFF14, (int) 0xFFFFFF1A, (int) 0xFFFFFF20, (int) 0xFFFFFF26, (int) 0xFFFFFF2C, (int) 0xFFFFFF33, 
	(int) 0xFFFFFF39, (int) 0xFFFFFF3F, (int) 0xFFFFFF45, (int) 0xFFFFFF4B, (int) 0xFFFFFF51, (int) 0xFFFFFF58, (int) 0xFFFFFF5E, (int) 0xFFFFFF64, 
	(int) 0xFFFFFF6A, (int) 0xFFFFFF70, (int) 0xFFFFFF77, (int) 0xFFFFFF7D, (int) 0xFFFFFF83, (int) 0xFFFFFF89, (int) 0xFFFFFF90, (int) 0xFFFFFF96, 
	(int) 0xFFFFFF9C, (int) 0xFFFFFFA2, (int) 0xFFFFFFA9, (int) 0xFFFFFFAF, (int) 0xFFFFFFB5, (int) 0xFFFFFFBB, (int) 0xFFFFFFC2, (int) 0xFFFFFFC8, 
	(int) 0xFFFFFFCE, (int) 0xFFFFFFD5, (int) 0xFFFFFFDB, (int) 0xFFFFFFE1, (int) 0xFFFFFFE7, (int) 0xFFFFFFEE, (int) 0xFFFFFFF4, (int) 0xFFFFFFFA, 
};


#endif
