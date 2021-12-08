/*****************************************************************//**
 * @file main_sampler_test.cpp
 *
 * @brief Basic test of nexys4 ddr mmio cores
 *
 * @author p chu
 * @version v1.0: initial release
 *********************************************************************/

// #define _DEBUG
#include "chu_init.h"
#include "gpio_cores.h"
#include "xadc_core.h"
#include "sseg_core.h"
#include "spi_core.h"
#include "i2c_core.h"
#include "ps2_core.h"
#include "ddfs_core.h"
#include "adsr_core.h"

/**
 * blink once per second for 5 times.
 * provide a sanity check for timer (based on SYS_CLK_FREQ)
 * @param led_p pointer to led instance
 */
void timer_check(GpoCore *led_p) {
   int i;

   for (i = 0; i < 5; i++) {
      led_p->write(0xffff);
      sleep_ms(500);
      led_p->write(0x0000);
      sleep_ms(500);
      debug("timer check - (loop #)/now: ", i, now_ms());
   }
}

/**
 * Test pattern in 7-segment LEDs
 * @param sseg_p pointer to 7-seg LED instance
 */


void ps2_check(Ps2Core *ps2_p) {
   int id;
   int lbtn, rbtn, xmov, ymov;
   char ch;
   unsigned long last;

   uart.disp("\n\rPS2 device (1-keyboard / 2-mouse): ");
   id = ps2_p->init();
   uart.disp(id);
   uart.disp("\n\r");
   last = now_ms();
   do {
      if (id == 2) {  // mouse
         if (ps2_p->get_mouse_activity(&lbtn, &rbtn, &xmov, &ymov)) {
            uart.disp("[");
            uart.disp(lbtn);
            uart.disp(", ");
            uart.disp(rbtn);
            uart.disp(", ");
            uart.disp(xmov);
            uart.disp(", ");
            uart.disp(ymov);
            uart.disp("] \r\n");
            last = now_ms();

         }   // end get_mouse_activitiy()
      } else {
         if (ps2_p->get_kb_ch(&ch)) {
            uart.disp(ch);
            uart.disp(" ");
            last = now_ms();
         } // end get_kb_ch()
      }  // end id==2
   } while (now_ms() - last < 5000);
   uart.disp("\n\rExit PS2 test \n\r");

}

/**
 * play primary notes with ddfs
 * @param adsr_p pointer to adsr core
 * @param ddfs_p pointer to ddfs core
 * @note: music tempo is defined as beats of quarter-note per minute.
 *        60 bpm is 1 sec per quarter note
 *
 */
void adsr_player(AdsrCore *adsr_p, GpoCore *led_p, GpiCore *sw_p) {

	//set tempo of music
	#define bpm 120

	// Note field
	#define C 	0
	#define Cs 	1
	#define Db	1
	#define D 	2
	#define Ds 	3
	#define Eb	3
	#define E 	4
	#define F 	5
	#define Fs	6
	#define Gb 	6
	#define G 	7
	#define Gs 	8
	#define Ab	8
	#define A 	9
	#define As 	10
	#define Bb	10
	#define B 	11

   int speed = (60000 / bpm);  // Determines beat of quarter note (i.e. 120bpm = 500ms)

   int hr = speed * 2;			// Half rset
   int qr = speed;				// Quarter rest
   int er = qr / 2;				// Eighth rest
   int dqr = qr + er;			// Dotted Quarter Rest
   int sr = er / 2;				// Sixteenth rest

//   const int melody[] = {C, F, F, G, F, E, D, D, D, G, G, A, G, F, E, C, C, A, A, As, A, G, F, D, C, C, D, G, E, F};
//   const int length[] = {qr,qr,er,er,er,er,qr,qr,qr,qr,er,er,er,er,qr,qr,qr,qr,er,er,er,er,qr,qr,er,er,qr,qr,qr,qr};

   // Music
   	   	   	   	   	   // megalovania. because funny
//   const int melody[] = {D, D, D, A, Gs, G, F, D, F, G,
//		   	   	   	   	 C, C, D, A, Gs, G, F, D, F, G,
//						 B, B, D, A, Gs, G, F, D, F, G,
//						 As, As, D, A, Gs, G, F, D, F, G};

   // array factoring length of notes.
//   const int length[] = {er,er,qr,dqr,qr,qr,qr,er,er,er,
//		   	   	   	   	 er,er,qr,dqr,qr,qr,qr,er,er,er,
//						 er,er,qr,dqr,qr,qr,qr,er,er,er,
//						 er,er,qr,dqr,qr,qr,qr,er,er,er};

//   const int octave[] = {4,4,5,4,4,4,4,4,4,4,
//   	   	   	   	   	   	 4,4,5,4,4,4,4,4,4,4,
//   	   	   	   	   	   	 3,3,5,4,4,4,4,4,4,4,
//   	   	   	   	   	   	 3,3,5,4,4,4,4,4,4,4};
   // some bit on the smash bros melee theme (melody0 is melody, melody1 is baseline)
   const int melody0[] = {B,0,0,0,0,A,G,Fs,E,0,Fs,0,G,0,B,0,A,0,0,0,0,G,Fs,E,E,0,Ds,0,A,0,G,0,G};
   const int melody1[] = {C,G,C,E,G,0,0,0 ,D,A,D,Fs,A,0,0,0,B,Fs,B,Ds,Fs,0,0,0,E,B,E,G,D,A,D,Fs};
   const int length[] = {qr,qr,qr,qr,qr};
   const int octave0[] = {5,0,0,0,0,5,5,5,5,0,5,0,5,0,5,0,5,0,0,0,0,5,5,5,5,0,5,0,5,0,5,0,5};
   const int octave1[] = {3,3,4,4,4,0,0,0,3,3,4,4,4,0,0,0,2,3,3,4,4,0,0,0,3,3,4,4,3,3,4,4};

   int noteAmt = sizeof(melody0)/sizeof(melody0[0]);

   adsr_p->init();
   adsr_p->select_env(sw_p->read());

	for (int i = 0; i < noteAmt;i++)
	{

		adsr_p->play_note(melody0[i],octave0[i],500,1);
		adsr_p->play_note(melody1[i],octave1[i],500,0);
//		adsr_p->play_note(C,3,250,0);
//		sleep_ms(5);
//		adsr_p->play_note(C,2,200,0);
//		adsr_p->play_note(E,2,200,1);
//		adsr_p->play_note(G,2,200,2);
//		adsr_p->play_note(C,3,200,3);
//		adsr_p->play_note(E,3,200,4);
//		adsr_p->play_note(G,3,200,5);
//		adsr_p->play_note(C,4,200,6);
//		adsr_p->play_note(E,4,200,7);
		sleep_ms(er);
	}

}

GpoCore led(get_slot_addr(BRIDGE_BASE, S2_LED));
GpiCore sw(get_slot_addr(BRIDGE_BASE, S3_SW));
XadcCore adc(get_slot_addr(BRIDGE_BASE, S5_XDAC));
PwmCore pwm(get_slot_addr(BRIDGE_BASE, S6_PWM));
DebounceCore btn(get_slot_addr(BRIDGE_BASE, S7_BTN));
SsegCore sseg(get_slot_addr(BRIDGE_BASE, S8_SSEG));
SpiCore spi(get_slot_addr(BRIDGE_BASE, S9_SPI));
I2cCore adt7420(get_slot_addr(BRIDGE_BASE, S10_I2C));
Ps2Core ps2(get_slot_addr(BRIDGE_BASE, S11_PS2));
DdfsCore ddfs(get_slot_addr(BRIDGE_BASE, S12_DDFS));
AdsrCore adsr(get_slot_addr(BRIDGE_BASE, S13_ADSR), &ddfs);


int main() {
   //uint8_t id, ;

 //  timer_check(&led);
	adsr.init();
   while (1) {
	   	adsr_player(&adsr, &led, &sw);
      sleep_ms(500);
   } //while
} //main

